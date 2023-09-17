library(shiny)
library(shinydashboard)
library(DT)

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
      menuItem("View Tickets", tabName = "view")
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
      TimeTaken = as.numeric(difftime(input$endDate, input$startDate, units = "hours"))
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
}

# Create the Shiny app
shinyApp(ui, server)
