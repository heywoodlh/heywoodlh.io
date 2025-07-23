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
      opener = if pkgs.stdenv.isDarwin then "open" else "${pkgs.xdg-utils}/bin/xdg-open";
      myRuby = pkgs.ruby.withPackages (p: with p; [
        jekyll
        jekyll-feed
        jekyll-gist
        jekyll-seo-tag
        jekyll-sitemap
        kramdown-parser-gfm
        webrick
      ]);
      run = pkgs.writeShellScriptBin "run" ''
        ${myRuby}/bin/jekyll serve -q --livereload --open-url --quiet
      '';
    in {
      devShell = pkgs.mkShell {
        name = "heywoodlh.io shell";
        buildInputs = with pkgs; [
          bundler
          marksman
          myRuby
          run
        ];
      };

      formatter = pkgs.alejandra;
    });
}
