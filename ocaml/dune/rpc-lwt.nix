{ lib, buildDunePackage, dune, dune-rpc, lwt, csexp, dyn }:


buildDunePackage {
  pname = "dune-rpc-lwt";
  inherit (dune) src version;

  propagatedBuildInputs = [ csexp dune-rpc lwt ];
  dontAddPrefix = true;
  inherit (dyn) preBuild;

  postPatch = ''
    substituteInPlace "otherlibs/dune-rpc-lwt/src/dune_rpc_lwt.ml" --replace \
      "Lwt_result.catch (Lwt_io.with_file ~mode:Input s Lwt_io.read)" \
      "Lwt_result.catch (fun () -> (Lwt_io.with_file ~mode:Input s Lwt_io.read))"
  '';
}
