<?php if (!defined('BASEPATH')) exit('No direct script access allowed');
/*
 * This file is part of AuthLDAP.

 AuthLDAP is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 AuthLDAP is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with AuthLDAP. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @authors     Greg Wojtak <gwojtak@techrockdo.com>, Helmuth Saatkamp <helmuthdu@gmail.com>
 * @copyright   Copyright © 2010-2013 by Greg Wojtak <gwojtak@techrockdo.com>
 * @package     AuthLDAP
 * @license     GNU Lesser General Public License
 */
class Auth extends CI_Controller {
    function __construct() {
        parent::__construct();

        // Enable firebug
        $this->load->library('Firephp');
        $this->firephp->setEnabled(TRUE);

        $this->load->helper(array('form', 'url'));
        $this->load->library('Form_validation');
        $this->load->library('AuthLDAP');
    }

    function index() {
        $this->session->keep_flashdata('tried_to');
        $this->login();
    }

    function login($errorMsg = NULL){
        $this->session->keep_flashdata('tried_to');
        if(!$this->authldap->is_authenticated()) {
            // Set up rules for form validation
            $rules = $this->form_validation;
            $rules->set_rules('username', 'Username', 'required');
            $rules->set_rules('password', 'Password', 'required');

            // Do the login...
            if($rules->run() && $this->authldap->login(
                $rules->set_value('username'),
                $rules->set_value('password'))) {
                    // Login WIN!
                    if($this->session->flashdata('tried_to')) {
                        redirect($this->session->flashdata('tried_to'));
                    } else {
                        redirect(base_url());
                    }
                }
            else {
                $data['login_fail'] = TRUE;
                $data['logged_in'] = FALSE;
                // Login FAIL
                $this->load->view('templates/login', $data);
            }
        }
    }

    function logout() {
        if($this->session->userdata('logged_in')) {
            $this->authldap->logout();
        } else {
            $data['logged_in'] = FALSE;
        }
        redirect(base_url());
    }
}