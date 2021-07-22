library(tidyverse)
library(shiny)
library(CodeClanData)
library(shinythemes)


olympics_overall_medals <- olympics_overall_medals


# ui ----------------------------------------------------------------------

ui <- fluidPage(
    
    theme = "olympic_style.css",
    
    titlePanel(title = fluidRow(column(3, offset = 1, img(src = "olympic_logo.png")),
                           column(8, br(), tags$h1("Five Country Medal Comparison"))),
               windowTitle = "Olympic Medals"),
    
    # Panel with ggplot graph
    
    navbarPage("Olympic Data: ",
        tabPanel("Graph",
                fluidRow(align = "center",
                     column(2, offset = 1,
                            selectInput(inputId = "country",
                                        label = "Select Country:",
                                        choices = c("All Countries",
                                                    "United States",
                                                    "Soviet Union",
                                                    "Germany",
                                                    "Italy",
                                                    "Great Britain"))
                     ),
                     
                     column(2, offset = 2,
                            selectInput(inputId = "season",
                                        label = "Select Season:",
                                        choices = c("Both", 
                                                    "Summer", 
                                                    "Winter"))
                     ),
                     
                     column(2, offset = 2,
                            selectInput(inputId = "medal",
                                        label = "Select Medal:",
                                        choices = c("All", 
                                                    "Gold", 
                                                    "Silver", 
                                                    "Bronze"))
                     )
                 ),
                 
                fluidRow(
                    column(8, offset = 2,
                           plotOutput("medal_plot")
                    )
                )
        ),
        
        # Panel showing counts of medals
        
        tabPanel("Medal Counts",
                 fluidRow(align = "center",
                     column(2, offset = 5,
                            selectInput(inputId = "country_2",
                                        label = "Select Country:",
                                        choices = c("United States",
                                                    "Soviet Union",
                                                    "Germany",
                                                    "Italy",
                                                    "Great Britain"))
                     )
                ),
                
                fluidRow(align = "center",
                    column(2, offset = 2,
                           tags$h2("Summer"),
                           tags$h3("Gold"),
                           tags$h4(textOutput("summer_gold")),
                           br(),
                           tags$h3("Silver"),
                           tags$h4( textOutput("summer_silver")),
                           br(),
                           tags$h3("Bronze"),
                           tags$h4(textOutput("summer_bronze"))),
                    
                    column(2, offset = 1,
                           tags$h2("Winter"),
                           tags$h3("Gold"),
                           tags$h4(textOutput("winter_gold")),
                           br(),
                           tags$h3("Silver"),
                           tags$h4(textOutput("winter_silver")),
                           br(),
                           tags$h3("Bronze"),
                           tags$h4(textOutput("winter_bronze"))),
                    
                    column(2, offset = 1,
                           tags$h2("Total"),
                           tags$h3("Gold"),
                           tags$h4(textOutput("total_gold")),
                           br(),
                           tags$h3("Silver"),
                           tags$h4(textOutput("total_silver")),
                           br(),
                           tags$h3("Bronze"),
                           tags$h4(textOutput("total_bronze"))),
                )
                    
                
        ),
        
        # Panel with selected team picture
        tabPanel("Team Photo"
        )
    )
)



# server ------------------------------------------------------------------

server <- function(input, output) {
    
    # Server side plot generation
    output$medal_plot <- renderPlot({
        
        # If "All Countries" is selected use vector for plot
        country_var <- case_when(
            input$country == "All Countries" ~ c("United States",
                                                "Soviet Union",
                                                "Germany",
                                                "Italy",
                                                "Great Britain"),
            TRUE ~ input$country
        )
        
        # If "All" medals are selected use vector for plot
        medal_var <- case_when(
            input$medal == "All" ~ c("Gold", "Silver", "Bronze"),
            TRUE ~ input$medal
        )
        
        # If "Both" seasons are selected use vector for plot
        season_var <- case_when(
            input$season == "Both" ~ c("Summer", "Winter"),
            TRUE ~ input$season
        )
        
        olympics_overall_medals %>%
            filter(team %in% country_var) %>%
            filter(medal %in% medal_var) %>%
            filter(season %in% season_var) %>%
            ggplot() +
            aes(x = team, y = count, fill = medal) +
            geom_col(show.legend = FALSE) +
            scale_fill_manual(values = c("Gold" = "#ffd700", "Silver" = "#c0c0c0", "Bronze" = "#996633")) +
            labs(
                x = "\nTeam Name",
                y = "Number of Medals\n",
                title = str_c("\n", input$country, " - ", input$medal, " medals for ", input$season, " Olympics\n")
            ) +
            theme_minimal() +
            theme(
                plot.title = element_text(size = 30, face = "bold", hjust = 0.5),
                axis.title = element_text(size = 16, face = "bold"),
                axis.text = element_text(size = 12)
            )
        
    })
    
    # All below to pull individual medal counts for season and country.
    # There must be a better way to do this, but it works
    output$summer_gold <- renderText ({
        
        summer_gold_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, season == "Summer", medal == "Gold") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(summer_gold_pulled)
            
    })
    
    output$summer_silver <- renderText ({
        
        summer_silver_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, season == "Summer", medal == "Silver") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(summer_silver_pulled)
        
    })
    
    output$summer_bronze <- renderText ({
        
        summer_bronze_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, season == "Summer", medal == "Bronze") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(summer_bronze_pulled)
        
    })
    
    output$winter_gold <- renderText ({
        
        winter_gold_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, season == "Winter", medal == "Gold") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(winter_gold_pulled)
        
    })
    
    output$winter_silver <- renderText ({
        
        winter_silver_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, season == "Winter", medal == "Silver") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(winter_silver_pulled)
        
    })
    
    output$winter_bronze <- renderText ({
        
        winter_bronze_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, season == "Winter", medal == "Bronze") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(winter_bronze_pulled)
        
    })
    
    output$total_gold <- renderText ({
        
        total_gold_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, medal == "Gold") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(total_gold_pulled)
        
    })
    
    output$total_silver <- renderText ({
        
        total_silver_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, medal == "Silver") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(total_silver_pulled)
        
    })
    
    output$total_bronze <- renderText ({
        
        total_bronze_pulled <- olympics_overall_medals %>%
            filter(team %in% input$country_2, medal == "Bronze") %>%
            summarise(count = sum(count)) %>%
            pull(count)
        
        return(total_bronze_pulled)
        
    })
}




# app ---------------------------------------------------------------------

shinyApp(ui = ui, server = server)
