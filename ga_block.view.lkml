explore: ga_sessions_base {
  extension: required
#
  view_name: ga_sessions
  view_label: "Session"

  join: totals {
    view_label: "Session"
    sql: LEFT JOIN UNNEST([${ga_sessions.totals}]) as totals ;;
    relationship: one_to_one
  }

  join: trafficSource {
    view_label: "Session: Traffic Source"
    sql: LEFT JOIN UNNEST([${ga_sessions.trafficSource}]) as trafficSource ;;
    relationship: one_to_one
  }

  join: device {
    view_label: "Session: Device"
    sql: LEFT JOIN UNNEST([${ga_sessions.device}]) as device ;;
    relationship: one_to_one
  }

  join: geoNetwork {
    view_label: "Session: Geo Network"
    sql: LEFT JOIN UNNEST([${ga_sessions.geoNetwork}]) as geoNetwork ;;
    relationship: one_to_one
  }

  join: hits {
    view_label: "Session: Hits"
    sql: LEFT JOIN UNNEST(${ga_sessions.hits}) as hits ;;
    relationship: one_to_many
  }

  join: hits_page {
    view_label: "Session: Hits: Page"
    sql: LEFT JOIN UNNEST([${hits.page}]) as hits_page ;;
    relationship: one_to_one
  }

  join: hits_transaction {
    view_label: "Session: Hits: Transaction"
    sql: LEFT JOIN UNNEST([${hits.transaction}]) as hits_transaction ;;
    relationship: one_to_one
  }

  join: hits_item {
    view_label: "Session: Hits: Item"
    sql: LEFT JOIN UNNEST([${hits.item}]) as hits_item ;;
    relationship: one_to_one
  }

  join: hits_social {
    view_label: "Session: Hits: Social"
    sql: LEFT JOIN UNNEST([${hits.social}]) as hits_social ;;
    relationship: one_to_one
  }

  join: hits_product {
    view_label: "Session: Hits: Product"
    sql: LEFT JOIN UNNEST(${hits.product}) as hits_product ;;
    relationship: one_to_one
  }


  join: hits_publisher {
    view_label: "Session: Hits: Publisher"
    sql: LEFT JOIN UNNEST([${hits.publisher}]) as hits_publisher ;;
    relationship: one_to_one
  }

  join: hits_appInfo {
    view_label: "Session: Hits: App Info"
    sql: LEFT JOIN UNNEST([${hits.appInfo}]) as hits_appInfo ;;
    relationship: one_to_one
  }

  join: hits_eventInfo{
    view_label: "Session: Hits: Events Info"
    sql: LEFT JOIN UNNEST([${hits.eventInfo}]) as hits_eventInfo ;;
    relationship: one_to_one
  }

  # join: hits_sourcePropertyInfo {
  #   view_label: "Session: Hits: Property"
  #   sql: LEFT JOIN UNNEST([hits.sourcePropertyInfo]) as hits_sourcePropertyInfo ;;
  #   relationship: one_to_one
  #   required_joins: [hits]
  # }

  # join: hits_eCommerceAction {
  #   view_label: "Session: Hits: eCommerce"
  #   sql: LEFT JOIN UNNEST([hits.eCommerceAction]) as  hits_eCommerceAction;;
  #   relationship: one_to_one
  #   required_joins: [hits]
  # }

  join: hits_customDimensions {
    view_label: "Session: Hits: Custom Dimensions"
    sql: LEFT JOIN UNNEST(${hits.customDimensions}) as hits_customDimensions ;;
    relationship: one_to_many
  }
  join: hits_customVariables{
    view_label: "Session: Hits: Custom Variables"
    sql: LEFT JOIN UNNEST(${hits.customVariables}) as hits_customVariables ;;
    relationship: one_to_many
  }
  join: first_hit {
    from: hits
    sql: LEFT JOIN UNNEST(${ga_sessions.hits}) as first_hit ;;
    relationship: one_to_one
    sql_where: ${first_hit.hitNumber} = 1 ;;
    fields: [first_hit.page]
  }
  join: first_page {
    view_label: "Session: First Page Visited"
    from: hits_page
    sql: LEFT JOIN UNNEST([${first_hit.page}]) as first_page ;;
    relationship: one_to_one
  }
}

