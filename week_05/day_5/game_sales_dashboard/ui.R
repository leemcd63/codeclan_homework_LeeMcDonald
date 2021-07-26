# ui ---------------------------------------------------------------------------

ui <- dashboardPage(skin = "green",
                    
                    # ShinyDashboard tabs
                    dashboardHeader(title = "Video Game Sales"), 
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Overview", tabName = "overview"),
                        menuItem("Game Sales Chart", tabName = "game_sales"),
                        menuItem("Game Scores Chart", tabName = "game_scores")
                      )
                    ),
                    dashboardBody(
                      tabItems(
                        # OVERVIEW PANEL ---------------------------------------
                        tabItem(tabName = "overview",
                                fluidRow(align = "center",
                                         
                                         column(2, offset = 5,
                                                selectInput("overview_year_select",
                                                            label = "Year of Release:",
                                                            choices = c("All", 
                                                                        sort(unique(game_sales_manufacturer$year_of_release))),
                                                            selected = "All")
                                         )
                                ),
                                fluidRow(
                                column(12, offset = 2,
                                fluidRow(
                                  infoBox("Top Scored Game by Critics",
                                          color = "green",
                                          textOutput("overview_top_critics"),
                                          icon = icon("glyphicon glyphicon-thumbs-up", lib = "glyphicon"),
                                          fill = TRUE),
                                  
                                  infoBox("Worst Scored Game by Critics",
                                          color = "red",
                                          textOutput("overview_bottom_critics"),
                                          icon = icon("glyphicon glyphicon-thumbs-down", lib = "glyphicon"),
                                          fill = TRUE)
                                  
                                ),
                                
                                fluidRow(
                                  infoBox("Top Scored Game by Users",
                                          color = "green",
                                          textOutput("overview_top_users"),
                                          icon = icon("glyphicon glyphicon-thumbs-up", lib = "glyphicon"),
                                          fill = TRUE),
                                  
                                  infoBox("Worst Scored Game by Users",
                                          color = "red",
                                          textOutput("overview_bottom_users"),
                                          icon = icon("glyphicon glyphicon-thumbs-down", lib = "glyphicon"),
                                          fill = TRUE)
                                ),
                                
                                fluidRow(
                                
                                  infoBox("Most Loved Genre",
                                          color = "green",
                                          textOutput("overview_top_genre"),
                                          icon = icon("glyphicon glyphicon-heart", lib = "glyphicon"),
                                          fill = TRUE),
                                  
                                  infoBox("Least Loved Genre",
                                          color = "red",
                                          textOutput("overview_bottom_genre"),
                                          icon = icon("glyphicon glyphicon-heart-empty", lib = "glyphicon"),
                                          fill = TRUE)
                                  
                                ),
                                
                                fluidRow(
                                  infoBox("Top Selling Game",
                                          color = "green",
                                          textOutput("overview_top_game"),
                                          icon = icon("glyphicon glyphicon-usd", lib = "glyphicon"),
                                          fill = TRUE),
                                  
                                  infoBox("Worst Selling Game",
                                          color = "red",
                                          textOutput("overview_bottom_game"),
                                          icon = icon("glyphicon glyphicon-remove", lib = "glyphicon"),
                                          fill = TRUE)
                                ),
                                
                                fluidRow(
                                  
                                  infoBox("Top Selling Console",
                                          color = "green",
                                          textOutput("overview_top_console"),
                                          icon = icon("glyphicon glyphicon-usd", lib = "glyphicon"),
                                          fill = TRUE),
                                  
                                  infoBox("Worst Selling Console",
                                          color = "red",
                                          textOutput("overview_bottom_console"),
                                          icon = icon("glyphicon glyphicon-remove", lib = "glyphicon"),
                                          fill = TRUE)
                                ),
                                
                                fluidRow(
                                  
                                  infoBox("Top Selling Developer",
                                          color = "green",
                                          textOutput("overview_top_developer"),
                                          icon = icon("glyphicon glyphicon-usd", lib = "glyphicon"),
                                          fill = TRUE),
                                  
                                  infoBox("Worst Selling Developer",
                                          color = "red",
                                          textOutput("overview_bottom_developer"),
                                          icon = icon("glyphicon glyphicon-remove", lib = "glyphicon"),
                                          fill = TRUE)
                                )
                                )
                                )
                        ),
                        
                        # GAME SALES PANEL -------------------------------------------------------------
                        tabItem(tabName = "game_sales",
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
                                
                                fluidRow(
                                  column(width = 2, align = "center",
                                         box(width = NULL, solidHeader = TRUE, background = "green",
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
                                  
                                  column(width = 10,
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
                                
                                
                        ),
                        
                        tabItem(tabName = "game_scores",
                                
                                fluidRow(align = "center",
                                  column(2, offset = 3,
                                  selectInput("score_year_select",
                                              label = "Year of Release:",
                                              choices = c("All", 
                                                          sort(unique(game_sales_manufacturer$year_of_release))),
                                              selected = "All")
                                  ),
                                  
                                  column(4,
                                  radioButtons("score_rater_select",
                                               label = "Rated by:",
                                               choices = c("All" = "total_score",
                                                           "Critics" = "critic_score",
                                                           "Users" = "user_score"),
                                               inline = TRUE)
                                  )
                                ),
                                
                                fluidRow(
                                  column(12,
                                  plotOutput("score_plot")
                                  )
                                )
                                
                                )
                      )
                    )
                    
)


