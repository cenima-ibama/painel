app.controller('cruzamentoCtrl', function ($scope, $http, $location , $routeParams, $rootScope,$cookies){

    $scope.Deter = 'true';

    $scope.url = '//' + window.location.hostname + '/new_panel/server/cruzamentos.php'; // The url of our search local
    $urlIcons = '//' + window.location.hostname + '/new_panel';

    $scope.taxas = ['PRODES', 'DETER', 'AWIFS', 'LANDSAT'];
    $scope.estados = ['AC', 'AM', 'AP', 'MA', 'MT', 'PA', 'RO', 'RR', 'TO', 'AMAZONIA LEGAL'];
    $scope.anos = ['2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014'];
    // $scope.dominios = [ {name: 'ESTADUAL'}, {name: 'FEDERAL'}];
    $scope.dominios = ['FEDERAL', 'ESTADUAL'];
    $scope.shapes= [
    { name: 'Terras Indígenas', value: 'terra_indigena' },
    { name: 'UC de uso sustentável', value: 'uc_sustentavel' },
    { name: 'UC de proteção integral', value: 'uc_integral' },
    { name: 'Assentamentos', value: 'assentamento' },
    { name: 'Floresta', value: 'floresta' },
    { name: 'Terra Arrecadada', value: 'terra_arrecadada' }
    ];
    $scope.ufs = [
        { name: 'AC', image: $urlIcons + '/img/icons/AC.png' },
        { name: 'AM', image: $urlIcons + '/img/icons/AM.png' },
        { name: 'AP', image: $urlIcons + '/img/icons/AP.png' },
        { name: 'MA', image: $urlIcons + '/img/icons/MA.png' },
        { name: 'MT', image: $urlIcons + '/img/icons/MT.png' },
        { name: 'PA', image: $urlIcons + '/img/icons/PA.png' },
        { name: 'RO', image: $urlIcons + '/img/icons/RO.png' },
        { name: 'RR', image: $urlIcons + '/img/icons/RR.png' },
        { name: 'TO', image: $urlIcons + '/img/icons/TO.png' },
        { name: 'AMAZONIA LEGAL', image: $urlIcons + '/img/icons/BR.png' }
    ];

    $scope.changeThis = function($out){
        if ($out === 'DETER')
            return $scope.Deter = 'true';
        if ($out === 'PRODES')
            return $scope.Deter = 'false';
    }

    $scope.getValueClass = function ($out){
        $scope.uf = $out.$$watchers[1].last;
    }

    $scope.changeClass = function ($out){
        if ($out.$$watchers[1].last == $scope.uf) {
            console.log('active');
            return 'active';
        }
    }


    $scope.hideState = function ($shape){
        if ($shape ==  'terra_indigena') {
            $scope.dominios.pop();
        } else if ($scope.dominios.indexOf('ESTADUAL') == -1){
            $scope.dominios.push('ESTADUAL');
        }
    }

    $scope.cruzamento = function() {

        var request = $http({
            method: "post",
            url:$scope.url,
            data: {
                taxa: $scope.taxa,
                inicio: $scope.inicio,
                fim: $scope.fim,
                shape: $scope.shape,
                dominio: $scope.dominio,
                uf: $scope.uf
            },
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });

        request.
        success(function(data, status) {
            $scope.status = status;
            $scope.data = data;
            var area = $scope.data.area;
            $rootScope.$broadcast('area', area)
            console.log('broadcasting');
        })
        request.
        error(function(data, status) {
            $scope.data = data || "Request failed";
            $scope.status = status;
        });

    };

});

app.directive('calendar', function () {
    return {
        require: 'ngModel',
        link: function (scope, el, attr, ngModel) {
            $(el).datepicker({
                dateFormat: 'yy-mm-dd',
                onSelect: function (dateText) {
                    scope.$apply(function () {
                        ngModel.$setViewValue(dateText);
                    });
                }
            });
        }
    };
})

function dateCtrl($scope) {

}

