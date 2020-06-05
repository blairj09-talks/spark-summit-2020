library(shiny)
library(shinydashboard)
library(pool)
library(tidyverse)

pool <- dbPool(odbc::odbc(), dsn = "databricks")

onStop(function() {
    poolClose(pool)
})

airlines <- c("Air Leap", "air-taxi Europe", "AirTran Airways", "Alaska Airlines, Inc.", 
              "Aloha Airlines", "America West Airlines", "American Airlines", 
              "American Eagle Airlines", "ATA Airlines", "Atlantic Southeast Airlines", 
              "Comair", "Continental Airlines", "Continental Express", "Delta Air Lines", 
              "Discovery Airways", "Eastern Air Lines", "Endeavor Air", "Envoy Air", 
              "European Air Express", "ExpressJet", "Frontier Airlines", "Hawaiian Airlines", 
              "Hawaiian Pacific Airlines", "Independence Air", "JetBlue Airways", 
              "MAP-Management and Planung", "Mesa Airlines", "Northwest Airlines", 
              "Norwegian Air Norway", "Pearl Airways", "Phoenix Airways", "Piedmont Airlines (1948-1989)", 
              "Pinnacle Airlines", "PSA Airlines", "SkyWest Airlines", "Sol del Paraguay", 
              "Southwest Airlines", "Sun Air (Fiji)", "T'way Air", "Tsaradia", 
              "Ukraine International Airlines", "Unavia Suisse", "United Airlines", 
              "US Airways")

header <- dashboardHeader(title = "Airline Comparison")
sidebar <- dashboardSidebar(
    selectInput(inputId = "airlines", 
                label = "Airlines", 
                choices = airlines, 
                selected = c("Southwest Airlines", "Delta Air Lines"), 
                multiple = TRUE),
    sliderInput(inputId = "years",
                label = "Years",
                min = 1987,
                max = 2008,
                value = c(1987, 2008),
                sep = ""),
    actionButton("go", "Go")
)

body <- dashboardBody(
    fluidRow(
        valueBoxOutput("n_records"),
        valueBoxOutput("dep_delay"),        
        valueBoxOutput("flight_length")
    ),
    fluidRow(
        box(plotOutput("flights_plot"), width = 12)
    )
)

ui <- dashboardPage(
    header,
    sidebar,
    body
)

server <- function(input, output) {
    # Reactives ----
    n_records <- eventReactive(input$go, {
        years <- input$years[1]:input$years[2]
        tbl(pool, "all_flights") %>%
            filter(airline %in% local(input$airlines),
                   Year %in% years) %>% 
            tally() %>% 
            collect() %>% 
            pull(n)
    }, ignoreNULL = FALSE)
    
    dep_delay <- eventReactive(input$go, {
        years <- input$years[1]:input$years[2]
        tbl(pool, "all_flights") %>%
            filter(airline %in% local(input$airlines),
                   Year %in% years) %>% 
            summarise(avg_dep_delay = mean(DepDelay)) %>% 
            collect() %>% 
            pull(avg_dep_delay)
    }, ignoreNULL = FALSE)
    
    flight_length <- eventReactive(input$go, {
        years <- input$years[1]:input$years[2]
        tbl(pool, "all_flights") %>%
            filter(airline %in% local(input$airlines),
                   Year %in% years) %>% 
            summarise(avg_length = mean(AirTime, na.rm = TRUE)) %>% 
            collect() %>% 
            pull(avg_length)
    })
    
    plot_data <- eventReactive(input$go, {
        years <- input$years[1]:input$years[2]
        tbl(pool, "all_flights") %>%
            filter(airline %in% local(input$airlines),
                   Year %in% years) %>% 
            count(airline, Year, Month) %>% 
            collect()
    }, ignoreNULL = FALSE)
    
    
    # Outputs ----
    output$n_records <- renderValueBox({
        valueBox(value = n_records(),
                 subtitle = "Total Flights")
    })
    
    output$dep_delay <- renderValueBox({
        valueBox(value = round(dep_delay(), 2),
                 subtitle = "Average Departure Delay")
    })
    
    output$flight_length <- renderValueBox({
        valueBox(value = round(flight_length(), 2),
                 subtitle = "Average Flight Time")
    })
    
    output$flights_plot <- renderPlot({
        plot_data() %>% 
            ggplot(aes(x = Month, y = n, fill = airline)) +
            facet_wrap(~Year) +
            geom_area() +
            scale_y_continuous(labels = scales::comma) +
            scale_x_continuous(breaks = 1:12) +
            theme_bw() +
            theme(axis.text.x = element_blank()) +
            labs(title = "Flights per Year",
                 x = "Month",
                 y = "Flights",
                 fill = "Airline")
    })
    
}

shinyApp(ui, server)
