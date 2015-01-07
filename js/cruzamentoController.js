app.controller('cruzamentoCtrl', function ($scope, $http, $location , $routeParams, $rootScope,$cookies){


    $scope.Deter = 'true';
    $scope.load = 'false';

    $scope.uf = "BR";

    $baseUrl = '//' + window.location.hostname + '/cruzamentos';
    $scope.url = $baseUrl + '/server/cruzamentos.php'; // The url of our search local

    $scope.taxas = ['PRODES', 'DETER', 'AWIFS', 'INDICAR'];
    $scope.estados = ['AC', 'AM', 'AP', 'MA', 'MT', 'PA', 'RO', 'RR', 'TO', 'AMAZONIA LEGAL'];
    $scope.anos = ['2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014'];
    $scope.estagios = [
        { name: 'Corte Raso', value: '' },
        { name: 'Degradação', value: '' },
        { name: 'Fogo em Floresta', value: '' }
    ];
    $scope.dominios = ['FEDERAL', 'ESTADUAL'];
    $scope.shapes= [
        { name: 'Terras Indígenas', value: 'terra_indigena' },
        { name: 'UC de uso sustentável', value: 'uc_sustentavel' },
        { name: 'UC de proteção integral', value: 'uc_integral' },
        { name: 'Assentamentos', value: 'assentamento' },
        { name: 'Terra Arrecadada', value: 'terra_arrecadada' }
    ];
    $scope.ufs = [
        { name: 'AC', image: $baseUrl + '/img/icons/AC.png' },
        { name: 'AM', image: $baseUrl + '/img/icons/AM.png' },
        { name: 'AP', image: $baseUrl + '/img/icons/AP.png' },
        { name: 'MA', image: $baseUrl + '/img/icons/MA.png' },
        { name: 'MT', image: $baseUrl + '/img/icons/MT.png' },
        { name: 'PA', image: $baseUrl + '/img/icons/PA.png' },
        { name: 'RO', image: $baseUrl + '/img/icons/RO.png' },
        { name: 'RR', image: $baseUrl + '/img/icons/RR.png' },
        { name: 'TO', image: $baseUrl + '/img/icons/TO.png' },
        { name: 'BR', image: $baseUrl + '/img/icons/BR.png' }
    ];

    $scope.changeThis = function($out){
        if ($out === 'DETER') {
            $scope.estagios = [
                { name: 'Corte Raso + Degradação', value: '' }
            ];
            return $scope.Deter = 'true';
        }
        if ($out === 'PRODES') {
            $scope.estagios = [
                { name: 'Corte Raso', value: '' }
            ];
            return $scope.Deter = 'false';
        }
        if ($out === 'AWIFS') {
            $scope.estagios = [
                { name: 'DEGRADACAO', value: 'DEGRADACAO' },
                { name: 'DESMATAMENTO_CR', value: 'DESMATAMENTO_CR' },
                { name: 'DESMATAMENTO_VEG', value: 'DESMATAMENTO_VEG' },
                { name: 'CICATRIZ_DE_QUEIMADA', value: 'CICATRIZ_DE_QUEIMADA' },
                { name: 'CS_TIPO1', value: 'CS_TIPO1' },
                { name: 'CS_TIPO2', value: 'CS_TIPO2' },
                { name: 'MINERACAO', value: 'MINERACAO' },
                { name: 'CS_CONVENCIONAL', value: 'CS_CONVENCIONAL' },
                { name: 'CS_REGULAR', value: 'CS_REGULAR' },
                { name: 'TODOS', value: 'TODOS' }
            ];
            return $scope.Deter = 'true';
        }
        if ($out === 'INDICAR') {
            $scope.estagios = [
                { name: 'Corte Raso', value: 'CR' },
                { name: 'Degradação', value: 'DG' },
                { name: 'Fogo em Floresta', value: 'FF' },
                { name: 'Todos', value: 'TODOS' }
            ];
            return $scope.Deter = 'true';
        }
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
            if ($scope.dominios.indexOf('ESTADUAL') != -1) {
                $scope.dominios.pop();
            }
        } else if ($scope.dominios.indexOf('ESTADUAL') == -1){
            $scope.dominios.push('ESTADUAL');
        }
    }

    $scope.cruzamento = function() {

        $rootScope.$broadcast('load', 'true');

        var request = $http({
            method: "post",
            url:$scope.url,
            data: {
                taxa: $scope.taxa,
                inicio: $scope.inicio,
                fim: $scope.fim,
                shape: $scope.shape,
                dominio: $scope.dominio,
                estagio: $scope.estagio,
                uf: $scope.uf
            },
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });

        request.
        success(function(data, status) {
            $rootScope.taxa = $scope.taxa;
            $rootScope.$broadcast('load', 'false');
            $scope.status = status;
            console.log(data);
            $scope.data = data;
            // var area = $scope.data.area;
            var data = $scope.data;
            $rootScope.$broadcast('area', data);
            console.log('broadcasting');
        })
        request.
        error(function(data, status) {
            $rootScope.$broadcast('load', 'false');
            $scope.data = data || "Request failed";
            $scope.status = status;
        });

    }

});

app.directive('calendar', function () {
    return {
        require: 'ngModel',
        link: function (scope, el, attr, ngModel) {
            $(el).datepicker({
                dateFormat: 'dd-mm-yy',
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

