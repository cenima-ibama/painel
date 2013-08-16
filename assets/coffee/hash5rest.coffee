class H5.Rest

  options:
    url: null
    restService: "ws_geo_attributequery.php"
    table: null
    fields: null
    parameters: null
    order: null
    limit: null
    lines: {}

  data: null

  constructor: (options) ->
    # If the url wasn't passed with a trailing /, add it.
    if options.url.substr(options.url.length - 1, 1) != "/"
      options.url += "/"

    # configure object with the options
    @options = $.extend({}, @options, options)

    @_request()

  _request: ->
    url = @options.url + "v1/" + @options.restService

    if @options.table then query = "&table=" + @options.table
    if @options.parameters then query += "&parameters=" + @options.parameters
    if @options.fields then query += "&fields=" + @options.fields
    if @options.order then query += "&order=" + @options.order
    if @options.limit then query += "&limit=" + @options.limit

    url = url + "?" + query

    @data = JSON.parse(@_getfile(url))

  _getfile: (url) ->
    if (window.XMLHttpRequest)
      AJAX=new XMLHttpRequest()
    else
      AJAX=new ActiveXObject("Microsoft.XMLHTTP")
    if (AJAX)
      AJAX.open("GET", url, false)
      AJAX.send(null)
      return AJAX.responseText
    else
      return false
