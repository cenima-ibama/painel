H5.Map =
  base: null
  layer: {}
  layerList: null

H5.Leaflet = {}

# H5.Leaflet.VectorLayer {{{
# this Project is a fork from the LeafletVectorlayers from Json Sanfora
H5.Leaflet.Layer = L.Class.extend(
  # Default options for all layers
  options:
    scaleRange: null
    map: null
    cluster: false
    uniqueField: null
    visibleAtScale: true
    dynamic: false
    autoUpdate: false
    autoUpdateInterval: null
    popupTemplate: null
    popupOptions: {}
    singlePopup: false
    symbology: null
    showAll: false
    focus: false
    above: false

  initialize: (options) ->
    L.Util.setOptions this, options

  # Show this layer on the map provided
  setMap: (map) ->
    return if map and @options.map
    if map
      @options.map = map
      if @options.scaleRange and @options.scaleRange instanceof Array and @options.scaleRange.length is 2
        z = @options.map.getZoom()
        sr = @options.scaleRange
        @options.visibleAtScale = (z >= sr[0] and z <= sr[1])
      @_show()
    else if @options.map
      @_hide()
      @options.map = map

  # Get the map (if any) that the layer has been added to
  getMap: ->
    @options.map

  setOptions: (options) ->
    L.Util.setOptions this, options

  redraw: ->
    @_hide()
    @_show()

  _show: ->
    @_addIdleListener()
    @_addZoomChangeListener() if @options.scaleRange and @options.scaleRange instanceof Array and @options.scaleRange.length is 2
    if @options.visibleAtScale
      if @options.autoUpdate and @options.autoUpdateInterval
        @_autoUpdateInterval = setInterval(=>
          @_getFeatures()
        , @options.autoUpdateInterval)
      @options.map.fire("moveend").fire "zoomend"

  _hide: ->
    if @_idleListener
      @options.map.off "moveend", @_idleListener
    if @_zoomChangeListener
      @options.map.off "zoomend", @_zoomChangeListener
    if @_autoUpdateInterval
      clearInterval @_autoUpdateInterval
    @_lastQueriedBounds = null
    if @_gotAll
      @_gotAll = false
    @_clearFeatures()

  # Hide the vectors in the layer. This might get called if the layer is still on but out of scaleRange.
  _hideVectors: ->
    @options.map.removeLayer(@layer)

  # Show the vectors in the layer. This might get called if the layer is on and came back into scaleRange.
  _showVectors: ->
    # add to map
    @layer.addTo(@options.map)

  # Hide the vectors, then empty the vectory holding array
  _clearFeatures: ->
    @_vectors = []
    @layer.clearLayers()

  # Add an event hanlder to detect a zoom change on the map
  _addZoomChangeListener: ->
    # "this" means something different inside the on method. Assign it to "me".
    @_zoomChangeListener = @_zoomChangeListenerTemplate()
    @options.map.on "zoomend", @_zoomChangeListener, this

  _zoomChangeListenerTemplate: ->
    # Whenever the map's zoom changes, check the layer's visibility (this.options.visibleAtScale)
    return =>
      @_checkLayerVisibility()

  # This gets fired when the map is panned or zoomed
  _idleListenerTemplate: ->
    return =>
      if @options.visibleAtScale
        # Do they use the showAll para@er to load all features once?
        if @options.showAll
          # Have we already loaded these features
          if not @_gotAll
            # Grab the features and note that we've already loaded them (no need to _getFeatures again
            @_getFeatures()
            @_gotAll = true
        else
          @_hide()
          @_getFeatures()

  # Add an event hanlder to detect an idle (pan or zoom) on the map
  _addIdleListener: ->
    # "this" means something different inside the on method.
    @_idleListener = @_idleListenerTemplate()
    # Whenever the map idles (pan or zoom) get the features in the current map extent
    @options.map.on "moveend", @_idleListener, this

  # Get the current map zoom and check to see if the layer should still be visible
  _checkLayerVisibility: ->
    # Store current visibility so we can see if it changed
    visibilityBefore = @options.visibleAtScale

    # Check current map scale and see if it's in this layer's range
    z = @options.map.getZoom()
    sr = @options.scaleRange
    @options.visibleAtScale = (z >= sr[0] and z <= sr[1])

    # Check to see if the visibility has changed
    if visibilityBefore isnt @options.visibleAtScale
      # It did, hide or show vectors
      this[(if @options.visibleAtScale then "_showVectors" else "_hideVectors")]()

    # Check to see if we need to set or clear any intervals for auto-updating layers
    if visibilityBefore and not @options.visibleAtScale and @_autoUpdateInterval
      clearInterval @_autoUpdateInterval
    else if not visibilityBefore and @options.autoUpdate and @options.autoUpdateInterval
      @_autoUpdateInterval = setInterval(->
        @_getFeatures()
      , @options.autoUpdateInterval)

  # Set the Popup content for the feature
  _setPopupContent: (feature) ->

    # Store previous Popup content so we can check to see if it changed. If it didn't no sense changing the content as this has an ugly flashing effect.
    previousContent = feature.popupContent
    atts = feature.properties
    popupContent = undefined

    # Check to see if it's a string-based popupTemplate or function
    if typeof @options.popupTemplate is "string"
      # Store the string-based popupTemplate
      popupContent = @options.popupTemplate
      # Loop through the properties and replace mustache-wrapped property names with actual values
      for prop of atts
        re = new RegExp("{" + prop + "}", "g")
        popupContent = popupContent.replace(re, atts[prop])
    else if typeof @options.popupTemplate is "function"
      # It's a function-based popupTempmlate, so just call this function and pass properties
      popupContent = @options.popupTemplate(atts)
    else
      # Ummm, that's all we support. Seeya!
      return

    # Store the Popup content
    feature.popupContent = popupContent

    # Check to see if popupContent has changed and if so setContent
    if feature.popup
      # The Popup is associated with a feature
      feature.popup.setContent feature.popupContent if feature.popupContent isnt previousContent
    # The Popup is associated with the layer (singlePopup: true)
    else if @popup and @popup.associatedFeature is feature
      if feature.popupContent isnt previousContent
        @popup.setContent feature.popupContent

  # Show the feature's (or layer's) Popup
  _showPopup: (feature, event) ->

    # Popups on Lines and Polygons are opened slightly different, make note of it
    isLineOrPolygon = event.latlng

    # Set the popupAnchor if a marker was clicked
    if not isLineOrPolygon
      L.Util.extend @options.popupOptions,
        offset: event.target.options.icon.options.popupAnchor

    # Create a variable to hold a reference to the object that owns the Popup so we can show it later
    ownsPopup = undefined

    # If the layer isn't set to show a single Popup
    if not @options.singlePopup
      # Create a Popup and store it in the feature
      feature.popup = new L.Popup(@options.popupOptions, feature.vector)
      ownsPopup = feature
    else
      if @popup
        # If the layer already has an Popup created, close and delete it
        @options.map.removeLayer @popup
        @popup = null

      # Create a new Popup
      @popup = new L.Popup(@options.popupOptions, feature.vector)
      # Store the associated feature reference in the Popup so we can close and clear it later
      @popup.associatedFeature = feature
      ownsPopup = this

    ownsPopup.popup.setLatLng (if isLineOrPolygon then event.latlng else event.target.getLatLng())
    ownsPopup.popup.setContent feature.popupContent
    @options.map.addLayer ownsPopup.popup

  # Optional click event
  _fireClickEvent: (feature, event) ->
    @options.clickEvent feature, event

  # Optional mouseover event
  _fireMouseoverEvent: (feature, event) ->
    @options.mouseoverEvent feature, event

  # Optional mouseout event
  _fireMouseoutEvent: (feature, event) ->
    @options.mouseoutEvent feature, event

  # Get the appropriate Leaflet vector options for this feature
  _getFeatureVectorOptions: (feature) ->

    # Create an empty vectorStyle object to add to, or leave as is if no symbology can be found
    vectorStyle = {}
    atts = feature.properties

    # Is there a symbology set for this layer?
    if @options.symbology
      switch @options.symbology.type
        when "single"
          # It's a single symbology for all features so just set the key/value pairs in vectorStyle
          for key of @options.symbology.vectorStyle
            vectorStyle[key] = @options.symbology.vectorStyle[key]
            if vectorStyle.title
              for prop of atts
                re = new RegExp("{" + prop + "}", "g")
                vectorStyle.title = vectorStyle.title.replace(re, atts[prop])
        when "unique"
          # It's a unique symbology. Check if the feature's property value matches that in the symbology and style accordingly
          att = @options.symbology.property
          for i in [0 ... @options.symbology.values.length]
            if atts[att] is @options.symbology.values[i].value
              for key of @options.symbology.values[i].vectorStyle
                vectorStyle[key] = @options.symbology.values[i].vectorStyle[key]
                if vectorStyle.title
                  for prop of atts
                    re = new RegExp("{" + prop + "}", "g")
                    vectorStyle.title = vectorStyle.title.replace(re, atts[prop])
        when "range"
          # It's a range symbology. Check if the feature's property value is in the range set in the symbology and style accordingly
          att = @options.symbology.property
          for i in [0 ... @options.symbology.ranges.length]
            if atts[att] >= @options.symbology.ranges[i].range[0] and atts[att] <= @options.symbology.ranges[i].range[1]
              for key of @options.symbology.ranges[i].vectorStyle
                vectorStyle[key] = @options.symbology.ranges[i].vectorStyle[key]
                if vectorStyle.title
                  for prop of atts
                    re = new RegExp("{" + prop + "}", "g")
                    vectorStyle.title = vectorStyle.title.replace(re, atts[prop])
    return vectorStyle

  # Check to see if any attributes have changed
  _getPropertiesChanged: (oldAtts, newAtts) ->
    changed = false
    for key of oldAtts
      changed = true unless oldAtts[key] is newAtts[key]
    changed

  # Check to see if a particular property changed
  _getPropertyChanged: (oldAtts, newAtts, property) ->
    (oldAtts[property] isnt newAtts[property])

  # Check to see if the geometry has changed
  _getGeometryChanged: (oldGeom, newGeom) ->

    # TODO: make this work for points, linestrings and polygons
    changed = false

    # For now only checking for point changes
    if oldGeom.coordinates[0] isnt newGeom.coordinates[0] or oldGeom.coordinates[1] isnt newGeom.coordinates[1]
      changed = true

    return changed

  _makeJsonpRequest: (url) ->
    $.ajax
      url: url
      type: "GET"
      dataType: "jsonp"
      crossDomain: true
      success: (data) =>
        @_processRequest(data)
      error: (xhr, status, error) ->
        console.log "Failed URL request: " + error

  _processRequest: (json) ->
    data = {}
    data.features = []
    data.total = json.length
    data.type = "FeatureCollection" # Not really necessary, but let's follow the GeoJSON spec for a Feature
    # convert data to make it look like a GeoJSON FeatureCollection
    for i in [0 ... json.length]
      data.features[i] = {}
      data.features[i].type = "Feature" # Not really necessary, but let's follow the GeoJSON spec for a Feature
      data.features[i].properties = {}
      for prop of json[i]
        if prop is "geojson"
          data.features[i].geometry = JSON.parse(json[i].geojson)
        else data.features[i].properties[prop] = json[i][prop] unless prop is "properties"

    # remove json data
    json = null
    @_processFeatures data

  _processFeatures: (data) ->

    # Sometimes requests take a while to come back and
    # the user might have turned the layer off
    return unless @options.map
    bounds = @options.map.getBounds()

    # Check to see if the _lastQueriedBounds is the same as the new bounds
    # If true, don't bother querying again.
    return if @_lastQueriedBounds and @_lastQueriedBounds.equals(bounds) and not @options.autoUpdate

    # Store the bounds in the _lastQueriedBounds member so we don't have
    # to query the layer again if someone simply turns a layer on/off
    @_lastQueriedBounds = bounds

    # add to map
    @layer.addTo(@options.map)

    # If "data.features" exists and there's more than one feature in the array
    if data and data.features and data.features.length

      # Loop through the return features
      for i in [0 ... data.features.length]
        # All objects are assumed to be false until proven true (remember COPS?)
        onMap = false
        # If we have a "uniqueField" for this layer
        if @options.uniqueField
          # Loop through all of the features currently on the map
          for j in [0 ... @_vectors.length]
            # Does the "uniqueField" property for this feature match the feature on the map
            if data.features[i].properties[@options.uniqueField] is @_vectors[j].properties[@options.uniqueField]
              # The feature is already on the map
              onMap = true
              # We're only concerned about updating layers that are dynamic (options.dynamic = true).
              if @options.dynamic
                # The feature's geometry might have changed, let's check.
                if @_getGeometryChanged(@_vectors[j].geometry, data.features[i].geometry)
                  # Check to see if it's a point feature, these are the only ones we're updating for now
                  if not isNaN(data.features[i].geometry.coordinates[0]) and not isNaN(data.features[i].geometry.coordinates[1])
                    @_vectors[j].geometry = data.features[i].geometry
                    @_vectors[j].vector.setLatLng new L.LatLng(@_vectors[j].geometry.coordinates[1], @_vectors[j].geometry.coordinates[0])

                propertiesChanged = @_getPropertiesChanged(@_vectors[j].properties, data.features[i].properties)

                if propertiesChanged
                  symbologyPropertyChanged = @_getPropertyChanged(@_vectors[j].properties, data.features[i].properties, @options.symbology.property)
                  @_vectors[j].properties = data.features[i].properties
                  if @options.popupTemplate
                    @_setPopupContent @_vectors[j]
                  if @options.symbology and @options.symbology.type isnt "single" and symbologyPropertyChanged
                    if @_vectors[j].vectors
                      for k in [0 ... @_vectors[j].vectors.length]
                        if @_vectors[j].vectors[k].setStyle
                          # It's a LineString or Polygon, so use setStyle
                          @_vectors[j].vectors[k].setStyle @_getFeatureVectorOptions(@_vectors[j])
                        # It's a Point, so use setIcon
                        else @_vectors[j].vectors[k].setIcon @_getFeatureVectorOptions(@_vectors[j]).icon if @_vectors[j].vectors[k].setIcon
                    else if @_vectors[j].vector
                      if @_vectors[j].vector.setStyle
                        # It's a LineString or Polygon, so use setStyle
                        @_vectors[j].vector.setStyle @_getFeatureVectorOptions(@_vectors[j])
                      # It's a Point, so use setIcon
                      else @_vectors[j].vector.setIcon @_getFeatureVectorOptions(@_vectors[j]).icon if @_vectors[j].vector.setIcon

        if not onMap or not @options.uniqueField
          geometry = data.features[i].geometry
          geometryOptions = @_getFeatureVectorOptions(data.features[i])
          # Convert GeoJSON to Leaflet vector (Point, Polyline, Polygon)
          vector_or_vectors = @_geoJsonGeometryToLeaflet(geometry, geometryOptions)
          data.features[i][(if vector_or_vectors instanceof Array then "vectors" else "vector")] = vector_or_vectors

          # Store the vector in an array
          @_vectors.push data.features[i]

          # Add vector or vectors on the map
          if @_vectors[i].vector
            @layer.addLayer @_vectors[i].vector
          else if @_vectors[i].vectors and @_vectors[i].vectors.length
            for k in [0 ... @_vectors[i].vectors.length]
              @layer.addLayer @_vectors[i].vectors[k]

          if @options.popupTemplate
            me = this
            feature = data.features[i]
            @_setPopupContent feature
            ((feature) ->
              if feature.vector
                feature.vector.on "click", (event) ->
                  me._showPopup feature, event
              else if feature.vectors
                for k in [0 ... feature.vectors.length]
                  feature.vectors[k].on "click", (event) ->
                    me._showPopup feature, event
            ) feature

          if @options.clickEvent
            me = this
            feature = data.features[i]
            ((feature) ->
              if feature.vector
                feature.vector.on "click", (event) ->
                  me._fireClickEvent feature, event
              else if feature.vectors
                for k in [0 ... feature.vectors.length]
                  feature.vectors[k].on "click", (event) ->
                    me._fireClickEvent feature, event
            ) feature

          if @options.mouseoverEvent
            me = this
            feature = data.features[i]
            ((feature) ->
              if feature.vector
                feature.vector.on "mouseover", (event) ->
                  me._fireMouseoverEvent feature, event
              else if feature.vectors
                for k in [0 ... feature.vectors.length]
                  feature.vectors[k].on "mouseover", (event) ->
                    me._fireMouseoverEvent feature, event
            ) feature

          if @options.mouseoutEvent
            me = this
            feature = data.features[i]
            ((feature) ->
              if feature.vector
                feature.vector.on "mouseout", (event) ->
                  me._fireMouseoutEvent feature, event
              else if feature.vectors
                for k in [0 ... feature.vectors.length]
                  feature.vectors[k].on "mouseout", (event) ->
                    me._fireMouseoutEvent feature, event
            ) feature

    if @options.above
      @layer.eachLayer((layer) ->
        if layer.setZIndexOffset
          layer.setZIndexOffset(1000)
      )

    if @options.focus
      @options.map.fitBounds(@layer.getBounds())

    # clean unused data
    data = null
)

