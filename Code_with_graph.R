library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)

# Sample data frame to store tickets (in-memory)
tickets <- data.frame(
  TicketID = character(0),
  Title = character(0),
  Description = character(0),
  Status = character(0),
  AssignedTo = character(0),
  StartDate = character(0),
  EndDate = character(0),
  TimeTaken = numeric(0)
)

# Define the UI
ui <- dashboardPage(
  dashboardHeader(title = "Pharma Ticket Management"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Create Ticket", tabName = "create"),
      menuItem("View Tickets", tabName = "view"),
      menuItem("Last 3 Months Status", tabName = "status_chart")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "create",
        fluidPage(
          h2("Create a New Ticket"),
          textInput("title", "Title"),
          textAreaInput("description", "Description"),
          selectInput("status", "Status", c("Open", "In Progress", "Closed")),
          textInput("assignedTo", "Assigned To"),
          dateInput("startDate", "Start Date"),
          dateInput("endDate", "End Date"),
          actionButton("createButton", "Create Ticket")
        )
      ),
      tabItem(
        tabName = "view",
        fluidPage(
          h2("View Tickets"),
          DTOutput("ticketTable")
        )
      ),
      tabItem(
        tabName = "status_chart",
        fluidPage(
          h2("Last 3 Months Ticket Status"),
          plotlyOutput("statusPlot")
        )
      )
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  observeEvent(input$createButton, {
    # Create a new ticket and add it to the data frame
    newTicket <- data.frame(
      TicketID = as.character(nrow(tickets) + 1),
      Title = input$title,
      Description = input$description,
      Status = input$status,
      AssignedTo = input$assignedTo,
      StartDate = as.character(input$startDate),
      EndDate = as.character(input$endDate),
      TimeTaken = as.numeric(difftime(input$endDate, input$startDate, units = "days"))
    )
    tickets <<- rbind(tickets, newTicket)
    
    # Reset the input fields
    updateTextInput(session, "title", value = "")
    updateTextAreaInput(session, "description", value = "")
    updateSelectInput(session, "status", selected = "Open")
    updateTextInput(session, "assignedTo", value = "")
    updateDateInput(session, "startDate", value = "")
    updateDateInput(session, "endDate", value = "")
  })
  
  output$ticketTable <- renderDT({
    # Display the ticket data frame as a DataTable
    datatable(tickets, options = list(pageLength = 10))
  })
  
  output$statusPlot <- renderPlotly({
    # Filter tickets for the last 3 months
    today <- as.Date(Sys.Date())
    three_months_ago <- today - 90  # 90 days represent approximately 3 months
    filtered_tickets <- tickets %>%
      filter(as.Date(StartDate) >= three_months_ago)
    
    # Create a summary table of ticket statuses
    status_summary <- filtered_tickets %>%
      group_by(Status) %>%
      summarise(Count = n())
    
    # Create a bar chart
    plot_ly(status_summary, x = ~Status, y = ~Count, type = "bar", marker = list(color = "blue")) %>%
      layout(title = "Ticket Status in the Last 3 Months", xaxis = list(title = "Status"), yaxis = list(title = "Count"))
  })
}

# Create the Shiny app
shinyApp(ui, server)
