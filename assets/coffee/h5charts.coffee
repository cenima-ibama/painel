# DATA {{{
H5.Data.restURL = "http://" + document.domain + "/painel/rest"
H5.Data.domanin = "http://" + document.domain + "/painel"

H5.Data.changed = false
H5.DB.dado_prodes_consolidado = {}
H5.DB.dado_prodes_consolidado.table = "dado_prodes_consolidado"
H5.Data.state2 = "AC"
H5.Data.statesProdes = ["AC", "AP", "AM", "PA", "RO", "RR", "TO", "MT", "MA"]

# H5.Data.state3 = "brasil"
# H5.Data.statesNewStats = ["AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO"]

H5.Data.state = "brasil"
H5.Data.states = ["AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO"]
H5.Data.allstates = ["AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"]
H5.Data.regions = {
  names: ["norte", "sul", "nordeste", "sudeste", "centrooeste"]
  amazonia: ["AC", "AP", "AM", "PA", "RO", "RR", "TO", "MT", "MA", "brasil"]
  norte: ["AC", "AP", "AM", "PA", "RO", "RR", "TO"]
  sul: ["PR", "RS", "SC"]
  nordeste: ["AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE"]
  sudeste: ["ES", "MG", "RJ", "SP"]
  centrooeste: ["DF", "GO", "MT", "MS"]
}

H5.Data.years = [ "2013", "2012", "2011", "2010", "2009", "2008", "2007", "2006","2005" ]

H5.Data.thisDate = new Date()
H5.Data.thisYear = H5.Data.thisDate.getFullYear()
H5.Data.thisProdesYear = if H5.Data.thisMonth < 7 then H5.Data.thisYear else H5.Data.thisYear + 1
H5.Data.thisMonth = H5.Data.thisDate.getMonth()
H5.Data.thisDay = H5.Data.thisDate.getDate()

H5.Data.rateSlct = 0;
H5.Data.shapeSlct = 0;

H5.Data.totalPeriods = if H5.Data.thisMonth < 7 then (H5.Data.thisDate.getFullYear() - 2005) else (H5.Data.thisDate.getFullYear() - 2004)
H5.Data.periods = new Array(H5.Data.totalPeriods)
for i in [0..H5.Data.totalPeriods]
  if H5.Data.thisMonth < 7
    H5.Data.periods[i] = (H5.Data.thisDate.getFullYear() - i - 1) + "-" + (H5.Data.thisDate.getFullYear() - i)
  else
    H5.Data.periods[i] = (H5.Data.thisDate.getFullYear() - i) + "-" + (H5.Data.thisDate.getFullYear() - i + 1)

H5.Data.months =
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

# disable animation on mobile devices
unless H5.isMobile.any()
  H5.Data.animate = {
    duration: 500
    easing: "inAndOut"
  }
else
  H5.Data.animate = {}

#}}}
# DATABASES {{{
H5.DB.embargo.data =
  init: ->
    @states = {}
    for state in H5.Data.allstates
      @states[state] = {}

  populate: (state, date, value) ->
    # convert string into date
    if state and date

      convertDate = (dateStr) ->
        dateStr = String(dateStr)
        dArr = dateStr.split("-")
        return new Date(dArr[0], (dArr[1]) - 1, dArr[2])

      # populate object
      self = @states[state]
      self[date] = {}
      self[date].area = if value then value else 0
      self[date].date = convertDate(date)
      self[date].year = convertDate(date).getFullYear()
      self[date].month = convertDate(date).getMonth()
      self[date].day = convertDate(date).getDate()

      # set the value of the last value
      if @lastValue
        if @lastValue.date < self[date].date
          @lastValue = self[date]
      else
        @lastValue = self[date]
      return

rest = new H5.Rest (
  url: H5.Data.restURL
  table: H5.DB.embargo.table
  # parameters: "data_cadastro > '2013-01-01'"
  fields: "uf, data_cadastro, qtd_area_desmatada"
)

H5.DB.embargo.data.init()
for i, properties of rest.data
  H5.DB.embargo.data.populate(
    properties.uf, properties.data_cadastro, parseFloat(properties.qtd_area_desmatada)
  )

H5.DB.diary.data =
  init: ->
    @states = {}
    for state in H5.Data.states
      @states[state] = {}

  populate: (state, date, value) ->
    # convert string into date
    convertDate = (dateStr) ->
      dateStr = String(dateStr)
      dArr = dateStr.split("-")
      return new Date(dArr[0], (dArr[1]) - 1, dArr[2])
    # populate object
    self = @states[state]
    self[date] = {}
    self[date].area = value
    self[date].date = convertDate(date)
    self[date].year = convertDate(date).getFullYear()
    self[date].month = convertDate(date).getMonth()
    self[date].day = convertDate(date).getDate()

    # set the value of the last value
    if @lastValue
      if @lastValue.date < self[date].date
        @lastValue = self[date]
    else
      @lastValue = self[date]
    return

rest = new H5.Rest (
  url: H5.Data.restURL
  table: H5.DB.diary.table
  fields: "estado, data, total"
)

H5.DB.diary.data.init()
for i, properties of rest.data
  H5.DB.diary.data.populate(
    properties.estado, properties.data, parseFloat(properties.total)
  )

H5.DB.prodes.data =
  init: ->
    @states = {}
    for state in H5.Data.states
      @states[state] = {}
      for period in H5.Data.periods
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
  url: H5.Data.restURL
  table: H5.DB.prodes.table
)

H5.DB.prodes.data.init()
for i, properties of rest.data
  H5.DB.prodes.data.populate(
    properties.ano_prodes.replace('/','-'),
    parseFloat(properties.ac), parseFloat(properties.am),
    parseFloat(properties.ap), parseFloat(properties.ma),
    parseFloat(properties.mt), parseFloat(properties.pa),
    parseFloat(properties.ro), parseFloat(properties.rr),
    parseFloat(properties.to)
  )

H5.DB.cloud.data =
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
  url: H5.Data.restURL
  table: H5.DB.cloud.table
)

H5.DB.cloud.data.init()
for i, properties of rest.data
  H5.DB.cloud.data.populate(
    properties.data, properties.percent,
  )
#}}}
# PRODES CONSOLIDADO {{{
H5.DB.dado_prodes_consolidado.data =
  init: ->
    @states = {}
    for state in H5.Data.allstates
      @states[state] = {}
    @states['brasil'] = {}

  populate: (year, state, terra_indigena, uc_sustentavel, uc_integral, assentamento, floresta, dominio) ->
    # convert string into date
    if state and year

      # populate object
      self = @states[state]
      self[year] = {}
      self[year].terra_indigena = if terra_indigena then terra_indigena else 0
      self[year].uc_sustentavel = uc_sustentavel
      self[year].uc_integral = uc_integral
      self[year].assentamento = assentamento
      self[year].floresta = floresta
      self[year].dominio = dominio
      self[year].year = year

      # set the value of the last value
      if @lastValue
        if @lastValue.year < self[year].year
          @lastValue = self[year]
      else
        @lastValue = self[year]

      self = @states['brasil']
      if !self[year]
        self[year] = {}
        self[year].terra_indigena = 0
        self[year].uc_sustentavel = 0
        self[year].uc_integral = 0
        self[year].assentamento = 0
        self[year].floresta = 0
        self[year].dominio = 0
        self[year].year = year

      self[year].terra_indigena += if terra_indigena then terra_indigena else 0
      self[year].uc_sustentavel += uc_sustentavel
      self[year].uc_integral += uc_integral
      self[year].assentamento += assentamento
      self[year].floresta += floresta
      self[year].dominio += dominio

      return

rest = new H5.Rest (
  url: H5.Data.restURL
  table: H5.DB.dado_prodes_consolidado.table
  # parameters: "data_cadastro > '2013-01-01'"
  #fields: "ano, uf, terra_indigena, unidades_de_conservacao_uso_sustentavel, unidades_de_conservacao_protecao_integral, assentamentos, floresta_publica"
)

H5.DB.dado_prodes_consolidado.data.init()
for i, properties of rest.data
  H5.DB.dado_prodes_consolidado.data.populate(
    properties.ano, properties.uf, parseFloat(properties.terra_indigena), parseFloat(properties.unidades_de_conservacao_uso_sustentavel),parseFloat(properties.unidades_de_conservacao_protecao_integral), parseFloat(properties.assentamento), parseFloat(properties.floresta_publica), if properties.dominio_estadual then parseFloat(properties.dominio_estadual) else parseFloat(0)
  )

#   terra_indigena_sum += properties.terra_indigena
#   uc_sustentavel_sum += properties.unidades_de_conservacao_uso_sustentavel
#   uc_integral_sum += properties.unidades_de_conservacao_protecao_integral
#   assentamento_sum += properties.assentamento
#   floresta_sum += properties.floresta_publica

