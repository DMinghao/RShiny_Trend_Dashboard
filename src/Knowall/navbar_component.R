navbar <-
  tags$nav(
    class = "navbar navbar-expand-lg navbar-dark bg-dark fixed-top",
    tags$a(class = "navbar-brand  mb-0 h1",
           href = route_link("/"),
           "KNOWALL"),
    tags$button(class = "navbar-toggler",
                type = "button",
                "data-toggle" = "collapse",
                "data-target" = "#navbarText",
                "aria-controls" = "navbarText",
                "aria-expanded" = "false",
                "aria-label" = "Toggle navigation",
                tags$span(class = "navbar-toggler-icon")), 
    tags$div(
      class = "collapse navbar-collapse",
      id = "navbarText",
      tags$ul(
        class = "navbar-nav mr-auto",
        tags$li(class = "nav-item",
                tags$a(
                  class = "nav-link",
                  href = route_link("/"),
                  "Home"
                )),
        tags$li(class = "nav-item",
                tags$a(
                  class = "nav-link",
                  href = route_link("dashboard"), "Dashboard"
                )),
        tags$li(class = "nav-item",
                tags$a(
                  class = "nav-link",
                  href = route_link("about"), "About"
                ))
        # tags$li(class = "nav-item",
        #         tags$a(
        #           class = "nav-link",
        #           href = route_link("code"), "Code"
        #         ))
      ),
      tags$span(class = "navbar-text",
                "By Team Knowall")
    )
  )
