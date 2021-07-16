if (!require(shiny.router)) {
  install.packages("shiny.router")
}

source("home_page.R")
source("dash_page.R")
source("about_page.R")

router <- make_router(route("/", home_page),
                      route("dashboard", dash_page),
                      route("about", about_page))

source("navbar_component.R")