# Extend Layer to support GeoJSON geometry parsing
# Convert GeoJSON to Leaflet vectors
H5.Leaflet.GeoJSONLayer = H5.Leaflet.Layer.extend(

  _geoJsonGeometryToLeaflet: (geometry, opts) ->
    # Create a variable for a single vector and for multi part vectors.
    vector = undefined
    vectors = undefined
    switch geometry.type
      when "Point"
        if opts.circleMarker
          vector = new L.CircleMarker(new L.LatLng(geometry.coordinates[1], geometry.coordinates[0]), opts)
        else
          vector = new L.Marker(new L.LatLng(geometry.coordinates[1], geometry.coordinates[0]), opts)
      when "MultiPoint"
        vectors = []
        for i in [0 ... geometry.coordinates.length]
          vectors.push new L.Marker(new L.LatLng(geometry.coordinates[i][1], geometry.coordinates[i][0]), opts)
      when "LineString"
        latlngs = []
        for i in [0 ... geometry.coordinates.length]
          latlngs.push new L.LatLng(geometry.coordinates[i][1], geometry.coordinates[i][0])
        vector = new L.Polyline(latlngs, opts)
      when "MultiLineString"
        vectors = []
        for i in [0 ... geometry.coordinates.length]
          latlngs = []
          for j in [0 ... geometry.coordinates[i].length]
            latlngs.push new L.LatLng(geometry.coordinates[i][j][1], geometry.coordinates[i][j][0])
          vectors.push new L.Polyline(latlngs, opts)
      when "Polygon"
        latlngss = []
        for i in [0 ... geometry.coordinates.length]
          latlngs = []
          for j in [0 ... geometry.coordinates[i].length]
            latlngs.push new L.LatLng(geometry.coordinates[i][j][1], geometry.coordinates[i][j][0])
          latlngss.push latlngs
        vector = new L.Polygon(latlngss, opts)
      when "MultiPolygon"
        vectors = []
        for i in [0 ... geometry.coordinates.length]
          latlngss = []
          for j in [0 ... geometry.coordinates[i].length]
            latlngs = []
            for k in [0 ... geometry.coordinates[i][j].length]
              latlngs.push new L.LatLng(geometry.coordinates[i][j][k][1], geometry.coordinates[i][j][k][0])
            latlngss.push latlngs
          vectors.push new L.Polygon(latlngss, opts)
      when "GeometryCollection"
        vectors = []
        for i in [0 ... geometry.coordinates.length]
          vectors.push @_geoJsonGeometryToLeaflet(geometry.geometries[i], opts)

    vector or vectors
)

