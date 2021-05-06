test: channel_grouping_not_null {
  #Make sure no null channel groupings come through
  explore_source: ga_sessions {
    column: channelGrouping {}
    filters: {
      field: ga_sessions.partition_date
      value: "2020"
    }
  }
  assert: historic_visit_total_is_accurate {
    expression: NOT is_null(${ga_sessions.channelGrouping})
 ;;
  }
}

test: hostname_check {
  # make sure another GA property isn't hooked up by accident
  explore_source: ga_sessions {
    column: hostname {
      field: hits_page.hostName
    }
    filters: {
      field: ga_sessions.partition_date
      value: "7 days ago for 7 days"
    }
  }
  assert: hostname_is_correct {
    expression: ${hits_page.hostName} = "www.googlemerchandisestore.com" OR ${hits_page.hostName} = "shop.googlemerchandisestore.com";;
  }
}


test: fanout_check{
  explore_source: ga_sessions {
    column: session_count {
      field: ga_sessions.session_count
    }
    filters: {
      field: ga_sessions.partition_date
      value: "this year"
    }
  }
  assert: not_crazy_numbers {
    expression: NOT ${ga_sessions.session_count} > 20000000;;
  }
}
