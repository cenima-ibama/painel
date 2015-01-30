app.controller('chartsCtrl', function ($scope, $http, $location , $routeParams, $rootScope, $cookies){
    console.log('listening');

    $scope.load = 'false';
    $scope.chartWidth = ($(window).width() / 2) - 40;
    $scope.windowHeight = $(window).height();

    // Manages the presentation of loading gifs while waiting for server infos
    $scope.$on('load',function(event,status){
        $scope.load = status;
    });


    $scope.$on('area', function(event, dbdata){
        $rootScope.cruzamento = dbdata;
        $rootScope.pie = dbdata;
        $scope.graphs = ['Linha', 'Coluna', 'Tabela'];
        $scope.graph = 'Linha';

        $dataInicio = $rootScope.cruzamento[4].filters[1].inicio;
        $dataFim = $rootScope.cruzamento[4].filters[2].fim;
        $areaComparacao = $rootScope.cruzamento[4].filters[3].shape;
        $estagio = "";
        if ($rootScope.cruzamento[4].filters[5].estagio !== '') {
            $estagio = " - " + $rootScope.cruzamento[4].filters[5].estagio;
        }

        // $rootScope.cruzamento = dbdata[0];
         // console.log($rootScope.cruzamento);

        var border = 'border-left: 1px solid; border-right: 1px solid; border-bottom: 1px solid; border-top: 0px solid; border-color: #DDDDDD; ';
        // var style = "height:210px; width:" + parseFloat(($(window).width() / 2 ) - 40) + "px;display:inline-block;" + border + " margin:0px 10px 0px 10px;";
        var style = "height:242px; width:" + $scope.chartWidth + "px;display:inline-block;" + border + " margin:0px 10px 10px 10px;";

        $scope.divStyle = style;

        var chart1 = {};
        chart1.type = "LineChart";
        // chart1.cssStyle = "height:210px; width:" + $scope.chartWidth + "px;display:inline-block;border-left: 1px solid; border-right: 1px solid; border-bottom: 1px solid; border-color: #DDDDDD; margin:0px 10px 0px 10px;";
        // chart1.cssStyle = "heigth:179px";
        chart1.data = {"cols": [
            {id: "month", label: "Período", type: "string"},
            {id: "laptop-id", label: "Área km²", type: "number"}


        ], "rows": $rootScope.cruzamento[0].chart1
        };

        chart1.options = {
            // "title": $rootScope.taxa + " - Gráfico de Linha",
            "isStacked": "true",
            "fill": 20,
            "displayExactValues": true,
            "vAxis": {
                "title": "Área km²", "gridlines": {"count": 4}
            },
            "hAxis": {
                "title": "Date"
            }
        };
        if ($rootScope.taxa) {
            chart1.title = $rootScope.taxa + " - Gráfico de Linha";
        } else {
            chart1.title = "Gráfico de Linha";
        }
        chart1.formatters = {};
        $scope.chart1 = chart1;

        //inicio do segundo grafico

        var chart2 = {};
        chart2.type = "PieChart";
        // chart2.cssStyle = "height:210px; width:679px;display:inline-block; " + border + " padding-left:10px; margin:0px 10px 0px 10px;";
        // chart2.cssStyle = "heigth:180px";
        chart2.data = {"cols": [
            {id: "month", label: "Período", type: "string"},
            {id: "laptop-id", label: "Área km²", type: "number"}
        ], "rows": $rootScope.cruzamento[3].geralChart
        };

        chart2.options = {
            // "title": $rootScope.taxa + " - Gráfico de Barra",
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
        if ($rootScope.taxa) {
           chart2.title = $rootScope.taxa + " - Áreas Estaduais vs. Áreas Federais";
        } else {
            chart1.title = "Gráfico de Barra";
        }
        chart2.formatters = {};
        $scope.chart2 = chart2;

        //inicio do terceiro grafico

        var chart3 = {};
        chart3.type = "PieChart";
        // chart3.cssStyle = "height:210px; width:679px;display:inline-block;" + border + " padding-left:10px; margin:0px 10px 0px 10px;";
        // chart3.cssStyle = "heigth:180px";
        chart3.data = {"cols": [
            {id: "m", label: "Período", type: "string"},
            {id: "l-id", label: "Área km²", type: "number"}
        ], "rows": $rootScope.cruzamento[1].federalChart
        };

        chart3.options = {
            // "title": $rootScope.taxa + " - Gráfico de Áreas Federais",
            "sliceVisibilityThreshold": 0
        };
        if ($rootScope.taxa) {
            chart3.title = $rootScope.taxa + " - Federais - " + $dataInicio.replace(/-/g , "/") + " a " + $dataFim.replace(/-/g , "/") + $estagio;
        } else {
            chart1.title = "Gráfico de Áreas Federais";
        }
        chart3.formatters = {};
        $scope.chart3 = chart3;

        //inicio do quarto grafico


        //inicio do terceiro grafico

        var chart4 = {};
        chart4.type = "PieChart";
        // chart3.cssStyle = "height:210px; width:679px;display:inline-block;" + border + " padding-left:10px; margin:0px 10px 0px 10px;";
        // chart3.cssStyle = "heigth:180px";
        chart4.data = {"cols": [
            {id: "m", label: "Período", type: "string"},
            {id: "l-id", label: "Área km²", type: "number"}
        ], "rows": $rootScope.cruzamento[2].estadualChart
        };

        chart4.options = {
            // "title": $rootScope.taxa + " - Gráfico de Áreas Estaduais",
            "sliceVisibilityThreshold": 0
        };
        if ($rootScope.taxa) {
            chart4.title = $rootScope.taxa + " - Estaduais - " + $dataInicio.replace(/-/g , "/") + " a " + $dataFim.replace(/-/g , "/") + $estagio;
        } else {
            chart1.title = "Gráfico de Áreas Estaduais";
        }
        chart4.formatters = {};
        $scope.chart4 = chart4;

        //inicio do quarto grafico

        // var chart5 = {};
        // chart5.type = "Table";
        // chart5.cssStyle = "height:200px; width:" + parseFloat(($(window).width() / 2 ) - 40) + "px;display:inline-block;";
        // // chart4.cssStyle = "heigth:200px";
        // chart5.data = {"cols": [
        //     {id: "m", label: "Período", type: "string"},
        //     {id: "l-id", label: "Área km²", type: "number"}
        // ], "rows": $rootScope.cruzamento[0].chart1
        // };

        // chart5.options = {
        //     // "title": $rootScope.taxa + " - Tabela",
        // };
        // if ($rootScope.taxa) {
        //    chart5.title = $rootScope.taxa + " - Tabela";
        // } else {
        //     chart1.title = "Tabela";
        // }
        // chart5.formatters = {};
        // $scope.chart5 = chart5;
    });

    $scope.changeGraph = function($out){
        var chart1 = {};

        if ($out === 'Linha') {
            console.log("linha");

            chart1.type = "LineChart";
            // chart1.cssStyle = "height:210px; width:" + $scope.chartWidth + "px;display:inline-block;border-left: 1px solid; border-right: 1px solid; border-bottom: 1px solid; border-color: #DDDDDD; margin:0px 10px 0px 10px;";
            // chart1.cssStyle = "heigth:179px";
            chart1.data = {"cols": [
                {id: "month", label: "Período", type: "string"},
                {id: "laptop-id", label: "Área km²", type: "number"}


            ], "rows": $rootScope.cruzamento[0].chart1
            };

            chart1.options = {
                // "title": $rootScope.taxa + " - Gráfico de Linha",
                "isStacked": "true",
                "fill": 20,
                "displayExactValues": true,
                "vAxis": {
                    "title": "Área km²", "gridlines": {"count": 4}
                },
                "hAxis": {
                    "title": "Date"
                }
            };
            if ($rootScope.taxa) {
                chart1.title = $rootScope.taxa + " - Gráfico de Linha";
            } else {
                chart1.title = "Gráfico de Linha";
            }
            chart1.formatters = {};
            $scope.chart1 = chart1;

        } else if ($out === 'Coluna') {
            console.log("Coluna");

            chart1.type = "ColumnChart";
            // chart2.cssStyle = "height:210px; width:679px;display:inline-block; " + border + " padding-left:10px; margin:0px 10px 0px 10px;";
            // chart2.cssStyle = "heigth:180px";
            chart1.data = {"cols": [
                {id: "month", label: "Período", type: "string"},
                {id: "laptop-id", label: "Área km²", type: "number"}
            ], "rows": $rootScope.cruzamento[0].chart1
            };

            chart1.options = {
                // "title": $rootScope.taxa + " - Gráfico de Barra",
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
            if ($rootScope.taxa) {
                chart1.title = $rootScope.taxa + " - Gráfico de Barra";
            } else {
                chart1.title = "Gráfico de Barra";
            }
            chart1.formatters = {};
            $scope.chart1 = chart1;

        } else {
            console.log("tabela");

            chart1.type = "Table";
            chart1.cssStyle = "height:200px; width:" + parseFloat(($(window).width() / 2 ) - 40) + "px;display:flex;";
            // chart4.cssStyle = "heigth:200px";
            chart1.data = {"cols": [
                {id: "m", label: "Período", type: "string", style: "text-align:center"},
                {id: "l-id", label: "Área km²", type: "number", style: "text-align:center"}
            ], "rows": $rootScope.cruzamento[0].chart1
            };

            chart1.options = {
                // "title": $rootScope.taxa + " - Tabela",
            };
            if ($rootScope.taxa) {
                chart1.title = $rootScope.taxa + " - Tabela";
            } else {
                chart1.title = "Tabela";
            }
            chart1.formatters = {};
            $scope.chart1 = chart1;
        }
    }


});