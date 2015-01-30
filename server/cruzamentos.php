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
    $estagio = $request->estagio;
    $uf = $request->uf;

    $federal = 0.0;
    $estadual = 0.0;

    // chart1 - Cruzamentos
    $obj = [];
    // chart3 - Área Federais
    $obj1 = [];
    // chart4 - Área Estaduais
    $obj2 = [];
    // chart3 - Área Federais vs Áreas Estaduais
    $obj3 = [];
    // Filter informations
    $obj4 = [];


    // Inicialização da variavel que guardará o nome da função a ser consultada no banco.
    $function = "";

    if ($taxa != "PRODES") {
        $date_diff = date_diff(new DateTime($inicio),new DateTime($fim));
    }

    // Array que guardará os dias que serão consultados no banco
    $periodosinicio = [];
    $periodosfim = [];
    $totalMonths = 0;

    $months = ['','Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];


    if ($taxa != "PRODES") {
        // Se o ultimo dia da consulta for menor que o primeiro dia da consulta, adiciona uma nova iteração
        // para que o problema de calculo de iterações se auto-corrija
        $varFim = new DateTime($fim);
        $var = new DateTime($inicio);
        if ($varFim->format('d') < $var->format('d') || $varFim->format('m') < $var->format('m')) {
            $beginning = 0;
        } else {
            $beginning = 1;
        }


        if($date_diff->days < 50){
            // cria periodos para a consulta sql
            for ($i=1; $i <= $date_diff->days; $i++) {
                array_push($periodosinicio,date_format($var, 'Y-m-d'));
                $var->add(new DateInterval('P1D'));
                array_push($periodosfim,date_format($var, 'Y-m-d'));
            }
        } else if ($date_diff->days < 730) {

            // Para o caso de ter mais de 1 ano, adiciona-se mais 12 meses ao limite da iteração
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

                // Seta o periodo de 1 mes para a consulta no banco
                $var->add(new DateInterval('P1M'));

                // Seta o ultimo dia para ser consultado como o ultimo dia do mes
                $var->sub(new DateInterval('P1D'));

                array_push($periodosfim,date_format($var, 'Y-m-d'));

                // Retorna o valor do proximo dia como sendo o valor inicial, o primeiro dia do proximo mes
                $var->add(new DateInterval('P1D'));
            }

            array_push($periodosinicio,date_format($var, 'Y-m-d'));
            array_push($periodosfim,date_format(new DateTime($fim), 'Y-m-d'));

        } else {

            while ($var->format('y') != $varFim->format('y')) {
                array_push($periodosinicio,date_format($var, 'Y-m-d'));
                if($var->format('d') != 1) {
                    $var->setDate($var->format('Y'),'1','1');
                }

                // Seta o periodo de 1 ano para a consulta no banco
                $var->add(new DateInterval('P1Y'));

                // Seta o ultimo dia para ser consultado como o ultimo dia do ano
                $var->sub(new DateInterval('P1D'));

                array_push($periodosfim,date_format($var, 'Y-m-d'));

                // Retorna o valor do proximo dia como sendo o valor inicial, o primeiro dia do proximo ano
                $var->add(new DateInterval('P1D'));
            }

            array_push($periodosinicio,date_format($var, 'Y-m-d'));
            array_push($periodosfim,date_format(new DateTime($fim), 'Y-m-d'));
        }

    } else {
        // for ($i=2000; $i < 2014; $i++) {
        for ($i=$inicio; $i <= $fim; $i++) {
            array_push($periodosfim,(string) "01-01-" . $i);
        }
    }


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
            case 'terra_arrecadada':
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
            case 'terra_arrecadada':
                $function = 'painel.f_awifs_terra_arrecadada';
                break;
        }

    } else if ($taxa == 'INDICAR'){

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
            case 'terra_arrecadada':
                $function = 'painel.f_landsat_terra_arrecadada';
                break;
        }

    } else if ($taxa == 'PRODES'){

        switch ($shape) {
            case 'assentamento':
                $function = 'assentamento';
                break;
            case 'terra_indigena':
                $function = 'terra_indigena';
                break;
            case 'uc_integral':
                $function = 'unidades_de_conservacao_protecao_integral';
                break;
            case 'uc_sustentavel':
                $function = 'unidades_de_conservacao_uso_sustentavel';
                break;
            case 'terra_arrecadada':
                $function = 'terra_arrecadada';
                break;
        }

    }

    $query = "";

    if ($taxa == 'PRODES') {
        $query = "SELECT ";

        if(($shape == "uc_integral" || $shape == "uc_sustentavel" || $shape == "assentamentos" || $shape == "terra_arrecadada") && $dominio == 'ESTADUAL') {
            $function = $function . "_estadual";
        }

        for ($i=0; $i < sizeof($periodosfim); $i++) {
            $array = explode('-', $periodosfim[$i]);
            $query = $query . "( SELECT SUM(" . $function . ") FROM public.dado_prodes_consolidado WHERE ano = '$array[2]' ";
            if ($uf != 'BR') {
                $query = $query . " and uf='$uf' ";
            }
            $query = $query . " ), ";
        }
    } else {
        if (($shape == "terra_arrecadada") && ($dominio == "ESTADUAL")) {
            $function = $function . "_estadual";
        } else if (($shape == "terra_arrecadada") && ($dominio == "FEDERAL")) {
            $function = $function . "_federal";
        }

        if (($taxa == 'INDICAR') || ($taxa == 'AWIFS')) {
            $estagioDB = " '" . $estagio . "', ";
        } else {
            $estagioDB = "";
        }

        if(($shape == "terra_indigena") || ($shape == "terra_arrecadada")){
            $query = "SELECT ";

            for ($i=0; $i < sizeof($periodosinicio); $i++) {
                $query = $query . "( SELECT coalesce(resultado,0) FROM  ". $function ." ( " . $estagioDB . " '$uf' ,'$periodosinicio[$i]','$periodosfim[$i]' ) AS foo (Resultado float)), ";
            }
        }else{
            $query = "SELECT ";

            for ($i=0; $i < sizeof($periodosinicio); $i++) {
                $query = $query . "( SELECT coalesce(resultado,0) FROM  ".$function." ( " . $estagioDB . " '$dominio' , '$uf' ,'$periodosinicio[$i]','$periodosfim[$i]' ) AS foo (Resultado float)), ";
            }
        }
    }

    $query = substr($query, 0, -2);

    $rows = [];
    $table = [];

    $POSTGRES = pg_connect("host=$HOST port=$PORT dbname=$DATABASE user=$USER password=$PASSWORD");

    // echo $query;
    // exit;

	$result = pg_query($query);


    $out = [];

    while($row = pg_fetch_row($result)){
        $out = $row;
    }

    $return = [];

    foreach ($out as $key => $value) {
        $c = [];

        $string = new DateTime($periodosinicio[$key]);

        if ($taxa != "PRODES") {
            if ($date_diff->days < 50)
                array_push($c, (object) array(v => $string->format('d/m')));
            else if ($date_diff->days < 730)
                array_push($c, (object) array(v => $months[(int) $string->format('m')]));
            else
                array_push($c, (object) array(v => $string->format('Y')));
        } else {
            array_push($c, (object) array(v => $string->format('Y')));
        }

        array_push($c, (object) array(v => (float) number_format((float)$value, 2, '.', '')));

        // array_push($obj, (object) array(c => $c));
        array_push($obj, (object) array(c => $c));
    }


    array_push($return, (object) array(chart1 => $obj));



    $tax = strtolower($taxa);
    $areas = ["assentamento", "terra_arrecadada", "uc_integral", "uc_sustentavel", "terra_indigena"];
    $dominios = ["FEDERAL", "ESTADUAL"];

    // $dataInicio = date_format($inicio, 'Y-m-d');
    // $dataFim = date_format($fim, 'Y-m-d');

    // print_r($dataInicio . " " . $dataFim);
    // exit;


    $selectedUf = $uf != 'BR' ? " AND uf='" . $uf . "' " : " ";

    foreach ($areas as $key => $area) {
        foreach ($dominios as $key => $dom) {

            $query = "";
            $label = "";

            if ($area == "terra_indigena")
                $field = $area;
            else if ($area == "uc_sustentavel")
                $field = $dom == 'ESTADUAL' ? "unidades_de_conservacao_uso_sustentavel_" . strtolower($dom) : "unidades_de_conservacao_uso_sustentavel";
            else if ($area == "uc_integral")
                $field = $dom == 'ESTADUAL' ? "unidades_de_conservacao_protecao_integral_" . strtolower($dom) : "unidades_de_conservacao_protecao_integral";
            else
                $field = $dom == 'ESTADUAL' ? $area . "_" . strtolower($dom) : $area;

            switch ($area) {
                case 'assentamento':
                    // if($dom == 'federal') {
                    //     $query = $query . "f_deter_assentamento('','FEDERAL','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    // } else {
                    //     $query = $query . "f_awifs_assentamento('','ESTADUAL'," . $uf . ",'" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    // }
                    $label = "Assentamento " . ucfirst(strtolower($dom));

                    if ($tax == 'deter')
                        $query = "SELECT * FROM painel.f_" . $tax . "_assentamento('" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    else if ($tax == 'prodes')
                        $query = "SELECT sum(" . $field . ") FROM public.dado_prodes_consolidado WHERE ano<='" . $fim . "' AND ano>='" . $inicio . "' " . $selectedUf;
                    else if ($tax == 'indicar')
                        $query = "SELECT * FROM painel.f_landsat_assentamento('" . $estagio . "','" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    else
                        $query = "SELECT * FROM painel.f_" . $tax . "_assentamento('" . $estagio . "','" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    break;

                case 'terra_arrecadada':
                    $label = "Terra Arrecadada " . ucfirst(strtolower($dom));

                    if ($tax == 'deter')
                        $query = "SELECT * FROM painel.f_" . $tax . "_terra_arrecadada_" . strtolower($dom) . "('" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    else if ($tax == 'prodes')
                        $query = "SELECT sum(" . $field . ") FROM public.dado_prodes_consolidado WHERE ano<='" . $fim . "' AND ano>='" . $inicio . "' " . $selectedUf;
                    else if ($tax == 'indicar')
                        $query = "SELECT * FROM painel.f_landsat_terra_arrecadada_" . strtolower($dom) . "('" . $estagio . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    else
                        $query = "SELECT * FROM painel.f_" . $tax . "_terra_arrecadada_" . strtolower($dom) . "('" . $estagio . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";

                    break;

                case 'uc_integral':
                    $label = "UC Proteção Integral " . ucfirst(strtolower($dom));

                    if ($tax == 'deter')
                        $query = "SELECT * FROM painel.f_" . $tax . "_unidade_protecao_integral('" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    else if ($tax == 'prodes')
                        $query = "SELECT sum(" . $field . ") FROM public.dado_prodes_consolidado WHERE ano<='" . $fim . "' AND ano>='" . $inicio . "' " . $selectedUf;
                    else if ($tax == 'indicar')
                        $query = "SELECT * FROM painel.f_landsat_unidade_protecao_integral('" . $estagio . "','" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    else
                        $query = "SELECT * FROM painel.f_" . $tax . "_unidade_protecao_integral('" . $estagio . "','" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    break;

                case 'uc_sustentavel':
                    $label = "UC Uso Sustentavel " . ucfirst(strtolower($dom));

                    if ($tax == 'deter')
                        $query = "SELECT * FROM painel.f_" . $tax . "_unidade_uso_sustentavel('" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    else if ($tax == 'prodes')
                        $query = "SELECT sum(" . $field . ") FROM public.dado_prodes_consolidado WHERE ano<='" . $fim . "' AND ano>='" . $inicio . "' " . $selectedUf;
                    else if ($tax == 'indicar')
                        $query = "SELECT * FROM painel.f_landsat_unidade_uso_sustentavel('" . $estagio . "','" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    else
                        $query = "SELECT * FROM painel.f_" . $tax . "_unidade_uso_sustentavel('" . $estagio . "','" . $dom . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    break;

                case 'terra_indigena':
                    $label = "Terra Indígena";

                    if ($dom == "FEDERAL") {
                        if ($tax == 'deter')
                            $query = "SELECT * FROM painel.f_" . $tax . "_terra_indigena('" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                        else if ($tax == 'prodes')
                            $query = "SELECT sum(" . $field . ") FROM public.dado_prodes_consolidado WHERE ano<='" . $fim . "' AND ano>='" . $inicio . "' " . $selectedUf;
                        else if ($tax == 'indicar')
                            $query = "SELECT * FROM painel.f_landsat_terra_indigena('" . $estagio . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                        else
                            $query = "SELECT * FROM painel.f_" . $tax . "_terra_indigena('" . $estagio . "','" . $uf . "','" . $inicio . "','" . $fim . "') AS foo (Resultado float);";
                    }
                    break;

                default:
                    $query = "";
                    break;
            }

            if(!empty($query)) {
                $result = pg_query($query);

                // print_r($query);
                // exit;

                $out = [];

                while($row = pg_fetch_row($result)){
                    $out = $row;
                }

                // if ($area == "terra_indigena") {
                //     print_r($query);
                //     print_r(json_encode($out));
                // }

                foreach ($out as $key => $value) {
                    $c = [];


                    // if ($taxa == "PRODES") {
                    //     if ($date_diff->days < 50)
                    //         array_push($c, (object) array(v => $string->format('d/m')));
                    //     else if ($date_diff->days < 730)
                    //         array_push($c, (object) array(v => $months[(int) $string->format('m')]));
                    //     else
                    //         array_push($c, (object) array(v => $string->format('Y')));
                    // } else {
                        // array_push($c, (object) array(v => $string->format('Y')));
                    // }
                    // $label = $area . "_" . strtolower($dom);

                    array_push($c, (object) array(v => $label));

                    array_push($c, (object) array(v => (float) number_format((float)$value, 2, '.', '')));

                    if ($dom == "FEDERAL" || $area == "terra_indigena") {
                        array_push($obj1, (object) array(c => $c));
                        $federal = $federal + (float) number_format((float)$value, 2, '.', '');
                    } else {
                        $estadual = $estadual + (float) number_format((float)$value, 2, '.', '');
                        array_push($obj2, (object) array(c => $c));
                    }
                }
            }
        }
    }

    // Creating the object that holds the info for the graphic "Estaduais vs Federais"
    $c = [];
    array_push($c, (object) array(v => "Áreas Estaduais"));
    array_push($c, (object) array(v => $estadual));
    array_push($obj3, (object) array(c => $c));

    $c = [];
    array_push($c, (object) array(v => "Áreas Federais"));
    array_push($c, (object) array(v => $federal));
    array_push($obj3, (object) array(c => $c));

    // Return infos on the current data crossing
    foreach ($request as $key => $value) {
        $c = [];
        array_push($obj4, (object) array($key => ucfirst(strtolower($value))));
    }

    // $taxa = $request->taxa;
    // $inicio = $request->inicio;
    // $fim = $request->fim;
    // $shape = $request->shape;
    // $dominio = $request->dominio;
    // $estagio = $request->estagio;
    // $uf = $request->uf;

    // Adding objects with infos for the graphics into the returning object
    array_push($return, (object) array(federalChart => $obj1));
    array_push($return, (object) array(estadualChart => $obj2));
    array_push($return, (object) array(geralChart => $obj3));
    array_push($return, (object) array(filters => $obj4));


    $result = pg_query($query);

    pg_close($POSTGRES);


    $jsn = json_encode($return);
    print_r($jsn);

    ?>
















