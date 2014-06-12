/**
* @preserve Copyright (c) 2013, Jason Sanford, Helmuth Saatkamp
* Leaflet Vector Layers is a library for showing geometry objects
* from multiple geoweb services in a Leaflet map
*/

/*global lvector */

(function (root) {
  root.lvector = {
    VERSION: '1.4.0',

    noConflict: function () {
      root.lvector = this._originallvector;
      return this;
    },

    _originallvector: root.lvector
  };
}(this));

// lvector.Layer is a base class for rendering vector layers on a Leaflet map. It's inherited by AGS, A2E, CartoDB, GeoIQ, etc.
lvector.Layer = L.Class.extend({

  // Default options for all layers
  options: {
    scaleRange: null,
    map: null,
    uniqueField: null,
    visibleAtScale: true,
    dynamic: false,
    autoUpdate: false,
    autoUpdateInterval: null,
    popupTemplate: null,
    popupOptions: {},
    singlePopup: false,
    symbology: null,
    showAll: false
  },

  initialize: function(options) {
    L.Util.setOptions(this, options);
  },

  // Show this layer on the map provided
  setMap: function(map) {
    if (map && this.options.map) {
      return;
    }
    if (map) {
      this.options.map = map;
      if (this.options.scaleRange && this.options.scaleRange instanceof Array && this.options.scaleRange.length === 2) {
        var z = this.options.map.getZoom();
        var sr = this.options.scaleRange;
        this.options.visibleAtScale = (z >= sr[0] && z <= sr[1]);
      }
      this._show();
    } else if (this.options.map) {
      this._hide();
      this.options.map = map;
    }
  },

  // Get the map (if any) that the layer has been added to
  getMap: function() {
    return this.options.map;
  },

  setOptions: function(options) {
    L.Util.setOptions(this, options);
  },

  _show: function() {
    this._addIdleListener();
    if (this.options.scaleRange && this.options.scaleRange instanceof Array && this.options.scaleRange.length === 2) {
      this._addZoomChangeListener();
    }
    if (this.options.visibleAtScale) {
      if (this.options.autoUpdate && this.options.autoUpdateInterval) {
        var me = this;
        this._autoUpdateInterval = setInterval(function() {
          me._getFeatures();
        }, this.options.autoUpdateInterval);
      }
      this.options.map.fire("moveend").fire("zoomend");
    }
  },

  _hide: function() {
    if (this._idleListener) {
      this.options.map.off("moveend", this._idleListener);
    }
    if (this._zoomChangeListener) {
      this.options.map.off("zoomend", this._zoomChangeListener);
    }
    if (this._autoUpdateInterval) {
      clearInterval(this._autoUpdateInterval);
    }
    this._clearFeatures();
    this._lastQueriedBounds = null;
    if (this._gotAll) {
      this._gotAll = false;
    }
  },

  // Hide the vectors in the layer. This might get called if the layer is still on but out of scaleRange.
  _hideVectors: function() {
    // TODO: There's probably an easier way to first check for "singlePopup" option then just remove the one
    //       instead of checking for "assocatedFeatures"
    for (var i = 0; i < this._vectors.length; i++) {
      if (this._vectors[i].vector) {
        this.options.map.removeLayer(this._vectors[i].vector);
        if (this._vectors[i].popup) {
          this.options.map.removeLayer(this._vectors[i].popup);
        } else if (this.popup && this.popup.associatedFeature && this.popup.associatedFeature == this._vectors[i]) {
          this.options.map.removeLayer(this.popup);
          this.popup = null;
        }
      }
      if (this._vectors[i].vectors && this._vectors[i].vectors.length) {
        for (var j = 0; j < this._vectors[i].vectors.length; j++) {
          this.options.map.removeLayer(this._vectors[i].vectors[j]);
          if (this._vectors[i].vectors[j].popup) {
            this.options.map.removeLayer(this._vectors[i].vectors[j].popup);
          } else if (this.popup && this.popup.associatedFeature && this.popup.associatedFeature == this._vectors[i]) {
            this.options.map.removeLayer(this.popup);
            this.popup = null;
          }
        }
      }
    }
  },

  // Show the vectors in the layer. This might get called if the layer is on and came back into scaleRange.
  _showVectors: function() {
    for (var i = 0; i < this._vectors.length; i++) {
      if (this._vectors[i].vector) {
        this.options.map.addLayer(this._vectors[i].vector);
      }
      if (this._vectors[i].vectors && this._vectors[i].vectors.length) {
        for (var j = 0; j < this._vectors[i].vectors.length; j++) {
          this.options.map.addLayer(this._vectors[i].vectors[j]);
        }
      }
    }
  },

  // Hide the vectors, then empty the vectory holding array
  _clearFeatures: function() {
    // TODO - Check to see if we even need to hide these before we remove them from the DOM
    this._hideVectors();
    this._vectors = [];
  },

  // Add an event hanlder to detect a zoom change on the map
  _addZoomChangeListener: function() {
    // "this" means something different inside the on method. Assign it to "me".
    var me = this;

    me._zoomChangeListener = me._zoomChangeListenerTemplate();

    this.options.map.on("zoomend", me._zoomChangeListener, me);
  },

  _zoomChangeListenerTemplate: function() {
    // Whenever the map's zoom changes, check the layer's visibility (this.options.visibleAtScale)
    var me = this;
    return function() {
      me._checkLayerVisibility();
    };
  },

  // This gets fired when the map is panned or zoomed
  _idleListenerTemplate: function() {
    var me = this;
    return function() {
      if (me.options.visibleAtScale) {
        // Do they use the showAll parameter to load all features once?
        if (me.options.showAll) {
          // Have we already loaded these features
          if (!me._gotAll) {
            // Grab the features and note that we've already loaded them (no need to _getFeatures again
              me._getFeatures();
              me._gotAll = true;
          }
        } else {
          me._getFeatures();
        }
      }
    };
  },

  // Add an event hanlder to detect an idle (pan or zoom) on the map
  _addIdleListener: function() {
    // "this" means something different inside the on method.
    this._idleListener = this._idleListenerTemplate();
    // Whenever the map idles (pan or zoom) get the features in the current map extent
    this.options.map.on("moveend", this._idleListener, this);
  },

  // Get the current map zoom and check to see if the layer should still be visible
  _checkLayerVisibility: function() {
    // Store current visibility so we can see if it changed
    var visibilityBefore = this.options.visibleAtScale;

    // Check current map scale and see if it's in this layer's range
    var z = this.options.map.getZoom();
    var sr = this.options.scaleRange;
    this.options.visibleAtScale = (z >= sr[0] && z <= sr[1]);

    // Check to see if the visibility has changed
    if (visibilityBefore !== this.options.visibleAtScale) {
      // It did, hide or show vectors
      this[this.options.visibleAtScale ? "_showVectors" : "_hideVectors"]();
    }

    // Check to see if we need to set or clear any intervals for auto-updating layers
    if (visibilityBefore && !this.options.visibleAtScale && this._autoUpdateInterval) {
      clearInterval(this._autoUpdateInterval);
    } else if (!visibilityBefore && this.options.autoUpdate && this.options.autoUpdateInterval) {
      var me = this;
      this._autoUpdateInterval = setInterval(function() {
        me._getFeatures();
      }, this.options.autoUpdateInterval);
    }
  },

  // Set the Popup content for the feature
  _setPopupContent: function(feature) {
    // Store previous Popup content so we can check to see if it changed. If it didn't no sense changing the content as this has an ugly flashing effect.
    var previousContent = feature.popupContent;

    var atts = feature.properties;

    var popupContent;

    // Check to see if it's a string-based popupTemplate or function
    if (typeof this.options.popupTemplate == "string") {
      // Store the string-based popupTemplate
      popupContent = this.options.popupTemplate;

      // Loop through the properties and replace mustache-wrapped property names with actual values
      for (var prop in atts) {
        var re = new RegExp("{" + prop + "}", "g");
        popupContent = popupContent.replace(re, atts[prop]);
      }
    } else if (typeof this.options.popupTemplate == "function") {
      // It's a function-based popupTempmlate, so just call this function and pass properties
      popupContent = this.options.popupTemplate(atts);
    } else {
      // Ummm, that's all we support. Seeya!
      return;
    }

    // Store the Popup content
    feature.popupContent = popupContent;

    // Check to see if popupContent has changed and if so setContent
    if (feature.popup) {
      // The Popup is associated with a feature
      if (feature.popupContent !== previousContent) {
        feature.popup.setContent(feature.popupContent);
      }
    } else if (this.popup && this.popup.associatedFeature == feature) {
      // The Popup is associated with the layer (singlePopup: true)
      if (feature.popupContent !== previousContent) {
        this.popup.setContent(feature.popupContent);
      }
    }
  },

  // Show the feature's (or layer's) Popup
  _showPopup: function(feature, event) {
    // Popups on Lines and Polygons are opened slightly different, make note of it
    var isLineOrPolygon = event.latlng;

    // Set the popupAnchor if a marker was clicked
    if (!isLineOrPolygon) {
      L.Util.extend(this.options.popupOptions, {
        offset: event.target.options.icon.options.popupAnchor
      });
    }

    // Create a variable to hold a reference to the object that owns the Popup so we can show it later
    var ownsPopup;

    // If the layer isn't set to show a single Popup
    if (!this.options.singlePopup) {
      // Create a Popup and store it in the feature
      feature.popup = new L.Popup(this.options.popupOptions, feature.vector);
      ownsPopup = feature;
    } else {
      if (this.popup) {
        // If the layer already has an Popup created, close and delete it
        this.options.map.removeLayer(this.popup);
        this.popup = null;
      }

      // Create a new Popup
      this.popup = new L.Popup(this.options.popupOptions, feature.vector);

      // Store the associated feature reference in the Popup so we can close and clear it later
      this.popup.associatedFeature = feature;

      ownsPopup = this;
    }

    ownsPopup.popup.setLatLng(isLineOrPolygon ? event.latlng : event.target.getLatLng());
    ownsPopup.popup.setContent(feature.popupContent);
    this.options.map.addLayer(ownsPopup.popup);
  },

  // Optional click event
  _fireClickEvent: function (feature, event) {
    this.options.clickEvent(feature, event);
  },

  // Get the appropriate Leaflet vector options for this feature
  _getFeatureVectorOptions: function(feature) {
    // Create an empty vectorStyle object to add to, or leave as is if no symbology can be found
    var vectorStyle = {};

    var atts = feature.properties;

    // Is there a symbology set for this layer?
    if (this.options.symbology) {
      switch (this.options.symbology.type) {
        case "single":
          // It's a single symbology for all features so just set the key/value pairs in vectorStyle
          for (var key in this.options.symbology.vectorStyle) {
            vectorStyle[key] = this.options.symbology.vectorStyle[key];
            if (vectorStyle.title) {
              for (var prop in atts) {
                var re = new RegExp("{" + prop + "}", "g");
                vectorStyle.title = vectorStyle.title.replace(re, atts[prop]);
              }
            }
          }
          break;
        case "unique":
          // It's a unique symbology. Check if the feature's property value matches that in the symbology and style accordingly
          var att = this.options.symbology.property;
          for (var i = 0, len = this.options.symbology.values.length; i < len; i++) {
            if (atts[att] == this.options.symbology.values[i].value) {
              for (var key in this.options.symbology.values[i].vectorStyle) {
                vectorStyle[key] = this.options.symbology.values[i].vectorStyle[key];
                if (vectorStyle.title) {
                  for (var prop in atts) {
                    var re = new RegExp("{" + prop + "}", "g");
                    vectorStyle.title = vectorStyle.title.replace(re, atts[prop]);
                  }
                }
              }
            }
          }
          break;
        case "range":
          // It's a range symbology. Check if the feature's property value is in the range set in the symbology and style accordingly
          var att = this.options.symbology.property;
          for (var i = 0, len = this.options.symbology.ranges.length; i < len; i++) {
            if (atts[att] >= this.options.symbology.ranges[i].range[0] && atts[att] <= this.options.symbology.ranges[i].range[1]) {
              for (var key in this.options.symbology.ranges[i].vectorStyle) {
                vectorStyle[key] = this.options.symbology.ranges[i].vectorStyle[key];
                if (vectorStyle.title) {
                  for (var prop in atts) {
                    var re = new RegExp("{" + prop + "}", "g");
                    vectorStyle.title = vectorStyle.title.replace(re, atts[prop]);
                  }
                }
              }
            }
          }
          break;
      }
    }
    return vectorStyle;
  },

  // Check to see if any attributes have changed
  _getPropertiesChanged: function(oldAtts, newAtts) {
    var changed = false;
    for (var key in oldAtts) {
      if (oldAtts[key] != newAtts[key]) {
        changed = true;
      }
    }
    return changed;
  },

  // Check to see if a particular property changed
  _getPropertyChanged: function(oldAtts, newAtts, property) {
    return !(oldAtts[property] == newAtts[property]);
  },

  // Check to see if the geometry has changed
  _getGeometryChanged: function(oldGeom, newGeom) {
    // TODO: make this work for points, linestrings and polygons
    var changed = false;

    // For now only checking for point changes
    if (!(oldGeom.coordinates[0] == newGeom.coordinates[0] && oldGeom.coordinates[1] == newGeom.coordinates[1])) {
      changed = true;
    }

    return changed;
  },

  _makeJsonpRequest: function(url) {
    var head = document.getElementsByTagName("head")[0];
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = url;
    head.appendChild(script);
  },

  _processRequest: function (json) {
    var data = {};
    data.features = [];
    data.total = json.length;
    data.type = "FeatureCollection"; // Not really necessary, but let's follow the GeoJSON spec for a Feature
    // convert data to make it look like a GeoJSON FeatureCollection
    for (i = 0, len = json.length; i < len; i++) {
      data.features[i] = {};
      data.features[i].type = "Feature"; // Not really necessary, but let's follow the GeoJSON spec for a Feature
      data.features[i].properties = {};
      for (var prop in json[i]) {
        if (prop == "geojson") {
          data.features[i].geometry = JSON.parse(json[i].geojson);
        } else
        if (prop != "properties") {
          data.features[i].properties[prop] = json[i][prop];
        }
      }
    }

    // remove json data
    json=null;

    this._processFeatures(data);
  },

  _processFeatures: function(data) {
    // Sometimes requests take a while to come back and
    // the user might have turned the layer off
    if (!this.options.map) {
      return;
    }
    var bounds = this.options.map.getBounds();

    // Check to see if the _lastQueriedBounds is the same as the new bounds
    // If true, don't bother querying again.
    if (this._lastQueriedBounds && this._lastQueriedBounds.equals(bounds) && !this.options.autoUpdate) {
      return;
    }

    // Store the bounds in the _lastQueriedBounds member so we don't have
    // to query the layer again if someone simply turns a layer on/off
    this._lastQueriedBounds = bounds;

    // If "data.features" exists and there's more than one feature in the array
    if (data && data.features && data.features.length) {

      // Loop through the return features
      for (i = 0; i < data.features.length; i++) {
        // All objects are assumed to be false until proven true (remember COPS?)
        var onMap = false;
        // If we have a "uniqueField" for this layer
        if (this.options.uniqueField) {
          // Loop through all of the features currently on the map
          for (var j = 0; j < this._vectors.length; j++) {
            // Does the "uniqueField" property for this feature match the feature on the map
            if (data.features[i].properties[this.options.uniqueField] == this._vectors[j].properties[this.options.uniqueField]) {
              // The feature is already on the map
              onMap = true;
              // We're only concerned about updating layers that are dynamic (options.dynamic = true).
              if (this.options.dynamic) {
                // The feature's geometry might have changed, let's check.
                if (this._getGeometryChanged(this._vectors[j].geometry, data.features[i].geometry)) {
                  // Check to see if it's a point feature, these are the only ones we're updating for now
                  if (!isNaN(data.features[i].geometry.coordinates[0]) && !isNaN(data.features[i].geometry.coordinates[1])) {
                    this._vectors[j].geometry = data.features[i].geometry;
                    this._vectors[j].vector.setLatLng(new L.LatLng(this._vectors[j].geometry.coordinates[1], this._vectors[j].geometry.coordinates[0]));
                  }
                }
                var propertiesChanged = this._getPropertiesChanged(this._vectors[j].properties, data.features[i].properties);
                if (propertiesChanged) {
                  var symbologyPropertyChanged = this._getPropertyChanged(this._vectors[j].properties, data.features[i].properties, this.options.symbology.property);
                  this._vectors[j].properties = data.features[i].properties;
                  if (this.options.popupTemplate) {
                    this._setPopupContent(this._vectors[j]);
                  }
                  if (this.options.symbology && this.options.symbology.type != "single" && symbologyPropertyChanged) {
                    if (this._vectors[j].vectors) {
                      for (var k = 0, len3 = this._vectors[j].vectors.length; k < len3; k++) {
                        if (this._vectors[j].vectors[k].setStyle) {
                          // It's a LineString or Polygon, so use setStyle
                          this._vectors[j].vectors[k].setStyle(this._getFeatureVectorOptions(this._vectors[j]));
                        } else if (this._vectors[j].vectors[k].setIcon) {
                          // It's a Point, so use setIcon
                          this._vectors[j].vectors[k].setIcon(this._getFeatureVectorOptions(this._vectors[j]).icon);
                        }
                      }
                    } else if (this._vectors[j].vector) {
                      if (this._vectors[j].vector.setStyle) {
                        // It's a LineString or Polygon, so use setStyle
                        this._vectors[j].vector.setStyle(this._getFeatureVectorOptions(this._vectors[j]));
                      } else if (this._vectors[j].vector.setIcon) {
                        // It's a Point, so use setIcon
                        this._vectors[j].vector.setIcon(this._getFeatureVectorOptions(this._vectors[j]).icon);
                      }
                    }
                  }
                }
              }
            }
          }
        }
        if (!onMap || !this.options.uniqueField) {
          // Convert GeoJSON to Leaflet vector (Point, Polyline, Polygon)
          var geometry =  data.features[i].geometry;
          var geometryOptions = this._getFeatureVectorOptions(data.features[i]);

          var vector_or_vectors = this._geoJsonGeometryToLeaflet(geometry,geometryOptions);
          data.features[i][vector_or_vectors instanceof Array ? "vectors" : "vector"] = vector_or_vectors;

          // Show the vector or vectors on the map
          if (data.features[i].vector) {
            this.options.map.addLayer(data.features[i].vector);
          } else if (data.features[i].vectors && data.features[i].vectors.length) {
            for (var k = 0; k < data.features[i].vectors.length; k++) {
              this.options.map.addLayer(data.features[i].vectors[k]);
            }
          }

          // Store the vector in an array so we can remove it later
          this._vectors.push(data.features[i]);

          if (this.options.popupTemplate) {
            var me = this;
            var feature = data.features[i];
            this._setPopupContent(feature);
            (function(feature){
              if (feature.vector) {
                feature.vector.on("click", function(event) {
                  me._showPopup(feature, event);
                });
              } else if (feature.vectors) {
                for (var k = 0, len = feature.vectors.length; k < len; k++) {
                  feature.vectors[k].on("click", function(event) {
                    me._showPopup(feature, event);
                  });
                }
              }
            }(feature));
          }

          if (this.options.clickEvent) {
            var me = this;
            var feature = data.features[i];
            (function(feature){
              if (feature.vector) {
                feature.vector.on("click", function(event) {
                  me._fireClickEvent(feature, event);
                });
              } else if (feature.vectors) {
                for (var i3 = 0, len = feature.vectors.length; i3 < len; i3++) {
                  feature.vectors[i3].on("click", function(event) {
                    me._fireClickEvent(feature, event);
                  });
                }
              }
            }(feature));
          }
        }
      }
    }
  }
});

