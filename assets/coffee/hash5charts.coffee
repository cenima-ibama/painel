google.load "visualization", "1",
  packages: ["corechart"]

google.load "visualization", "1",
  packages: ["gauge"]

google.load "visualization", "1",
  packages: ["table"]

H5.Charts = {}

class H5.Charts.Container

  options:
    type: null
    container: null
    period: 1
    title: ""
    defaultClass: ""
    selects: undefined
    resizing: 0
    buttons:
      minusplus: false
      arrows: false
      table: false
      export: false
      minimize: false
      maximize: false
      close: false

  constructor: (options) ->
    # configure object with the options
    @options = $.extend({}, @options, options)
    @_createContainer()

  changeTitle: (title) ->
    $(@_boxTitle).html(title)
    if @options.buttons.arrows or @options.buttons.minusplus or @options.selects?
      pipeline = "<span class=\"break\"></span>"
      $(@_boxTitle).prepend pipeline

  _createContainer: ->
    @_container = document.getElementById(@options.container)

    boxHeader = document.createElement("div")
    boxHeader.className = "box-header"
    @_boxHeader = boxHeader

    boxTitle = document.createElement("h2")
    boxTitle.innerHTML = @options.title
    @_boxTitle = boxTitle

    leftCtrl = document.createElement("div")
    leftCtrl.className = "btn-group chart-icon btn-left"
    @_leftCtrl = leftCtrl

    rightCtrl = document.createElement("div")
    rightCtrl.className = "btn-group chart-icon btn-right"
    @_rightCtrl = rightCtrl

    boxContent = document.createElement("div")
    boxContent.id = "box-" + @options.container
    boxContent.className = "box-content"
    @_boxContent = boxContent

    $(@_boxHeader).append @_leftCtrl, @_boxTitle, @_rightCtrl
    $(@_container).append @_boxHeader, @_boxContent

    pipeline = "<span class=\"break\"></span>"
    # add minus and plus controllers
    if @options.buttons.minusplus
      # add break
      $(@_boxTitle).prepend pipeline
      # add buttons
      delBtn = document.createElement("button")
      delBtn.id = @options.container + "-btn-minus"
      delBtn.setAttribute 'title', 'Remover último Período'
      delBtn.className = "btn"
      @_delBtn = delBtn

      delIcon = document.createElement("i")
      delIcon.className = "icon-minus"
      @_delIcon = delIcon
      $(@_delBtn).append @_delIcon

      addBtn = document.createElement("button")
      addBtn.id = @options.container + "-btn-plus"
      addBtn.setAttribute 'title', 'Adicionar novo Período'
      addBtn.className = "btn"
      @_addBtn = addBtn

      addIcon = document.createElement("i")
      addIcon.className = "icon-plus"
      @_addIcon = addIcon
      $(@_addBtn).append @_addIcon

      $(@_leftCtrl).append @_delBtn, @_addBtn

    else if @options.buttons.arrows
      # add break
      $(@_boxTitle).prepend pipeline
      # right buttons
      leftBtn = document.createElement("button")
      leftBtn.id = @options.container + "-btn-left"
      leftBtn.className = "btn"
      @_leftBtn = leftBtn

      leftIcon = document.createElement("i")
      leftIcon.className = "icon-arrow-left"
      @_leftIcon = leftIcon
      $(@_leftBtn).append @_leftIcon

      rightBtn = document.createElement("button")
      rightBtn.id = @options.container + "-btn-right"
      rightBtn.className = "btn"
      @_rightBtn = rightBtn

      rightIcon = document.createElement("i")
      rightIcon.className = "icon-arrow-right"
      @_rightIcon = rightIcon
      $(@_rightBtn).append @_rightIcon

      $(@_leftCtrl).append @_leftBtn, @_rightBtn

    else if @options.selects?
      # add break
      $(@_boxTitle).prepend pipeline
      # create form
      formBtn = document.createElement("form")
      formBtn.name = "form-" + @options.container
      formBtn.className = "form-inline"
      @_formBtn = formBtn

      for name, options of @options.selects
        select = "<select id=\"" + name + "Slct\" class=\"input-mini\" name=\"" + name + "\">"
        for value, key of options
          select += "<option value=" + value + ">" + key + "</option>"
        select += "</select>"
        $(@_formBtn).append select

      $(@_leftCtrl).append @_formBtn
      $(@_leftCtrl).removeClass "btn-group"

      for name, data of @options.selects
        @["_" + name + "Slct"] = document["form-" + @options.container][name]
        @_enableSelect("#" + name + "Slct")

    if @options.buttons.table

      # add table button
      tableBtn = document.createElement("button")
      tableBtn.id = @options.container + "-btn-table"
      tableBtn.className = "btn"
      tableBtn.setAttribute 'title', 'Tabela de Dados'
      @_tableBtn = tableBtn

      tableIcon = document.createElement("i")
      tableIcon.className = "icon-table"
      @_tableIcon = tableIcon
      $(@_tableBtn).append @_tableIcon

      $(@_rightCtrl).append @_tableBtn

      boxTable = document.createElement("div")
      boxTable.id = "table-" + @options.container
      boxTable.className = "box-content-table"
      @_boxTable = boxTable
      $(@_container).append @_boxTable

      @_enableTable()

    if @options.buttons.export

      # add export button
      exportBtn = document.createElement("button")
      exportBtn.id = @options.container + "-btn-export"
      exportBtn.setAttribute 'title', 'Exportar Dados'
      exportBtn.className = "btn"
      @_exportBtn = exportBtn

      exportIcon = document.createElement("i")
      exportIcon.className = "icon-download-alt"
      @_exportIcon = exportIcon
      $(@_exportBtn).append @_exportIcon

      $(@_rightCtrl).append @_exportBtn

      @_enableExport()

    if @options.buttons.minimize

      # add minimize button
      minBtn = document.createElement("button")
      minBtn.id = @options.container + "-btn-minimize"
      minBtn.setAttribute 'title', 'Esconder/Mostrar Gráfico'
      minBtn.className = "btn"
      @_minBtn = minBtn

      minIcon = document.createElement("i")
      minIcon.className = "icon-chevron-up"
      @_minIcon = minIcon
      $(@_minBtn).append @_minIcon

      $(@_rightCtrl).append @_minBtn

      @_enableMinimize()

    if @options.buttons.maximize

      # add minimize button
      maxBtn = document.createElement("button")
      maxBtn.id = @options.container + "-btn-maximize"
      maxBtn.setAttribute 'title', 'Ativar/Desativar Tela Cheia'
      maxBtn.className = "btn"
      @_maxBtn = maxBtn

      maxIcon = document.createElement("i")
      maxIcon.className = "icon-resize-full"
      @_maxIcon = maxIcon
      $(@_maxBtn).append @_maxIcon

      $(@_rightCtrl).append @_maxBtn

      @_enableMaximize()

    if @options.buttons.close

      # add minimize button
      closeBtn = document.createElement("button")
      closeBtn.id = @options.container + "-btn-close"
      closeBtn.className = "btn"
      @_closeBtn = closeBtn

      closeIcon = document.createElement("i")
      closeIcon.className = "icon-remove"
      @_closeIcon = closeIcon
      $(@_closeBtn).append @_closeIcon

      $(@_rightCtrl).append @_closeBtn

      @_enableClose()

  _enableMinimize: ->
    $(@_minBtn).on "click", (event) =>
      event.preventDefault()

      if $(@_boxContent).is(":visible")
        @_minIcon.className = "icon-chevron-down"
        if @options.buttons.minusplus
          $(@_addBtn).prop "disabled", true
          $(@_delBtn).prop "disabled", true
        else if @options.buttons.arrows
          $(@_leftBtn).prop "disabled", true
          $(@_rightBtn).prop "disabled", true
      else
        @_minIcon.className = "icon-chevron-up"
        if @options.buttons.minusplus
          $(@_addBtn).prop "disabled", false
          $(@_delBtn).prop "disabled", false
        else if @options.buttons.arrows
          $(@_leftBtn).prop "disabled", false
          $(@_rightBtn).prop "disabled", false

      if $(@_boxTable).is(":visible")
        $(@_boxTable).slideToggle("fast", "linear")

      $(@_boxContent).slideToggle("fast", "linear")

  _enableMaximize: ->
    $(@_maxBtn).on "click", (event) =>
      event.preventDefault()

      if @_maxIcon.className is "icon-resize-full"
        @defaultClass = @_container.className
        $(@_minBtn).prop "disabled", true
        $(@_closeBtn).prop "disabled", true
        @_maxIcon.className = "icon-resize-small"
        $("#navbar").hide()
      else
        $(@_minBtn).prop "disabled", false
        $(@_closeBtn).prop "disabled", false
        @_maxIcon.className = "icon-resize-full"
        $("#navbar").show()

      # always hide the charttable div
      $(@_boxTable).hide()
      $(@_boxTable).toggleClass "box-table-overlay"
      @_tableIcon.className = "icon-table"

      $(@_container).toggleClass @defaultClass
      $(@_container).toggleClass "box-overlay"
      $("body").toggleClass "body-overlay"

      $(@_boxContent).toggleClass "content-overlay"
      $(@_boxTable).toggleClass "content-overlay"
      $(@_boxContent).hide()
      $(@_boxContent).fadeToggle(500, "linear")

      @drawChart()

  _enableClose: ->
    $(@_closeBtn).on "click", (event) =>
      event.preventDefault()
      $(@_container).hide("slide", "linear", 600)

  _enableSelect: (select) ->
    $(select).on "change", (event) =>
      @drawChart()

  # _loadingScreen: (message)->
  #   if @_boxContent
  #     document.getElementById(@_boxContent.id).innerHTML = message

