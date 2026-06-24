library(shiny)

ui <- fluidPage(
  titlePanel("Établi Vitrine — sample app"),
  sidebarLayout(
    sidebarPanel(
      selectInput("var", "Variable", choices = names(mtcars), selected = "mpg"),
      sliderInput("bins", "Bins", min = 5, max = 30, value = 12)
    ),
    mainPanel(plotOutput("hist"), verbatimTextOutput("summary"))
  )
)

server <- function(input, output) {
  output$hist <- renderPlot({
    hist(mtcars[[input$var]], breaks = input$bins,
         col = "#28A745", border = "white", main = input$var, xlab = input$var)
  })
  output$summary <- renderPrint(summary(mtcars[[input$var]]))
}

shinyApp(ui, server)
