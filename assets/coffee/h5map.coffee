# OBJECT {{{
H5.Map =
  base: null
  layer: {}
  layerList: null

H5.Leaflet = {}
# }}}
# LAYERS {{{
bingKey = "AsyRHq25Hv8jQbrAIVSeZEifWbP6s1nq1RQfDeUf0ycdHogebEL7W2dxgFmPJc9h"
bingaerial = new L.BingLayer(bingKey,
  type: "Aerial"
  attribution: ""
)

bingroad = new L.BingLayer(bingKey,
  type: "Road"
  attribution: ""
)

binghybrid = new L.BingLayer(bingKey,
  type: "AerialWithLabels"
  attribution: ""
)

bingMini = new L.BingLayer(bingKey,
  type: "AerialWithLabels"
  attribution: ""
  minZoom: 1
  maxZoom: 11
)

openstreetUrl = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
openstreet = new L.TileLayer(openstreetUrl,
  maxZoom: 18
  attribution: ""
)

openmapquestUrl = "http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png"
openmapquestSub = ['otile1','otile2','otile3','otile4']
openmapquest = new L.TileLayer(openmapquestUrl,
  maxZoom: 18
  subdomains: openmapquestSub
)

rapidEye = new L.TileLayer("http://geo1.ibama.gov.br/geo/tmstest/{z}/{x}/{y}.png",
  tms: true
)

###
nuvem = new L.TileLayer.WMS("http://painel:painel@siscom.ibama.gov.br/geo-srv/cemam/wms",
  layers: "cemam:Daily_Cloud_With_Geometry"
  format: "image/png"
  transparent: true
)
###

# }}}
# SCREEN SIZE {{{
# update size of the map container
###
$( '#map' ).width( $( window ).width() )
$( '#map' ).height( $( window ).height() - $('#navbar').height())
###

$( '#dash' ).width("100%" )
$( '#dash' ).height("100%")

# Detect whether device supports orientationchange event,
# otherwise fall back to the resize event.
supportsOrientationChange = "onorientationchange" of window
orientationEvent = (if supportsOrientationChange then "orientationchange" else "resize")

# update chart if orientation or the size of the screen changed
window.addEventListener orientationEvent, (->
  ###
  $( '#map' ).width( $( window ).width() )
  $( '#map' ).height( $( window ).height() - $('#navbar').height())
  ###
  $( '#dash' ).width("100%" )
  $( '#dash' ).height("100%")   

), false
# }}}
# MAP LAYER {{{
H5.Map.base = new L.Map("map",
  center: new L.LatLng(-10.0, -58.0)
  zoom: 5
  layers: [binghybrid]
)

H5.Map.minimap = new L.Control.MiniMap(bingMini,
  toggleDisplay: true
  zoomLevelOffset: -4
  autoToggleDisplay: false
).addTo(H5.Map.base)

# add custom attribution
H5.Map.base.attributionControl.setPrefix "Hexgis Hash5"

# add scale
new L.control.scale().addTo(H5.Map.base)

# add fullscreen control
new L.control.fullscreen(
  position: 'topleft'
  title: 'Fullscreen'
).addTo(H5.Map.base)

new L.control.GeoSearch(
  provider: new L.GeoSearch.Provider.Google
  searchLabel: "Endereço, Estado - UF"
  notFoundMessage: "Endereço não encontrado."
  showMarker: false
).addTo(H5.Map.base)

new L.control.locate(
  position: "topleft"
  drawCircle: true
  follow: false
  stopFollowingOnDrag: false
  circleStyle: {}
  markerStyle: {}
  followCircleStyle: {}
  followMarkerStyle: {}
  metric: true
  onLocationError: (err) ->
    alert err.message

  onLocationOutsideMapBounds: (context) ->
    alert context.options.strings.outsideMapBoundsMsg

  setView: true
  strings:
    title: "Localizar minha posição"
    popup: "Você está a {distance} {unit} deste lugar"
    outsideMapBoundsMsg: "Você está em um outra dimensão! o.O"

  locateOptions: {}
).addTo(H5.Map.base)

# display stations
H5.Data.restURL = "http://" + document.domain + "/painel/rest"

H5.Map.layer.alerta = new L.VectorLayer.Postgis (
  url: H5.Data.restURL
  geotable: H5.DB.alert.table
  fields: "id_des, tipo, data_imagem, area_km2, dominio"
  srid: 4326
  geomFieldName: "shape"
  popupTemplate: (properties) ->
    html = '<div class="iw-content"><h4>' + properties.id_des + '</h4>'
    html += '<h5>' + properties.tipo + '</h5>'
    html += '<table class="condensed-table bordered-table zebra-striped"><tbody>'
    html += '<tr><th>Data: </th><td>' + properties.data_imagem.split(" ", 1) + '</td></tr>'
    html += '<tr><th>Área: </th><td>' + properties.area_km2+ '</td></tr>'
    if properties.dominio.length > 1
      html += '<tr><th>Domínio: </th><td>' + properties.dominio + '</td></tr>'
    html += '</tbody></table></div>'
    return html
  singlePopup: true
  where: "ano = '2013'"
  showAll: false
  limit: 200
  scaleRange: [9, 20]
  symbology:
    type: "single"
    vectorStyle:
      fillColor: "#ff0000"
      fillOpacity: 0.6
      weight: 4.0
      color: "#ff0000"
      opacity: 0.8
)
H5.Map.layer.alerta.setMap H5.Map.base

