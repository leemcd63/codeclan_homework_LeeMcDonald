library(tidyverse)
library(shiny)
library(DT)
library(shinydashboard)

# load in data from CodeClanData package
game_sales <- CodeClanData::game_sales

# Create "manufacturer" column and recode platform names
game_sales_manufacturer <- game_sales %>%
    mutate(manufacturer = case_when(
        str_detect(platform, "^PS") ~ "Sony",
        str_detect(platform, "^X") ~ "Microsoft",
        str_detect(platform, "Wii|DS|GC|GBA") ~ "Nintendo",
        TRUE ~ "PC"),
        platform = case_when(
            platform == "X360" ~ "Xbox 360",
            platform == "XB" ~ "Xbox",
            platform == "XOne" ~ "Xbox One",
            platform == "GC" ~ "Gamecube",
            platform == "WiiU" ~ "Wii U",
            platform == "PS" ~ "PS1",
            platform == "PSP" ~ "PSP",
            platform == "PSV" ~ "PSVita",
            TRUE ~ platform
        ),
        # Remove longer words from end of developer/publisher to make gggplot nicer.
        developer = str_remove(developer, " Entertainment"),
        publisher = str_remove_all(publisher, " Entertainment| Interactive"),
        user_score = user_score * 10
    ) %>%
    arrange(manufacturer, platform) %>%
    # Add levels to platform and manufacturer for plot colour consistency
    mutate(platform = factor(platform, levels = c("Xbox", "Xbox 360", "Xbox One",
                                                  "3DS", "DS", "Gamecube", "GBA", "Wii", "Wii U",
                                                  "PC",
                                                  "PS1", "PS2", "PS3", "PS4", "PSP", "PSVita")),
           manufacturer = factor(manufacturer, levels = c("Microsoft", "Nintendo", "PC", "Sony")))

# create colour vector for platform and manufacturer
console_colours <- c("#00cc00", "#00e600", "#00ff00", # Microsoft
                     "#ff0000", "#ff1a1a", "#ff3333", "#ff4d4d", "#ff6666", "#ff8080", # Nintendo
                     "#993399", # PC
                     "#0040ff", "#1a53ff", "#3366ff", "#4d79ff", "#668cff", "#809fff") # Sony

manufacturer_colours <- c("#00cc00", "#ff0000", "#993399", "#0040ff")

# assign platform and manufacturer names to colour vector
names(console_colours) <- levels(game_sales_manufacturer$platform)
names(manufacturer_colours) <- levels(game_sales_manufacturer$manufacturer)


game_sales_manufacturer %>%
    group_by(genre) %>%
    summarise(avg_rating = mean(critic_score + user_score)) %>%
    arrange(desc(avg_rating))

# LAUNCH APP
shinyApp(ui = ui, server = server)

