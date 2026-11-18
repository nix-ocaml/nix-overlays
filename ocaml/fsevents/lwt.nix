{
  buildDunePackage,
  fsevents,
  cf-lwt,
  lwt,
  cmdliner,
  alcotest,
}:

buildDunePackage {
  pname = "fsevents-lwt";
  inherit (fsevents) version src meta;
  buildInputs = [ cmdliner ];
  propagatedBuildInputs = [
    fsevents
    cf-lwt
    lwt
  ];
  checkInputs = [ alcotest ];
  doCheck = true;
  postPatch = ''
    substituteInPlace src/fs_events.ml \
      --replace-fail 'Term.(ret (pure stream $ format $ paths)),' \
        'Cmd.v (Cmd.info "fsevents" ~doc) Term.(const stream $ format $ paths)' \
      --replace-fail 'Term.info "fsevents" ~doc' "" \
      --replace-fail $'match Term.eval stream_cmd with\n| `Error _ -> exit 1\n| _ -> exit 0' \
        'exit (Cmd.eval stream_cmd)'
  '';
}
