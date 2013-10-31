<div class="loading" id="loading">
  <img src="http://siscom.ibama.gov.br/painel/assets/img/ibama_logo.png" id="loading_logo" style="display: inline;" title="">
</div>
<?php
  if(!$logged_in) {
    echo '<div id="login" class="login"> </div>';
  }
?>
<div id="map" class="map"></div>
<div id="dash" class="dash">
  <div class="charts-content">
    <div class="row-fluid">
      <?php
      if(!$this->session->userdata('logged_in')) {
        echo '<div class="alert alert-info alert-block fade in" style="margin: 0 20% 20px">';
        echo '<button class="close" data-dismiss="alert">&times;</button>
        <h4 style="text-align: left">Importante:</h4></br>
        <p style="text-align: left">
        As informações do DETER/INPE devem ser usadas com cuidado, pois este sistema não foi concebido para medição de áreas desmatadas.
        Informação: '. anchor('http://www.obt.inpe.br/deter/metodologia_v2.pdf', 'Metodologia DETER') . '</p>';
        echo '</div>';
      }
      ?>
      <div class="quick-slct">
        <div class="item">
          <label>Mês</label>
          <select id="monthsSlct" class="input-small" name="months">
            <option value="0">Jan</option>
            <option value="1">Fev</option>
            <option value="2">Mar</option>
            <option value="3">Abr</option>
            <option value="4">Mai</option>
            <option value="5">Jun</option>
            <option value="6">Jul</option>
            <option value="7">Ago</option>
            <option value="8">Set</option>
            <option value="9">Out</option>
            <option value="10">Nov</option>
            <option value="11">Dez</option>
          </select>
        </div>
        <div class="item">
          <label>Ano</label>
          <select id="yearsSlct" class="input-small" name="years">
            <option value="2004">2004</option>
            <option value="2005">2005</option>
            <option value="2006">2006</option>
            <option value="2007">2007</option>
            <option value="2008">2008</option>
            <option value="2009">2009</option>
            <option value="2010">2010</option>
            <option value="2011">2011</option>
            <option value="2012">2012</option>
            <option value="2013">2013</option>
            <option value="2014">2014</option>
          </select>
        </div>
        <div class="item">
          <label>Tipo</label>
          <select id="typeSlct" class="input-medium" name="type">
            <option value="deter">DETER</option>
            <option value="embargos">Embargos</option>
          </select>
        </div>
      </div>
      <div class="quick-btn">
        <a id="norte" href="#" class="item">
          <i class="icon-norte"></i>
          <span>Norte</span>
        </a>
        <a id="AC" href="#" class="item" style="display:none">
          <i class="icon-ac"></i>
          <span>AC</span>
        </a>
        <a id="AP" href="#" class="item" style="display:none">
          <i class="icon-ap"></i>
          <span>AP</span>
        </a>
        <a id="AM" href="#" class="item" style="display:none">
          <i class="icon-am"></i>
          <span>AM</span>
        </a>
        <a id="PA" href="#" class="item" style="display:none">
          <i class="icon-pa"></i>
          <span>PA</span>
        </a>
        <a id="RO" href="#" class="item" style="display:none">
          <i class="icon-ro"></i>
          <span>RO</span>
        </a>
        <a id="RR" href="#" class="item" style="display:none">
          <i class="icon-rr"></i>
          <span>RR</span>
        </a>
        <a id="TO" href="#" class="item" style="display:none">
          <i class="icon-to"></i>
          <span>TO</span>
        </a>
        <a id="centrooeste" href="#" class="item">
          <i class="icon-centrooeste"></i>
          <span>Centro-Oeste</span>
        </a>
        <a id="DF" href="#" class="item" style="display:none">
          <i class="icon-df"></i>
          <span>DF</span>
        </a>
        <a id="GO" href="#" class="item" style="display:none">
          <i class="icon-go"></i>
          <span>GO</span>
        </a>
        <a id="MT" href="#" class="item" style="display:none">
          <i class="icon-mt"></i>
          <span>MT</span>
        </a>
        <a id="MS" href="#" class="item" style="display:none">
          <i class="icon-ms"></i>
          <span>MS</span>
        </a>
        <a id="sul" href="#" class="item">
          <i class="icon-sul"></i>
          <span>Sul</span>
        </a>
        <a id="PR" href="#" class="item" style="display:none">
          <i class="icon-pr"></i>
          <span>PR</span>
        </a>
        <a id="RS" href="#" class="item" style="display:none">
          <i class="icon-rs"></i>
          <span>RS</span>
        </a>
        <a id="SC" href="#" class="item" style="display:none">
          <i class="icon-sc"></i>
          <span>SC</span>
        </a>
        <a id="nordeste" href="#" class="item">
          <i class="icon-nordeste"></i>
          <span>Nordeste</span>
        </a>
        <a id="AL" href="#" class="item" style="display:none">
          <i class="icon-al"></i>
          <span>AL</span>
        </a>
        <a id="BA" href="#" class="item" style="display:none">
          <i class="icon-ba"></i>
          <span>BA</span>
        </a>
        <a id="CE" href="#" class="item" style="display:none">
          <i class="icon-ce"></i>
          <span>CE</span>
        </a>
        <a id="MA" href="#" class="item" style="display:none">
          <i class="icon-ma"></i>
          <span>MA</span>
        </a>
        <a id="PB" href="#" class="item" style="display:none">
          <i class="icon-pb"></i>
          <span>PB</span>
        </a>
        <a id="PE" href="#" class="item" style="display:none">
          <i class="icon-pe"></i>
          <span>PE</span>
        </a>
        <a id="PI" href="#" class="item" style="display:none">
          <i class="icon-pi"></i>
          <span>PI</span>
        </a>
        <a id="RN" href="#" class="item" style="display:none">
          <i class="icon-rn"></i>
          <span>RN</span>
        </a>
        <a id="SE" href="#" class="item" style="display:none">
          <i class="icon-se"></i>
          <span>SE</span>
        </a>
        <a id="sudeste" href="#" class="item">
          <i class="icon-sudeste"></i>
          <span>Sudeste</span>
        </a>
        <a id="ES" href="#" class="item" style="display:none">
          <i class="icon-es"></i>
          <span>ES</span>
        </a>
        <a id="MG" href="#" class="item" style="display:none">
          <i class="icon-mg"></i>
          <span>MG</span>
        </a>
        <a id="RJ" href="#" class="item" style="display:none">
          <i class="icon-rj"></i>
          <span>RJ</span>
        </a>
        <a id="SP" href="#" class="item" style="display:none">
          <i class="icon-sp"></i>
          <span>SP</span>
        </a>
        <a id="brasil" href="#" class="item active">
          <i class="icon-brasil"></i>
          <span>Brasil</span>
        </a>
      </div>
    </div>
    <hr>
    <div class="row-fluid">
      <div id="sparks-deter" class="sparks">
        <div id="knob1" class="spark"> </div>
        <div id="knob2" class="spark"> </div>
        <div id="knob3" class="spark"> </div>
        <div id="spark1" class="spark"> </div>
        <div id="spark2" class="spark"> </div>
      </div>
      <div id="sparks-embargo" class="sparks">
        <div id="spark-tvaa-embargo" class="spark"> </div>
        <div id="spark-tvma-embargo" class="spark"> </div>
        <div id="spark-tvpa-embargo" class="spark"> </div>
        <div id="spark-monthly-embargo" class="spark"> </div>
        <div id="spark-annual-embargo" class="spark"> </div>
      </div>
    </div>
    <hr>
    <div id="charts-deter" class="row-fluid">
      <div id="chart1" class="box"> </div>
      <div id="chart2" class="box"> </div>
      <div id="chart3" class="box"> </div>
      <div id="chart4" class="box"> </div>
      <div id="chart5" class="box"> </div>
      <div id="chart6" class="box"> </div>
      <div id="chart9" class="box"> </div>
      <div id="chart7" class="box-small"> </div>
      <div id="chart8" class="box-small"> </div>
    </div>
    <div id="charts-embargo" class="row-fluid">
      <div id="chart-daily-embargo" class="box"> </div>
      <div id="chart-monthly-embargo" class="box"> </div>
      <div id="chart-annual-embargo" class="box"> </div>
      <div id="chart-states-embargo" class="box"> </div>
    </div>
  </div>
</div>
