# server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  # OVERVIEW TAB ---------------------------------------------------------------
  
  # Filter data based on year selection
  overview_data <- reactive({
    
    if (input$overview_year_select == "All") {
      year_selection_over <- unique(game_sales_manufacturer$year_of_release)
    } else {
      year_selection_over <- input$overview_year_select
    }
    
    game_sales_manufacturer %>%
      filter(year_of_release %in% year_selection_over)
  })
  
  # textOutputs for overview tab
  output$overview_top_critics <- renderText({
    overview_data() %>%
      slice_max(critic_score, with_ties = FALSE) %>%
      pull(name)
  })
  
  output$overview_top_users <- renderText({
    overview_data() %>%
      slice_max(user_score, with_ties = FALSE) %>%
      pull(name)
  })
  
  output$overview_top_genre <- renderText({
    overview_data() %>%
      group_by(genre) %>%
      summarise(avg_rating = mean(critic_score + user_score)) %>%
      slice_max(avg_rating, with_ties = FALSE) %>%
      pull(genre)
  })
  
  output$overview_bottom_critics <- renderText({
    overview_data() %>%
      slice_min(critic_score, with_ties = FALSE) %>%
      pull(name)
  })
  
  output$overview_bottom_users <- renderText({
    overview_data() %>%
      slice_min(user_score, with_ties = FALSE) %>%
      pull(name)
  })
  
  output$overview_bottom_genre <- renderText({
    overview_data() %>%
      group_by(genre) %>%
      summarise(avg_rating = mean(critic_score + user_score)) %>%
      slice_min(avg_rating, with_ties = FALSE) %>%
      pull(genre)
  })
  
  output$overview_top_game <- renderText({
    overview_data() %>%
      slice_max(sales, with_ties = FALSE) %>%
      pull(name)
  })
  
  output$overview_top_console <- renderText({
    overview_data() %>%
      mutate(platform = as.character(platform)) %>%
      group_by(platform) %>%
      summarise(total_sales = sum(sales)) %>%
      slice_max(total_sales, with_ties = FALSE) %>%
      pull(platform)
  })
  
  output$overview_top_developer <- renderText({
    overview_data() %>%
      group_by(developer) %>%
      summarise(total_sales = sum(sales)) %>%
      slice_max(total_sales, with_ties = FALSE) %>%
      pull(developer)
  })
  
  output$overview_bottom_game <- renderText({
    overview_data() %>%
      slice_min(sales, with_ties = FALSE) %>%
      pull(name)
  })
  
  output$overview_bottom_console <- renderText({
    overview_data() %>%
      mutate(platform = as.character(platform)) %>%
      group_by(platform) %>%
      summarise(total_sales = sum(sales)) %>%
      slice_min(total_sales, with_ties = FALSE) %>%
      pull(platform)
  })
  
  output$overview_bottom_developer <- renderText({
    overview_data() %>%
      group_by(developer) %>%
      summarise(total_sales = sum(sales)) %>%
      slice_min(total_sales, with_ties = FALSE) %>%
      pull(developer)
  })
  
  
  # GAME SALES TAB -------------------------------------------------------------
  
  # GAME SALES Checkbox buttons
  observe({
    # For each filter selected, update list of selections 
    if(input$sales_filter == "platform") {
      sales_filter_selection <- unique(game_sales_manufacturer$platform)
    } else if (input$sales_filter == "manufacturer") {
      sales_filter_selection <- unique(game_sales_manufacturer$manufacturer)
    } else if (input$sales_filter == "developer") {
      sales_filter_selection <- unique(game_sales_manufacturer$developer)
    } else {
      sales_filter_selection <- unique(game_sales_manufacturer$publisher)
    }
    
    # Refresh Checkboxes with new selections
    updateCheckboxGroupInput(session, 
                             "sales_group_select", 
                             label = str_c("Select ", str_to_title(input$sales_filter), ":"),
                             choices = sort(sales_filter_selection),
                             selected = sales_filter_selection)
    
    # "Select/Deselect All" button
    # If pressed, tick/untick all checkboxes
    if (input$sales_select_all > 0) {
      if(input$sales_select_all %% 2 == 0) {
        updateCheckboxGroupInput(session, 
                                 "sales_group_select", 
                                 label = str_c("Select ", str_to_title(input$sales_filter), ":"),
                                 choices = sales_filter_selection,
                                 selected = sales_filter_selection)
      } else {
        updateCheckboxGroupInput(session, 
                                 "sales_group_select", 
                                 label = str_c("Select ", str_to_title(input$sales_filter), ":"),
                                 choices = sales_filter_selection,
                                 selected = c())
      }
    }
  })
  
  # FILTER DATA
  sales_totals <- reactive({
    # Create filtering variable for genre selection - "All" or specific
    if (input$sales_genre_select == "All") {
      genre_selection <- unique(game_sales_manufacturer$genre)
    } else {
      genre_selection <- input$sales_genre_select
    }
    
    # Create filtering variable for year selection - "All" or specific
    if(input$sales_year_select == "All") {
      year_selection <- unique(game_sales_manufacturer$year_of_release)
    } else {
      year_selection <- input$sales_year_select
    }
    
    # Filter by main group, then genre and year if selected.
    # Group by main group (Console, Dev etc...)
    # Summarise for total sales
    # Think I understand the need for BANG BANG here, but need to understand more
    game_sales_manufacturer %>%
      filter(!!sym(input$sales_filter) %in% input$sales_group_select,
             genre %in% genre_selection,
             year_of_release %in% year_selection) %>%
      group_by(!!sym(input$sales_filter)) %>%
      summarise(total_sales = round(sum(sales), 2)) 
  })
  
  # COLOUR SCHEME
  filter_colours <- reactive ({
    # Edit ggplot colour variable based on main group filter
    if(input$sales_filter == "platform") {
      filter_colours <- scale_fill_manual(values = console_colours)
    } else if (input$sales_filter == "manufacturer") {
      filter_colours <- scale_fill_manual(values = manufacturer_colours)
    # Only specified colours for platform and manufacturer for now, might add later
    } else {
      filter_colours <- NULL
    }
    
  })
  
  # PLOT OUTPUT
  output$sales_plot <- renderPlot({
    # If no selection in main group, show notification
    if (is.null(input$sales_group_select)) {
      showNotification(str_c("No ", input$sales_filter, " selected"))
    } else {
      # Initialise plot
      sales_totals() %>%
        ggplot() +
        # Aesthetics are main group filter and total_sales
        aes(x = !!sym(input$sales_filter), y = total_sales, fill = !!sym(input$sales_filter)) +
        geom_col(show.legend = FALSE) +
        filter_colours() +
        # Add Reactive labels
        labs(
          x = str_c("\n", str_to_title(input$sales_filter), " Name"),
          y = "Game Units (millions)\n",
          title = str_c("\n", input$sales_genre_select, " Games Sold - by ", 
                        str_to_title(input$sales_filter), " - Release Year: ", input$sales_year_select, "\n")
        ) +
        # add theme elements, rotate x axis text 45deg
        theme_minimal() +
        theme(
          plot.title = element_text(size = 24, hjust = 0.5, face = "bold"),
          axis.title = element_text(size = 16, face = "bold"),
          axis.text.y = element_text(size = 14),
          axis.text.x = element_text(size = 12, angle = 45,  vjust = 1, hjust = 1)
        )
      
    }
  })
  
  # DATA OUTPUT
  output$sales_data <- renderDataTable({
    # data table with reactive title
    datatable(sales_totals(),
              rownames = FALSE,
              colnames = c("Game Units (millions)" = "total_sales"),
              caption = tags$h3(str_c(input$sales_genre_select, " Games Sold - by ", 
                                      str_to_title(input$sales_filter), " - Release Year: ", input$sales_year_select))
    )
    
  })
  
  # RATING TAB -----------------------------------------------------------------
  
  # FILTER DATA
  score_totals <- reactive({
    # Create filtering variable for year selection - "All" or specific
    if(input$score_year_select == "All") {
      score_year_selection <- unique(game_sales_manufacturer$year_of_release)
    } else {
      score_year_selection <- input$score_year_select
    }
    
    # Filter by main group, then genre and year if selected.
    # Think I understand the need for BANG BANG here, but need to understand more
    game_sales_manufacturer %>%
      filter(year_of_release %in% score_year_selection) %>%
      mutate(total_score = (critic_score + user_score) / 2)
  })
  

  
  # PLOT OUTPUT
  output$score_plot <- renderPlot({

    score_totals() %>%
      ggplot() +
      # Aesthetics are main group filter and total_rating
      aes(x = !!sym(input$score_rater_select)) +
      geom_histogram(colour = "white", fill = "#2ca25f") +
      # Add Reactive labels
      labs(
        x = str_c("\n Review Score"),
        y = "Count \n",
        title = str_c("\n", str_to_title(str_replace(input$score_rater_select, "_", " ")),
                      " - Release Year: ", input$score_year_select, "\n")
      ) +
      scale_x_continuous(n.breaks = 10) + 
    # add theme elements, rotate x axis text 45deg
    theme_minimal() +
      theme(
        plot.title = element_text(size = 24, hjust = 0.5, face = "bold"),
        axis.title = element_text(size = 16, face = "bold"),
        axis.text = element_text(size = 14),
      )
  })
  
}