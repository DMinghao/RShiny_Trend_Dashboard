source("home_page.R")
source("dash_page.R")
source("about_page.R")

router <- make_router(
  route("/", home_page),
  route("dashboard", dash_page),
  route("about", about_page)
  # route(
  #   "code",
  #   tags$div(class = "embed-responsive embed-responsive-16by9",
  #            tags$script(src = "https://unpkg.com/@ungap/custom-elements-builtin"),
  #            tags$script(type = "module",
  #                        src = "x-frame-bypass.js"),
  #            tags$iframe(class = "embed-responsive-item",
  #                        is = "x-frame-bypass",
  #                        # seamless="seamless", 
  #                        src = "https://github.com/DMinghao/RShiny_Trend_Dashboard"
  #                        # allowfullscreen = TRUE
  #                        )
  #            )
  #   # tags$iframe(seamless = "seamless",src = "https://github.com/DMinghao/RShiny_Trend_Dashboard", width = 1400)
  # )
)

source("navbar_component.R")
