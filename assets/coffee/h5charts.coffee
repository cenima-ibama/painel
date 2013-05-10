# DATA {{{
H5.Charts.data.state = "Todos"
H5.Charts.data.states = ["AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO"]

H5.Charts.data.thisDate = new Date()
H5.Charts.data.thisYear = if H5.Charts.data.thisDate.getMonth() < 6 then H5.Charts.data.thisDate.getFullYear() else H5.Charts.data.thisDate.getFullYear() + 1
H5.Charts.data.thisMonth = new Date().getMonth()
H5.Charts.data.thisDay = new Date().getDate()

H5.Charts.data.selectedYear = H5.Charts.data.thisYear
H5.Charts.data.selectedMonth = H5.Charts.data.thisMonth

H5.Charts.data.totalPeriods = H5.Charts.data.thisDate.getFullYear() - 2005
H5.Charts.data.periods = new Array(H5.Charts.data.totalPeriods)
for i in [0..H5.Charts.data.totalPeriods]
  H5.Charts.data.periods[i] = (H5.Charts.data.thisDate.getFullYear() - i - 1) + "-" + (H5.Charts.data.thisDate.getFullYear() - i)

H5.Charts.data.months =
  0: "Ago"
  1: "Set"
  2: "Out"
  3: "Nov"
  4: "Dez"
  5: "Jan"
  6: "Fev"
  7: "Mar"
  8: "Abr"
  9: "Mai"
  10: "Jun"
  11: "Jul"

#}}}
# DATABASES {{{
H5.Charts.tables.alerta =
  init: ->
    @states = {}
    for state in H5.Charts.data.states
      @states[state] = {}

  populate: (state, date, value) ->
    convertDate = (dateStr) ->
      dateStr = String(dateStr)
      dArr = dateStr.split("-")
      new Date(dArr[0], (dArr[1]) - 1, dArr[2])
    self = @states[state]
    self[date] = {}
    self[date].area = value
    self[date].date = convertDate(date)
    self[date].year = convertDate(date).getFullYear()
    self[date].month = convertDate(date).getMonth()
    self[date].day = convertDate(date).getDate()

rest = new H5.Rest (
  url: "../painel/rest"
  table: "alerta_acumulado_diario"
)

H5.Charts.tables.alerta.init()
$.each rest.request(), (i, properties) ->
  H5.Charts.tables.alerta.populate(
    properties.estado, properties.data, parseFloat(properties.total)
  )

H5.Charts.tables.prodes =
  init: ->
    @states = {}
    for state in H5.Charts.data.states
      @states[state] = {}
      for period in H5.Charts.data.periods
        @states[state][period] = {}

  populate: (period, ac, am, ap, ma, mt, pa, ro, rr, to) ->
    self = @states
    self.AC[period].area = ac
    self.AM[period].area = am
    self.AP[period].area = ap
    self.MA[period].area = ma
    self.MT[period].area = mt
    self.PA[period].area = pa
    self.RO[period].area = ro
    self.RR[period].area = rr
    self.TO[period].area = to

rest = new H5.Rest (
  url: "../painel/rest"
  table: "taxa_prodes"
)

H5.Charts.tables.prodes.init()
$.each rest.request(), (i, properties) ->
  H5.Charts.tables.prodes.populate(
    properties.ano_prodes.replace('/','-'),
    parseFloat(properties.ac), parseFloat(properties.am),
    parseFloat(properties.ap), parseFloat(properties.ma),
    parseFloat(properties.mt), parseFloat(properties.pa),
    parseFloat(properties.ro), parseFloat(properties.rr),
    parseFloat(properties.to)
  )

H5.Charts.tables.nuvens =
  init: ->
    @nuvem = {}

  populate: (date, value) ->
    convertDate = (dateStr) ->
      dateStr = String(dateStr)
      dArr = dateStr.split("-")
      new Date(dArr[0], (dArr[1]) - 1, dArr[2])
    self = @nuvem
    self[date] = {}
    self[date].value = value
    self[date].date = convertDate(date)
    self[date].year = convertDate(date).getFullYear()
    self[date].month = convertDate(date).getMonth()
    self[date].day = convertDate(date).getDate()

