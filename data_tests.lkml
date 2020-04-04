# and another test!
test: historic_visit_count_is_accurate {
  explore_source: ga_sessions {
    column: visits_total {
      field: totals.visits_total
    }
    filters: {
      field: ga_sessions.partition_date
      value: "2019"
    }
  }
  assert: historic_visit_total_is_accurate {
    expression: ${totals.visits_total} = 697176 ;;
  }
}


test: dimension_channel_check {
  explore_source: ga_sessions {
    column: channelGrouping {
      field: ga_sessions.channelGrouping
    }
    filters: {
      field: ga_sessions.partition_date
      value: "7 days ago for 7 days"
    }
    filters: {
      field: ga_sessions.channelGrouping
      value: "Affiliates"
    }
  }
  assert: Affiliates_persists{
    expression: ${ga_sessions.channelGrouping} = "Affiliates";;
  }
}


test: join_check{
  explore_source: ga_sessions {
    column: session_count {
      field: ga_sessions.session_count
    }
    filters: {
      field: ga_sessions.partition_date
      value: "2019"
    }
  }
  assert: session_count_2019{
    expression: ${ga_sessions.session_count} = 697176;;
  }
}
