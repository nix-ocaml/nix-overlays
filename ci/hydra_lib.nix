rec {
  mkJobset = { enabled ? 1, hidden ? false, description ? "", nixexprinput, nixexprpath, checkinterval ? 5 * minutes, schedulingshares ? 100, enableemail ? false, emailoverride ? false, keepnr ? 5, inputs }@args: {
    enabled = 1;
    hidden = false;
    emailoverride = "";
    enableemail = false;
    checkinterval = 5 * minutes;
    schedulingshares = 100;
    keepnr = 5;
  } // args;
  minutes = 60;
  hours = 60 * minutes;
  days = 24 * hours;

  makeSpec = contents: builtins.derivation {
    name = "spec.json";
    system = "x86_64-linux";
    preferLocalBuild = true;
    allowSubstitutes = false;
    builder = "/bin/sh";
    args = [ (builtins.toFile "builder.sh" ''
      echo "$contents" > $out
    '') ];
    contents = builtins.toJSON contents;
  };
}