H5.Leaflet.Postgis = H5.Leaflet.GeoJSONLayer.extend(
  initialize: (options) ->

    # Check for required parameters
    for i in [0 ... @_requiredParams.length]
      if not options[@_requiredParams[i]]
        throw new Error("No \"" + @_requiredParams[i] + "\" parameter found.")

    # If the url wasn't passed with a trailing /, add it.
    options.url += "/" if options.url.substr(options.url.length - 1, 1) isnt "/"

    # Extend Layer to create Postgis
    H5.Leaflet.Layer::initialize.call this, options

    # _globalPointer is a string that points to a global function variable
    # Features returned from a JSONP request are passed to this function
    @_globalPointer = "Postgis_" + @options.geotable + "_" + @options.geomFieldName
    window[@_globalPointer] = this

    # Create an array to hold the features
    @_vectors = []

    if @options.cluster
      # Create a cluster layer
      @layer = new L.MarkerClusterGroup()
    else
      # create layer to group all vectors
      @layer = new L.featureGroup()

    if @options.map
      if @options.scaleRange and @options.scaleRange instanceof Array and @options.scaleRange.length is 2
        z = @options.map.getZoom()
        sr = @options.scaleRange
        @options.visibleAtScale = (z >= sr[0] and z <= sr[1])
      @_show()

  options:
    geotable: null
    srid: null
    geomFieldName: "the_geom"
    fields: null
    where: null
    limit: 5000
    uniqueField: null

  _requiredParams: ["url", "geotable"]
  
  _getFeatures: ->

    # Build Query
    where = (if (@options.where) then "&parameters=" + encodeURIComponent(@options.where) else "")
    if not @options.showAll
      bounds = @options.map.getBounds()
      sw = bounds.getSouthWest()
      ne = bounds.getNorthEast()
      where += (if where.length then " AND " else "")
      if @options.srid
        where += encodeURIComponent("st_setsrid(" + @options.geomFieldName + "," + @options.srid + ") && st_setsrid(st_makebox2d(st_point(" + sw.lng + "," + sw.lat + "),st_point(" + ne.lng + "," + ne.lat + "))," + @options.srid + ")")
      else
        where += encodeURIComponent("" + @options.geomFieldName + " && st_setsrid(st_makebox2d(st_point(" + sw.lng + "," + sw.lat + "),st_point(" + ne.lng + "," + ne.lat + "))")

    # Build fields
    fields = ((if @options.fields then @options.fields else "*")) + ", st_asgeojson(" + @options.geomFieldName + "" + ((if @options.geomPrecision then "," + @options.geomPrecision else "")) + ") as geojson"

    # Build URL
    url = @options.url + "v1/ws_geo_attributequery.php" + "?table=" + @options.geotable + "&fields=" + encodeURIComponent(fields) + where + "&limit=" + @options.limit

    # JSONP request
    @_makeJsonpRequest url
)
H5.Leaflet.Geoserver = H5.Leaflet.GeoJSONLayer.extend(
  initialize: (options) ->
    i = 0
    len = @_requiredParams.length

    while i < len
      throw new Error("No \"" + @_requiredParams[i] + "\" parameter found.")  unless options[@_requiredParams[i]]
      i++
    lvector.Layer::initialize.call this, options
    @_globalPointer = "Geoserver_" + Math.floor(Math.random() * 100000)
    window[@_globalPointer] = this
    @_vectors = []
    if @options.map
      if @options.scaleRange and @options.scaleRange instanceof Array and @options.scaleRange.length is 2
        z = @options.map.getZoom()
        sr = @options.scaleRange()
        @options.visibleAtScale = (z >= sr[0] and z <= sr[1])
      @_show()

  options:
    baseUrl: null
    typeName: null
    uniqueField: null

  _requiredParams: ["baseUrl", "typeName", "uniqueField"]

  _getFeatures: ->

    url = @options.baseUrl.replace(/\?$/, "") + "?service=WFS&version=1.1.0&request=GetFeature&typeName=" + @options.typeName + "&outputFormat=json&format_options=callback:" + @_globalPointer + "._processRequest"
    url += "&bbox=" + @options.map.getBounds().toBBoxString() unless @options.showAll
    @_makeJsonpRequest url
)
# }}}
# H5.Leaflet.RapidEyeTMS {{{
class H5.Leaflet.RapidEyeTMS
  options:
    url: null
    table: null
    numberOfLayers: 4

  constructor: (options) ->
    # create object for the tiles
    @listLayers = []
    @layers = {}
    @layerGroup = []
    @count = 1

    # configure object with the options
    L.setOptions this, options

    @_createTMSLayers()
    @_loadGeoJSON()
    @_addToLayerControl()

  _onEachFeature: (feature, layer) ->

    popupContent = "<p>I started out as a GeoJSON " + feature.geometry.type + ", but now I'm a Leaflet vector!</p>"
    popupContent += feature.properties.popupContent  if feature.properties and feature.properties.popupContent

    layer.bindPopup popupContent

    #load TMS on mouseover or click
    layer.on "mouseover click", (e) ->

      # get the tile URL
      tmsUrl = feature.properties.url_tiles + "{z}/{x}/{y}.png"

      # remove border
      layer.setStyle
        fillColor: "transparent"
        stroke: false

      if @_checkLayer(layer._leaflet_id)

        # add tile inside polygon
        @layers[@count].setUrl tmsUrl
        @layers[@count].redraw()

        # add layer id to the list of layers
        @listLayers.push layer._leaflet_id

        # compare if number of tiles is bigger then the
        # number of layers
        @listLayers.shift() if @listLayers.length > @options.numberOfLayers

        # make next tile avaliable
        @count++

        # if the tile number is bigger then the number of layers
        # reset the controller
        @count = 1 if @count > @options.numberOfLayers

    # restore style when leave
    layer.on "mouseout", (e) ->

      # restore style
      layer.setStyle stroke: true

  _createTMSLayers: ->
    # create number of layers to display the tms
    i = 1
    while i <= @options.numberOfLayers
      @layers[i] = new L.TileLayer("",
        minZoom: 3
        maxZoom: 17
        tms: true
      )
      # add layer to list of layers
      @layerGroup.push @layers[i]
      i++

  _checkLayer: (layerId) ->
    # check if the layer is already loaded
      for i in [0 ... @listLayers.length]
        return false if layerId is @listLayers[i]
      return true

  _loadGeoJSON: ->
    #request data from the server
    rest = new H5.PgRest {
      url: @options.url
      table: @options.table
    }
    # load geojson data
    @_vectors = L.geoJson(rest.request(),
      style:
        fillColor: "transparent"
        color: "purple"
        weight: 4

      onEachFeature: @_onEachFeature
    )

  _addToLayerControl: ->
    # create a group of layers and add then to the layers list
    rapidEyeLayer = new L.LayerGroup(@layerGroup)
    rapidEyeLayer.addLayer @_vectors
    if H5.Map.layerList then H5.Map.layerList.addLayer rapidEyeLayer, "RapidEye"
