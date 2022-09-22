{ buildDunePackage }:

buildDunePackage {
  pname = "prometheus";
  version = "n/a";

  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/prometheus/archive/5acd3509.tar.gz;
    sha256 = "01vxgjfydiwa5164c0l0waks3k3xj0mj2f6bxf7mjhcxj6bixhns";
  };
}