H5.Map.layer.nuvem = new L.VectorLayer.Postgis (
  url: H5.Data.restURL
  geotable: "nuvem_deter"
  fields: "objectid, data_src,to_char(data_src,'DD/MM/YYYY') as data_f,percent "
  srid: 4326
  geomFieldName: "shape"
  popupTemplate: (properties) ->
    html = '<div class="iw-content"><h4>' + properties.objectid + '</h4>'
    html += '<table class="condensed-table bordered-table zebra-striped"><tbody>'
    html += '<tr><th>Data de Registro: </th><td>' + properties.data_f+ '</td></tr>'    
    html += '<tr><th>Território(%): </th><td>' + (parseFloat(properties.percent)*100).toFixed(2)+ '</td></tr>'
    html += '</tbody></table></div>'
    return html
  singlePopup: true
  where: "data_src = '2014-06-22'"  
  #order: "data_src asc"
  #limit: 1    
  showAll: true  
  #scaleRange: [9, 20]
  symbology:
    type: "single"
    vectorStyle:
      fillColor: "#63B0FF"
      fillOpacity: 0.6      
      color: "#007CFB"
      opacity: 0.6
)

H5.Map.layer.heli_hist = {}
H5.Map.layer.heli_atual = {}

actualDate = new Date()

customMarker = L.Icon.extend(
  options:
    iconUrl: "http://" + document.domain + "/painel/assets/img/ibama_marker.png"
    shadowUrl: null
    iconSize: new L.Point(0, 0)
    iconAnchor: new L.Point(0, 0)
    popupAnchor: new L.Point(0, 0)
    clickable: false
)

# display clusters
H5.Map.layer.clusters = new L.VectorLayer.Postgis (
  url: H5.Data.restURL
  geotable: H5.DB.alert.table
  fields: "id_des"
  srid: 4326
  geomFieldName: "centroide"
  showAll: true
  cluster: true
  popupTemplate: null
  where: "ano = '2013'"
  # focus: true
  symbology:
    type: "single"
    vectorStyle:
      icon: new customMarker()
)
H5.Map.layer.clusters.setMap H5.Map.base

if H5.DB.logged_in
  #Quando logado mostrar a camada de nuvens.
  H5.Map.layer.nuvem.setMap H5.Map.base
  
  new L.Control.Cleancontrol(
    "OSM":
      layer: openstreet
    "Bing Aerial":
      layer: bingaerial
    "Bing Road":
      layer: bingroad
    "Bing Hybrid":
      layer: binghybrid
  ,
    "DETER Alerta":
      layer: H5.Map.layer.alerta.layer
      vectorLayer:
        layer: H5.Map.layer.alerta
        clusters: H5.Map.layer.clusters
        opacity: true
        filters:
          "Estado":
            type: "select"
            value: ["Todos", "AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO"]
            reset: "Todos"
            dbfield: "estado"
          "Periodo":
            type: "period"
            placeholder: "dd/mm/aaaa"
            dbfield: "data_imagem"
    "RapidEye":
      layer: rapidEye
    "DETER Nuvem":
      layer: H5.Map.layer.nuvem.layer
      vectorLayer:
        layer: H5.Map.layer.nuvem
        filters:
          "Data de Registro":
            type: "date"
            placeholder: "dd/mm/aaaa"
            dbfield: "data_src"     

  ).addTo(H5.Map.base)
else
  new L.Control.Cleancontrol(
    "OSM":
      layer: openstreet
    "Bing Aerial":
      layer: bingaerial
    "Bing Road":
      layer: bingroad
    "Bing Hybrid":
      layer: binghybrid
  ,
    "DETER Alerta":
      layer: H5.Map.layer.alerta.layer
      vectorLayer:
        layer: H5.Map.layer.alerta
        clusters: H5.Map.layer.clusters
        opacity: true
        filters:
          "Estado":
            type: "select"
            value: ["Todos", "AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO"]
            reset: "Todos"
            dbfield: "estado"
          "Periodo":
            type: "period"
            placeholder: "dd/mm/aaaa"
            dbfield: "data_imagem"
    "RapidEye":
      layer: rapidEye
  ).addTo(H5.Map.base)

# $(H5.Map.layer.heli_hist._vectors.length).on "change"