// Extend Layer to support GeoJSON geometry parsing
lvector.GeoJSONLayer = lvector.Layer.extend({
  // Convert GeoJSON to Leaflet vectors
  _geoJsonGeometryToLeaflet: function(geometry, opts) {
    // Create a variable for a single vector and for multi part vectors.
    var vector, vectors;

    switch (geometry.type) {
      case "Point":
        if (opts.circleMarker) {
          vector = new L.CircleMarker(new L.LatLng(geometry.coordinates[1], geometry.coordinates[0]), opts);
        }
        else {
          vector = new L.Marker(new L.LatLng(geometry.coordinates[1], geometry.coordinates[0]), opts);
        }
        break;

      case "MultiPoint":
        vectors = [];
        for (var i = 0, len = geometry.coordinates.length; i < len; i++) {
          vectors.push(new L.Marker(new L.LatLng(geometry.coordinates[i][1], geometry.coordinates[i][0]), opts));
        }
        break;

      case "LineString":
        var latlngs = [];
        for (var i = 0, len = geometry.coordinates.length; i < len; i++) {
          latlngs.push(new L.LatLng(geometry.coordinates[i][1], geometry.coordinates[i][0]));
        }
        vector = new L.Polyline(latlngs, opts);
        break;

      case "MultiLineString":
        vectors = [];
        for (var i = 0, len = geometry.coordinates.length; i < len; i++){
          var latlngs = [];
          for (var j = 0, len2 = geometry.coordinates[i].length; j < len2; j++){
            latlngs.push(new L.LatLng(geometry.coordinates[i][j][1], geometry.coordinates[i][j][0]));
          }
          vectors.push(new L.Polyline(latlngs, opts));
        }
        break;

      case "Polygon":
        var latlngss = [];
        for (var i = 0, len = geometry.coordinates.length; i < len; i++) {
          var latlngs = [];
          for (var j = 0, len2 = geometry.coordinates[i].length; j < len2; j++) {
            latlngs.push(new L.LatLng(geometry.coordinates[i][j][1], geometry.coordinates[i][j][0]));
          }
          latlngss.push(latlngs);
        }
        vector = new L.Polygon(latlngss, opts);
        break;

      case "MultiPolygon":
        vectors = [];
        for (var i = 0, len = geometry.coordinates.length; i < len; i++) {
          latlngss = [];
          for (var j = 0, len2 = geometry.coordinates[i].length; j < len2; j++) {
            var latlngs = [];
            for (var k = 0, len3 = geometry.coordinates[i][j].length; k < len3; k++) {
              latlngs.push(new L.LatLng(geometry.coordinates[i][j][k][1], geometry.coordinates[i][j][k][0]));
            }
            latlngss.push(latlngs);
          }
          vectors.push(new L.Polygon(latlngss, opts));
        }
        break;

      case "GeometryCollection":
        vectors = [];
        for (var i = 0, len = geometry.geometries.length; i < len; i++) {
          vectors.push(this._geoJsonGeometryToLeaflet(geometry.geometries[i], opts));
        }
        break;
    }
    return vector || vectors;
  }
});

