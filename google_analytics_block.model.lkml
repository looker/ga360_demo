connection: "gaming_demo"

# include all the views
include: "*.view*"
include: "data_tests.lkml"

# include all the dashboards
# include: "*.dashboard"

explore: ga_sessions {
  label: "GA 360 Sessions"
  extends: [ga_sessions_block]
}