view: ga_sessions_base {
  extension: required

  dimension_group: partition {
    label: "Visit Start"
    timeframes: [date,day_of_week,fiscal_quarter,week,month,year,month_name,month_num,week_of_year]
    type: time
    sql: TIMESTAMP_ADD(TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'^\d\d\d\d\d\d\d\d'))), INTERVAL (date_diff(current_date(), cast('2017-08-01' as date), day)) DAY )  ;;
  }

  dimension_group: visitStart {
    label: "Visit Start"
    type: time
    datatype: epoch
    sql: ${TABLE}.visitStarttime ;;
    timeframes: [raw,time]
    hidden: no
  }

  dimension: id {
    primary_key: yes
    sql: CONCAT(CAST(${fullVisitorId} AS STRING), '|', COALESCE(CAST(${visitId} AS STRING),''), CAST(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'^\d\d\d\d\d\d\d\d'))   AS STRING)) ;;
  }
  dimension: visitorId {label: "Visitor ID"}

  dimension: visitnumber {
    label: "Visit Number"
    type: number
    description: "The session number for this user. If this is the first session, then this is set to 1."
  }

  dimension:  first_time_visitor {
    type: yesno
    sql: ${visitnumber} = 1 ;;
  }

  dimension: visitnumbertier {
    label: "Visit Number Tier"
    type: tier
    tiers: [1,2,5,10,15,20,50,100]
    style: integer
    sql: ${visitnumber} ;;
  }
  dimension: visitId {label: "Visit ID"}
  dimension: fullVisitorId {label: "Full Visitor ID"}

  dimension: visitStartSeconds {
    label: "Visit Start Seconds"
    type: date_time
    sql: TIMESTAMP_SECONDS(${TABLE}.visitStarttime) ;;
    hidden: yes
  }

  ## referencing partition_date for demo purposes only. Switch this dimension to reference visistStartSeconds
  dimension_group: visitStart {
    timeframes: [date,day_of_week,fiscal_quarter,week,month,year,month_name,month_num,week_of_year, hour12]
    label: "Visit Start"
    type: time
    sql: (TIMESTAMP(${visitStartSeconds})) ;;
  }
  ## use visit or hit start time instead
  dimension: date {
    hidden: yes
  }
  dimension: socialEngagementType {label: "Social Engagement Type"}
  dimension: userid {label: "User ID"}

  measure: session_count {
    type: count
    filters: {
      field: hits.isInteraction
      value: "yes"
    }
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.transactions_count, totals.transactionRevenue_total]
  }
  measure: unique_visitors {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: average_sessions_ver_visitor {
    type: number
    sql: 1.0 * (${session_count}/NULLIF(${unique_visitors},0))  ;;
    value_format_name: decimal_2
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: total_visitors {
    type: count
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: first_time_visitors {
    label: "First Time Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "1"
    }
  }

  measure: second_time_visitors {
    label: "Second Time Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "2"
    }
  }


  measure: returning_visitors {
    label: "Returning Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "<> 1"
    }
  }

  dimension: channelGrouping {label: "Channel Grouping"}

  # subrecords
  dimension: geoNetwork {hidden: yes}
  dimension: totals {hidden:yes}
  dimension: trafficSource {hidden:yes}
  dimension: device {hidden:yes}
  dimension: customDimensions {hidden:yes}
  dimension: hits {hidden:yes}
  dimension: hits_eventInfo {hidden:yes}

}