rest = new H5.Rest (
  url: "../painel/rest"
  table: "nuvem_deter"
)

H5.Charts.tables.nuvens.init()
$.each rest.request(), (i, properties) ->
  H5.Charts.tables.nuvens.populate(
    properties.data, properties.percent,
  )
#}}}
# CHART1 {{{
chart1 = new H5.Charts.GoogleCharts (
  type: "Line"
  container: "chart1"
  title: "Alerta DETER: Índice Diário"
  buttons:
    minimize: true
    maximize: true
  selects:
    months:
      0: 'Jan'
      1: 'Fev'
      2: 'Mar'
      3: 'Abr'
      4: 'Mai'
      5: 'Jun'
      6: 'Jul'
      7: 'Ago'
      8: 'Set'
      9: 'Out'
      10: 'Nov'
      11: 'Dez'
    years:
      2004: '2004'
      2005: '2005'
      2006: '2006'
      2007: '2007'
      2008: '2008'
      2009: '2009'
      2010: '2010'
      2011: '2011'
      2012: '2012'
      2013: '2013'
)
chart1.createContainer()

# make those options selected
chart1._yearsSlct.options[H5.Charts.data.totalPeriods+1].selected = true
chart1._monthsSlct.options[H5.Charts.data.thisMonth].selected = true

$("#yearsSlct").on "change", (event) ->
  H5.Charts.data.selectedYear = chart1._yearsSlct.value
  chart8.drawChart()
  knob1.drawChart()
  knob2.drawChart()
  knob3.drawChart()
  spark1.drawChart()
  spark2.drawChart()
  H5.Charts.updateMap()

$("#monthsSlct").on "change", (event) ->
  H5.Charts.data.selectedMonth = chart1._monthsSlct.value
  chart3.drawChart()
  chart8.drawChart()
  knob1.drawChart()
  knob2.drawChart()
  knob3.drawChart()
  spark1.drawChart()
  spark2.drawChart()
  H5.Charts.updateMap()

chart1.drawChart = ->
  createTable = (state) =>
    sum = 0
    for day in [1..daysInMonth]
      $.each H5.Charts.tables.alerta.states[state], (key, reg) ->
        if firstPeriod <= reg.date <= secondPeriod and reg.day is day
          sum += reg.area
          return false
      @data.setValue (day - 1), 1, Math.round((@data.getValue((day - 1), 1) + sum) * 100) / 100

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  @data.addColumn "number", "Dia"
  @data.addColumn "number", "Área"

  daysInMonth = new Date(@_yearsSlct.value, @_monthsSlct.value + 1, 0).getDate()
  firstPeriod = new Date(@_yearsSlct.value, @_monthsSlct.value, 1)
  secondPeriod = new Date(@_yearsSlct.value, @_monthsSlct.value, daysInMonth)
  data = []

  # populate table with 0
  for day in [1..daysInMonth]
    data[0] = day
    data[1] = 0
    @data.addRow data

  # populate table with real values
  if H5.Charts.data.state is "Todos"
    $.each H5.Charts.tables.alerta.states, (state, value) ->
      createTable state
  else
    createTable H5.Charts.data.state

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    legend: "none"
    chartArea:
      width: "70%"
      height: "70%"
    colors: ['#3ABCFC']
    vAxis:
      title: "Área Km2"
    hAxis:
      title: "Dias"
      gridlines:
        color: "#CCC"
        count: daysInMonth / 5
    animation:
      duration: 500
      easing: "inAndOut"

  @chart.draw @data, options
#}}}
# CHART2 {{{
chart2 = new H5.Charts.GoogleCharts(
  type: "Area"
  container: "chart2"
  period: 2
  title: "Alerta DETER: Índice Mensal"
  buttons:
    minusplus: true
    minimize: true
    maximize: true
)
chart2.createContainer()