# H5.DB.dado_prodes_consolidado.data.populate()


#}}}
# DETER CONSOLIDADO {{{
# H5.DB.dado_deter_consolidado.data =
#   init: ->
#     @states = {}
#     for state in H5.Data.allstates
#       @states[state] = {}

#   populate: (year, state, terra_indigena, uc_sustentavel, uc_integral, assentamento, floresta) ->
#     # convert string into date
#     if state and year

#       # populate object
#       self = @states[state]
#       self[year] = {}
#       self[year].terra_indigena = if terra_indigena then terra_indigena else 0
#       self[year].uc_sustentavel = uc_sustentavel
#       self[year].uc_integral = uc_integral
#       self[year].assentamento = assentamento
#       self[year].floresta = floresta
#       self[year].year = year

#       # set the value of the last value
#       if @lastValue
#         if @lastValue.year < self[year].year
#           @lastValue = self[year]
#       else
#         @lastValue = self[year]
#       return


#   getValues: ->
#     rest = new H5.Rest (
#       url: H5.Data.restURL
#       table: H5.DB.dado_deter_consolidado.table + "('" +  + "'" + "'')"
#     )

#     H5.DB.dado_prodes_consolidado.data.init()
#     for i, properties of rest.data
#       H5.DB.dado_prodes_consolidado.data.populate(
#         properties.ano, properties.uf, parseFloat(properties.terra_indigena), parseFloat(properties.unidades_de_conservacao_uso_sustentavel),parseFloat(properties.unidades_de_conservacao_protecao_integral), parseFloat(properties.assentamento), parseFloat(properties.floresta_publica)
#       )
#}}}
# RELOAD DATE {{{
# reload date based on database
H5.Data.thisDate = H5.DB.diary.data.lastValue.date
H5.Data.thisDay = H5.DB.diary.data.lastValue.day
H5.Data.thisMonth = H5.DB.diary.data.lastValue.month
H5.Data.thisYear = H5.DB.diary.data.lastValue.year
H5.Data.thisProdesYear = if H5.Data.thisMonth < 7 then H5.Data.thisYear else H5.Data.thisYear + 1

H5.Data.selectedYear = H5.Data.thisYear
H5.Data.selectedMonth = H5.Data.thisMonth

H5.Data.totalPeriods = if H5.Data.thisMonth < 7 then (H5.Data.thisDate.getFullYear() - 2005) else (H5.Data.thisDate.getFullYear() - 2004)
H5.Data.periods = new Array(H5.Data.totalPeriods)
for i in [0..H5.Data.totalPeriods]
  if H5.Data.thisMonth < 7
    H5.Data.periods[i] = (H5.Data.thisDate.getFullYear() - i - 1) + "-" + (H5.Data.thisDate.getFullYear() - i)
  else
    H5.Data.periods[i] = (H5.Data.thisDate.getFullYear() - i) + "-" + (H5.Data.thisDate.getFullYear() - i + 1)
#}}}
# CHART1 {{{
chart1 = new H5.Charts.GoogleCharts (
  type: "Line"
  container: "chart1"
  title: "Alerta DETER: Índice Diário"
  buttons:
    export: true
    table: true
    minimize: true
    maximize: true
)

chart1.drawChart = ->
  createTable = (state) =>
    sum = 0
    for day in [1..daysInMonth]
      for key, reg of H5.DB.diary.data.states[state]
        do (reg) ->
          if firstPeriod <= reg.date <= secondPeriod and reg.day is day
            sum += reg.area
            return false
      @data.setValue (day - 1), 1, Math.round((@data.getValue((day - 1), 1) + sum) * 100) / 100

  # create an empty table
  @createDataTable()

  @data.addColumn "number", "Dia"
  @data.addColumn "number", "Área"

  daysInMonth = new Date(H5.Data.selectedYear, H5.Data.selectedMonth + 1, 0).getDate()
  firstPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, 1)
  secondPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, daysInMonth)
  data = []

  # populate table with 0
  for day in [1..daysInMonth]
    data[0] = day
    data[1] = 0
    @data.addRow data

  # populate table with real values
  if H5.Data.state is "brasil"
    for state of H5.DB.diary.data.states
      createTable state
  else
    createTable H5.Data.state

  months =
    0: "Janeiro"
    1: "Fevereiro"
    2: "Março"
    3: "Abril"
    4: "Maio"
    5: "Junho"
    6: "Julho"
    7: "Agosto"
    8: "Setembro"
    9: "Outubro"
    10: "Novembro"
    11: "Dezembro"

  @changeTitle "Alerta DETER: Índice Diário [" + months[H5.Data.selectedMonth] + "]"

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
      title: "Área km²"
    hAxis:
      title: "Dias"
      gridlines:
        color: "#CCC"
        count: daysInMonth / 5
    animation: H5.Data.animate

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
    export: true
    table: true
    minimize: true
    maximize: true
)

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
    if H5.Data.state is "brasil"
      for name, state of H5.DB.diary.data.states
        for key, reg of state
          if firstPeriod <= reg.date <= secondPeriod and reg.month == month
            sum += reg.area
    else
      for key, reg of H5.DB.diary.data.states[H5.Data.state]
        if firstPeriod <= reg.date <= secondPeriod and reg.month == month
          sum += reg.area

    return Math.round(sum * 100) / 100

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Mês"
  for i in [0...@options.period]
    @data.addColumn "number", H5.Data.periods[i]

  for month of H5.Data.months
    data = [H5.Data.months[month]]
    month = parseInt month
    if 7 <= (month + 7) <= 11 then month+= 7 else month-= 5
    for i in [1..@options.period]
      data[i] = sumValues(H5.Data.thisProdesYear - i + 1, month)
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
      title: "Área km²"
    animation: H5.Data.animate

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Data.totalPeriods
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
    export: true
    table: true
    minimize: true
    maximize: true
)

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
    if H5.Data.state is "brasil"
      for name, state of H5.DB.diary.data.states
        for key, reg of state
          if firstPeriod <= reg.date <= secondPeriod
            sum += reg.area
    else
      for key, reg of H5.DB.diary.data.states[H5.Data.state]
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
    month = H5.Data.selectedMonth
    firstPeriod = new Date(year - 1, 7, 1)
    if month > 6
      if month is H5.Data.thisMonth
        secondPeriod = new Date(year-1, month, H5.Data.thisDay)
      else
        secondPeriod = new Date(year-1, month+1, 0)
    else
      if month is H5.Data.thisMonth
        secondPeriod = new Date(year, month, H5.Data.thisDay)
      else
        secondPeriod = new Date(year, month+1, 0)
    sumValues firstPeriod, secondPeriod

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Ano"
  @data.addColumn "number", "Parcial"
  @data.addColumn "number", "Diferença"

  # populate table
  for i in [0..@options.period]
    data = [H5.Data.periods[i]]
    sumTotal = sumTotalValues(H5.Data.thisProdesYear - i)
    sumAvg = sumAvgValues(H5.Data.thisProdesYear - i)
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
      title: "Período PRODES"
    hAxis:
      title: "Área km²"
    bar:
      groupWidth: "80%"
    isStacked: true
    animation: H5.Data.animate

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Data.totalPeriods - 1
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
    export: true
    table: true
    minimize: true
    maximize: true
)

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
    for key, reg of H5.DB.diary.data.states[state]
      if firstPeriod <= reg.date <= secondPeriod
        sum += reg.area
    Math.round(sum * 100) / 100

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Estado"
  for i in [0...@options.period]
    @data.addColumn "number", H5.Data.periods[i]

  # populate table with real values
  if H5.Data.state is "brasil"
    for name, state of H5.DB.diary.data.states
      data = [name]
      for j in [1..@options.period]
        data[j] = sumValues(name, H5.Data.thisProdesYear - j + 1)
      @data.addRow data
  else
    data = [H5.Data.state]
    for j in [1..@options.period]
      data[j] = sumValues(H5.Data.state, H5.Data.thisProdesYear - j + 1)
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
      title: "Área km²"
    animation: H5.Data.animate

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Data.totalPeriods
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# CHART5 {{{
chart5 = new H5.Charts.GoogleCharts(
  type: "Area"
  container: "chart5"
  title: "Taxa PRODES|Alerta DETER: Acumulado Períodos"
  buttons:
    export: true
    table: true
    minimize: true
    maximize: true
)

