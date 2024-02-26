{ backoff
, buildDunePackage
, domain-local-await
, domain-local-timeout
, multicore-magic
}:

buildDunePackage {
  pname = "kcas";
  version = "0.7.9";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/kcas/releases/download/0.7.0/kcas-0.7.0.tbz;
    sha256 = "148zgbvkq67ial8rgmz5kzyi3y8m35dw62sqr4fx9vq1g6vfi3ws";
  };
  propagatedBuildInputs = [
    domain-local-await
    domain-local-timeout
    multicore-magic
    backoff
  ];
}
