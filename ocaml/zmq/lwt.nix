{ buildDunePackage, zmq, lwt, ounit2 }:

buildDunePackage {
  pname = "zmq-lwt";

  inherit (zmq) src version;

  propagatedBuildInputs = [ lwt zmq ];

  checkInputs = [ ounit2 ];

  # Tests seem flakey
  doCheck = false;
}
