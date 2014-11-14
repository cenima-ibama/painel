app.controller('chartsCtrl', function ($scope, $http, $location , $routeParams, $rootScope, $cookies){
    console.log('listening');

    $scope.load = 'false';

    // Manages the presentation of loading gifs while waiting for server infos
    $scope.$on('load',function(event,status){
        $scope.load = status;
    });


    $scope.$on('area', function(event, dbdata){
        $rootScope.cruzamento = dbdata;
        $rootScope.pie = dbdata;
        // $rootScope.cruzamento = dbdata[0];
         // console.log($rootScope.cruzamento);

        var border = 'border-left: 1px solid; border-right: 1px solid; border-bottom: 1px solid; border-top: 30px solid #DDDDFF; border-color: #DDDDDD; '

        var chart1 = {};
        chart1.type = "LineChart";
        chart1.cssStyle = "height:210px; width:679px;display:inline-block;" + border + " padding-left:10px; margin:0px 10px 0px 10px;";
        chart1.data = {"cols": [
            {id: "month", label: "Month", type: "string"},
            {id: "laptop-id", label: "Área km²", type: "number"}


        ], "rows": $rootScope.cruzamento
        // ], "rows": [
        //     {c: [
        //         {v: ""},
        //         {v: 0, f: ""}
        //     ]},
        //     {c: [
        //         {v: "2014"},
        //         {v: $rootScope.area}

        //     ]}
        };

        chart1.options = {
            "title": "DETER",
            "isStacked": "true",
            "fill": 20,
            "displayExactValues": true,
            // "fontSize": 18,
            "vAxis": {
                "title": "Área km²", "gridlines": {"count": 4}
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
        chart2.cssStyle = "height:210px; width:679px;display:inline-block; " + border + " padding-left:10px; margin:0px 10px 0px 10px;";
        chart2.data = {"cols": [
            {id: "month", label: "Month", type: "string"},
            {id: "laptop-id", label: "Área km²", type: "number"}
        ], "rows": $rootScope.cruzamento
        };

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

        //inicio do segundo grafico

        console.log($rootScope.cruzamento);

        var chart3 = {};
        chart3.type = "PieChart";
        chart3.cssStyle = "height:210px; width:679px;display:inline-block;" + border + " padding-left:10px; margin:0px 10px 0px 10px;";
        chart3.data = {"cols": [
            {id: "m", label: "Month", type: "string"},
            {id: "l-id", label: "Área km²", type: "number"}
        ], "rows": $rootScope.cruzamento
        };

        console.log($rootScope.cruzamento);

        chart3.options = {
            "title": "DETER"
        };
        chart3.formatters = {};
        $scope.chart3 = chart3;
    });


});