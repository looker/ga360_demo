connection: "lookerdata"

# include all the views
include: "/z_ga360_pharma/*.view*"
# include: "data_tests.lkml"

# include all the dashboards
# include: "*.dashboard"

explore: ga_sessions {
  label: "GA 360 Sessions (Pharma)"
  extends: [ga_sessions_block]
}
