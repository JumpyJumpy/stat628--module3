library(shiny)
library(dplyr)

business <- read.csv('../business.csv')

ui <- fluidPage(
    titlePanel('Recommendations Based on Yelp Reviews'),
    sidebarLayout(
        sidebarPanel(
            selectInput('State', 'State:', choices = unique(business$state),
                        selected = 'OR'),
            selectInput('City', 'City:', choices = '', selected = 'Portland'),
            selectInput('Business', 'Business:',
                        choices = '',
                        selected = 'Flying Elephants at PDX (7000 NE Airport Way)'),
        ),
        mainPanel(
            tableOutput('Reccos')
        )
    )
)

server <- function(input, output, session) {
    observe({
        updateSelectInput(session, 'City', choices =
                              (business %>% filter(state == input$State))$city %>%
                              unique)
    })
    observe({
        updateSelectInput(session, 'Business', choices = paste(
            (
                business %>% filter(state == input$State) %>%
                    filter(city == input$City)
            )$name,
            ' (', (
                business %>% filter(state == input$State) %>%
                    filter(city == input$City)
            )$address, ')', sep = '')
        )
    })
    output$Reccos <- renderTable({
        reccs <- data.frame(cbind('This is what the business does well',
                                  'This is what the business needs to improve.'))
        colnames(reccs) <- c('Strengths', 'Weaknesses')
        reccs
    })
}

shinyApp(ui = ui, server = server)