view: geoNetwork_base {
  extension: required
  dimension: continent {
    drill_fields: [subcontinent,country,region,city,metro,approximate_networkLocation,networkLocation]
  }
  dimension: subcontinent {
    drill_fields: [country,region,city,metro,approximate_networkLocation,networkLocation]

  }
  dimension: country {
    map_layer_name: countries
    drill_fields: [region,metro,city,approximate_networkLocation,networkLocation]
  }
  dimension: region {
    drill_fields: [metro,city,approximate_networkLocation,networkLocation]
  }
  dimension: metro {
    drill_fields: [city,approximate_networkLocation,networkLocation]
  }
  dimension: city {drill_fields: [metro,approximate_networkLocation,networkLocation]}
  dimension: cityid { label: "City ID"}
  dimension: networkDomain {label: "Network Domain"}
  dimension: latitude {
    type: number
    hidden: yes
    sql: CAST(${TABLE}.latitude as FLOAT64);;
  }
  dimension: longitude {
    type: number
    hidden: yes
    sql: CAST(${TABLE}.longitude as FLOAT64);;
  }
  dimension: networkLocation {label: "Network Location"}
  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }
  dimension: approximate_networkLocation {
    type: location
    sql_latitude: ROUND(${latitude},1) ;;
    sql_longitude: ROUND(${longitude},1) ;;
    drill_fields: [networkLocation]
  }
}


