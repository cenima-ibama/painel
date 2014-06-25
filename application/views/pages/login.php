<div class="container">
    <div class="form-login">
    <button id="close-btn-login" type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
        <?php echo form_fieldset('<img src="' . base_url() . '/assets/img/ibama_inv.png"> <span class="label label-inverse">Login</span>'); ?>
        <?php
            if (validation_errors()) {
                echo '<div class="alert alert-block alert-error fade in">';
                echo '<button class="close" data-dismiss="alert">&times;</button><span>' . validation_errors() .'</span>';
                echo '</div>';
            }
            else if (isset($login_fail)) {
                echo '<div class="alert alert-block alert-error fade in">';
                echo '<button class="close" data-dismiss="alert">&times;</button><span> Usuário ou Senha inválidos.</span>';
                echo '</div>';
            }
         ?>

        <?php echo form_open('auth/login', array('id' => 'loginform', 'class' => 'form-horizontal')); ?>

        <div class="control-group">
            <?php echo form_label('Usuário:', 'username', array('class' => 'control-label', 'for' => 'username')); ?>
            <div class="controls">
                <?php echo form_input(array('name' => 'username', 'id' => 'username', 'class' => 'formfield', 'type' => 'text')); ?>
            </div>
        </div>
        <div class="control-group">
            <?php echo form_label('Senha:', 'password', array('class' => 'control-label', 'for' => 'password')) ?>
            <div class="controls">
                <?php echo form_password(array('name' => 'password', 'id' => 'password','class' => 'formfield')); ?>
            </div>
        </div>
        <br />
        <div class="control-group">
            <div class="controls">
                <?php
                $checkbox = form_checkbox(array('name' => 'remember', 'id' => 'remember'), 1,  FALSE);
                echo form_label($checkbox . ' Lembrar-me', 'remember', array('class'=> 'checkbox pull-left'));
                ?>
                <?php echo form_button( array('name' => 'login', 'class'=> 'btn btn-primary pull-right', 'type' => 'submit'), 'Login'); ?>
            </div>
        </div>
        <?php echo form_close(); ?>
        <?php echo form_fieldset_close(); ?>
        <hr>
        <h4>Acesso Restrito</h4>
        <p>O acesso a essa sessão é permitida somente a usuários registrados no sistema Ibama-Net.</p>
    </div>
</div> <!-- container -->
