library(shiny)
library(dplyr)
library(ggplot2)
library(stringr)

business <- read.csv('../../data/business.csv') %>%
    mutate(across(where(is.factor), as.character))
suggestions <- read.csv('../../data/suggestions.csv') %>%
    mutate(across(c(suggestion1, suggestion2, suggestions3),
                  ~str_replace_all(., '\n', ' '))) %>%
    mutate(across(where(is.factor), as.character))

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
            h3('Suggestions'),
            htmlOutput('Words'),
            br(),
            htmlOutput('Suggestions')
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
        if(input$State == '' | input$City == '' | input$Name == '' | input$Address == '') {
            return(NULL)
        }
        businesses_city <- (business %>% filter(
            state == input$State & city == input$City))$business_id
        ratings_city <- suggestions %>% filter(business_id %in% businesses_city) %>%
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
        if(input$State == '' | input$City == '' | input$Name == '' | input$Address == '') {
            return(NULL)
        }
        businesses_city <- (business %>% filter(
            state == input$State & city == input$City))$business_id
        ratings_city <- suggestions %>% filter(business_id %in% businesses_city) %>%
            group_by(business_id) %>% summarize_at(vars(average_rating), mean) %>%
            arrange(desc(average_rating))
        bid <- (business %>% filter(
            state == input$State & city == input$City & name == input$Name &
                address == input$Address))$business_id
        paste('<b>Rank:', which(ratings_city$business_id == bid), 'of',
              dim(ratings_city)[1], 'businesses</b>')
    })
    output$Words <- renderText({
        if(input$State == '' | input$City == '' | input$Name == '' | input$Address == '') {
            return(NULL)
        }
        id <- (business %>% filter(
            state == input$State & city == input$City & name == input$Name &
                address == input$Address))$business_id
        info <- suggestions %>% filter(business_id == id)
        words <- c()
        if(!is.na(info$word1)) words <- c(words, info$word1)
        if(!is.na(info$word2)) words <- c(words, info$word2)
        if(!is.na(info$word3)) words <- c(words, info$word3)
        paste('<b>Most Important Words (Based on Reviews):</b>',
              paste(words, collapse = ', ')
        )
    })
    output$Suggestions <- renderText({
        if(input$State == '' | input$City == '' | input$Name == '' | input$Address == '') {
            return(NULL)
        }
        id <- (business %>% filter(
            state == input$State & city == input$City & name == input$Name &
                address == input$Address))$business_id
        info <- suggestions %>% filter(business_id == id)
        sug <- c()
        if(!is.na(info$suggestion1)) sug <- c(sug, info$suggestion1)
        if(!is.na(info$suggestion2)) sug <- c(sug, info$suggestion2)
        if(!is.na(info$suggestions3)) sug <- c(sug, info$suggestions3)
        paste(sug, collapse = '<br>')
    })
}

shinyApp(ui = ui, server = server)
