{
  description = "Thin Python wrapper of quickjs-ng";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        quickjs-src = pkgs.fetchFromGitHub {
          owner = "quickjs-ng";
          repo = "quickjs";
          rev = "v0.13.0";
          hash = "sha256-t1GvD1iBRfJwzZHoLxMbE2Gh1Ow8v0ZASxCVnOT7ST4=";
        };

        quickjs-ng-python = pkgs.python311Packages.buildPythonPackage rec {
          pname = "quickjs-ng";
          version = "0.12.1.1";
          pyproject = true;

          src = ./.;

          postPatch = ''
            rm -rf upstream-quickjs
            cp -r ${quickjs-src} upstream-quickjs
          '';

          build-system = [
            pkgs.python311Packages.setuptools
          ];

          pythonImportsCheck = [ "quickjs" ];

          meta = {
            description = "Thin Python wrapper of quickjs-ng";
            homepage = "https://github.com/genotrance/quickjs-ng";
            license = pkgs.lib.licenses.mit;
          };
        };
      in
      {
        packages = rec {
          default = quickjs-ng-python;
          quickjs-ng = quickjs-ng-python;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            python311
            python311Packages.setuptools
          ];
        };
      }
    );
}
