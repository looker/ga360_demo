



view: custom_events {

  extension: required





  # measure: add_to__cart {
  #   label: "Add to Cart"
  #   group_label: "Enhanced Ecommerce"
  #   type: count
  #   filters__all: [
  #     {
  # field: eventAction
  # value: "Add to Cart"
  # }
  #   ]
  # }

  measure: onsite__click {
    label: "Onsite Click"
    group_label: "Contact Us"
    type: count
    filters: [eventAction: "Onsite Click"]
  }

  measure: product__click {
    label: "Product Click"
    group_label: "Enhanced Ecommerce"
    type: count
    filters: [eventAction: "Product Click"]
  }

  measure: promotion__click {
    label: "Promotion Click"
    group_label: "Enhanced Ecommerce"
    type: count
    filters: [eventAction: "Promotion Click"
    ]
  }

  measure: quickview__click {
    label: "Quickview Click"
    group_label: "Enhanced Ecommerce"
    type: count
    filters: [eventAction: "Quickview Click"
    ]
  }

  measure: remove_from__cart {
    label: "Remove from Cart"
    group_label: "Enhanced Ecommerce"
    type: count
    filters: [eventAction: "Remove from Cart"
    ]
  }

}
