library(shiny)
library(dplyr)
library(ggplot2)
library(stringr)

business <- read.csv('data/business.csv') %>%
    mutate(across(where(is.factor), as.character))
word_sugs <- read.csv('data/suggestions.csv') %>%
    mutate(across(c(suggestion1, suggestion2, suggestions3),
                  ~str_replace_all(., '\n', ' '))) %>%
    mutate(across(where(is.factor), as.character))
attr_sugs <- read.csv('data/attributes_suggestions.csv') %>%
    mutate(across(where(is.factor), as.character))
attr <- read.csv('data/Attributes_advice.csv')

ui <- fluidPage(
    titlePanel('Recommendations Based on Yelp Reviews'),
    sidebarLayout(
        sidebarPanel(
            selectInput('State', 'State:', choices = unique(business$state),
                        selected = 'OR'),
            selectInput('City', 'City:', choices = '', selected = 'Portland'),
            selectInput('Name', 'Name:', choices = '', selected = 'Flying Elephants at PDX'),
            selectInput('Address', 'Address:', choices = '',
                        selected = '7000 NE Airport Way')
        ),
        mainPanel(
            plotOutput('RankBar', width = '75%', height = '300px'),
            htmlOutput('Rank'),
            h4('Word-Based Suggestions'),
            htmlOutput('Words'),
            br(),
            htmlOutput('WordSugs'),
            h4('Other Suggestions'),
            htmlOutput('AttrSugs')
        )
    )
)

server <- function(input, output, session) {
    observe({
        updateSelectInput(session, 'City', choices = (
            business %>% filter(state == input$State))$city %>% unique
        )
    })
    observe({
        updateSelectInput(session, 'Name', choices = (
            business %>% filter(state == input$State & city == input$City))$name 
        )
    })
    observe({
        updateSelectInput(session, 'Address', choices = (
            business %>% filter(
                state == input$State & city == input$City & name == input$Name
            ))$address
        )
    })
    output$RankBar <- renderPlot({
        businesses_city <- (business %>% filter(
            state == input$State & city == input$City))$business_id
        ratings_city <- word_sugs %>% filter(business_id %in% businesses_city) %>%
            group_by(business_id) %>% summarize_at(vars(average_rating), mean) %>%
            arrange(desc(average_rating))
        bid <- (business %>% filter(
            state == input$State & city == input$City & name == input$Name &
                address == input$Address))$business_id
        ratings_city %>% ggplot(aes(x = average_rating)) + geom_histogram(binwidth = 0.2) +
            xlab('Average Rating from Reviews (Stars)') + ylab('Number of Businesses') +
            ggtitle(paste('Average Rating for Businesses in', input$City, input$State)) +
            geom_vline(xintercept =
                (ratings_city %>% filter(business_id == bid))$average_rating
            )
    })
    output$Rank <-renderText({
        businesses_city <- (business %>% filter(
            state == input$State & city == input$City))$business_id
        ratings_city <- word_sugs %>% filter(business_id %in% businesses_city) %>%
            group_by(business_id) %>% summarize_at(vars(average_rating), mean) %>%
            arrange(desc(average_rating))
        bid <- (business %>% filter(
            state == input$State & city == input$City & name == input$Name &
                address == input$Address))$business_id
        paste('<b>Rank:', which(ratings_city$business_id == bid), 'of',
              dim(ratings_city)[1], 'businesses</b>')
    })
    output$Words <- renderText({
        id <- (business %>% filter(
            state == input$State & city == input$City & name == input$Name &
                address == input$Address))$business_id
        info <- word_sugs %>% filter(business_id == id)
        words <- c()
        if(!is.na(info$word1)) words <- c(words, info$word1)
        if(!is.na(info$word2)) words <- c(words, info$word2)
        if(!is.na(info$word3)) words <- c(words, info$word3)
        paste('<b>Most Important Words (Based on Reviews):</b>',
              paste(words, collapse = ', ')
        )
    })
    output$WordSugs <- renderText({
        id <- (business %>% filter(
            state == input$State & city == input$City & name == input$Name &
                address == input$Address))$business_id
        info <- word_sugs %>% filter(business_id == id)
        sug <- c()
        if(!is.na(info$suggestion1)) sug <- c(sug, info$suggestion1)
        if(!is.na(info$suggestion2)) sug <- c(sug, info$suggestion2)
        if(!is.na(info$suggestions3)) sug <- c(sug, info$suggestions3)
        paste(sug, collapse = '<br><br>')
    })
    output$AttrSugs <- renderText({
        id <- (business %>% filter(
            state == input$State & city == input$City & name == input$Name &
                address == input$Address))$business_id
        info <- attr %>% filter(business_id == id)
        sug <- c()
        if(is.na(info$RestaurantsDelivery) | info$RestaurantsDelivery == 'False') {
            sug <- c(sug, attr_sugs$Suggestions[1])
        }
        if(is.na(info$street) | info$street == 'False') {
            sug <- c(sug, attr_sugs$Suggestions[2])
        }
        if(is.na(info$OutdoorSeating) | info$OutdoorSeating == 'False') {
            sug <- c(sug, attr_sugs$Suggestions[3])
        }
        if(is.na(info$HasTV) | info$HasTV == 'True') {
            sug <- c(sug, attr_sugs$Suggestions[4])
        }
        if(is.na(info$classy) | info$classy == 'False') {
            sug <- c(sug, attr_sugs$Suggestions[6])
        }
        paste(sug, collapse = '<br><br>')
    })
}

shinyApp(ui = ui, server = server)