chart2._addBtn.onclick = ->
  chart2.options.period++
  chart2.drawChart()

chart2._delBtn.onclick = ->
  chart2.options.period--
  chart2.drawChart()

chart2.drawChart = ->
  # sum values
  sumValues = (year, month) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    if H5.Charts.data.state is "Todos"
      $.each H5.Charts.tables.alerta.states, (key, state) ->
        $.each state, (key, reg) ->
          if firstPeriod <= reg.date <= secondPeriod and reg.month == month
            sum += reg.area
    else
      $.each H5.Charts.tables.alerta.states[H5.Charts.data.state], (key, reg) ->
        if firstPeriod <= reg.date <= secondPeriod and reg.month == month
          sum += reg.area

    return Math.round(sum * 100) / 100

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "mes"
  for i in [0...@options.period]
    @data.addColumn "number", H5.Charts.data.periods[i]

  for month of H5.Charts.data.months
    data = [H5.Charts.data.months[month]]
    month = parseInt month
    if 7 <= (month + 7) <= 11 then month+= 7 else month-= 5
    for i in [1..@options.period]
      data[i] = sumValues(H5.Charts.data.thisYear - i + 1, month)
    @data.addRow data

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    focusTarget: "category"
    chartArea:
      width: "70%"
      height: "80%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#67C2EF', '#FF5454', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']
    vAxis:
      title: "Área Km2"
    animation:
      duration: 500
      easing: "inAndOut"

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Charts.data.totalPeriods
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# CHART3 {{{
chart3 = new H5.Charts.GoogleCharts(
  type: "Bar"
  container: "chart3"
  period: 1
  title: "Alerta DETER: Índice Períodos"
  buttons:
    minusplus: true
    minimize: true
    maximize: true
)
chart3.createContainer()

chart3._addBtn.onclick = ->
  chart3.options.period++
  chart3.drawChart()

chart3._delBtn.onclick = ->
  chart3.options.period--
  chart3.drawChart()

chart3.drawChart = ->
  # sum values
  sumValues = (firstPeriod, secondPeriod) ->
    sum = 0
    if H5.Charts.data.state is "Todos"
      $.each H5.Charts.tables.alerta.states, (key, state) ->
        $.each state, (key, reg) ->
          if firstPeriod <= reg.date <= secondPeriod
            sum += reg.area
    else
      $.each H5.Charts.tables.alerta.states[H5.Charts.data.state], (key, reg) ->
        if firstPeriod <= reg.date <= secondPeriod
          sum += reg.area
    return Math.round(sum * 100) / 100

  # sum total values
  sumTotalValues = (year) ->
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year, 7, 0)
    sumValues firstPeriod, secondPeriod

  # sum average values
  sumAvgValues = (year) ->
    month = parseInt(chart1._monthsSlct.value)
    firstPeriod = new Date(year - 1, 7, 1)
    if month > 6
      secondPeriod = new Date(year-1, month+1, 0)
    else if month != H5.Charts.data.thisMonth
      secondPeriod = new Date(year, month+1, 0)
    else
      secondPeriod = new Date(year, month, H5.Charts.data.thisDay)
    sumValues firstPeriod, secondPeriod

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Ano"
  @data.addColumn "number", "Parcial"
  @data.addColumn "number", "Diferença"

  # populate table
  for i in [0..@options.period]
    data = [H5.Charts.data.periods[i]]
    sumTotal = sumTotalValues(H5.Charts.data.thisYear - i)
    sumAvg = sumAvgValues(H5.Charts.data.thisYear - i)
    data[1] = sumAvg
    data[2] = Math.round((sumTotal - sumAvg) * 100) / 100
    @data.addRow data

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    focusTarget: "category"
    chartArea:
      width: "68%"
      height: "76%"
    colors: ['#3ABCFC', '#FC2121']
    vAxis:
      title: "H5.Charts.data.periods"
    hAxis:
      title: "Área Km2"
    bar:
      groupWidth: "80%"
    isStacked: true
    animation:
      duration: 500
      easing: "inAndOut"

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Charts.data.totalPeriods - 1
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# CHART4 {{{
chart4 = new H5.Charts.GoogleCharts(
  type: "Column"
  container: "chart4"
  period: 2
  title: "Alerta DETER: UFs"
  buttons:
    minusplus: true
    minimize: true
    maximize: true
)
chart4.createContainer()

