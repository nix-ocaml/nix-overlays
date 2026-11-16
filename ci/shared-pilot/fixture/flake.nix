{
  description = "Three tiny derivations for the signed shared-workflow smoke test";

  outputs =
    { self }:
    let
      # This source-less fixture uses only shell builtins. Its separate smoke
      # configuration disables sandboxing for /bin/sh; production does not.
      mk =
        name: dependencies: outputs:
        derivation {
          inherit dependencies outputs;
          name = "nix-ci-shared-workflow-v1-${name}";
          system = "x86_64-linux";
          builder = "/bin/sh";
          args = [
            "-eu"
            "-c"
            ''
              for dependency in $dependencies; do
                read -r value < "$dependency"
                test "$value" = shared-workflow-fixture
              done
              for output in $outputs; do
                eval "path=\$$output"
                printf '%s\n' shared-workflow-fixture > "$path"
              done
            ''
          ];
        };
      shared = mk "shared" [ ] [ "out" "dev" ];
    in
    {
      inherit shared;
      first = mk "first" [ shared.out ] [ "out" ];
      second = mk "second" [ shared.dev ] [ "out" ];
    };
}
