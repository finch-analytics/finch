{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      projectName = "finch";
    in
    {
      # use toolchain file
      nci.toolchainConfig = ./rust-toolchain.toml;

      # declare projects
      nci.projects.${projectName} = {
        path = ./.;
        export = true;
      };

      # configure crates
      nci.crates."finch-root" = {
        drvConfig = {
          mkDerivation = {
            buildInputs = [ pkgs.protobuf_27 ];
          };
        };
      };

      nci.crates."spark-submit" = { };
    };
}
