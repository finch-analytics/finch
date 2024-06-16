{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nci.url = "github:yusdacra/nix-cargo-integration";
    nci.inputs.nixpkgs.follows = "nixpkgs";

    parts.url = "github:hercules-ci/flake-parts";
    parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    # crane = {
    #   url = "github:ipetkov/crane";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ parts, nci, ... }:
    parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
        nci.flakeModule
        ./crates.nix
      ];

      perSystem = { pkgs, config, ... }:
        let
          # shorthand for accessing this crate's outputs
          # you can access crate outputs under `config.nci.outputs.<crate name>` (see documentation)
          crateOutputs = config.nci.outputs."finch";

          # craneLib = inputs.crane.mkLib pkgs;
          # src = craneLib.cleanCargoSource ./.;
        in {
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.rustfmt.enable = true;
          };

          formatter = config.treefmt.build.wrapper;

          pre-commit.settings = let
            simplehook = cmd: {
              enable = true;
              name = cmd;
              description = "Run ${cmd}";
              entry = cmd;
              pass_filenames = false;
            };
          in {
            hooks.nixfmt.enable = true;
            hooks.rustfmt.enable = true;
            hooks.deadnix.enable = true;
            hooks.cargocheck = simplehook "cargo check";
            hooks.cargoclippy = simplehook "cargo clippy";
            hooks.cargotest = simplehook "cargo test";
          };

          # checks = { finch-fmt = craneLib.cargoFmt { inherit src; }; };

          # export the crate devshell as the default devshell
          devShells.default = crateOutputs.devShell.overrideAttrs (old: {
            packages = (old.packages or [ ]) ++ [ pkgs.protobuf_27 ];
            shellHook = ''
              ${old.shellHook or ""}
              ${config.pre-commit.installationScript}
            '';
          });
          # export the release package of the crate as default package
          packages.default = crateOutputs.packages.release;
        };
    };
}