# }}}
# H5.Leaflet.LayerControl {{{
H5.Leaflet.LayerControl = L.Control.extend (
  options:
    collapsed: true
    position: "topright"
    autoZIndex: true

  initialize: (baseLayers, overlayers, options) ->
    L.setOptions this, options
    @_layers = {}
    @_lastZIndex = 0
    @_handlingClick = false
    $.each baseLayers, (name, obj) =>
      @_addLayer(obj.layer, name, false, false)

    $.each overlayers, (name, obj) =>
      control = if (typeof obj.overlayControl is "boolean") then obj.overlayControl else true
      @_addLayer(obj.layer, name, true, control)

  onAdd: (map) ->
    @_initLayout()
    @_update()
    map
      .on("layeradd", @_onLayerChange, this)
      .on("layerremove", @_onLayerChange, this)
    return @_container

  onRemove: (map) ->
    map
      .off("layeradd", @_onLayerChange)
      .off("layerremove", @_onLayerChange)

  addBaseLayer: (layer, name) ->
    @_addLayer layer, name
    @_update()
    return this

  addOverLayer: (layer, name, overlayControl) ->
    @_addLayer layer, name, true, overlayControl
    @_update()
    return this

  removeLayer: (layer) ->
    id = L.stamp(layer)
    delete @_layers[id]

    @_update()
    return this

  _initLayout: ->
    className = "switch-control-layers"
    container = @_container = L.DomUtil.create("div", "leaflet-bar " + className)

		# Makes this work on IE10 Touch devices by stopping it from firing a mouseout event when the touch is released
    container.setAttribute('aria-haspopup', true)

    unless L.Browser.touch
      L.DomEvent.disableClickPropagation container
      L.DomEvent.on(container, "mousewheel", L.DomEvent.stopPropagation)
    else
      L.DomEvent.on(container, "click", L.DomEvent.stopPropagation)

    form = @_form = L.DomUtil.create("form", className + "-list form-layer-list")

    if @options.collapsed
      L.DomEvent
        .on(container, "mouseover", @_expand, this)
        .on(container, "mouseout", @_collapse, this)

      link = @_layersLink = L.DomUtil.create("a", className + "-toggle", container)
      link.href = "#"
      link.title = "Layers"

      if L.Browser.touch
        L.DomEvent
          .on(link, "click", L.DomEvent.stop)
          .on(link, "click", @_expand, this)
      else
        L.DomEvent.on(link, "focus", @_expand, this)

      @_map.on("click", @_collapse, this)
    else
      @_expand()

    @_baseLayersList = L.DomUtil.create('div', className + '-base', form)
    @_separator = L.DomUtil.create('div', className + '-separator', form)
    @_overlayersList = L.DomUtil.create('div', className + '-overlayers', form)
    $(container).append form
    

  _addLayer: (layer, name, overlayer, overlayControl) ->
    id = L.stamp(layer)

    @_layers[id] =
      layer: layer
      name: name
      overlayer: overlayer
      overlayControl: overlayControl

    if @options.autoZIndex and layer.setZIndex
      @_lastZIndex++
      layer.setZIndex @_lastZIndex

  _update: ->
    return unless @_container

    @_baseLayersList.innerHTML = ""
    @_overlayersList.innerHTML = ""

    baseLayersPresent = false
    overlayersPresent = false

    for i of @_layers
      obj = @_layers[i]
      @_addItem obj
      overlayersPresent = overlayersPresent or obj.overlayer
      baseLayersPresent = baseLayersPresent or not obj.overlayer

      @_separator.style.display = (if overlayersPresent and baseLayersPresent then "" else "none")

  _onLayerChange: (e) ->
    obj = @_layers[L.stamp(e.layer)]

    return unless obj

    @_update() unless @_handlingClick

    type = (if obj.overlayer then ((if e.type is "layeradd" then "overlayeradd" else "overlayerremove")) else ((if e.type is "layeradd" then "baselayerchange" else null)))

    @_map.fire(type, obj) if type

  _addItem: (obj) ->
    container = (if obj.overlayer then @_overlayersList else @_baseLayersList)
    controlgroup = L.DomUtil.create("div", "control-group", container)
    checked = @_map.hasLayer(obj.layer)

    # layer name
    label = L.DomUtil.create("label", "control-label", controlgroup)
    if H5.isMobile.any() or obj.name.length < 12
      label.innerHTML = obj.name
    else
      name =  obj.name.substr(0,12) + "…"
      label.innerHTML = "<abbr title=\"" + obj.name + "\">" + name + "</abbr>"

    control = L.DomUtil.create("div", "control", controlgroup)
    toggle = L.DomUtil.create("div", "switch-small", control)
    $(toggle).addClass("baseLayers") unless obj.overlayer
    input = L.DomUtil.create("input", "", toggle)
    if not H5.isMobile.any() and obj.overlayer
      input.type = "checkbox"
      $(input).addClass("switch-control-layers-selector")

      # insert slider, but exclude from touch devices
      if obj.overlayControl
        slider = L.DomUtil.create("div", "", controlgroup)
        $(slider).addClass("switch-control-layers-slider")
        $(slider).slider
          min: 0
          max: 100
          value: 100
          range: "min"
          slide: (event, ui) ->
            obj.layer.eachLayer( (layer) =>
              if layer.setOpacity
                layer.Opacity (ui.value/100)
              else
                layer.setStyle (
                  fillOpacity: ui.value/100
                  opacity: ui.value/100
                )
            )
    else
      input.type = "radio"
      $(input).attr("name", "leaflet-base-layers")
    input.defaultChecked = checked
    input.layerId = L.stamp(obj.layer)

    # create switch
    $(toggle).bootstrapSwitch()

    $(toggle).on "switch-change", (e, data) =>
      unless obj.overlayer
        $('.baseLayers').bootstrapSwitch('toggleRadioState')
      @_onInputClick input, obj

    return controlgroup

  _onInputClick: (input, obj) ->
    @_handlingClick = true

    if input.checked and not @_map.hasLayer(obj.layer)
      @_map.addLayer obj.layer
    else
      unless input.checked and @_map.hasLayer(obj.layer)
        @_map.removeLayer obj.layer

    @_handlingClick = false

  _expand: ->
    L.DomUtil.addClass @_form, "switch-control-layers-expanded"

  _collapse: ->
    @_form.className = @_form.className.replace(" switch-control-layers-expanded", "")
)
# }}}
