{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  cmdliner,
  findlib,
  mlx,
  ocamlformat,
  ocamlformat-mlx,
  ocamlformat-mlx-lib,
  ppxlib,
  reason,
}:

buildDunePackage rec {
  pname = "reason-to-mlx";
  version = "0.1.0";
  minimalOCamlVersion = "5.5";

  src = fetchFromGitHub {
    owner = "ocaml-mlx";
    repo = "reason-to-mlx";
    tag = version;
    hash = "sha256-rhw3c8n3UlnjawR4Ymf1lvHOzNZZTu/rRc57OqY0d3k=";
  };

  buildInputs = [
    cmdliner
    ocamlformat-mlx
  ];
  propagatedBuildInputs = [
    ocamlformat-mlx-lib
    ppxlib
    reason
  ];

  doCheck = true;
  nativeCheckInputs = [
    findlib
    mlx
    ocamlformat
    ocamlformat-mlx
  ];

  meta = {
    broken = reason.meta.broken or false;
    description = "Convert Reason source to MLX, with an in-memory library API";
    homepage = "https://github.com/ocaml-mlx/reason-to-mlx";
    license = lib.licenses.mit;
    mainProgram = "reason-to-mlx";
  };
}