chart5.drawChart = ->
  # sum values
  sumDeter = (year) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    if H5.Data.state is "brasil"
      for name, state of H5.DB.diary.data.states
        for key, reg of state
          if firstPeriod <= reg.date <= secondPeriod
            sum += reg.area
    else
      for key, reg of H5.DB.diary.data.states[H5.Data.state]
        if firstPeriod <= reg.date <= secondPeriod
          sum += reg.area
    return Math.round(sum * 100) / 100 if sum >= 0

  sumProdes = (period) ->
    sum = 0
    if H5.Data.state is "brasil"
      for name, state of H5.DB.prodes.data.states
        sum+= state[period].area
    else
      sum = H5.DB.prodes.data.states[H5.Data.state][period].area

    return sum if sum >= 0

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Ano"
  @data.addColumn "number", "Alerta DETER"
  @data.addColumn "number", "Taxa PRODES"

  # populate table
  i = H5.Data.totalPeriods
  while i >= 0
    data = [H5.Data.periods[i]]
    data[1] = sumDeter(H5.Data.thisProdesYear - i)
    data[2] = sumProdes(H5.Data.periods[i])
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
      title: "Área km²"
    hAxis:
      title: "Período PRODES"
    animation: H5.Data.animate

  @chart.draw @data, options
#}}}
# CHART6 {{{
chart6 = new H5.Charts.GoogleCharts(
  type: "Column"
  container: "chart6"
  period: 1
  title: "Taxa PRODES|Alerta DETER: UFs"
  buttons:
    export: true
    table: true
    minimize: true
    maximize: true
    arrows: true
)

chart6.changeTitle H5.Data.periods[chart6.options.period]

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
    for key, reg of H5.DB.diary.data.states[state]
      if firstPeriod <= reg.date <= secondPeriod
        sum+= reg.area
    return Math.round(sum * 100) / 100

  sumProdes = (state, year) ->
    sum = 0
    period = (year - 1) + "-" + (year)
    for key, reg of H5.DB.prodes.data.states[state]
      if key is period
        sum+= reg.area if reg.area?
    return Math.round(sum * 100) / 100

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Estado"
  @data.addColumn "number", "Alerta DETER"
  @data.addColumn "number", "Taxa PRODES"

  # populate table with real values
  if H5.Data.state is "brasil"
    for name, state of H5.DB.diary.data.states
      data = [name]
      data[1] = sumDeter(name, H5.Data.thisProdesYear - @options.period)
      data[2] = sumProdes(name, H5.Data.thisProdesYear - @options.period)
      @data.addRow data
  else
    data = [H5.Data.state]
    data[1] = sumDeter(H5.Data.state, H5.Data.thisProdesYear - @options.period)
    data[2] = sumProdes(H5.Data.state, H5.Data.thisProdesYear - @options.period)
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
      title: "Área km²"
    animation: H5.Data.animate

  @changeTitle "Taxa PRODES|Alerta DETER: UFs [" + H5.Data.periods[@options.period] + "]"

  # Disabling the buttons while the chart is drawing.
  @_rightBtn.disabled = true
  @_leftBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_rightBtn.disabled = @options.period < 2
    @_leftBtn.disabled = @options.period >= H5.Data.totalPeriods

  @chart.draw @data, options
#}}}
# CHART7 {{{
chart7 = new H5.Charts.GoogleCharts(
  type: "Pie"
  container: "chart7"
  period: 0
  buttons:
    arrows: true
    export: true
    table: true
    minimize: true
    maximize: true
)

chart7.changeTitle H5.Data.periods[chart7.options.period]

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
    for key, reg of H5.DB.diary.data.states[state]
      if firstPeriod <= reg.date <= secondPeriod
        sum += reg.area
    Math.round(sum * 100) / 100

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Mês"
  @data.addColumn "number", H5.Data.periods[@options.period]

  # populate table
  for i in [0...H5.Data.states.length]
    estado = H5.Data.states[i]
    data = [estado]
    data[1] = sumValues(H5.Data.states[i], H5.Data.thisProdesYear - @options.period)
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

  @changeTitle H5.Data.periods[@options.period]

  # Disabling the buttons while the chart is drawing.
  @_rightBtn.disabled = true
  @_leftBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_rightBtn.disabled = @options.period < 1
    @_leftBtn.disabled = @options.period >= H5.Data.totalPeriods

  @chart.draw @data, options
#}}}
# CHART8 {{{
chart8 = new H5.Charts.GoogleCharts(
  type: "Pie"
  container: "chart8"
  period: 1
  buttons:
    export: true
    table: true
    minimize: true
    maximize: true
)

chart8.drawChart = ->
  # sum values
  sumValues = (state) ->
    sum = 0
    for key, reg of H5.DB.diary.data.states[state]
      if firstPeriod <= reg.date <= secondPeriod
        sum += reg.area
    if firstPeriod > H5.Data.thisDate
      return 1
    else
      Math.round(sum * 100) / 100

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Estado"
  @data.addColumn "number", "Área Total"

  daysInMonth = new Date(H5.Data.selectedYear, H5.Data.selectedMonth + 1, 0).getDate()
  firstPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, 1)
  secondPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, daysInMonth)

  if firstPeriod > H5.Data.thisDate
    pieText = "none"
    pieTooltip = "none"
  else
    pieText = "percent"
    pieTooltip = "focus"

  # populate table
  for i in [0...H5.Data.states.length]
    estado = H5.Data.states[i]
    data = [estado]
    data[1] = sumValues(H5.Data.states[i])
    @data.addRow data

  @changeTitle selectMonths.options[H5.Data.selectedMonth].label + ", " + H5.Data.selectedYear

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
      title: "Área km²"
    animation: H5.Data.animate

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
    export: true
    table: true
    minimize: true
    maximize: true
)

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
    maxDate = firstPeriod
    for key, reg of  H5.DB.cloud.data.nuvem
      do (reg) ->
        if reg.date >= firstPeriod and reg.date <= secondPeriod and reg.month is month
          if reg.date >= maxDate
            maxDate = reg.date
            percent = reg.value
            return false

    return Math.round(percent * 100)

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Mês"
  for i in [0...@options.period]
    @data.addColumn "number", H5.Data.periods[i]

  for month of H5.Data.months
    data = [H5.Data.months[month]]
    month = parseInt month
    if 7 <= (month + 7) <= 11 then month+= 7 else month-= 5
    for i in [1..@options.period]
      data[i] = sumValues(H5.Data.thisProdesYear - i + 1, month)
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
    animation: H5.Data.animate

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Data.totalPeriods - 4
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# QUICK BTNS 2
lastSelectedRegion = ""
$("#quick2 a").on "click", (e) ->
  e.preventDefault()

  return if H5.Data.state2 is this.id

  H5.Data.state2 = this.id

  # clean all selection
  $(this).each ->
    $("a").removeClass "active"

  $(this).addClass "active"

  # chart10.drawChart()

  # H5.Data.changed = true

# #}}
# CHART10 {{{
chart10 = new H5.Charts.GoogleCharts  (
  type: "Line"
  container: "chart10"
  title: "Taxa de desmatamento PRODES em Terras Indígenas"
  loadingImage: '<img src="' + H5.Data.domanin  + '/assets/img/spinner.gif" id="loading_spinner" style="display: inline; padding-top:90px;" title="">'
  buttons:
    export: true
    table: true
    minimize: true
    maximize: true
)


chart10._consultBtn = document.getElementById('consultBtn')

chart10._shapesSlct = document.getElementById('shapesSlct')
chart10._shapesSlct.options[0].selected = true
chart10._ratesSlct = document.getElementById('ratesSlct')
chart10._shapesSlct.options[0].selected = true

chart10._dateBegin = document.getElementById('dateBegin')
chart10._dateEnd = document.getElementById('dateFinish')

chart10._stateGroup = document.getElementById('quick2').children
chart10._state = 'Brasil'


$(chart10._consultBtn).on "click", (event) ->
  chart10.drawChart()

$.each chart10._stateGroup, ()->
  $(@).on "click", (event) ->
    chart10._state = $(@).children('span').html() ? 'Brasil'
    # chart10.drawChart()

