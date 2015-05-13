Clarat.GMaps =
  initialize: -> # callback for when maps script is loaded from google
    Clarat.GMaps.initializeMap()
    Clarat.GMaps.initializePlacesAutocomplete()

  initializeMap: ->
    canvas = document.getElementById('map-canvas')
    markers = $(canvas).data('markers')
    infowindow = new (google.maps.InfoWindow)({ maxWidth: 200 })
    includedPoints = []

    if markers
      # Create Map
      mapOptions =
        scrollwheel: false
      map = new google.maps.Map(canvas, mapOptions)
      bounds = new google.maps.LatLngBounds()

      # Create Markers
      for key, markerData of markers
        continue unless markerData.position
        markerPosition = new google.maps.LatLng(
          markerData.position.latitude,
          markerData.position.longitude
        )
        marker = new google.maps.Marker
          position: markerPosition
          map: map
          icon: '/assets/gmaps_marker_1.svg'

        includedPoints.push markerPosition
        bounds.extend markerPosition

        # Bind Event Listeners To Marker
        Clarat.GMaps.bindMapsEvents map, marker, markerData, infowindow
        Clarat.GMaps.bindMarkerToResults marker, markerData, infowindow

      # Get User Position
      userPosition = $(canvas).data('position')
      if userPosition
        # Include User Position in Map
        userPosition = new google.maps.LatLng(
          userPosition.latitude,
          userPosition.longitude
        )
        # if not exact location as only other marker
        unless includedPoints.length is 1 and
               userPosition.toString() == includedPoints[0].toString()
          includedPoints.push userPosition
          bounds.extend userPosition

      # Expand Map to Include All Markers
      if includedPoints.length > 1
        map.fitBounds bounds
      else
        map.setCenter bounds.getCenter()
        map.setZoom 15

  initializePlacesAutocomplete: ->
    location_input = document.getElementById('search_form_search_location')
    if location_input
      # autocomplete settings
      opts =
        bounds: new google.maps.LatLngBounds(
          new google.maps.LatLng(53, 14),
          new google.maps.LatLng(52, 12.5)
        )
        types: ['geocode']
        language: 'de'
        componentRestrictions:
          country: 'de'

      # instantiate autocomplete field
      Clarat.placesAutocomplete =
        new google.maps.places.Autocomplete location_input, opts

      # register event listener that pushes to GA when field is changed by user
      google.maps.event.addListener Clarat.placesAutocomplete, 'place_changed', ->
        Clarat.Analytics.placesAutocompleteChanged()

  bindMapsEvents: (map, marker, markerData, infowindow) ->
    if not markerData.organization_display_name # if is organization
      contentString =
        HoganTemplates['map_info_window_organization'].render(markerData)
    else if markerData.ids[1] != undefined
      contentString =
        HoganTemplates['map_info_window_multiple'].render
          title: I18n.t 'js.map_info_window_multiple.title'
          text: I18n.t 'js.map_info_window_multiple.text'
          anchor: I18n.t 'js.map_info_window_multiple.anchor'
          url: Clarat.GMaps.generate_exact_search_url markerData.position
    else
      contentString = HoganTemplates['map_info_window_offer'].render(markerData)

    google.maps.event.addListener marker, 'click', (event) ->
      map.setCenter marker.getPosition()
      infowindow.close()
      infowindow.setContent contentString;
      infowindow.open map, this

    google.maps.event.addListener map, 'click', (event) ->
      infowindow.close()

  generate_exact_search_url: (position) ->
    location.origin + location.pathname + $.query.set(
      'search_form[generated_geolocation]',
      "#{position.latitude},#{position.longitude}"
    ).set(
      'search_form[exact_location]', 't'
    ).toString()

  bindMarkerToResults: (marker, markerData) ->
    for offerID in markerData.ids
      $("#result-offer-#{offerID}").data('marker', marker)