chart4._addBtn.onclick = ->
  chart4.options.period++
  chart4.drawChart()

chart4._delBtn.onclick = ->
  chart4.options.period--
  chart4.drawChart()

chart4.drawChart = ->
  # sum values
  sumValues = (state, year) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    $.each H5.Charts.tables.alerta.states[state], (key, reg) ->
      if firstPeriod <= reg.date <= secondPeriod
        sum += reg.area
    Math.round(sum * 100) / 100

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "mes"
  for i in [0...@options.period]
    @data.addColumn "number", H5.Charts.data.periods[i]

  # populate table with real values
  if H5.Charts.data.state is "Todos"
    $.each H5.Charts.tables.alerta.states, (state, reg) =>
      data = [state]
      for j in [1..@options.period]
        data[j] = sumValues(state, H5.Charts.data.thisYear - j + 1)
      @data.addRow data
  else
    data = [H5.Charts.data.state]
    for j in [1..@options.period]
      data[j] = sumValues(H5.Charts.data.state, H5.Charts.data.thisYear - j + 1)
    @data.addRow data

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    focusTarget: "category"
    chartArea:
      width: "70%"
      height: "76%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#67C2EF', '#FF5454', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']
    bar:
      groupWidth: "100%"
    vAxis:
      title: "Área Km2"
    animation:
      duration: 500
      easing: "inAndOut"

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Charts.data.totalPeriods
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# CHART5 {{{
chart5 = new H5.Charts.GoogleCharts(
  type: "Area"
  container: "chart5"
  title: "Taxa PRODES|Alerta DETER: Acumulado Períodos"
  buttons:
    minimize: true
    maximize: true
)
chart5.createContainer()

chart5.drawChart = ->
  # sum values
  sumDeter = (year) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    if H5.Charts.data.state is "Todos"
      $.each H5.Charts.tables.alerta.states, (key, state) ->
        $.each state, (key, reg) ->
          if firstPeriod <= reg.date <= secondPeriod
            sum += reg.area
    else
      $.each H5.Charts.tables.alerta.states[H5.Charts.data.state], (key, reg) ->
        if firstPeriod <= reg.date <= secondPeriod
          sum += reg.area
    return Math.round(sum * 100) / 100 if sum >= 0

  sumProdes = (period) ->
    sum = 0
    if H5.Charts.data.state is "Todos"
      $.each H5.Charts.tables.prodes.states, (key, state) ->
        sum+= state[period].area
    else
      sum = H5.Charts.tables.prodes.states[H5.Charts.data.state][period].area

    return sum if sum >= 0

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Ano"
  @data.addColumn "number", "Alerta DETER"
  @data.addColumn "number", "Taxa PRODES"

  # populate table
  i = H5.Charts.data.totalPeriods
  while i >= 0
    data = [H5.Charts.data.periods[i]]
    data[1] = sumDeter(H5.Charts.data.thisYear - i)
    data[2] = sumProdes(H5.Charts.data.periods[i])
    @data.addRow data
    i--

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    focusTarget: "category"
    chartArea:
      width: "70%"
      height: "80%"
    colors: ['#3ABCFC', '#D0FC3F']
    vAxis:
      title: "Área Km2"
    hAxis:
      title: "H5.Charts.data.periods"
    animation:
      duration: 500
      easing: "inAndOut"

  @chart.draw @data, options
#}}}
# CHART6 {{{
chart6 = new H5.Charts.GoogleCharts(
  type: "Column"
  container: "chart6"
  period: 1
  title: "Taxa PRODES|Alerta DETER: UFs"
  buttons:
    minimize: true
    maximize: true
    arrows: true
)
chart6.createContainer()