chart10.drawChart = ->
  createTable = (state) =>
    sum = 0
    for day in [1..daysInMonth]
      $.each H5.DB.diary.data.states[state], (key, reg) ->
        if firstPeriod <= reg.date <= secondPeriod and reg.day is day
          sum += reg.area
          return false
      @data.setValue (day - 1), 1, Math.round((@data.getValue((day - 1), 1) + sum) * 100) / 100

  @createDataTable()

  @data.addColumn "string", "Ano"
  @data.addColumn "number", "Área em km²"

  data = []

  areaSelected = chart10._shapesSlct.value
  rateSelected = chart10._ratesSlct.value
  dateBegin = chart10._dateBegin.value
  dateEnd = chart10._dateEnd.value
  if chart10._state isnt 'Brasil'
    state = "'" + chart10._state + "',"
  else
    state = ''


  shapes =
    "terra_indigena": "Terras Indígenas"
    "uc_sustentavel": "Unidade de Conservação de uso sustentável"
    "uc_integral": "Unidade de Conservação de proteção integral"
    "assentamento": "Assentamento"
    "floresta": "Floresta Pública"
    "dominio_publico": "Domínio Estadual"

  rates =
    "0": "DETER"
    "1": "PRODES"


  if rateSelected is '1'
    stateData = H5.DB.dado_prodes_consolidado.data.states[H5.Data.state2]

    switch areaSelected
      when "terra_indigena"
        for year in ["2010", "2011", "2012", "2013"]
          data[0] = year
          data[1] = parseFloat stateData[year].terra_indigena.toFixed(2)
          @data.addRow data
        break
      when "assentamento"
        for year in ["2010", "2011", "2012", "2013"]
          data[0] = year
          data[1] = parseFloat stateData[year].assentamento.toFixed(2)
          @data.addRow data
        break
      when "floresta"
        for year in ["2010", "2011", "2012", "2013"]
          data[0] = year
          data[1] = parseFloat stateData[year].floresta.toFixed(2)
          @data.addRow data
        break
      when "uc_integral"
        for year in ["2010", "2011", "2012", "2013"]
          data[0] = year
          data[1] = parseFloat stateData[year].uc_integral.toFixed(2)
          @data.addRow data
        break
      when "uc_sustentavel"
        for year in ["2010", "2011", "2012", "2013"]
          data[0] = year
          data[1] = parseFloat stateData[year].uc_sustentavel.toFixed(2)
          @data.addRow data
        break
      when "dominio_publico"
        for year in ["2010", "2011", "2012", "2013"]
          data[0] = year
          data[1] = parseFloat stateData[year].uc_sustentavel.toFixed(2)
          @data.addRow data
        break

  else

    if !$("#loading").is ':visible'
      @_loadScreen()

    deter_area

    switch areaSelected
      when 'terra_indigena'
        deter_area = "'" + 'terra_indigena'
        break
      when 'assentamento'
        deter_area = "'" + 'assentamento'
        break
      when 'floresta'
        deter_area = "'" + 'floresta_publica'
        break
      when 'uc_integral'
        deter_area = "'" + 'unidade_conservacao'
        break
      when 'uc_sustentavel'
        deter_area = "'" + 'unidade_conservacao'
        break
      else deter_area = ''

    deter_area_state = if deter_area isnt '' then deter_area + "'," + state + "'" else state  + "'"

    timeBegin = $.datepicker.parseDate('dd/mm/yy',dateBegin)
    timeEnd = $.datepicker.parseDate('dd/mm/yy',dateEnd)

    timeBetween = (timeEnd - timeBegin) / 1000 / 60 / 60 / 24

    partialBegin = new Date(timeBegin)
    partialEnd = new Date(timeBegin)

    if state isnt ""
      if areaSelected is 'uc_integral'
        function_name = 'dados_deter_pi'
      else if areaSelected is 'uc_sustentavel'
        function_name = 'dados_deter_us'
      else if areaSelected is 'dominio_publico'
        function_name = 'dados_deter_total_outros'
      else
        function_name = 'dados_deter'
    else
      if areaSelected is 'dominio_publico'
        function_name = 'dados_deter_total_outros_brasil'
      else
        function_name = 'dados_deter_brasil'

    deter_field = ''
    deter_table = function_name + "(" +
            deter_area_state +
            $.datepicker.formatDate('dd/mm/yy',partialBegin) + "','" +
            $.datepicker.formatDate('dd/mm/yy',partialBegin) + "') AS (resultado float)"

    months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

    if timeBetween < 50 # about a months and a half
      console.log 'time to print by days'

      while partialEnd.setDate(partialEnd.getDate() + 1) < timeEnd
        deter_field += "(select * from " + function_name + "(" +
            deter_area_state +
            $.datepicker.formatDate('dd/mm/yy',partialBegin) + "','" +
            $.datepicker.formatDate('dd/mm/yy',partialEnd) + "') AS (resultado float)) as \"" + partialBegin.getDate() + "/" + months[partialBegin.getMonth()] + "\","

        partialBegin = new Date(partialEnd)

      partialEnd = timeEnd
      deter_field += "(select * from " + function_name + "(" +
          deter_area_state +
          $.datepicker.formatDate('dd/mm/yy',partialBegin) + "','" +
          $.datepicker.formatDate('dd/mm/yy',partialEnd) + "') AS (resultado float)) as \"" + partialBegin.getDate() + "/" + months[partialBegin.getMonth()] + "\""

    else if timeBetween < 730 # 2 years
      console.log 'time to print by months'

      partialEnd.setDate(1)

      while partialEnd.setMonth(partialEnd.getMonth() + 1) < timeEnd
        deter_field += "(select * from " + function_name + "(" +
            deter_area_state +
            $.datepicker.formatDate('dd/mm/yy',partialBegin) + "','" +
            $.datepicker.formatDate('dd/mm/yy',partialEnd) + "') AS (resultado float)) as \"" + months[partialBegin.getMonth()] + "/" + partialBegin.getFullYear() + "\","

        partialBegin = new Date(partialEnd)

      partialEnd = timeEnd
      deter_field += "(select * from " + function_name + "(" +
          deter_area_state +
          $.datepicker.formatDate('dd/mm/yy',partialBegin) + "','" +
          $.datepicker.formatDate('dd/mm/yy',partialEnd) + "') AS (resultado float)) as \"" + months[partialBegin.getMonth()] + "/" + partialBegin.getFullYear() + "\""

    else
      console.log 'time to print by years'

      partialEnd.setDate(1)
      partialEnd.setMonth(0)

      while partialEnd.setFullYear(partialEnd.getFullYear() + 1) < timeEnd
        deter_field += "(select * from " + function_name + "(" +
          deter_area_state +
          $.datepicker.formatDate('dd/mm/yy',partialBegin) + "','" +
          $.datepicker.formatDate('dd/mm/yy',partialEnd) + "') AS (resultado float)) as \"" + partialBegin.getFullYear() + "\","

        partialBegin = new Date(partialEnd)

      partialEnd = timeEnd
      deter_field += "(select * from " + function_name + "(" +
          deter_area_state +
          $.datepicker.formatDate('dd/mm/yy',partialBegin) + "','" +
          $.datepicker.formatDate('dd/mm/yy',partialEnd) + "') AS (resultado float)) as \"" + partialBegin.getFullYear() + "\""


    # getting values from the database
    rest = new H5.Rest (
      url: H5.Data.restURL
      fields: deter_field
      table: deter_table
      restService: "ws_selectonlyquery.php"
    )

    $.each rest.data[0], (field,result)=>
      data[0] = field.toString()
      data[1] = if result then parseFloat result.toFixed(2) else 0
      @data.addRow data



  @changeTitle "Taxas de Desmatamento " + rates[rateSelected] + "  em " + shapes[areaSelected] + " - [2010 - 2013]"

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
      title: "Área km²"
    animation: H5.Data.animate

  @_chartScreen()

  @chart.draw @data, options

#}}}
# CHART11 {{{
chart11 = new H5.Charts.GoogleCharts  (
  type: "SteppedArea"
  container: "chart11"
  period: 1
  title: "Taxa de desmatamento PRODES - [2010 - 2013]"
  buttons:
    minusplus: true
    export: true
    table: true
    minimize: true
    maximize: true
)

chart11._addBtn.onclick = ->
  chart11.options.period++
  chart11.drawChart()

chart11._delBtn.onclick = ->
  chart11.options.period--
  chart11.drawChart()


chart11.drawChart = ->
  createTable = (states) =>
    sum = 0
    totalsum = 0
    data = []
    i = 1

    period = []

    for j in [0..@options.period + 3]
      period[j] = H5.Data.years[j]

    for year in period
      data[0] = year
      for rate in ["terra_indigena" , "assentamento", "floresta", "uc_integral", "uc_sustentavel"]
        for state in H5.Data.statesProdes
          estado = H5.DB.dado_prodes_consolidado.data.states[state]
          sum += estado[year][rate]

        data[i] = parseFloat sum.toFixed(2)
        i++
        sum = 0

      i = 1
      @data.addRow data
      @data.addRow [null, null, null, null, null, null]

    @data.removeRow(@data.getNumberOfRows() - 1)
  # create an empty table
  @createDataTable()

  @data.addColumn "string", "Ano"
  @data.addColumn "number", "Terra indígena em km²"
  @data.addColumn "number", "Assentamento em km²"
  @data.addColumn "number", "Terras Arrecadadas em km²"
  @data.addColumn "number", "UC Inegral em km²"
  @data.addColumn "number", "UC Sustentável em km²"

  data = []

  # populate table with real data
  createTable "nenhumEstado"

  @changeTitle "Taxas de Desmatamento PRODES  em áreas específicas - [" + H5.Data.years[@options.period + 3] + " - " + H5.Data.years[0] + "]"

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    focusTarget: "category"
    connectSteps: "false"
    chartArea:
      width: "70%"
      height: "80%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#FF5454', '#C7A258', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']
    vAxis:
      title: "Área em km2"
    isStacked: true
    animation: H5.Data.animate

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_delBtn.disabled = @options.period < 2
    @_addBtn.disabled = @options.period >= 5

  @chart.draw @data, options
