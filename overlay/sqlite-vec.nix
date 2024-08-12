{ lib
, cmake
, fetchFromGitHub
, gomp
, llvmPackages
, sqlite
, stdenv
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sqlite-vss";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "asg017";
    repo = "sqlite-vec";
    rev = "v${finalAttrs.version}";
    hash = lib.fakeHash;
  };

  # nativeBuildInputs = [ python3 ];

  buildInputs = [ sqlite ];

  installPhase = ''
    runHook preInstall

    install -Dm444 -t "$out/lib" \
      "libsqlite_vector0${stdenv.hostPlatform.extensions.staticLibrary}" \
      "libsqlite_vss0${stdenv.hostPlatform.extensions.staticLibrary}" \
      "vector0${stdenv.hostPlatform.extensions.sharedLibrary}" \
      "vss0${stdenv.hostPlatform.extensions.sharedLibrary}"

    runHook postInstall
  '';

  meta = with lib;{
    description = "vector search SQLite extension that runs anywhere";
    homepage = "https://github.com/asg017/sqlite-vec";
    changelog = "https://github.com/asg017/sqlite-vec/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    platforms = platforms.unix;
  };
})
