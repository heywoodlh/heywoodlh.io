{
  description = "devshell for heywoodlh.io";

  inputs.nixos-configs.url = "git+https://tangled.org/heywoodlh.io/nixos-configs";

  outputs = {
    self,
    nixos-configs,
  }:
    nixos-configs.inputs.flake-utils.lib.eachDefaultSystem (system: let
      nixpkgs = nixos-configs.inputs.nixpkgs;
      pkgs = nixpkgs.legacyPackages.${system};
      tangled-sync = nixos-configs.packages.${system}.tangled-sync;
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
        shellHook = ''
          ${tangled-sync}/bin/tangled-sync.sh
        '';
      };

      formatter = pkgs.alejandra;
    });
}
