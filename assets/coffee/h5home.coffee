if document.getElementById("login")
  $("#login").load("http://" + document.domain + "/painel/index.php/login")
  $("#login").hide()
  $("#configs").hide()
  # $("#prodes").hide()

$(document).ready ->

  #-------------------------------------------------------------------------
  # NAVBAR
  #-------------------------------------------------------------------------

  $(".dropdown-menu input, .dropdown-menu label").click (e) ->
    e.stopPropagation()

  $(".navbar a").on "click", (event) ->
    # clean all selection
    $(@).each ->
      $("a").parent().removeClass("active")
    # mark selected option
    $(@).parent().addClass("active")

    if $(@).prop("id") is "btn-map"
      $("#dash").hide()
      $("#login").hide()
      $("#prodes").hide()
      $("#configs").hide()
      $("#map").show()

      if H5.Data.changed
        if H5.Data.state is "brasil"
          qry = "ano='" + H5.Data.selectedYear + "'"
        else
          qry = "estado='" + H5.Data.state + "' AND ano='" + H5.Data.selectedYear + "'"

        H5.Map.layer.alerta.setOptions({where: qry})
        H5.Map.layer.clusters.setOptions({where: qry})
        H5.Map.layer.alerta.redraw()
        H5.Map.layer.clusters.redraw()

        H5.Data.changed = false

    else if $(@).prop("id") is "btn-charts"
      $("#login").hide()
      $("#map").hide()
      $("#prodes").hide()
      $("#configs").hide()
      $("#dash").show()
    else if $(@).prop("id") is "btn-login"
      $("#dash").hide()
      $("#login").show()
      $("#prodes").hide()
      $("#configs").hide()
      $("#map").show()
    else if $(@).prop("id") is "btn-charts2"
      $("#dash").hide()
      $("#map").hide()
      $("#login").hide()
      $("#configs").hide()
      $("#prodes").show()
    else if $(@).prop("id") is "btn-charts3"
      $("#dash").hide()
      $("#map").hide()
      $("#login").hide()
      $("#prodes").hide()
      $("#configs").show()

    $('.nav-collapse').collapse('hide')

    $("#username").mask("999.999.999-99")

  #-------------------------------------------------------------------------
  # MISC
  #-------------------------------------------------------------------------

  # Change the case to Letter case, ex: helmuth saatkamp to Helmuth Saatkamp
  String::toProperCase = ->
    @replace /\w\S*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

  # Round numbers function
  roundNumber = (number, digits) ->
    multiple = Math.pow(10, digits)
    rndedNum = Math.round(number * multiple) / multiple
    rndedNum

  # Animate load screen
  $(".loading").fadeOut 2000

  #-------------------------------------------------------------------------
  # Aba 2
  #-------------------------------------------------------------------------
  # $('#newstats .input-append.date').datepicker({})
  # $('#newstats .input-daterange').datepicker({format: "dd/mm/yyyy",language: "pt-BR"})

  # $('.selectpicker').selectpicker()

  $('#prodes .input-append.date').datepicker({format: "dd/mm/yyyy",language: "pt-BR", autoclose: true})
  $('#prodes .input-daterange').datepicker({format: "dd/mm/yyyy",language: "pt-BR", autoclose: true, cleanbtn: true})

  $("#dash").hide()
  $("#map").show()

  $("#dash").show()
  $("#map").hide()
  
  $('.selectpicker').selectpicker()