chart6.changeTitle H5.Charts.data.periods[chart6.options.period]

chart6._leftBtn.onclick = ->
  chart6.options.period++
  chart6.drawChart()

chart6._rightBtn.onclick = ->
  chart6.options.period--
  chart6.drawChart()

chart6.drawChart = ->
  # sum values
  sumDeter = (state, year) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    $.each H5.Charts.tables.alerta.states[state], (key, reg) ->
      if firstPeriod <= reg.date <= secondPeriod
        sum+= reg.area
    return Math.round(sum * 100) / 100

  sumProdes = (state, year) ->
    sum = 0
    period = (year - 1) + "-" + (year)
    $.each H5.Charts.tables.prodes.states[state], (key, reg) ->
      if key is period
        sum+= reg.area if reg.area?
    return Math.round(sum * 100) / 100

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Estado"
  @data.addColumn "number", "Alerta DETER"
  @data.addColumn "number", "Taxa PRODES"

  # populate table with real values
  if H5.Charts.data.state is "Todos"
    $.each H5.Charts.tables.alerta.states, (state, reg) =>
      data = [state]
      data[1] = sumDeter(state, H5.Charts.data.thisYear - @options.period)
      data[2] = sumProdes(state, H5.Charts.data.thisYear - @options.period)
      @data.addRow data
  else
    data = [H5.Charts.data.state]
    data[1] = sumDeter(H5.Charts.data.state, H5.Charts.data.thisYear - @options.period)
    data[2] = sumProdes(H5.Charts.data.state, H5.Charts.data.thisYear - @options.period)
    @data.addRow data

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    focusTarget: "category"
    chartArea:
      width: "70%"
      height: "76%"
    colors: ['#3ABCFC', '#D0FC3F']
    bar:
      groupWidth: "100%"
    vAxis:
      title: "Área Km2"
    animation:
      duration: 500
      easing: "inAndOut"

  @changeTitle "Taxa PRODES|Alerta DETER: UFs [" + H5.Charts.data.periods[@options.period] + "]"

  # Disabling the buttons while the chart is drawing.
  @_rightBtn.disabled = true
  @_leftBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_rightBtn.disabled = @options.period < 2
    @_leftBtn.disabled = @options.period >= H5.Charts.data.totalPeriods

  @chart.draw @data, options
#}}}
# CHART7 {{{
chart7 = new H5.Charts.GoogleCharts(
  type: "Pie"
  container: "chart7"
  period: 0
  buttons:
    arrows: true
    minimize: true
    maximize: true
)
chart7.createContainer()

chart7.changeTitle H5.Charts.data.periods[chart7.options.period]

chart7._leftBtn.onclick = ->
  chart7.options.period++
  chart7.drawChart()

chart7._rightBtn.onclick = ->
  chart7.options.period--
  chart7.drawChart()

chart7.drawChart = ->
  # sum values
  sumValues = (state, year) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    $.each H5.Charts.tables.alerta.states[state], (key, reg) ->
      if firstPeriod <= reg.date <= secondPeriod
        sum += reg.area
    Math.round(sum * 100) / 100

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "mes"
  @data.addColumn "number", H5.Charts.data.periods[H5.Charts.data.totalPeriods]

  # populate table
  for i in [0...H5.Charts.data.states.length]
    estado = H5.Charts.data.states[i]
    data = [estado]
    data[1] = sumValues(H5.Charts.data.states[i], H5.Charts.data.thisYear - @options.period)
    @data.addRow data

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    chartArea:
      width: "90%"
      height: "80%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#67C2EF', '#FF5454', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']
    backgroundColor: "transparent"

  @changeTitle H5.Charts.data.periods[@options.period]

  # Disabling the buttons while the chart is drawing.
  @_rightBtn.disabled = true
  @_leftBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_rightBtn.disabled = @options.period < 1
    @_leftBtn.disabled = @options.period >= H5.Charts.data.totalPeriods

  @chart.draw @data, options
