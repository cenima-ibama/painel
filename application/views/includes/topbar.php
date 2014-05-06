<header id="navbar" class="navbar navbar-inverse navbar-fixed-top">
  <div class="navbar-inner">
    <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </a>
    <a class="brand" href="#"><img src="<?= base_url()?>/assets/img/ibama.png" style="margin:-2px 2px 0 10px;"> <span class="label label-inverse">v3.0</span></a>
    <div class="nav-collapse collapse">
      <ul class="nav">
        <li class=""><a id="btn-map" href="#"><i class="icon-globe icon-white"></i> Mapa</a></li>
        <li class="active"><a id="btn-charts" href="#"><i class="icon-dashboard icon-white"></i> Estatística</a></li>

        <?php
          if($this->session->userdata('logged_in')) {
            echo '<li class=""><a id="btn-charts2" href="#"><i class="icon-bar-chart icon-white"></i> Cruzamento de Dados</a></li>';
            echo '<li class=""><a id="btn-charts3" href="#"><i class="icon-bar-chart icon-white"></i> Configurações do Sistema</a></li>';
          }
        ?>
        <!-- <li class=""><a id="btn-charts3" href="#"><i class="icon-bar-chart icon-white"></i> Novas Estatísticas</a></li> -->
      </ul>
      <?php
        if($this->session->userdata('logged_in')) {
          echo '<ul class="nav pull-right">';
            echo '<li class="dropdown">';
              echo('<a id="btn-logged" class="dropdown-toggle" href="#" data-toggle="dropdown"><i class="icon-user icon-white"></i> ' . $name . '<strong class="caret"></strong></a>');
              echo '<ul class="dropdown-menu">';
                echo '<li>' . anchor(base_url() . '/index.php/auth/logout', 'Logout', '') . '</li>';
              echo '</ul>';
            echo '</li>';
          echo '</ul>';
        }
        else {
          echo '<ul class="nav pull-right">';
          echo '<li class=""><a id="btn-login" href="#"><i class="icon-user icon-white"></i> Login</a>';
          echo '</ul>';
        }
      ?>
    </div>
  </div>
</header>