lvector.Postgis = lvector.GeoJSONLayer.extend({
  initialize: function(options) {

    // Check for required parameters
    for (var i = 0, len = this._requiredParams.length; i < len; i++) {
      if (!options[this._requiredParams[i]]) {
        throw new Error("No \"" + this._requiredParams[i] + "\" parameter found.");
      }
    }

    // If the url wasn't passed with a trailing /, add it.
    if (options.url.substr(options.url.length - 1, 1) !== "/") {
      options.url += "/";
    }

    // Extend Layer to create PRWSF
    lvector.Layer.prototype.initialize.call(this, options);

    // _globalPointer is a string that points to a global function variable
    // Features returned from a JSONP request are passed to this function
    this._globalPointer = "PRWSF_" + Math.floor(Math.random() * 100000);
    window[this._globalPointer] = this;

    // Create an array to hold the features
    this._vectors = [];

    if (this.options.map) {
      if (this.options.scaleRange && this.options.scaleRange instanceof Array && this.options.scaleRange.length === 2) {
        var z = this.options.map.getZoom();
        var sr = this.options.scaleRange;
        this.options.visibleAtScale = (z >= sr[0] && z <= sr[1]);
      }
      this._show();
    }
  },

  options: {
    geotable: null,
    srid: null,
    geomFieldName: "the_geom",
    fields: null,
    where: null,
    limit: 1000,
    uniqueField: null
  },

  _requiredParams: ["url", "geotable"],

  _getFeatures: function() {

    // Build Query
    var where = this.options.where ? "&parameters=" + encodeURIComponent(this.options.where) : "";
    if (!this.options.showAll) {
      var bounds = this.options.map.getBounds();
      var sw = bounds.getSouthWest();
      var ne = bounds.getNorthEast();
      where += where.length ? " AND " : "";
      if (this.options.srid) {
        where += this.options.geomFieldName + " && st_setsrid(st_makebox2d(st_point(" + sw.lng + "," + sw.lat + "),st_point(" + ne.lng + "," + ne.lat + "))," + this.options.srid + ")";
      } else {
        where += "" + this.options.geomFieldName + ",4326) && st_setsrid(st_makebox2d(st_point(" + sw.lng + "," + sw.lat + "),st_point(" + ne.lng + "," + ne.lat + "))";
      }
    }

    // Build fields
    var fields = (this.options.fields ? this.options.fields : "*") + ", st_asgeojson(" + this.options.geomFieldName + "" + (this.options.geomPrecision ? "," + this.options.geomPrecision : "") + ") as geojson";

    // Build URL
    var url = this.options.url + "v1/ws_geo_attributequery.php" + // The attribute query service
      "?table=" + this.options.geotable + // The table name
      "&fields=" + encodeURIComponent(fields) + // The table fields
      where +
      "&limit=" + this.options.limit + // The limit value
      "&callback=" + this._globalPointer + "._processRequest"; // Need this for JSONP

    // JSONP request
    this._makeJsonpRequest(url);
  }
});