#}}}
# CHART8 {{{
chart8 = new H5.Charts.GoogleCharts(
  type: "Pie"
  container: "chart8"
  period: 1
  buttons:
    minimize: true
    maximize: true
)
chart8.createContainer()

chart8.drawChart = ->
  # sum values
  sumValues = (state) ->
    sum = 0
    $.each H5.Charts.tables.alerta.states[state], (key, reg) ->
      if firstPeriod <= reg.date <= secondPeriod
        sum += reg.area
    if firstPeriod > H5.Charts.data.thisDate
      return 1
    else
      Math.round(sum * 100) / 100

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Estado"
  @data.addColumn "number", "Área Total"

  daysInMonth = new Date(chart1._yearsSlct.value, chart1._monthsSlct.value + 1, 0).getDate()
  firstPeriod = new Date(chart1._yearsSlct.value, chart1._monthsSlct.value, 1)
  secondPeriod = new Date(chart1._yearsSlct.value, chart1._monthsSlct.value, daysInMonth)

  if firstPeriod > H5.Charts.data.thisDate
    pieText = "none"
    pieTooltip = "none"
  else
    pieText = "percent"
    pieTooltip = "focus"

  # populate table
  for i in [0...H5.Charts.data.states.length]
    estado = H5.Charts.data.states[i]
    data = [estado]
    data[1] = sumValues(H5.Charts.data.states[i])
    @data.addRow data

  @changeTitle chart1._monthsSlct.options[chart1._monthsSlct.value].label + ", " + chart1._yearsSlct.value

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    focusTarget: "category"
    pieSliceText: pieText
    tooltip:
      trigger: pieTooltip
    chartArea:
      width: "90%"
      height: "80%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#67C2EF', '#FF5454', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']
    bar:
      groupWidth: "100%"
    vAxis:
      title: "Área Km2"
    animation:
      duration: 500
      easing: "inAndOut"

  @chart.draw @data, options
#}}}
# CHART9 {{{
chart9 = new H5.Charts.GoogleCharts(
  type: "Line"
  container: "chart9"
  period: 2
  title: "Alerta DETER: Taxa(%) de Nuvens"
  buttons:
    minusplus: true
    minimize: true
    maximize: true
)
chart9.createContainer()

chart9._addBtn.onclick = ->
  chart9.options.period++
  chart9.drawChart()

chart9._delBtn.onclick = ->
  chart9.options.period--
  chart9.drawChart()

chart9.drawChart = ->
  # sum values
  sumValues = (year, month) ->
    percent = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    $.each H5.Charts.tables.nuvens.nuvem, (key, nuvem) ->
      if nuvem.date >= firstPeriod and nuvem.date <= secondPeriod and nuvem.month is month
        percent = nuvem.value
        return false

    return Math.round(percent * 100)

  # create new chart
  @createChart()

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "mes"
  for i in [0...@options.period]
    @data.addColumn "number", H5.Charts.data.periods[i]

  for month of H5.Charts.data.months
    data = [H5.Charts.data.months[month]]
    month = parseInt month
    if 7 <= (month + 7) <= 11 then month+= 7 else month-= 5
    for i in [1..@options.period]
      data[i] = sumValues(H5.Charts.data.thisYear - i + 1, month)
    @data.addRow data

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    focusTarget: "category"
    chartArea:
      width: "70%"
      height: "80%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#67C2EF', '#FF5454', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']
    vAxis:
      title: "Porcentagem"
    animation:
      duration: 500
      easing: "inAndOut"

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Charts.data.totalPeriods - 4
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# SPARK1 {{{
spark1 = new H5.Charts.Sparks(
  container: "spark1"
  title: "Total Mensal"
)

spark1.createContainer()

