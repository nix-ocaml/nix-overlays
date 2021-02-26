{ callPackage }:


{
  cockroachdb-20_x = callPackage ./generic.nix (rec {
    version = "20.2.5";
    src = builtins.fetchurl
      {
        url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
        sha256 = "181h0ywk6r661fy1z37jbdhxz8hn4q09n795l9063cqndm8gcr7r";
      };
  });
  cockroachdb-21_x = callPackage ./generic.nix (rec{
    version = "21.1.0-alpha.3";
    src = builtins.fetchurl
      {
        url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
        sha256 = "1jfn53lyapqsi9zm4khplfqp7lkja2s7gk78vcgz8zfaqi551qq7";
      };
  });
}