view: totals_base {
  extension: required
  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${ga_sessions.id} ;;
  }
  measure: visits_total {
    type: sum
    sql: ${TABLE}.visits ;;
  }
  measure: hits_total {
    type: sum
    sql: ${TABLE}.hits ;;
    drill_fields: [hits.detail*]
  }
  measure: hits_average_per_session {
    type: number
    sql: 1.0 * ${hits_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }
  measure: pageviews_total {
    label: "Page Views"
    type: sum
    sql: ${TABLE}.pageviews ;;
  }
  measure: timeonsite_total {
    label: "Time On Site"
    type: sum
    sql: ${TABLE}.timeonsite ;;
  }
  dimension: timeonsite_tier {
    label: "Time On Site Tier"
    type: tier
    sql: ${TABLE}.timeonsite ;;
    tiers: [0,15,30,60,120,180,240,300,600]
    style: integer
  }
  measure: timeonsite_average_per_session {
    label: "Time On Site Average Per Session"
    type: number
    sql: 1.0 * ${timeonsite_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }

  measure: page_views_session {
    label: "PageViews Per Session"
    type: number
    sql: 1.0 * ${pageviews_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }

  measure: bounces_total {
    type: sum
    sql: ${TABLE}.bounces ;;
  }
  measure: bounce_rate {
    type:  number
    sql: 1.0 * ${bounces_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: percent_2
  }
  measure: transactions_count {
    type: sum
    sql: ${TABLE}.transactions ;;
  }
  measure: transactionRevenue_total {
    label: "Transaction Revenue Total"
    type: sum
    sql: (${TABLE}.transactionRevenue/1000000) ;;
    value_format_name: usd_0
    drill_fields: [transactions_count, transactionRevenue_total]
  }
  measure: newVisits_total {
    label: "New Visits Total"
    type: sum
    sql: ${TABLE}.newVisits ;;
  }
  measure: screenViews_total {
    label: "Screen Views Total"
    type: sum
    sql: ${TABLE}.screenViews ;;
  }
  measure: timeOnScreen_total{
    label: "Time On Screen Total"
    type: sum
    sql: ${TABLE}.timeOnScreen ;;
  }
  measure: uniqueScreenViews_total {
    label: "Unique Screen Views Total"
    type: sum
    sql: ${TABLE}.uniqueScreenViews ;;
  }
  dimension: timeOnScreen_total_unique{
    label: "Time On Screen Total"
    type: number
    sql: ${TABLE}.timeOnScreen ;;
  }
}


view: trafficSource_base {
  extension: required

# dimension: adwords {}
  dimension: referralPath {label: "Referral Path"}
  dimension: campaign {}
  dimension: source {}
  dimension: medium {}
  dimension: keyword {}
  dimension: adContent {label: "Ad Content"}
  measure: source_list {
    type: list
    list_field: source
  }
  measure: source_count {
    type: count_distinct
    sql: ${source} ;;
    drill_fields: [source, totals.hits, totals.pageviews]
  }
  measure: keyword_count {
    type: count_distinct
    sql: ${keyword} ;;
    drill_fields: [keyword, totals.hits, totals.pageviews]
  }
  # Subrecords
#   dimension: adwordsClickInfo {}
}

view: adwordsClickInfo_base {
  extension: required
  dimension: campaignId {label: "Campaign ID"}
  dimension: adGroupId {label: "Ad Group ID"}
  dimension: creativeId {label: "Creative ID"}
  dimension: criteriaId {label: "Criteria ID"}
  dimension: page {type: number}
  dimension: slot {}
  dimension: criteriaParameters {label: "Criteria Parameters"}
  dimension: gclId {}
  dimension: customerId {label: "Customer ID"}
  dimension: adNetworkType {label: "Ad Network Type"}
  dimension: targetingCriteria {label: "Targeting Criteria"}
  dimension: isVideoAd {
    label: "Is Video Ad"
    type: yesno
  }
}

view: device_base {
  extension: required

  dimension: browser {}
  dimension: browserVersion {label:"Browser Version"}
  dimension: operatingSystem {label: "Operating System"}
  dimension: operatingSystemVersion {label: "Operating System Version"}
  dimension: deviceCategory { label:"Device Category" description:"mobile,tablet,desktop"}
  dimension: isMobile {type: yesno label: "Is Mobile" sql: ${deviceCategory} in ('mobile','tablet') ;; }
  dimension: isDesktop {type: yesno label: "Is Desktop" sql: ${deviceCategory} = 'desktop' ;; }
  dimension: flashVersion {label: "Flash Version"}
  dimension: javaEnabled {
    label: "Java Enabled"
    type: yesno
  }
  dimension: language {}
  dimension: screenColors {label: "Screen Colors"}
  dimension: screenResolution {label: "Screen Resolution"}
  dimension: mobileDeviceBranding {label: "Mobile Device Branding"}
  dimension: mobileDeviceInfo {label: "Mobile Device Info"}
  dimension: mobileDeviceMarketingName {label: "Mobile Device Marketing Name"}
  dimension: mobileDeviceModel {label: "Mobile Device Model"}
  dimension: mobileInputSelector {label: "Mobile Input Selector"}
}

view: hits_base {
  extension: required
  dimension: id {
    primary_key: yes
    sql: CONCAT(${ga_sessions.id},'|',FORMAT('%05d',${hitNumber})) ;;
  }
  dimension: hitNumber {}
  dimension: time {}
  dimension_group: hit {
    timeframes: [date,day_of_week,fiscal_quarter,week,month,year,month_name,month_num,week_of_year]
    type: time
    sql: TIMESTAMP_MILLIS(1000 * ${ga_sessions.visitStart_raw} + ${TABLE}.time)  ;;
  }
  dimension: hour {}
  dimension: minute {}
  dimension: isSecure {
    label: "Is Secure"
    type: yesno
  }
  dimension: isInteraction {
    label: "Is Interaction"
    type: yesno
    description: "If this hit was an interaction, this is set to true. If this was a non-interaction hit (i.e., an event with interaction set to false), this is false."
  }
  dimension: referer {}

  measure: count {
    type: count
    drill_fields: [hits.detail*]
  }

  # subrecords
  dimension: page {hidden:yes}
  dimension: transaction {hidden:yes}
  dimension: item {hidden:yes}
  dimension: contentinfo {hidden:yes}
  dimension: social {hidden: yes}
  dimension: publisher {hidden: yes}
  dimension: appInfo {hidden: yes}
  dimension: contentInfo {hidden: yes}
  dimension: customDimensions {hidden: yes}
  dimension: customMetrics {hidden: yes}
  dimension: customVariables {hidden: yes}
  dimension: ecommerceAction {hidden: yes}
  dimension: eventInfo {hidden:yes}
  dimension: exceptionInfo {hidden: yes}
  dimension: experiment {hidden: yes}
  dimension: product { hidden: yes}

  set: detail {
    fields: [ga_sessions.id, ga_sessions.visitnumber, ga_sessions.session_count, hits_page.pagePath, hits.pageTitle]
  }
}

view: hits_page_base {
  extension: required
  dimension: pagePath {
    label: "Page Path"
    link: {
      label: "Link"
      url: "{{ value }}"
    }
    link: {
      label: "Page Info Dashboard"
      url: "/dashboards/101?Page%20Path={{ value | encode_uri}}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }
  dimension: hostName {label: "Host Name"}
  dimension: pageTitle {label: "Page Title"}
  dimension: searchKeyword {label: "Search Keyword"}
  dimension: searchCategory{label: "Search Category"}
}

view: hits_transaction_base {
  extension: required

  dimension: id {
    primary_key: yes
    sql: ${hits.id} ;;
  }
  dimension: transactionShipping {label: "Transaction Shipping"}
  dimension: affiliation {}
  dimension: currencyCode {label: "Currency Code"}
  dimension: localTransactionRevenue {label: "Local Transaction Revenue"}
  dimension: localTransactionTax {label: "Local Transaction Tax"}
  dimension: localTransactionShipping {label: "Local Transaction Shipping"}
}

view: hits_item_base {
  extension: required

  dimension: id {
    primary_key: yes
    sql: ${hits.id} ;;
  }
  dimension: transactionId {label: "Transaction ID"}
  dimension: productName {
    label: "Product Name"
    }

  dimension: productCategory {label: "Product Catetory"}
  dimension: productSku {label: "Product Sku"}

  dimension: itemQuantity {
    description: "Should only be used as a dimension"
    label: "Item Quantity"
    hidden: yes
    }
  dimension: itemRevenue {
    description: "Should only be used as a dimension"
    label: "Item Revenue"
    hidden: yes
    }
  dimension: currencyCode {label: "Currency Code"}
  dimension: localItemRevenue {
    label:"Local Item Revenue"
    description: "Should only be used as a dimension"
    }

  measure: product_count {
    type: count_distinct
    sql: ${productSku} ;;
    drill_fields: [productName, productCategory, productSku, total_item_revenue]
  }
}

view: hits_product_base {
  extension: required

  dimension: product_sku {
    type: string
    sql: ${TABLE}.productSKU ;;
  }

  dimension: v2_product_name {
    type: string
    sql: ${TABLE}.v2ProductName ;;
  }

  dimension: v2_product_category {
    type: string
    sql: ${TABLE}.v2ProductCategory ;;
  }

  dimension: product_variant {
    type: string
    sql: ${TABLE}.productVariant ;;
  }

  dimension: product_brand {
    type: string
    sql: ${TABLE}.productBrand ;;
  }

  dimension: product_revenue {
    type: number
    sql: ${TABLE}.productRevenue ;;
  }

  dimension: local_product_revenue {
    type: number
    sql: ${TABLE}.localProductRevenue ;;
  }

  dimension: product_price {
    type: number
    sql: ${TABLE}.productPrice ;;
  }

  dimension: local_product_price {
    type: number
    sql: ${TABLE}.localProductPrice ;;
  }

  dimension: product_quantity {
    type: number
    sql: ${TABLE}.productQuantity ;;
  }

  dimension: product_refund_amount {
    type: number
    sql: ${TABLE}.productRefundAmount ;;
  }

  dimension: local_product_refund_amount {
    type: number
    sql: ${TABLE}.localProductRefundAmount ;;
  }

  dimension: is_impression {
    type: string
    sql: ${TABLE}.isImpression ;;
  }

  dimension: is_click {
    type: string
    sql: ${TABLE}.isClick ;;
  }

  dimension: custom_dimensions {
    hidden: yes
    type: string
    sql: ${TABLE}.customDimensions ;;
  }

  dimension: custom_metrics {
    hidden: yes
    type: string
    sql: ${TABLE}.customMetrics ;;
  }

  dimension: product_list_name {
    type: string
    sql: ${TABLE}.productListName ;;
  }

  dimension: product_list_position {
    type: number
    sql: ${TABLE}.productListPosition ;;
  }

  dimension: product_coupon_code {
    type: string
    sql: ${TABLE}.productCouponCode ;;
  }

}

view: hits_social_base {
  extension: required   ## THESE FIELDS WILL ONLY BE AVAILABLE IF VIEW "hits_social" IN GA CUSTOMIZE HAS THE "extends" parameter declared

  dimension: socialInteractionNetwork {label: "Social Interaction Network"}
  dimension: socialInteractionAction {label: "Social Interaction Action"}
  dimension: socialInteractions {label: "Social Interactions"}
  dimension: socialInteractionTarget {label: "Social Interaction Target"}
  dimension: socialNetwork {label: "Social Network"}
  dimension: uniqueSocialInteractions {
    label: "Unique Social Interactions"
    type: number
  }
  dimension: hasSocialSourceReferral {label: "Has Social Source Referral"}
  dimension: socialInteractionNetworkAction {label: "Social Interaction Network Action"}
}

view: hits_publisher_base {
  extension: required    ## THESE FIELDS WILL ONLY BE AVAILABLE IF VIEW "hits_publisher" IN GA CUSTOMIZE HAS THE "extends" parameter declared

  dimension: dfpClicks {}
  dimension: dfpImpressions {}
  dimension: dfpMatchedQueries {}
  dimension: dfpMeasurableImpressions {}
  dimension: dfpQueries {}
  dimension: dfpRevenueCpm {}
  dimension: dfpRevenueCpc {}
  dimension: dfpViewableImpressions {}
  dimension: dfpPagesViewed {}
  dimension: adsenseBackfillDfpClicks {}
  dimension: adsenseBackfillDfpImpressions {}
  dimension: adsenseBackfillDfpMatchedQueries {}
  dimension: adsenseBackfillDfpMeasurableImpressions {}
  dimension: adsenseBackfillDfpQueries {}
  dimension: adsenseBackfillDfpRevenueCpm {}
  dimension: adsenseBackfillDfpRevenueCpc {}
  dimension: adsenseBackfillDfpViewableImpressions {}
  dimension: adsenseBackfillDfpPagesViewed {}
  dimension: adxBackfillDfpClicks {}
  dimension: adxBackfillDfpImpressions {}
  dimension: adxBackfillDfpMatchedQueries {}
  dimension: adxBackfillDfpMeasurableImpressions {}
  dimension: adxBackfillDfpQueries {}
  dimension: adxBackfillDfpRevenueCpm {}
  dimension: adxBackfillDfpRevenueCpc {}
  dimension: adxBackfillDfpViewableImpressions {}
  dimension: adxBackfillDfpPagesViewed {}
  dimension: adxClicks {}
  dimension: adxImpressions {}
  dimension: adxMatchedQueries {}
  dimension: adxMeasurableImpressions {}
  dimension: adxQueries {}
  dimension: adxRevenue {}
  dimension: adxViewableImpressions {}
  dimension: adxPagesViewed {}
  dimension: adsViewed {}
  dimension: adsUnitsViewed {}
  dimension: adsUnitsMatched {}
  dimension: viewableAdsViewed {}
  dimension: measurableAdsViewed {}
  dimension: adsPagesViewed {}
  dimension: adsClicked {}
  dimension: adsRevenue {}
  dimension: dfpAdGroup {}
  dimension: dfpAdUnits {}
  dimension: dfpNetworkId {}
}

view: hits_appInfo_base {
  extension: required

  dimension: name {}
  dimension: version {}
  dimension: id {}
  dimension: installerId {}
  dimension: appInstallerId {}
  dimension: appName {}
  dimension: appVersion {}
  dimension: appId {}
  dimension: screenName {}
  dimension: landingScreenName {}
  dimension: exitScreenName {}
  dimension: screenDepth {}
}

view: contentInfo_base {
  extension: required
  dimension: contentDescription {}
}

view: hits_customDimensions_base {
  extension: required
  dimension: index {type:number}
  dimension: value {}
}

view: hits_customMetrics_base {
  extension: required

  dimension: index {type:number}
  dimension: value {}
}

view: hits_customVariables_base {
  extension: required
  dimension: customVarName {}
  dimension: customVarValue {}
  dimension: index {type:number}
}

view: hits_eCommerceAction_base {
  extension: required
  dimension: action_type {}
  dimension: option {}
  dimension: step {}
}

view: hits_eventInfo_base {
  extension: required
  dimension: eventCategory {label: "Event Category"}

  dimension: eventAction {label: "Event Action"}
  dimension: eventLabel {label: "Event Label"}
  dimension: eventValue {label: "Event Value"}

}

# view: hits_sourcePropertyInfo {
# #   extension: required
#   dimension: sourcePropertyDisplayName {label: "Property Display Name"}
# }