spark1.drawChart = ->
  #Create array with values
  createTable = (state) =>
    dayValue = 0
    for day in [1..daysInMonth]
      $.each H5.Charts.tables.alerta.states[state], (key, reg) ->
        if firstPeriod <= reg.date <= secondPeriod and reg.day is day
          dayValue += reg.area
          return false
      data[(day-1)] = Math.round((data[(day-1)] + dayValue) * 100)/100

  daysInMonth = new Date(chart1._yearsSlct.value, chart1._monthsSlct.value + 1, 0).getDate()
  firstPeriod = new Date(chart1._yearsSlct.value, chart1._monthsSlct.value, 1)
  secondPeriod = new Date(chart1._yearsSlct.value, chart1._monthsSlct.value, daysInMonth)
  data = []

  # populate table with 0
  for day in [1..daysInMonth]
    data[(day-1)] = 0

  # populate table with real values
  if H5.Charts.data.state is "Todos"
    $.each H5.Charts.tables.alerta.states, (state, value) ->
      createTable state
  else
    createTable H5.Charts.data.state

  value = data[daysInMonth-1]
  @updateInfo data, value
#}}}
# SPARK2 {{{
spark2 = new H5.Charts.Sparks(
  container: "spark2"
  title: "Total Período"
)

spark2.createContainer()

spark2.drawChart = ->
  #Create array with values
  # sum values
  sumValues = (year, month) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    if H5.Charts.data.state is "Todos"
      $.each H5.Charts.tables.alerta.states, (key, state) ->
        $.each state, (key, reg) ->
          if reg.date >= firstPeriod and reg.date <= secondPeriod and reg.month is month
            sum += reg.area
    else
      $.each H5.Charts.tables.alerta.states[H5.Charts.data.state], (key, reg) ->
        if reg.date >= firstPeriod and reg.date <= secondPeriod and reg.month is month
          sum += reg.area
    return Math.round(sum * 100) / 100

  # init table
  data = []

  # populate table
  # list months
  $.each H5.Charts.data.months, (number, month) =>
    i = number
    number = parseInt number
    if 7 <= (number + 7) <= 11 then number+= 7 else number-= 5
    data[i] = sumValues(chart1._yearsSlct.value, number)

  value = 0
  $.each data, ->
    value += this

  @updateInfo data, Math.round(value*100)/100
#}}}
# KNOB1 {{{
knob1 = new H5.Charts.Knobs(
  container: "knob1"
  title: "Taxa VAA"
  popover: "Taxa de variação em relação ao mesmo mês do ano anterior"
)

knob1.createContainer()

knob1.drawChart = ->
  # sum values
  periodDeforestationRate = (year, month) ->
    sumValues = (date) ->
      sum = 0
      if H5.Charts.data.state is "Todos"
        for state of H5.Charts.tables.alerta.states
          for reg of H5.Charts.tables.alerta.states[state]
            reg = H5.Charts.tables.alerta.states[state][reg]
            if date.getFullYear() <= reg.year <= date.getFullYear() and reg.month is date.getMonth()
              sum += reg.area
      else
        for reg of H5.Charts.tables.alerta.states[H5.Charts.data.state]
          reg = H5.Charts.tables.alerta.states[H5.Charts.data.state][reg]
          if date.getFullYear() <= reg.year <= date.getFullYear() and reg.month is date.getMonth()
            sum += reg.area
      return sum

    # definir periodo atual
    curDate = new Date(year, month)
    # definir periodo anterior
    preDate = new Date(year - 1, month)

    # definir valores referentes ao periodo atual
    curValue = sumValues(curDate)
    preValue = sumValues(preDate)

    # caso o valor do periodo anterior seja 0, retorna 0
    # para evitar uma divisão por 0
    if preValue is 0
      return 0
    else
      return Math.round (curValue - preValue) / preValue * 100

  value = periodDeforestationRate(
    parseInt(chart1._yearsSlct.value), parseInt(chart1._monthsSlct.value)
  )
  @updateInfo value
#}}}
# KNOB2 {{{
knob2 = new H5.Charts.Knobs(
  container: "knob2"
  title: "Taxa VMA"
  popover: "Taxa de variação em relação ao mês anterior"
)

knob2.createContainer()

