var app = angular.module('app',['ngRoute','googlechart','ngCookies']);

app.config(function($routeProvider){

    //configure Route Provider
    $routeProvider.
    when('/',{
        templateUrl:'views/cruzamentos.html',
        controller: 'cruzamentoCtrl'
    }).
    when('/cruzamento',{
        templateUrl:'views/cruzamentos.html',
        controller: 'cruzamentoCtrl'
    }).
    otherwise({
        redirectTo:'/'
    });
});

