{ dockerTools, cli }:
dockerTools.buildLayeredImage {
  name = "pyret-autograder-cli";
  tag = "latest";

  contents = [ cli ];
  config = {
    Entrypoint = [ "/bin/cli" ];
    Cmd = [ "--help" ];
  };
}
