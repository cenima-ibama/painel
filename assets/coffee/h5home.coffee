if document.getElementById("login")
  $("#login").load("http://" + document.domain + "/painel/index.php/login")
  $("#login").hide()

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
      $("#dash").show()
    else if $(@).prop("id") is "btn-login"
      $("#dash").hide()
      $("#map").show()
      $("#login").show()

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
