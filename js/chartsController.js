app.controller('chartsCtrl', function ($scope, $http, $location , $routeParams, $rootScope, $cookies){
    console.log('listening');

    $scope.$on('area', function(event, area){
        $rootScope.area = area;
         console.log($rootScope.area);

        var chart1 = {};
        chart1.type = "LineChart";
        chart1.cssStyle = "height:100px; width:500px;";
        chart1.data = {"cols": [
            {id: "month", label: "Month", type: "string"},
            {id: "laptop-id", label: "Área km²", type: "number"}

        ], "rows": [
            {c: [
                {v: ""},
                {v: 0, f: ""}
            ]},
            {c: [
                {v: "2014"},
                {v: $rootScope.area}

            ]}
        ]};

        chart1.options = {
            "title": "DETER",
            "isStacked": "true",
            "fill": 20,
            "displayExactValues": true,
            "vAxis": {
                "title": "Área km²", "gridlines": {"count": 6}
            },
            "hAxis": {
                "title": "Date"
            }
        };

        chart1.formatters = {};

        $scope.chart1 = chart1;

        //inicio do segundo grafico

        var chart2 = {};
        chart2.type = "ColumnChart";
        chart2.cssStyle = "height:100px; width:500px;";
        chart2.data = {"cols": [
            {id: "month", label: "Month", type: "string"},
            {id: "laptop-id", label: "Área km²", type: "number"}

        ], "rows": [
            {c: [
                {v: ""},
                {v: 0, f: ""}
            ]},
            {c: [
                {v: "2014"},
                {v: $rootScope.area}

            ]}
        ]};

        chart2.options = {
            "title": "DETER",
            "isStacked": "true",
            "fill": 20,
            "displayExactValues": true,
            "vAxis": {
                "title": "Área km²", "gridlines": {"count": 6}
            },
            "hAxis": {
                "title": "Date"
            }
        };
        chart2.formatters = {};
        $scope.chart2 = chart2;

    });


});