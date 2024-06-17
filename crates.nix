{ ... }: {
  perSystem = { ... }:
    let crateName = "finch";
    in {
      # declare projects
      nci.projects."simple".path = ./.;
      # configure crates
      nci.crates.${crateName} = { };
    };
}
