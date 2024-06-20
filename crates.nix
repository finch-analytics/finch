{ ... }: {
  perSystem = { ... }:
    let crateName = "finch";
    in {
      # use toolchain file
      nci.toolchainConfig = ./rust-toolchain.toml;
      # declare projects
      nci.projects."simple".path = ./.;
      # configure crates
      nci.crates.${crateName} = { };
    };
}
