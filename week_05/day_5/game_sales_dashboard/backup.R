

# GAME RATINGS PANEL ----------------------------------------------
tabPanel("Game Ratings",
         fluidRow(align = "center",
                  column(5, offset = 2,
                         radioButtons("rating_filter",
                                      label = "Select Filter:",
                                      choices = c("By Console" = "platform",
                                                  "By Manufacturer" = "manufacturer",
                                                  "By Developer" = "developer",
                                                  "By Publisher" = "publisher"),
                                      inline = TRUE,
                                      selected = "platform")
                  ),
                  
                  column(3,
                         radioButtons("score_filter",
                                      label = "Scored By:",
                                      choices = c("By Critics" = "critic_score",
                                                  "By Users" = "user_score"),
                                      inline = TRUE)
                  )
         ),
         
         
         sidebarLayout(
           sidebarPanel(width = 2, align = "center",
                        
                        fluidRow(
                          selectInput("rating_genre_select",
                                      label = "Game Genre:",
                                      choices = c("All", 
                                                  sort(unique(game_sales_manufacturer$genre))),
                                      selected = "All"),
                          
                          selectInput("rating_year_select",
                                      label = "Year of Release:",
                                      choices = c("All", 
                                                  sort(unique(game_sales_manufacturer$year_of_release))),
                                      selected = "All"),
                          
                          checkboxGroupInput("rating_group_select",
                                             label = NULL),
                          
                          
                          actionButton("rating_select_all", "Select/Deselect All")
                          
                          
                          
                        )
           ),
           
           mainPanel(width = 10,
                     
                     tabsetPanel(
                       
                       tabPanel("Graph",
                                plotOutput("rating_plot", height = 500)
                       ),
                       
                       tabPanel("Data",
                                dataTableOutput("rating_data")
                       )
                     )
                     
                     
                     
           )
           
         )
         
         





# GAME RATINGS TAB -----------------------------------------------------------
# GAME RATINGS Checkbox buttons
observe({
  # For each filter selected, update list of selections 
  if(input$rating_filter == "platform") {
    rating_filter_selection <- unique(game_sales_manufacturer$platform)
  } else if (input$rating_filter == "manufacturer") {
    rating_filter_selection <- unique(game_sales_manufacturer$manufacturer)
  } else if (input$rating_filter == "developer") {
    rating_filter_selection <- unique(game_sales_manufacturer$developer)
  } else {
    rating_filter_selection <- unique(game_sales_manufacturer$publisher)
  }
  
  # Refresh Checkboxes with new selections
  updateCheckboxGroupInput(session, 
                           "rating_group_select", 
                           label = str_c("Select ", str_to_title(input$rating_filter), ":"),
                           choices = sort(rating_filter_selection),
                           selected = rating_filter_selection)
  
  # "Select/Deselect All" button
  # If pressed, tick/untick all checkboxes
  if (input$rating_select_all > 0) {
    if(input$rating_select_all %% 2 == 0) {
      updateCheckboxGroupInput(session, 
                               "rating_group_select", 
                               label = str_c("Select ", str_to_title(input$rating_filter), ":"),
                               choices = rating_filter_selection,
                               selected = rating_filter_selection)
    } else {
      updateCheckboxGroupInput(session, 
                               "rating_group_select", 
                               label = str_c("Select ", str_to_title(input$rating_filter), ":"),
                               choices = rating_filter_selection,
                               selected = c())
    }
  }
})

# FILTER DATA
rating_totals <- reactive({
  # Create filtering variable for genre selection - "All" or specific
  if (input$rating_genre_select == "All") {
    genre_selection <- unique(game_sales_manufacturer$genre)
  } else {
    genre_selection <- input$rating_genre_select
  }
  
  # Create filtering variable for year selection - "All" or specific
  if(input$rating_year_select == "All") {
    year_selection <- unique(game_sales_manufacturer$year_of_release)
  } else {
    year_selection <- input$rating_year_select
  }
  
  
  
  # Filter by main group, then genre and year if selected.
  # Think I understand the need for BANG BANG here, but need to understand more
  game_sales_manufacturer %>%
    filter(!!sym(input$rating_filter) %in% input$rating_group_select,
           genre %in% genre_selection,
           year_of_release %in% year_selection)
})

# COLOUR SCHEME
filter_colours <- reactive ({
  # Edit ggplot colour variable based on main group filter
  if(input$rating_filter == "platform") {
    filter_colours <- scale_fill_manual(values = console_colours)
  } else if (input$rating_filter == "manufacturer") {
    filter_colours <- scale_fill_manual(values = manufacturer_colours)
    # Only specified colours for platform and manufacturer for now, might add later
  } else {
    filter_colours <- NULL
  }
  
})

# PLOT OUTPUT
output$rating_plot <- renderPlot({
  # If no selection in main group, show notification
  if (is.null(input$rating_group_select)) {
    showNotification(str_c("No ", input$rating_filter, " selected"))
  } else {
    # Initialise plot
    rating_totals() %>%
      ggplot() +
      # Aesthetics are main group filter and total_rating
      aes(x = !!sym(input$score_filter), fill = !!sym(input$rating_filter)) +
      geom_histogram(show.legend = TRUE) +
      filter_colours() +
      # Add Reactive labels
      labs(
        x = str_c("\n Review Score"),
        y = "Count \n",
        title = str_c("\n", str_to_title(str_replace(input$score_filter, "_", " ")), " - ", str_to_title(input$rating_genre_select), " Games - by ", 
                      str_to_title(input$rating_filter), " - Release Year: ", input$rating_year_select, "\n")
      ) +
      scale_x_continuous(n.breaks = 10)
    # add theme elements, rotate x axis text 45deg
    theme_minimal() +
      theme(
        plot.title = element_text(size = 24, hjust = 0.5, face = "bold"),
        axis.title = element_text(size = 16, face = "bold"),
        axis.text = element_text(size = 14),
      )
    
  }
})

# DATA OUTPUT
output$rating_data <- renderDataTable({
  # data table with reactive title
  datatable(rating_totals(),
            rownames = FALSE,
            caption = str_c("\n", str_to_title(str_replace(input$score_filter, "_", " ")), " - ", str_to_title(input$rating_genre_select), " Games - by ", 
                            str_to_title(input$rating_filter), " - Release Year: ", input$rating_year_select, "\n")
  )
  
})
