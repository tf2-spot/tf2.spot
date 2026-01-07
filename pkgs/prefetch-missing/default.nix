{ writeShellApplication, jq, depotdownloader }:

writeShellApplication {
  name = "prefetch-missing";

  runtimeInputs = [ jq depotdownloader ];
  runtimeEnv = {
    MAKE_COMMANDS = ./make-commands.jq;
  };

  text = ''
    [ -f chunks.json ]
    jq -rf $MAKE_COMMANDS chunks.json | sh
  '';
}
