<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Home extends CI_Controller {

    function __construct() {
        parent::__construct();

        $this->load->library('AuthLDAP');

        // Enable firebug
        $this->load->library('Firephp');
        $this->firephp->setEnabled(TRUE);
    }

    public function index()
    {

        // $this->firephp->log($this->session->userdata('logged_in'));

        if($this->session->userdata('logged_in')) {
            $data['name'] = $this->session->userdata('name');
            $data['username'] = $this->session->userdata('username');
            $data['logged_in'] = TRUE;
        } else {
            $data['logged_in'] = FALSE;
        }

        $this->userEnableList = [
            "27975460168",
            "43982204020",
            "05219910485",
            "05965497172",
            "22448705372",
            "15074323134",
            "30355683830",
            "30345030087",
            "84408413100",
            "78061423987",
            "00218532156",
            "92724043120",
            "67710158587",
            "80826474187",
            "26655225191",
            "25473575859",
            "32449984291",
            "86930982172",
            "01900791935",
            "60389346261",
            "01801878994",
            "72024887104",
            "89190637100",
            "37099167120",
            "03361709806",
            "01433540355",   // DEVELOPER'S CPF
            "02203779101",   // DEVELOPER'S CPF
            "02539550177"   // DEVELOPER'S CPF
        ];


        $this->load->view('templates/home', $data);

    }
}
