<?php

	include 'config.php';

	$postdata = file_get_contents("php://input");
    $request = json_decode($postdata);

    //recebendo variaveis para cruzamento de dados
    $taxa = $request->taxa;
    $inicio = $request->inicio;
    $fim = $request->fim;
    $shape = $request->shape;
    $dominio = $request->dominio;
    $uf = $request->uf;

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
        if($shape ==="terra_indigena"){
            $query = " SELECT * FROM  ".$function." ( '$uf' ,'$inicio','$fim' ) AS foo (Resultado float);";
        }else{
        	$query = " SELECT * FROM  ".$function." ( '$dominio' , '$uf' ,'$inicio','$fim' ) AS foo (Resultado float);";
        }

        // echo $query;
        // exit;

    } else {

    }

    $rows = array();
    $table = array();

    //echo $query;

    $POSTGRES = pg_connect("host=$HOST port=$PORT dbname=$DATABASE user=$USER password=$PASSWORD");

	$result = pg_query($query);

    $out = array();

    while($row = pg_fetch_row($result)){
        $out = $row;
    }
    $local = $out[0];

    $arr = array(
    'area'  => $local
    );

    $jsn = json_encode($arr);
    print_r($jsn);


    ?>
















