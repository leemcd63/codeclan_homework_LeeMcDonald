# ui ---------------------------------------------------------------------------

ui <- fluidPage(
  
  titlePanel(title = "Video Game Sales Dashboard"),
  
  navbarPage("Sections:",
             # OVERVIEW PANEL
             tabPanel("Overview",
                      fluidRow(align = "center",
                               column(2,
                               selectInput("overview_console_select",
                                           label = "Console:",
                                           choices = c("All", 
                                                       levels(game_sales_manufacturer$platform)),
                                           selected = "All")
                               ),
                               
                               column(2,
                               selectInput("overview_manufacturer_select",
                                           label = "Manufacturer:",
                                           choices = c("All", 
                                                       levels(game_sales_manufacturer$manufacturer)),
                                           selected = "All")
                               ),
                               
                               column(2,
                               selectInput("overview_developer_select",
                                           label = "Developer:",
                                           choices = c("All", 
                                                       sort(unique(game_sales_manufacturer$developer))),
                                           selected = "All")
                               ),
                                          
                               column(2,
                               selectInput("overview_publisher_select",
                                           label = "Publisher:",
                                           choices = c("All", 
                                                       sort(unique(game_sales_manufacturer$publisher))),
                                           selected = "All")
                               ),
                               
                               column(2,
                               selectInput("overview_genre_select",
                                           label = "Game Genre:",
                                           choices = c("All", 
                                                       sort(unique(game_sales_manufacturer$genre))),
                                           selected = "All")
                               ),
                               
                               column(2,
                               selectInput("overview_year_select",
                                           label = "Year of Release:",
                                           choices = c("All", 
                                                       sort(unique(game_sales_manufacturer$year_of_release))),
                                           selected = "All")
                               )
                               ),
                      
                      fluidRow(
                        textOutput("overview_top_name"),
                        textOutput("overview_top_score"),
                        dataTableOutput("test")
                        
                      )
                      ),
             # GAME SALES PANEL -------------------------------------------------------------
             tabPanel("Game Sales",
                      fluidRow(align = "center",
                        radioButtons("sales_filter",
                                     label = "Select Filter:",
                                     choices = c("By Console" = "platform",
                                                 "By Manufacturer" = "manufacturer",
                                                 "By Developer" = "developer",
                                                 "By Publisher" = "publisher"),
                                     inline = TRUE,
                                     selected = "platform")
                      ),
                      
                      
                      sidebarLayout(
                        sidebarPanel(width = 2, align = "center",
                                     
                                     fluidRow(
                                       selectInput("sales_genre_select",
                                                   label = "Game Genre:",
                                                   choices = c("All", 
                                                               sort(unique(game_sales_manufacturer$genre))),
                                                   selected = "All"),
                                       
                                       selectInput("sales_year_select",
                                                   label = "Year of Release:",
                                                   choices = c("All", 
                                                               sort(unique(game_sales_manufacturer$year_of_release))),
                                                   selected = "All"),
                                       
                                       checkboxGroupInput("sales_group_select",
                                                          label = NULL),
                                       
                                       
                                       actionButton("sales_select_all", "Select/Deselect All")
                                       
                                       
                                       
                                     )
                        ),
                        
                        mainPanel(width = 10,
                                  
                                  tabsetPanel(
                                    
                                    tabPanel("Graph",
                                             plotOutput("sales_plot", height = 500)
                                    ),
                                    
                                    tabPanel("Data",
                                             dataTableOutput("sales_data")
                                    )
                                  )
                                  
                                  
                                  
                        )
                        
                      )
                      
                      
             )
             )
             
  )


