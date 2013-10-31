<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Login extends CI_Controller {

    function __construct()
    {
        parent::__construct();

        $this->load->helper('form');
        $this->load->library('Form_validation');
        $this->load->driver('session');
    }

    public function index()
    {
        if (! file_exists('application/views/pages/login.php')) {
            // Whoops, we don't have a page for that!
            show_404();
        }

        if($this->session->userdata('logged_in')) {
            redirect(base_url());
        }
        else {
            $this->load->view('pages/login');
        }
    }
}
