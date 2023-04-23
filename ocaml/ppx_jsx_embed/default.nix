{ fetchFromGitHub, buildDunePackage, reason, ppxlib }:

buildDunePackage {
  pname = "ppx_jsx_embed";
  version = "0.0.0";
  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "ppx_jsx_embed";
    rev = "97045c4544f25729bdc05a3cb50743c20210686c";
    hash = "sha256-7dPvSmpT+hU6+GlZoa/SpHVi7zRHwX/SZR7Jsk2aJ3A=";
  };
  doCheck = true;
  useDune2 = true;
  propagatedBuildInputs = [ reason ppxlib ];
}