#}}}
# CHART12 {{{
chart12 = new H5.Charts.GoogleCharts(
  type: "Pie"
  container: "chart12"
  period: 0
  buttons:
    arrows: true
    export: true
    table: true
    minimize: true
    maximize: true
)

chart12._leftBtn.onclick = ->
  chart12.options.period++
  chart12.drawChart()

chart12._rightBtn.onclick = ->
  chart12.options.period--
  chart12.drawChart()

# years = ["2010", "2011", "2012", "2013"]
years = H5.Data.years

chart12.drawChart = ->
  createTable = (states) =>
    data = []
    sumFederal = 0
    sumEstadual = 0
    # years = ["2010", "2011", "2012", "2013"]
    years = H5.Data.years
    year = years[chart12.options.period]

    for state in H5.Data.statesProdes
      for territory in ['uc_sustentavel', 'uc_integral', 'terra_indigena', 'floresta', 'assentamento', 'dominio']
        switch territory
          when 'uc_sustentavel', 'uc_integral', 'terra_indigena', 'floresta'
            estado = H5.DB.dado_prodes_consolidado.data.states[state]
            sumFederal += estado[year][territory]
          when 'assentamento', 'dominio'
            estado = H5.DB.dado_prodes_consolidado.data.states[state]
            sumEstadual += estado[year][territory]

    for rate in ["federal" , "estadual"]
      if rate is "federal"
        data[0] = "Territórios de Competência Federal"
        data[1] = parseFloat sumFederal.toFixed(2)
      else
        data[0] = "Territórios de Competência Estadual"
        data[1] = parseFloat sumEstadual.toFixed(2)

      @data.addRow data

  # create an empty table
  @createDataTable()

  @data.addColumn "string", "Comparação"
  @data.addColumn "number", "Área em km²"

  # populate table with real data
  createTable "nenhumEstado"

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    chartArea:
      width: "90%"
      height: "80%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#FF5454', '#C7A258', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']

  @changeTitle "Distribuição de Detecções por Competência de Fiscalização [" + H5.Data.years[chart12.options.period] + "]"

  # Disabling the buttons while the chart is drawing.
  @_rightBtn.disabled = true
  @_leftBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_rightBtn.disabled = @options.period < 1
    @_leftBtn.disabled = @options.period >= 8

  @chart.draw @data, options
#}}}
# CHART13 {{{
chart13 = new H5.Charts.GoogleCharts(
  type: "Pie"
  container: "chart13"
  period: 0
  buttons:
    arrows: true
    export: true
    table: true
    minimize: true
    maximize: true
)

# chart13.changeTitle "Taxas de desmatamento PRODES em 2012"

chart13._leftBtn.onclick = ->
  chart13.options.period++
  chart13.drawChart()

chart13._rightBtn.onclick = ->
  chart13.options.period--
  chart13.drawChart()

# years = ["2010", "2011", "2012", "2013"]
years = H5.Data.years

chart13.drawChart = ->
  createTable = (states) =>
    data = []
    sum = 0
    # years = ["2010", "2011", "2012", "2013"]
    years = H5.Data.years
    year = years[chart12.options.period]
    for rate in ["terra_indigena" , "floresta", "uc_integral", "uc_sustentavel"]
      switch rate
        when "terra_indigena"
          data[0] = "Terras Indígenas"
        # when "assentamento"
        #   data[0] = "Assentamentos"
        when "floresta"
          data[0] = "Terras Arrecadadas"
        when "uc_integral"
          data[0] = "UC Integral"
        when "uc_sustentavel"
          data[0] = "UC Sustentável"
      for state in H5.Data.statesProdes
        estado = H5.DB.dado_prodes_consolidado.data.states[state]
        sum += estado[year][rate]
      data[1] = parseFloat sum.toFixed(2)
      sum = 0
      @data.addRow data

  # create an empty table
  @createDataTable()

  @data.addColumn "string", "Comparação"
  @data.addColumn "number", "Área em km²"

  # populate table with real data
  createTable "nenhumEstado"

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    chartArea:
      width: "90%"
      height: "80%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#FF5454', '#C7A258', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']

  @changeTitle "Território de Competência Federal em " + years[@options.period]

  # Disabling the buttons while the chart is drawing.
  @_rightBtn.disabled = true
  @_leftBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_rightBtn.disabled = @options.period < 1
    @_leftBtn.disabled = @options.period >= 8

  @chart.draw @data, options
#}}}
# CHART14 {{{
chart14 = new H5.Charts.GoogleCharts(
  type: "Pie"
  container: "chart14"
  period: 0
  buttons:
    arrows: true
    export: true
    table: true
    minimize: true
    maximize: true
)

chart14._leftBtn.onclick = ->
  chart14.options.period++
  chart14.drawChart()

chart14._rightBtn.onclick = ->
  chart14.options.period--
  chart14.drawChart()

years = H5.Data.years

chart14.drawChart = ->
  createTable = (states) =>
    data = []
    sum = 0
    sumUC = 0

    years = H5.Data.years
    year = years[chart14.options.period]
    for rate in [ "assentamento", "uc_integral_estadual", "uc_sustentavel_estadual", "dominio" ]
      switch rate
        when "assentamento"
          data[0] = "Assentamentos"
        when "uc_integral_estadual"
          data[0] = "UC Integral"
        when "uc_sustentavel_estadual"
          data[0] = "UC Federal"
        when "dominio"
          data[0] = "Demais Territórios do Estado"
      for state in H5.Data.statesProdes
        estado = H5.DB.dado_prodes_consolidado.data.states[state]
        sum += estado[year][rate]
        if rate is 'dominio'
          sumUC += estado[year]['uc_integral_estadual'] + estado[year]['uc_sustentavel_estadual']

      data[1] = parseFloat sum.toFixed(2) - parseFloat sumUC.toFixed(2)
      sum = 0
      @data.addRow data

  # create an empty table
  @createDataTable()

  @data.addColumn "string", "Comparação"
  @data.addColumn "number", "Área em km²"

  # populate table with real data
  createTable "nenhumEstado"

  options =
    title: ""
    titleTextStyle:
      color: "#333"
      fontSize: 13
    backgroundColor: "transparent"
    chartArea:
      width: "90%"
      height: "80%"
    colors: ['#3ABCFC', '#FC2121', '#D0FC3F', '#FCAC0A',
             '#FF5454', '#C7A258', '#CBE968', '#FABB3D',
             '#77A4BD', '#CC6C6C', '#A6B576', '#C7A258']

  @changeTitle "Território de Competência Estadual em " + years[@options.period]

  # Disabling the buttons while the chart is drawing.
  @_rightBtn.disabled = true
  @_leftBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_rightBtn.disabled = @options.period < 1
    @_leftBtn.disabled = @options.period >= 8

  @chart.draw @data, options
#}}}
# SPARK1 {{{
spark1 = new H5.Charts.Sparks(
  container: "spark1"
  title: "Total Mensal"
)

spark1.drawChart = ->
  #Create array with values
  createTable = (state) =>
    dayValue = 0
    for day in [1..daysInMonth]
      for key, reg of H5.DB.diary.data.states[state]
        do (reg) ->
          if firstPeriod <= reg.date <= secondPeriod and reg.day is day
            dayValue += reg.area
            return false
      data[(day-1)] = Math.round((data[(day-1)] + dayValue) * 100)/100

  daysInMonth = new Date(H5.Data.selectedYear, H5.Data.selectedMonth + 1, 0).getDate()
  firstPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, 1)
  secondPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, daysInMonth)
  data = []

  # populate table with 0
  for day in [1..daysInMonth]
    data[(day-1)] = 0

  # populate table with real values
  if H5.Data.state is "brasil"
    for name, state of H5.DB.diary.data.states
      createTable name
  else
    createTable H5.Data.state

  value = data[daysInMonth-1]
  @updateInfo data, value
#}}}
# SPARK2 {{{
spark2 = new H5.Charts.Sparks(
  container: "spark2"
  title: "Total Período"
)

