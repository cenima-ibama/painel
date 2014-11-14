<?php

	include 'config.php';

	$postdata = file_get_contents("php://input");
    $request = json_decode($postdata);

    date_default_timezone_set('America/Sao_Paulo');

    //recebendo variaveis para cruzamento de dados
    $taxa = $request->taxa;
    $inicio = $request->inicio;
    $fim = $request->fim;
    $shape = $request->shape;
    $dominio = $request->dominio;
    $uf = $request->uf;

    $date_diff = date_diff(new DateTime($inicio),new DateTime($fim));

    // Array that will store the days that will be queried on the database
    $periodosinicio = [];
    $periodosfim = [];
    $totalMonths = 0;

    $months = ['','Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];


    // if the ending day is smaller than the beginning day, adds a new loop so the bug
    // revolving around the number of loops corrects itself
    $varFim = new DateTime($fim);
    $var = new DateTime($inicio);
    if ($varFim->format('d') < $var->format('d') || $varFim->format('m') < $var->format('m')) {
        $beginning = 0;
    } else {
        $beginning = 1;
    }


    if($date_diff->days < 50){
        // creates periods for the sql query
        for ($i=1; $i <= $date_diff->days; $i++) {
            array_push($periodosinicio,date_format($var, 'Y-m-d'));
            $var->add(new DateInterval('P1D'));
            array_push($periodosfim,date_format($var, 'Y-m-d'));
        }
    } else if ($date_diff->days < 730) {

        // In case there is more than 1 year, adds 12 months to the loop limit
        if($date_diff->y > 0) {
            $totalMonths = 12 + $date_diff->m;
        } else {
            $totalMonths = $date_diff->m;
        }

        while ($var->format('m') != $varFim->format('m') || $var->format('y') != $varFim->format('y')) {
            array_push($periodosinicio,date_format($var, 'Y-m-d'));
            if($var->format('d') != 1) {
                $var->setDate($var->format('Y'),$var->format('m'),'1');
            }

            // sets the period of a month, on the query value
            $var->add(new DateInterval('P1M'));

            // sets the last day to be queried as being the last day of the month
            $var->sub(new DateInterval('P1D'));

            array_push($periodosfim,date_format($var, 'Y-m-d'));

            // resets the next day as being the previous first day of the month
            $var->add(new DateInterval('P1D'));
        }

        // for ($i=$beginning; $i <= $totalMonths ; $i++) {

        //     array_push($periodosinicio,date_format($var, 'Y-m-d'));
        //     if($var->format('d') != 1) {
        //         $var->setDate($var->format('Y'),$var->format('m'),'1');
        //     }

        //     // sets the period of a month, on the query value
        //     $var->add(new DateInterval('P1M'));

        //     // sets the last day to be queried as being the next query day minus one day
        //     $var->sub(new DateInterval('P1D'));

        //     array_push($periodosfim,date_format($var, 'Y-m-d'));

        //     // resets the next day as being the previous first day
        //     $var->add(new DateInterval('P1D'));

        // }
        array_push($periodosinicio,date_format($var, 'Y-m-d'));
        array_push($periodosfim,date_format(new DateTime($fim), 'Y-m-d'));

    } else {

        while ($var->format('y') != $varFim->format('y')) {
            array_push($periodosinicio,date_format($var, 'Y-m-d'));
            if($var->format('d') != 1) {
                $var->setDate($var->format('Y'),'1','1');
            }

            // sets the period of a year, on the query value
            $var->add(new DateInterval('P1Y'));

            // sets the last day to be queried as being the next query day minus one day
            $var->sub(new DateInterval('P1D'));

            array_push($periodosfim,date_format($var, 'Y-m-d'));

            // resets the next day as being the previous first day
            $var->add(new DateInterval('P1D'));
        }

        // for ($i=$beginning; $i <= $date_diff->y; $i++) {
        //     array_push($periodosinicio,date_format($var, 'Y-m-d'));
        //     if($var->format('d') != 1) {
        //         $var->setDate($var->format('Y'),'1','1');
        //     }

        //     // sets the period of a year, on the query value
        //     $var->add(new DateInterval('P1Y'));

        //     // sets the last day to be queried as being the next query day minus one day
        //     $var->sub(new DateInterval('P1D'));

        //     array_push($periodosfim,date_format($var, 'Y-m-d'));

        //     // resets the next day as being the previous first day
        //     $var->add(new DateInterval('P1D'));

        // }

        array_push($periodosinicio,date_format($var, 'Y-m-d'));
        array_push($periodosfim,date_format(new DateTime($fim), 'Y-m-d'));
    }


    // echo json_encode($periodosinicio);
    // echo json_encode($periodosfim);
    // exit;


    if($taxa ==='DETER'){

        switch ($shape) {
            case 'assentamento':
                $function = 'painel.f_deter_assentamento';
                break;
            case 'terra_indigena':
                $function = 'painel.f_deter_terra_indigena';
                break;
            case 'uc_integral':
                $function = 'painel.f_deter_unidade_protecao_integral';
                break;
            case 'uc_sustentavel':
                $function = 'painel.f_deter_unidade_uso_sustentavel';
                break;
            case 'floresta':
                $function = 'painel.f_deter_floresta_publica';
                break;
            default:
                $function = 'painel.f_deter_terra_arrecadada';
                break;
        }

    } else if ($taxa == 'AWIFS'){

        switch ($shape) {
            case 'assentamento':
                $function = 'painel.f_awifs_assentamento';
                break;
            case 'terra_indigena':
                $function = 'painel.f_awifs_terra_indigena';
                break;
            case 'uc_integral':
                $function = 'painel.f_awifs_unidade_protecao_integral';
                break;
            case 'uc_sustentavel':
                $function = 'painel.f_awifs_unidade_uso_sustentavel';
                break;
            case 'floresta':
                $function = 'painel.f_awifs_floresta_publica';
                break;
            default:
                $function = 'painel.f_awifs_terra_arrecadada';
                break;
        }

    } else if ($taxa == 'LANDSAT'){

        switch ($shape) {
            case 'assentamento':
                $function = 'painel.f_landsat_assentamento';
                break;
            case 'terra_indigena':
                $function = 'painel.f_landsat_terra_indigena';
                break;
            case 'uc_integral':
                $function = 'painel.f_landsat_unidade_protecao_integral';
                break;
            case 'uc_sustentavel':
                $function = 'painel.f_landsat_unidade_uso_sustentavel';
                break;
            case 'floresta':
                $function = 'painel.f_landsat_floresta_publica';
                break;
            default:
                $function = 'painel.f_landsat_terra_arrecadada';
                break;
        }

    }

    if($shape ==="terra_indigena" || $shape ==="terra_arrecadada" || $shape ==="floresta"){
        $query = "SELECT ";

        for ($i=0; $i < sizeof($periodosinicio); $i++) {
            $query = $query . "( SELECT coalesce(resultado,0) FROM  ".$function." ( '$uf' ,'$periodosinicio[$i]','$periodosfim[$i]' ) AS foo (Resultado float)), ";
        }
        // $query = " SELECT * FROM  ".$function." ( '$uf' ,'$inicio','$fim' ) AS foo (Resultado float);";
    }else{
        $query = "SELECT ";

        for ($i=0; $i < sizeof($periodosinicio); $i++) {
            $query = $query . "( SELECT coalesce(resultado,0) FROM  ".$function." ( '$dominio' , '$uf' ,'$periodosinicio[$i]','$periodosfim[$i]' ) AS foo (Resultado float)), ";
        }
        // $query = " SELECT * FROM  ".$function." ( '$dominio' , '$uf' ,'$inicio','$fim' ) AS foo (Resultado float);";
    }

    $query = substr($query, 0, -2);

    $rows = array();
    $table = array();

    //echo $query;

    $POSTGRES = pg_connect("host=$HOST port=$PORT dbname=$DATABASE user=$USER password=$PASSWORD");

    // echo $query;
    // exit;

	$result = pg_query($query);


    $out = array();

    while($row = pg_fetch_row($result)){
        $out = $row;
    }
    // $local = $out[0];

    // $arr = array(
    // 'area'  => $local
    // );

    $return = array();
    $obj = array();

    foreach ($out as $key => $value) {
        $c = array();

        $string = new DateTime($periodosfim[$key]);

        if ($date_diff->days < 50)
            array_push($c, (object) array(v => $string->format('d/m')));
        else if ($date_diff->days < 730)
            array_push($c, (object) array(v => $months[(int) $string->format('m')]));
        else
            array_push($c, (object) array(v => $string->format('Y')));

        array_push($c, (object) array(v => (float) number_format((float)$value, 2, '.', '')));

        // array_push($obj, (object) array(c => $c));
        array_push($return, (object) array(c => $c));
    }

    // array_push($return, $obj);


    // $query  = " SELECT * FROM dado_prodes_consolidado "


    // $result = pg_query($query);

    pg_close($POSTGRES);


    $jsn = json_encode($return);
    print_r($jsn);

    ?>
