class H5.Charts.GoogleCharts extends H5.Charts.Container

  constructor: ->
    super
    @createChart()

  createDataTable: ->
    @data = new google.visualization.DataTable()

  createChart: ->
    # setup new chart
    if @options.type is "Gauge"
      @chart = new google.visualization.Gauge(
        @_boxContent
      )
    else
      @chart = new google.visualization[@options.type + "Chart"](
        @_boxContent
      )
    @_detectScreenChanges()

  _detectScreenChanges: ->
    # Detect whether device supports orientationchange event,
    # otherwise fall back to the resize event.
    supportsOrientationChange = "onorientationchange" of window
    orientationEvent = (if supportsOrientationChange then "orientationchange" else "resize")

    # update chart if orientation or the size of the screen changed
    window.addEventListener orientationEvent, (=>
      if $(@_boxContent).is(":visible") and not @options.resizing
        @options.resizing = true
        @drawChart()
        @options.resizing = false
    ),false

  _enableTable: ->

    $(@_tableBtn).on "click", (event) =>
      event.preventDefault()

      if $(@_boxContent).is(":hidden")
        @_minIcon.className = "icon-chevron-up"
        $(@_boxContent).fadeToggle('fast', 'linear')

      $(@_boxTable).fadeToggle('fast', 'linear')

      # update values
      if @_tableIcon.className is "icon-table"
        @_tableIcon.className = "icon-bar-chart"
        visualization = new google.visualization.Table(
          @_boxTable
        )
        visualization.draw @data, null
      else
        @_tableIcon.className = "icon-table"

      $(@_leftBtn).add(@_rightBtn).add(@_addBtn).add(@_delBtn).on "click", (event) =>
        if $(@_boxTable).is(":visible")
          # Create and draw the visualization.
          visualization = new google.visualization.Table(
            @_boxTable
          )
          visualization.draw @data, null

  _enableExport: ->

    # generate csv from the @data file
    generateCSV = =>

      str = ""
      line = ""

      # get the title of table
      for col in [0...@data.getNumberOfColumns()]
        title = @data.getColumnLabel(col)
        line += "\"" + title + "\","

      # create a new line
      str += line + "\r\n"

      # get data for the rows
      for row in [0...@data.getNumberOfRows()]
        line = ""
        for col in [0...@data.getNumberOfColumns()]
          value = @data.getFormattedValue(row, col)
          line += "\"" + value + "\","
        str += line + "\r\n"

      return str

    $(@_exportBtn).click ->
      csv = generateCSV()
      window.open "data:text/csv;charset=utf-8," + escape(csv)