spark2.drawChart = ->
  #Create array with values
  # sum values
  sumValues = (year, month) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    if month > 6
      secondPeriod = new Date(year-1, month+1, 0)
    else if month != H5.Data.thisMonth
      secondPeriod = new Date(year, month+1, 0)
    else
      secondPeriod = new Date(year, month, H5.Data.thisDay)
    if H5.Data.state is "brasil"
      for name, state of H5.DB.diary.data.states
        for key, reg of state
          if firstPeriod <= reg.date <= secondPeriod and reg.month == month
            sum += reg.area
    else
      for key, reg of H5.DB.diary.data.states[H5.Data.state]
        if firstPeriod <= reg.date <= secondPeriod and reg.month == month
          sum += reg.area

    return Math.round(sum * 100) / 100

  # init table
  data = []

  for month of H5.Data.months

    month = parseInt month
    year = if H5.Data.selectedMonth < 7 then H5.Data.selectedYear else H5.Data.selectedYear + 1
    count = parseInt H5.Data.selectedMonth

    if count >= 7 then count-= 7 else count+= 5

    if month <= count
      if 7 <= (month + 7) <= 11 then month+= 7 else month-= 5
      data.push sumValues(year, month)
    else
      data.push 0

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

knob1.drawChart = ->
  # sum values
  periodDeforesttionRate = (year, month) ->
    sumValues = (date) ->
      sum = 0
      if H5.Data.state is "brasil"
        for state of H5.DB.diary.data.states
          for reg of H5.DB.diary.data.states[state]
            reg = H5.DB.diary.data.states[state][reg]
            if date.getFullYear() <= reg.year <= date.getFullYear() and reg.month is date.getMonth()
              sum += reg.area
      else
        for reg of H5.DB.diary.data.states[H5.Data.state]
          reg = H5.DB.diary.data.states[H5.Data.state][reg]
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

  value = periodDeforesttionRate(
    H5.Data.selectedYear, H5.Data.selectedMonth
  )
  @updateInfo value
#}}}
# KNOB2 {{{
knob2 = new H5.Charts.Knobs(
  container: "knob2"
  title: "Taxa VMA"
  popover: "Taxa de variação em relação ao mês anterior"
)

knob2.drawChart = ->
  # sum values
  periodDeforesttionRate = (year, month) ->
    sumValues = (date) ->
      sum = 0
      if H5.Data.state is "brasil"
        for state of H5.DB.diary.data.states
          for reg of H5.DB.diary.data.states[state]
            reg = H5.DB.diary.data.states[state][reg]
            if date.getFullYear() <= reg.year <= date.getFullYear() and reg.month is date.getMonth()
              sum += reg.area
      else
        for reg of H5.DB.diary.data.states[H5.Data.state]
          reg = H5.DB.diary.data.states[H5.Data.state][reg]
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

  value = periodDeforesttionRate(
    H5.Data.selectedYear, H5.Data.selectedMonth
  )
  @updateInfo value
#}}}
# KNOB3 {{{
knob3 = new H5.Charts.Knobs(
  container: "knob3"
  title: "Taxa VPA"
  popover: "Taxa de variação em relação ao período PRODES anterior"
)

knob3.drawChart = ->
  # sum values
  periodDeforesttionAvgRate = (year, month) ->
    sumValues = (firstPeriod, secondPeriod) ->
      sum = 0
      if H5.Data.state is "brasil"
        for name, state of H5.DB.diary.data.states
          for key, reg of state
            if firstPeriod <= reg.date <= secondPeriod
              sum += reg.area
      else
        for key, reg of H5.DB.diary.data.states[H5.Data.state]
          if firstPeriod <= reg.date <= secondPeriod
            sum += reg.area
      return Math.round(sum * 100) / 100

    if month > 6 then year++ else year

    sumPeriods = (year, month) ->
      firstPeriod = new Date(year-1, 7, 1)
      if month > 6
        if month is H5.Data.thisMonth
          # secondPeriod = new Date(year-1, month, H5.Data.thisDay)
          secondPeriod = new Date(year-1, month + 1,  1 - 1)
        else
          secondPeriod = new Date(year-1, month+1, 0)
      else
        if month is H5.Data.thisMonth
          # secondPeriod = new Date(year, month, H5.Data.thisDay)
          secondPeriod = new Date(year, month + 1, 1 - 1)
        else
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

  value = periodDeforesttionAvgRate(
    H5.Data.selectedYear, H5.Data.selectedMonth
  )
  @updateInfo value
#}}}
# chartDailyEmbargo {{{
chartDailyEmbargo = new H5.Charts.GoogleCharts (
  type: "Line"
  container: "chart-daily-embargo"
  title: "Embargos: Índice Diário"
  buttons:
    export: true
    table: true
    minimize: true
    maximize: true
)

chartDailyEmbargo.drawChart = ->
  createTable = (state) =>
    sum = 0
    for day in [1..daysInMonth]
      for key, reg of H5.DB.embargo.data.states[state]
        do (reg) ->
          if firstPeriod <= reg.date <= secondPeriod and reg.day is day
            sum += reg.area
            return false
      @data.setValue (day - 1), 1, Math.round((@data.getValue((day - 1), 1) + sum) * 100) / 100

  # create an empty table
  @createDataTable()

  @data.addColumn "number", "Dia"
  @data.addColumn "number", "Área"

  daysInMonth = new Date(H5.Data.selectedYear, H5.Data.selectedMonth + 1, 0).getDate()
  firstPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, 1)
  secondPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, daysInMonth)
  data = []

  # populate table with 0
  for day in [1..daysInMonth]
    data[0] = day
    data[1] = 0
    @data.addRow data

  # populate table with real values
  if H5.Data.state is "brasil"
    for name of H5.DB.embargo.data.states
      createTable name
  else
    createTable H5.Data.state

  months =
    0: "Janeiro"
    1: "Fevereiro"
    2: "Março"
    3: "Abril"
    4: "Maio"
    5: "Junho"
    6: "Julho"
    7: "Agosto"
    8: "Setembro"
    9: "Outubro"
    10: "Novembro"
    11: "Dezembro"

  @changeTitle "Embargos: Índice Diário [" + months[H5.Data.selectedMonth] + "]"

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
      title: "Área km²"
    hAxis:
      title: "Dias"
      gridlines:
        color: "#CCC"
        count: daysInMonth / 5
    animation: H5.Data.animate

  @chart.draw @data, options
#}}}
# chartMonthlyEmbargo {{{
chartMonthlyEmbargo = new H5.Charts.GoogleCharts(
  type: "Area"
  container: "chart-monthly-embargo"
  period: 2
  title: "Embargos: Índice Mensal"
  buttons:
    minusplus: true
    export: true
    table: true
    minimize: true
    maximize: true
)

chartMonthlyEmbargo._addBtn.onclick = ->
  chartMonthlyEmbargo.options.period++
  chartMonthlyEmbargo.drawChart()

chartMonthlyEmbargo._delBtn.onclick = ->
  chartMonthlyEmbargo.options.period--
  chartMonthlyEmbargo.drawChart()

chartMonthlyEmbargo.drawChart = ->
  # sum values
  sumValues = (year, month) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    if H5.Data.state is "brasil"
      for name, state of H5.DB.embargo.data.states
        for key, reg of state
          if firstPeriod <= reg.date <= secondPeriod and reg.month == month
            sum += reg.area
    else
      for key,reg of H5.DB.embargo.data.states[H5.Data.state]
        if firstPeriod <= reg.date <= secondPeriod and reg.month == month
          sum += reg.area

    return Math.round(sum * 100) / 100

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Mês"
  for i in [0...@options.period]
    @data.addColumn "number", H5.Data.periods[i]

  for month of H5.Data.months
    data = [H5.Data.months[month]]
    month = parseInt month
    if 7 <= (month + 7) <= 11 then month+= 7 else month-= 5
    for i in [1..@options.period]
      data[i] = sumValues(H5.Data.thisProdesYear - i + 1, month)
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
      title: "Área km²"
    animation: H5.Data.animate

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Data.totalPeriods
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# chartAnnualEmbargo {{{
chartAnnualEmbargo = new H5.Charts.GoogleCharts(
  type: "Bar"
  container: "chart-annual-embargo"
  period: 1
  title: "Embargos: Índice Períodos"
  buttons:
    minusplus: true
    export: true
    table: true
    minimize: true
    maximize: true
)

chartAnnualEmbargo._addBtn.onclick = ->
  chartAnnualEmbargo.options.period++
  chartAnnualEmbargo.drawChart()

chartAnnualEmbargo._delBtn.onclick = ->
  chartAnnualEmbargo.options.period--
  chartAnnualEmbargo.drawChart()

