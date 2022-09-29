{ lib
, fetchFromGitHub
, buildDunePackage
, dream-pure
, lwt
, lwt_ppx
, lwt_ssl
, ssl
, angstrom
, base64
, bigstringaf
, digestif
, faraday
, faraday-lwt-unix
, psq
, result
, ppx_expect
  # vendored
, gluten
, gluten-lwt-unix
, httpaf
, httpaf-lwt-unix
, h2
, h2-lwt-unix
, websocketaf
, websocketaf-lwt-unix
}:

buildDunePackage rec {
  pname = "dream-httpaf";
  inherit (dream-pure) src version;

  propagatedBuildInputs = [
    dream-pure
    lwt
    lwt_ppx
    lwt_ssl
    ssl

    ppx_expect

    # vendored
    gluten
    gluten-lwt-unix
    httpaf
    httpaf-lwt-unix
    h2
    h2-lwt-unix
    websocketaf
    websocketaf-lwt-unix
  ];

  patches = [ ./upload.patch ];

  postPatch = ''
    substituteInPlace src/http/shared/websocket.ml --replace \
      'Websocketaf.Server_connection.{frame;' \
      'Websocketaf.Websocket_connection.{frame;'
    substituteInPlace src/http/shared/websocket.ml --replace \
      'Websocketaf.Client_connection.{frame;' \
      'Websocketaf.Websocket_connection.{frame;'
    substituteInPlace src/http/shared/websocket.ml --replace \
      'Websocketaf.Client_connection.input_handlers' \
      'Websocketaf.Websocket_connection.input_handlers'
  '';

  preBuild = ''
    rm -rf src/vendor
  '';

  doCheck = false;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
