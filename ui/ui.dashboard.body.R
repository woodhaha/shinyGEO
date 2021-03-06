#####################################
# dashboard body 
#####################################

source("ui/ui.tab.expression.R")
source("ui/ui.tab.analyses.R")
source("ui/ui.tab.reproducible.R")
source("ui/ui.tab.about.R")
source("misc/html.R")


header = dashboardHeader(
  title = uiOutput("shinyTitle"), titleWidth = 350, disable = FALSE 
)

# add id to sidebar toggle link so that we can refresh when clicked
tmp = header$children[[3]]$children[[2]]
tmp = gsub("\"#\"", "\"#\" id = \"sidebarToggle\"", tmp)
header$children[[3]]$children[[2]] = tmp

gse.input = div(style = "display:inline-block; width: 75%",
            selectizeInput('GSE', label = "Accession Number", choices = NULL, width = 275,
              options = list(placeholder = "Please enter a GSE #",
                          maxOptions = 100)
            )
          )

gse.button = div(style = "display:inline-block; width: 11%",
                actionButton("submitButton", "Go!")
          )

gse.platform=  conditionalPanel(condition = "output.sidebarDisplay=='PLATFORM'|output.sidebarDisplay=='ALL'",

                  div(style = "display:inline-block; width: 75%",
                        selectizeInput('platform', label = "Platform", choices = NULL, width = 275,
                                options = list(placeholder = "Please select a platform",
                                maxOptions = 10)
                        )
                  )

# Button was needed to trigger server-busy for please wait message based on server-busy
#                  div(style = "display:inline-block; width: 11%",
#                        actionButton("submitPlatform", "Go!")
#                  )
                )

sidebar = dashboardSidebar(width = 350,
  includeCSS('www/ecsu.css'),
  includeScript('www/ecsu.js'),
	gse.input, gse.button, gse.platform,
	conditionalPanel(condition = "output.sidebarDisplay=='ALL'",
	sidebarMenu(id = "tabs",
		hr(),
        menuItem("New Analysis", tabName = "NewAnalysis", icon = icon("refresh")), 
	hr(),
        menuItem("Home", tabName = "Home", icon = icon("home"), selected = TRUE),
        menuItem("Differential Expression Analysis", 
		tabName = "DifferentialExpressionAnalysis", icon = icon("flask")),
	menuItem("Survival Analysis", tabName = "SurvivalAnalysis", icon = icon("life-ring")),
	menuItem("View Clinical Data Table", tabName = "FullDataTable", icon = icon("table")),
	menuItem("Code", tabName = "Code", icon = icon("code")),
	menuItem("About", tabName = "About", icon = icon("info-circle"))
	     )
      )
)


####################################
# DE and survival analyses
####################################
analyses.common = conditionalPanel(condition = "input.tabs == 'DifferentialExpressionAnalysis' | input.tabs == 'SurvivalAnalysis'",
        bsAlert("alert2"),
        div(style = "display:inline-block; width: 40%",
         	selectizeInput('selectGenes', "Select Gene/Probe", choices = NULL)
	),

    div(style = "display:inline-block; width: 25%",
    		a(id = "platLink", "Change Search Feature",
			style="cursor:pointer; display:block; margin-bottom:5px;")
    ),
       bsModal("platformModal", "Platform annotation", 
                       "platLink", size = "large",
			selectizeInput('geneColumn', 'Selected Feature', choices = NULL),	
                       DT::dataTableOutput("platformData")
        ), 

 
       	div(style = "display:inline-block; width: 35%",
		conditionalPanel(condition = "input.tabs =='SurvivalAnalysis'",
            		genBSModal("autogenModal","Survival Analyses","",size="large")
        	)
	)
)

body = dashboardBody(
  conditionalPanel(condition = "input.tabs != 'About' & input.tabs != 'Code'",
                   bsAlert("alert1"),
                   uiOutput("busy")
                   ),


  shinyjs::useShinyjs(),
  summaryBSModal("summaryBSModal","Clinical Data","ClinicalDataBtn", size = "large",  

    tabsetPanel(
	tabPanel("Summary", DT::dataTableOutput("summaryModalTable")),
	tabPanel("Full Clinical Table",   
        DT::dataTableOutput("clinicalData")
	),

	tabPanel("Data I/O",
	      fluidRow(
	        column(12,
	               bsAlert("ioAlert1"),
	               bsAlert("ioAlert2"),
	               bsAlert("ioAlert3")
	               )
	      ),


	      fluidRow(
	        column(5,
	               tags$h4(class="ioTitle","Download Dataset"),
	               hr(),
	               downloadButton("downloadSet","Download")
	               
	              
	               ),
	        column(2,
	              tags$p("")
	               ),
	        column(5,
	               tags$h4(class="ioTitle","Upload Dataset"),
	               hr(),
	               fileInput('fileUpload', '',
	                         accept=c('text/csv', 
	                                  'text/comma-separated-values,text/plain', 
	                                  '.csv'))
	               
	        )
	      )
	   )    
   )
 ),

  # please wait conditional panel

  ## originally shiny-busy
  conditionalPanel(
	condition="$('html').hasClass('shiny-busy') & input.tabs == 'Home'",

#        div(style = "position:center; width:100%; height:100; text-align:center",
#            img(src="PleaseWait.gif", style = "width:50%")
#		"Please wait..."
 #      )


            	    HTML("<div class=\"progress\" style=\"height:25px !important\"><div class=\"progress-bar progress-bar-striped active\" role=\"progressbar\" aria-valuenow=\"40\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width:100%\">
        <span id=\"bar-text\">Loading...</span></div></div>") ),
  HTML("<link href='https://fonts.googleapis.com/css?family=Courgette' rel='stylesheet' type='text/css'>"),


   analyses.common, 

   tabItems(
      # First tab content
      tab.expression,
      tab.DE.analysis,
      tab.survival.analysis,
      tab.code,
      tab.about
    )
)