chartAnnualEmbargo.drawChart = ->
  # sum values
  sumValues = (firstPeriod, secondPeriod) ->
    sum = 0
    if H5.Data.state is "brasil"
      for name, state of H5.DB.embargo.data.states
        for key, reg of state
          if firstPeriod <= reg.date <= secondPeriod
            sum += reg.area
    else
      for key, reg of H5.DB.embargo.data.states[H5.Data.state]
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
    month = H5.Data.selectedMonth
    firstPeriod = new Date(year - 1, 7, 1)
    if month > 6
      if month is H5.Data.thisMonth
        secondPeriod = new Date(year-1, month, H5.Data.thisDay)
      else
        secondPeriod = new Date(year-1, month+1, 0)
    else
      if month is H5.Data.thisMonth
        secondPeriod = new Date(year, month, H5.Data.thisDay)
      else
        secondPeriod = new Date(year, month+1, 0)
    sumValues firstPeriod, secondPeriod

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Ano"
  @data.addColumn "number", "Parcial"
  @data.addColumn "number", "Diferença"

  # populate table
  for i in [0..@options.period]
    data = [H5.Data.periods[i]]
    sumTotal = sumTotalValues(H5.Data.thisProdesYear - i)
    sumAvg = sumAvgValues(H5.Data.thisProdesYear - i)
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
      title: "Período PRODES"
    hAxis:
      title: "Área km²"
    bar:
      groupWidth: "80%"
    isStacked: true
    animation: H5.Data.animate

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Data.totalPeriods - 1
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# chartStatesEmbargo {{{
chartStatesEmbargo = new H5.Charts.GoogleCharts(
  type: "Column"
  container: "chart-states-embargo"
  period: 2
  title: "Embargos: UFs"
  buttons:
    minusplus: true
    export: true
    table: true
    minimize: true
    maximize: true
)

chartStatesEmbargo._addBtn.onclick = ->
  chartStatesEmbargo.options.period++
  chartStatesEmbargo.drawChart()

chartStatesEmbargo._delBtn.onclick = ->
  chartStatesEmbargo.options.period--
  chartStatesEmbargo.drawChart()

chartStatesEmbargo.drawChart = ->
  # sum values
  sumValues = (state, year) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    secondPeriod = new Date(year , 7, 0)
    for key, reg of H5.DB.embargo.data.states[state]
      if firstPeriod <= reg.date <= secondPeriod
        sum += reg.area
    Math.round(sum * 100) / 100

  # create an empty table
  @createDataTable()

  # init table
  @data.addColumn "string", "Estado"
  for i in [0...@options.period]
    @data.addColumn "number", H5.Data.periods[i]

  # populate table with real values
  if H5.Data.state is "brasil"
    for name, state of H5.DB.embargo.data.states
      data = [name]
      for j in [1..@options.period]
        data[j] = sumValues(name, H5.Data.thisProdesYear - j + 1)
      @data.addRow data
  else
    data = [H5.Data.state]
    for j in [1..@options.period]
      data[j] = sumValues(H5.Data.state, H5.Data.thisProdesYear - j + 1)
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
      title: "Área km²"
    animation: H5.Data.animate

  # Disabling the buttons while the chart is drawing.
  @_addBtn.disabled = true
  @_delBtn.disabled = true

  google.visualization.events.addListener @chart, "ready", =>
    # Enabling only relevant buttons.
    @_addBtn.disabled = @options.period > H5.Data.totalPeriods
    @_delBtn.disabled = @options.period < 2

  @chart.draw @data, options
#}}}
# sparkTVAAEmbargo {{{
sparkTVAAEmbargo = new H5.Charts.Knobs(
  container: "spark-tvaa-embargo"
  title: "Taxa VAA"
  popover: "Taxa de variação em relação ao mesmo mês do ano anterior"
)

sparkTVAAEmbargo.drawChart = ->
  # sum values
  periodDeforesttionRate = (year, month) ->
    sumValues = (date) ->
      sum = 0
      if H5.Data.state is "brasil"
        for state of H5.DB.embargo.data.states
          for reg of H5.DB.embargo.data.states[state]
            reg = H5.DB.embargo.data.states[state][reg]
            if date.getFullYear() <= reg.year <= date.getFullYear() and reg.month is date.getMonth()
              sum += reg.area
      else
        for reg of H5.DB.embargo.data.states[H5.Data.state]
          reg = H5.DB.embargo.data.states[H5.Data.state][reg]
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

  value = periodDeforesttionRate(
    H5.Data.selectedYear, H5.Data.selectedMonth
  )
  @updateInfo value
#}}}
# sparkTVMAEmbargo {{{
sparkTVMAEmbargo = new H5.Charts.Knobs(
  container: "spark-tvma-embargo"
  title: "Taxa VMA"
  popover: "Taxa de variação em relação ao mês anterior"
)

sparkTVMAEmbargo.drawChart = ->
  # sum values
  periodDeforesttionRate = (year, month) ->
    sumValues = (date) ->
      sum = 0
      if H5.Data.state is "brasil"
        for state of H5.DB.embargo.data.states
          for reg of H5.DB.embargo.data.states[state]
            reg = H5.DB.embargo.data.states[state][reg]
            if date.getFullYear() <= reg.year <= date.getFullYear() and reg.month is date.getMonth()
              sum += reg.area
      else
        for reg of H5.DB.embargo.data.states[H5.Data.state]
          reg = H5.DB.embargo.data.states[H5.Data.state][reg]
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

  value = periodDeforesttionRate(
    H5.Data.selectedYear, H5.Data.selectedMonth
  )
  @updateInfo value
#}}}
# sparkTVPAEmbargo {{{
sparkTVPAEmbargo = new H5.Charts.Knobs(
  container: "spark-tvpa-embargo"
  title: "Taxa VPA"
  popover: "Taxa de variação em relação ao período PRODES anterior"
)

sparkTVPAEmbargo.drawChart = ->
  # sum values
  periodDeforesttionAvgRate = (year, month) ->
    sumValues = (firstPeriod, secondPeriod) ->
      sum = 0
      if H5.Data.state is "brasil"
        for name, state of H5.DB.embargo.data.states
          for key, reg of state
            if firstPeriod <= reg.date <= secondPeriod
              sum += reg.area
      else
        for key, reg of H5.DB.embargo.data.states[H5.Data.state]
          if firstPeriod <= reg.date <= secondPeriod
            sum += reg.area
      return Math.round(sum * 100) / 100

    if month > 6 then year++ else year

    sumPeriods = (year, month) ->
      firstPeriod = new Date(year-1, 7, 1)
      if month > 6
        if month is H5.Data.thisMonth
          secondPeriod = new Date(year-1, month, H5.Data.thisDay)
        else
          secondPeriod = new Date(year-1, month+1, 0)
      else
        if month is H5.Data.thisMonth
          secondPeriod = new Date(year, month, H5.Data.thisDay)
        else
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

  value = periodDeforesttionAvgRate(
    H5.Data.selectedYear, H5.Data.selectedMonth
  )
  @updateInfo value
#}}}
# sparkMonthlyEmbargo {{{
sparkMonthlyEmbargo = new H5.Charts.Sparks(
  container: "spark-monthly-embargo"
  title: "Total Mensal"
)

sparkMonthlyEmbargo.drawChart = ->
  #Create array with values
  createTable = (state) =>
    dayValue = 0
    for day in [1..daysInMonth]
      for key, reg of H5.DB.embargo.data.states[state]
        do (reg) ->
          if firstPeriod <= reg.date <= secondPeriod and reg.day is day
            dayValue += reg.area
            return false
      data[(day-1)] = Math.round((data[(day-1)] + dayValue) * 100)/100

  daysInMonth = new Date(H5.Data.selectedYear, H5.Data.selectedMonth + 1, 0).getDate()
  firstPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, 1)
  secondPeriod = new Date(H5.Data.selectedYear, H5.Data.selectedMonth, daysInMonth)
  data = []

  # populate table with 0
  for day in [1..daysInMonth]
    data[(day-1)] = 0

  # populate table with real values
  if H5.Data.state is "brasil"
    for name, state of H5.DB.embargo.data.states
      createTable name
  else
    createTable H5.Data.state

  value = data[daysInMonth-1]
  @updateInfo data, value
#}}}
# sparkAnnualEmbargo {{{
sparkAnnualEmbargo = new H5.Charts.Sparks(
  container: "spark-annual-embargo"
  title: "Total Período"
)

