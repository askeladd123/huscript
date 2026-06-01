{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {
        lib,
        pkgs,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [nushell check-jsonschema];
        };
      };
    };
}
