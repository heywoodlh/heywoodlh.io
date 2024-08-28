{
  description = "devshell for heywoodlh.io";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      opener = if pkgs.stdenv.isDarwin then "open" else "xdg-open";
      run = pkgs.writeShellScriptBin "run" ''
        ${pkgs.jekyll}/bin/jekyll build
        ${pkgs.jekyll}/bin/jekyll serve -B -q &>/dev/null
        process="$!"
        ${opener} http://localhost:4000
        echo 'Press ctrl+c to stop the server'
        read -r -d "" _ </dev/tty
        kill -3 "$process"
      '';
    in {
      devShell = pkgs.mkShell {
        name = "heywoodlh.io shell";
        buildInputs = with pkgs; [
          bundler
          jekyll
          marksman
          run
        ];
      };

      formatter = pkgs.alejandra;
    });
}