sparkAnnualEmbargo.drawChart = ->
  #Create array with values
  # sum values
  sumValues = (year, month) ->
    sum = 0
    firstPeriod = new Date(year - 1, 7, 1)
    if month > 6
      secondPeriod = new Date(year-1, month+1, 0)
    else if month != H5.Data.thisMonth
      secondPeriod = new Date(year, month+1, 0)
    else
      secondPeriod = new Date(year, month, H5.Data.thisDay)
    if H5.Data.state is "brasil"
      for name, state of H5.DB.embargo.data.states
        for key, reg of state
          if firstPeriod <= reg.date <= secondPeriod and reg.month == month
            sum += reg.area
    else
      for key, reg of H5.DB.embargo.data.states[H5.Data.state]
        if firstPeriod <= reg.date <= secondPeriod and reg.month == month
          sum += reg.area

    return Math.round(sum * 100) / 100

  # init table
  data = []

  for month of H5.Data.months

    month = parseInt month
    year = if H5.Data.selectedMonth < 7 then H5.Data.selectedYear else H5.Data.selectedYear + 1
    count = parseInt H5.Data.selectedMonth

    if count >= 7 then count-= 7 else count+= 5

    if month <= count
      if 7 <= (month + 7) <= 11 then month+= 7 else month-= 5
      data.push sumValues(year, month)
    else
      data.push 0

  value = 0
  $.each data, ->
    value += this

  @updateInfo data, Math.round(value*100)/100
#}}}
# controllers {{{
reloadChartsDeter = ->
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

reloadChartsEmbargos = ->
  chartDailyEmbargo.drawChart()
  chartMonthlyEmbargo.drawChart()
  chartAnnualEmbargo.drawChart()
  chartStatesEmbargo.drawChart()
  sparkTVAAEmbargo.drawChart()
  sparkTVMAEmbargo.drawChart()
  sparkTVPAEmbargo.drawChart()
  sparkAnnualEmbargo.drawChart()
  sparkMonthlyEmbargo.drawChart()

# selects
selectYears = document.getElementById('yearsSlct')
selectMonths = document.getElementById('monthsSlct')
selectType= document.getElementById('typeSlct')

# charts containers
chartsDeter= document.getElementById('charts-deter')
chartsEmbargo= document.getElementById('charts-embargo')
sparksDeter= document.getElementById('sparks-deter')
sparksEmbargo= document.getElementById('sparks-embargo')
$(chartsEmbargo).hide()
$(sparksEmbargo).hide()

# make those options selected
selectedYear = if H5.Data.thisMonth < 7 then H5.Data.totalPeriods + 1 else H5.Data.totalPeriods
selectYears.options[selectedYear].selected = true
selectMonths.options[H5.Data.thisMonth].selected = true

# SELECTS
$(selectMonths).on "change", (e) ->
  e.preventDefault()
  H5.Data.selectedMonth = parseInt selectMonths.value
  # reload charts
  if H5.Data.selectedType is "embargos"
    reloadChartsEmbargos()
  else
    chart1.drawChart()
    chart3.drawChart()
    chart8.drawChart()
    knob1.drawChart()
    knob2.drawChart()
    knob3.drawChart()
    spark1.drawChart()
    spark2.drawChart()

$(selectYears).on "change", (e) ->
  e.preventDefault()
  H5.Data.selectedYear = parseInt selectYears.value

  # reload charts
  if H5.Data.selectedType is "embargos"
    reloadChartsEmbargos()
  else
    chart1.drawChart()
    chart3.drawChart()
    chart8.drawChart()
    knob1.drawChart()
    knob2.drawChart()
    knob3.drawChart()
    spark1.drawChart()
    spark2.drawChart()

  H5.Data.changed = true

# display only the "amazonia" entries
for region in H5.Data.regions.names
  $("#" + region).hide()
for state in H5.Data.regions.amazonia
  $("#" + state).show()

$(selectType).on "change", (e) ->
  e.preventDefault()

  if this.value is "deter"
    for region in H5.Data.regions.names
      $("#" + region).hide()
    for state in H5.Data.regions.norte
      $("#" + state).hide()
    for state in H5.Data.regions.sul
      $("#" + state).hide()
    for state in H5.Data.regions.nordeste
      $("#" + state).hide()
    for state in H5.Data.regions.sudeste
      $("#" + state).hide()
    for state in H5.Data.regions.centrooeste
      $("#" + state).hide()

    for state in H5.Data.regions.amazonia
      $("#" + state).show()

    $(chartsEmbargo).hide()
    $(sparksEmbargo).hide()
    $(chartsDeter).show()
    $(sparksDeter).show()
    $("#brasil").addClass "active"
    H5.Data.state = "brasil"
    reloadChartsDeter()

  else if this.value is "embargos"
    for region in H5.Data.regions.names
      $("#" + region).show()
    for state in H5.Data.regions.norte
      $("#" + state).hide()
    for state in H5.Data.regions.sul
      $("#" + state).hide()
    for state in H5.Data.regions.nordeste
      $("#" + state).hide()
    for state in H5.Data.regions.sudeste
      $("#" + state).hide()
    for state in H5.Data.regions.centrooeste
      $("#" + state).hide()
    $("#brasil").show()
    $(chartsDeter).hide()
    $(sparksDeter).hide()
    $(chartsEmbargo).show()
    $(sparksEmbargo).show()
    # reset icons
    for region in H5.Data.regions.names
      $("#" + region).children("i").prop("class", "icon-" + region)
      $("#" + region).removeClass "active"
      $("#brasil").addClass "active"
      H5.Data.state = "brasil"
    reloadChartsEmbargos()

  H5.Data.selectedType = this.value

# QUICK BTNS
lastSelectedRegion = ""
$("#quick1 a").on "click", (e) ->
  e.preventDefault()

  return if H5.Data.state is this.id

  H5.Data.state = this.id

  # clean all selection
  $(this).each ->
    $("a").removeClass "active"

  if H5.Data.selectedType is "embargos"
    regionToggle = (regions, fastHide) ->
      for region in regions
        if fastHide
          $("#" + region).toggle()
        else
          $("#" + region).fadeToggle(300)

    displayRegion = (region) ->
      regionToggle(H5.Data.regions.names, true)
      regionToggle(region)
      lastSelectedRegion = H5.Data.state
      $("#brasil").hide()

    enableRegion = (region, name) ->
      regionToggle(region, true)
      $("#" + name).addClass "active"
      iconElement = $("#" + name).children("i")
      iconElement.prop("class", "icon-" + H5.Data.state.toLowerCase())
      $("#brasil").show()

    # reset icons
    for region in H5.Data.regions.names
      $("#" + region).children("i").prop("class", "icon-" + region)

    switch H5.Data.state
      when "norte"
        displayRegion(H5.Data.regions.norte)
      when "nordeste"
        displayRegion(H5.Data.regions.nordeste)
      when "sul"
        displayRegion(H5.Data.regions.sul)
      when "sudeste"
        displayRegion(H5.Data.regions.sudeste)
      when "centrooeste"
        displayRegion(H5.Data.regions.centrooeste)
      when "brasil"
        # mark selected option
        $(this).addClass "active"
        reloadChartsEmbargos()
      else
        switch lastSelectedRegion
          when "norte"
            enableRegion(H5.Data.regions.norte, "norte")
          when "nordeste"
            enableRegion(H5.Data.regions.nordeste, "nordeste")
          when "sul"
            enableRegion(H5.Data.regions.sul, "sul")
          when "sudeste"
            enableRegion(H5.Data.regions.sudeste, "sudeste")
          when "centrooeste"
            enableRegion(H5.Data.regions.centrooeste, "centrooeste")
        regionToggle(H5.Data.regions.names)

        reloadChartsEmbargos()
  else
    $(this).addClass "active"
    reloadChartsDeter()

    H5.Data.changed = true
#}}
# # QUICK BTNS 2
# $("#quick3 a").on "click", (event) ->
# # $(".quick-btn a").on "click", (event) ->
#   event.preventDefault()

#   return if H5.Data.state3 is this.id

#   H5.Data.state2 = this.id

#   # clean all selection
#   $(@).each ->
#     $("a").removeClass "active"
#   # mark selected option
#   $(@).addClass "active"

#   # save the selected option
#   H5.Data.state3 = $(@).prop("id")

#   # reload charts
#   reloadChartsNewStats()

#   H5.Data.changed = true




$(document).ready ->
  chart10.drawChart()
  chart11.drawChart()
  chart12.drawChart()
  chart13.drawChart()
  chart14.drawChart()
  # BOOTSTRAP
  $("[rel=tooltip]").tooltip placement: "bottom"
  $(".alert").alert()
  # DISPLAY CHARTS AFTER LOADING
  reloadChartsDeter()

  # MISC
  # enable masonry plugin
  $("#charts-content").masonry
    # options
    itemSelector: ".chart"
    animationOptions:
      duration: 1000

  $("#prodes").hide()
# }}}