knob2.drawChart = ->
  # sum values
  periodDeforestationRate = (year, month) ->
    sumValues = (date) ->
      sum = 0
      if H5.Charts.data.state is "Todos"
        for state of H5.Charts.tables.alerta.states
          for reg of H5.Charts.tables.alerta.states[state]
            reg = H5.Charts.tables.alerta.states[state][reg]
            if date.getFullYear() <= reg.year <= date.getFullYear() and reg.month is date.getMonth()
              sum += reg.area
      else
        for reg of H5.Charts.tables.alerta.states[H5.Charts.data.state]
          reg = H5.Charts.tables.alerta.states[H5.Charts.data.state][reg]
          if date.getFullYear() <= reg.year <= date.getFullYear() and reg.month is date.getMonth()
            sum += reg.area
      return sum

    # definir periodo atual
    curDate = new Date(year, month)
    # definir periodo anterior
    preDate = new Date(year, month - 1)

    # definir valores referentes ao periodo atual
    curValue = sumValues(curDate)
    preValue = sumValues(preDate)

    # caso o valor do periodo anterior seja 0, retorna 0
    # para evitar uma divisão por 0
    if preValue is 0
      return 0
    else
      return Math.round (curValue - preValue) / preValue * 100

  value = periodDeforestationRate(
    parseInt(chart1._yearsSlct.value), parseInt(chart1._monthsSlct.value)
  )
  @updateInfo value
#}}}
# KNOB3 {{{
knob3 = new H5.Charts.Knobs(
  container: "knob3"
  title: "Taxa VPA"
  popover: "Taxa de variação em relação ao período PRODES anterior"
)

knob3.createContainer()

knob3.drawChart = ->
  # sum values
  periodDeforestationAvgRate = (year, month) ->
    sumValues = (firstPeriod, secondPeriod) ->
      sum = 0
      if H5.Charts.data.state is "Todos"
        $.each H5.Charts.tables.alerta.states, (key, state) ->
          $.each state, (key, reg) ->
            if firstPeriod <= reg.date <= secondPeriod
              sum += reg.area
      else
        $.each H5.Charts.tables.alerta.states[H5.Charts.data.state], (key, reg) ->
          if firstPeriod <= reg.date <= secondPeriod
            sum += reg.area
      return Math.round(sum * 100) / 100

    if month > 6 then year++ else year

    sumPeriods = (year, month) ->
      firstPeriod = new Date(year-1, 7, 1)
      secondPeriod = new Date(year, month+1, 0)
      sumValues firstPeriod, secondPeriod

    curValue = sumPeriods(year, month)
    preValue = sumPeriods(year-1, month)

    # caso o valor do periodo anterior seja 0, retorna 0
    # para evitar uma divisão por 0
    if preValue is 0
      return 0
    else
      return Math.round (curValue - preValue) / preValue * 100

  value = periodDeforestationAvgRate(
    parseInt(chart1._yearsSlct.value), parseInt(chart1._monthsSlct.value)
  )
  @updateInfo value
#}}}
# CONTROLS {{{
H5.Charts.reloadCharts = ->
  chart1.drawChart()
  chart2.drawChart()
  chart3.drawChart()
  chart4.drawChart()
  chart5.drawChart()
  chart6.drawChart()
  chart7.drawChart()
  chart8.drawChart()
  chart9.drawChart()
  knob1.drawChart()
  knob2.drawChart()
  knob3.drawChart()
  spark1.drawChart()
  spark2.drawChart()

H5.Charts.updateMap = ->
  if H5.Charts.data.state is "Todos"
    where = "ano='" + H5.Charts.data.selectedYear + "'"
  else
    where = "estado='" + H5.Charts.data.state + "' AND ano='" + H5.Charts.data.selectedYear + "'"
  H5.Leaflet.layers.alerta.setOptions(
    where: where
  )
  H5.Leaflet.layers.alerta.setMap(null)
  H5.Leaflet.layers.alerta.setMap(H5.Leaflet.map)
