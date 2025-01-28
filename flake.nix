{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        inherit (pkgs) lib;
      in rec
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.cmake ] ++ self.packages.${system}.default.buildInputs;
          nativeBuildInputs = self.packages.${system}.default.nativeBuildInputs;
        };
        packages.default = pkgs.buildGoModule rec {
          pname = "cadvisor";
          version = "0.49.1";

          src = ./.;
          modRoot = "./cmd";

          vendorHash = "sha256-oL/durweXp0pTA5o0G5h+t23Pt6YTkVS44CBsjEI9x8=";

          ldflags = [
            "-s"
            "-w"
            "-X github.com/google/cadvisor/version.Version=${version}"
          ];

          postInstall = ''
            mv $out/bin/{cmd,cadvisor}
            rm $out/bin/example
          '';

          passthru.tests = {
            inherit (pkgs.nixosTests) cadvisor;
          };

          meta = with lib; {
            description = "Analyzes resource usage and performance characteristics of running docker containers";
            mainProgram = "cadvisor";
            homepage = "https://github.com/google/cadvisor";
            license = licenses.asl20;
            maintainers = with maintainers; [ offline ];
            platforms = platforms.linux;
          };
        };
      }
    );
}