class H5.Charts.SmallContainer

  options:
    type: null
    container: null
    title: ""
    popover: false

  constructor: (options) ->
    # configure object with the options
    @options = $.extend({}, @options, options)
    @_createContainer()

  _createContainer: ->
    @_container = document.getElementById(@options.container)

    leftCtrl = document.createElement("div")
    leftCtrl.className = "left"
    @_leftCtrl = leftCtrl

    rightCtrl = document.createElement("div")
    rightCtrl.className = "right"
    @_rightCtrl = rightCtrl

    $(@_container).append @_leftCtrl, @_rightCtrl

    if @options.popover
      $(@_container).addClass("popover-" + @options.container)
      @_createPopover()

  _createPopover: ->
    placement = "bottom"
    trigger = "hover"
    html = true
    $(".popover-" + @options.container).popover
      placement: placement
      delay: {show: 700, hide: 300}
      content: "<span>" + @options.popover + "</span>"
      trigger: trigger
      html: html

class H5.Charts.Knobs extends H5.Charts.SmallContainer

  updateInfo: (value) ->
    $(@_rightCtrl).html("<strong>" + value + "%</strong><br/> " + @options.title)
    @_updateChart(parseFloat(value))

  _createContainer: ->
    super
    dial = document.createElement("input")
    dial.type = "text"
    dial .className = "dial"
    @_dial = dial
    $(@_leftCtrl).append @_dial

    @_createChart()

  _createChart: ->
    $(@_dial).knob(
      min:-100
      max:100
      bgColor: "#DEDEDE"
      fgColor: "#DEDEDE"
      angleOffset:-125
      angleArc:250
      readOnly: true
      width: 58
      height: 58
      thickness: 0.5
      displayInput: false
      color: @options.color
      draw: ->
        value = @val()
        _min = @o.min
        _max = @o.max
        if @o.color is "coldtohot"
          if _min <= value <= _min*0.3 then color = pusher.color("#67C2EF")
          else if _min*0.3 < value <= _max*0.3 then color = pusher.color("#CBE968")
          else if _max*0.3 < value <= _max*0.7 then color = pusher.color("#FABB3D")
          else if _max*0.7 < value <=  _max*0.9 then color = pusher.color("#FA603D")
          else color = pusher.color("#FF5454")
        else
          if value <= 0 then color = pusher.color("#D0FC3F")
          else if 0 < value <= _max*0.6 then color = pusher.color("#FCAC0A")
          else color = pusher.color("#FC2121")
        this.o.fgColor = color.html()
    )
    $(@_dial).val(0).trigger "change"

  _updateChart: (total) ->

    dial = $(@_leftCtrl).find('.dial')

    if(!H5.isMobile.any())
      $(value: dial.val()).animate
        value: total,
          duration: 2000
          step: ->
            dial.val(Math.floor @value).trigger "change"
    else
      dial.val(Math.floor total).trigger "change"

class H5.Charts.Sparks extends H5.Charts.SmallContainer

  updateInfo: (data, value) ->
    $(@_rightCtrl).html("<strong>" + value + "</strong><br /> " + @options.title)
    @_updateChart(data)

  _createContainer: ->
    super
    spark = document.createElement("div")
    spark.className = "minichart"
    @_spark = spark

    $(@_leftCtrl).append @_spark

  _updateChart: (data) ->
    $(@_spark).sparkline data,
      width: 58 #Width of the chart
      height: 62 #Height of the chart
      lineColor: "#2FABE9" #Used by line to specify the colour of the line drawn
      fillColor: "#67C2EF" #Specify the colour used to fill the area under the graph
      spotColor: "#CBE968" #The CSS colour of the final value marker.
      maxSpotColor: "#FF5454" #The CSS colour of the marker displayed for the maximum value.
      minSpotColor: "#67C2EF" #The CSS colour of the marker displayed for the mimum value.
      spotRadius: 1.5 #Radius of all spot markers.
      lineWidth: 1 #In pixels (default: 1)
