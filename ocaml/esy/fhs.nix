{ esy, buildFHSUserEnv }:
buildFHSUserEnv {
  name = "esy-fhs";
  targetPkgs = pkgs: with pkgs; [
    ligo
    esy
  ];
  extraBuildCommands = ''
    cp ${esy}/lib/ocaml/4.12.0/site-lib/esy/esyBuildPackageCommand $out/usr/lib/esy
    cp ${esy}/lib/ocaml/4.12.0/site-lib/esy/esyRewritePrefixCommand $out/usr/lib/esy
  '';
  runScript = "bash -c $SHELL";
  meta = esy.meta // { description = "FHS-compaible version of esy"; };
}
