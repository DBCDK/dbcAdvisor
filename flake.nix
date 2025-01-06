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

          #vendorHash = lib.fakeHash;
          vendorHash = "sha256-gjopg8pSmXANvz11bA4wIfmbMl1A0LOlBbV6DyJeSf8=";
          #vendorHash = "sha256-nX0hFaRv6J6eAaX9dCOsFy7VcRcR8QFw7/HLgw/0xDw=";
          #vendorHash = "sha256-sCrPcsrE6r5WrM1YTd+xL2kvMJuGOMkck4pYcmUnf+I=";

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
