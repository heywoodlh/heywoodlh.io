---
title: "Deploying everywhere with Nix Flakes"
layout: post
published: true
permalink: nix-deployments-everywhere
tags: [ nix, nixos, macos, linux, flakes ]
---

I've been using Nix for a long time (I think it was 2018, back when I was a security engineer at the [Utah Education Network](https://www.uen.org/)). I think I first discovered it -- accidentally -- while looking for alternatives to Homebrew on my Mac. Little did I know, it would become an ecosystem that would change my entire computing experience.

I've written a couple of posts on Nix, but over the course of this year, a coworker of mine encouraged me to invest in Nix flakes _and_ better understand the Nix programming language itself. While I would still consider myself a Nix noob, I'm much more comfortable with Nix expressions than I was at the beginning of 2023.

This post will break down how -- and why -- I'm using Nix.

## Why I use Nix

I won't go over all the reasons Nix is awesome. For a great example of why you should use Nix, I'd check out the Determinate Systems blog: <https://determinate.systems/#blog>

Instead I'll cover the primary points as to why _I_ use Nix: 
- With all of my engineering roles, I have been issued Mac workstations: I like having one tool to manage both MacOS and Linux
- One more MacOS-specific point: Nix makes my Macs feel as extensible as Linux (seemingly, in spite of Apple's best efforts)
- Nix allows me to declare all of my configurations and environments in `git` repositories
- Transitioning to Nix Flakes has allowed me to transition away from using containers for fully reproducible environments
- Nix has become my portable target platform -- enabling me to care far less about what OS/distribution I'm running

That last point is key for me: I love distro-hopping. Nix allows me to distro-hop without having to start from scratch!

### Disclaimer: Nix can be hard

This might just be exclusive to me, but I found Nix to be a bit difficult to get into.

The following actions helped me to _really_ get into Nix:
- Start building things with Nix
- Read other people's examples, looking at the [nixpkgs repo](https://github.com/nixos/nixpkgs) or the [NixOS Discourse](https://discourse.nixos.org/)
- Ask questions of more experienced Nix users
- Contribute to [nixpkgs](https://github.com/nixos/nixpkgs) and other Nix resources you may consume

### Use Flakes

From the [nixos.wiki entry on Flakes](https://nixos.wiki/wiki/Flakes):

> Flakes is a feature of managing Nix packages to simplify usability and improve reproducibility of Nix installations.

Although Flakes are currently still an "experimental" feature of Nix, [the RFC to stabilize Flakes in the CLI has been approved](https://github.com/NixOS/rfcs/pull/136). My understanding of this approval is that we definitively know that eventually Flakes will become a non-experimental feature of Nix. Additionally, the use of Nix flakes has become so widely adopted, I don't see it ever going away as a feature.

I would highly recommend using the Determinate Systems Nix installer, as Flakes are enabled by default (along with some other improvements): https://github.com/DeterminateSystems/nix-installer

## A beginner's example: configuring Tmux as a Nix flake

I have a repository on GitHub for managing all of my most critical applications: [heywoodlh/flakes](https://github.com/heywoodlh/flakes)

Let's examine one of the simpler flakes I have in that repository to configure `tmux`: <https://github.com/heywoodlh/flakes/tree/f130c5c7a87fdaa24c8eaf78c44e4bf436a8e602/tmux>

Aside from the `README.md` file, there are two files in this flake, one named `flake.lock`, one named `flake.nix`.

The `flake.lock` file essentially contains a snapshot of all the dependencies (known as `inputs`) of my Flake. The `flake.lock` file essentially guarantees that if you build my Flake, we will be using the exact same dependencies.

My `flake.nix` file is what actually declares my Flake's configuration. There are two primary components of a Flake:
1. Inputs: external dependencies you will be using in your configuration
2. Outputs: things that your Flake will produce

### Inputs

In my case, I have the following inputs declared:

```
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.fish-flake.url = "github:heywoodlh/flakes?dir=fish";
```

The `flake-utils` input enables me to create cross-platform flakes -- I won't elaborate any more than that. Additionally, I'm consuming another Flake I've made that configures [my `fish` shell](https://github.com/heywoodlh/flakes/tree/f130c5c7a87fdaa24c8eaf78c44e4bf436a8e602/fish) as an input named `fish-flake`. One other unseen `input` that is not defined is the `nixpkgs` input. I believe that if you don't define the `nixpkgs` input, it uses whatever version of `nixpkgs` your current Nix installation is using (I may be wrong on that, and frankly I'm not too interested in finding out where that gets defined). If you care about using a specific version of `nixpkgs`, you should define it as an explicit input like so (this example is pointing to the `nixpkgs-unstable` branch):

```
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
```

When you run `nix flake update`, your `flake.lock` file will get updated with the current version of the `inputs` you have defined. This ensures that your dependencies are reproducible -- that you will get the same produced output every time.

### Outputs

Let's break down each line of this flake:

#### Line 7:

```
  outputs = { self, nixpkgs, flake-utils, fish-flake }:
```

I'm declaring my `outputs` and providing the following arguments to the outputs:
- `self`: allowing me to reference other things within the flake (I'm not actually using this)
- `nixpkgs`: an unseen `input` of the version of [nixpkgs](https://github.com/nixos/nixpkgs) that I'm using
- `flake-utils`: the `flake-utils` input that I defined
- `fish-flake`: the `fish-flake` input that I defined

Providing these arguments allows me to reference these things in my `outputs`.

#### Line 8:

```
    flake-utils.lib.eachDefaultSystem (system:
```

I'm using the `lib.eachDefaultSystem` function from the `flake-utils` `input` to provide cross-platform outputs and `system` variable that I can reference in my outputs.

#### Lines 9-11:

```
    let
      pkgs = nixpkgs.legacyPackages.${system};
      myFish = fish-flake.packages.${system}.fish;
```

In this case I'm declaring variables that I can use in my outputs. One is `pkgs` from my `nixpkgs` input and the other is `myFish` -- allowing me to reference the package named `fish` in my `fish-flake` input. Notice that I am using the `${system}` variable provided by `flake-utils` -- this allows me to use `${system}` to represent whatever my current system is. The `${system}` variable will have one of the following values (determined by the current system):

```
x86_64-linux
aarch64-linux
x86_64-darwin
aarch64-darwin
```

#### Lines 12-77: 

```
      tmuxConf = pkgs.writeText "tmux.conf" ''
        # Set shell
        set -g default-shell ${myFish}/bin/fish
        ...
      '';
```

I'm using the `pkgs.writeText` function to create a file named `tmux.conf` with my defined configuration in the values between the `''` characters. Saving it to the `tmuxConf` variable allows my to reference my configuration file later as `${tmuxConf}`. You can also see that I'm referencing the `bin/fish` binary within the `myFish` variable that is pointing to my `fish-flake` input.

I won't place the entire contents of my `tmuxConf` variable in here because it's huge and `tmux` configuration parameters are pretty well documented. Look at the rest of the config here if desired: <https://github.com/heywoodlh/flakes/blob/f130c5c7a87fdaa24c8eaf78c44e4bf436a8e602/tmux/flake.nix#L12-L77>

#### Lines 78-87:

```
    in {
      packages = rec {
        tmux = pkgs.writeShellScriptBin "tmux" ''
            ${pkgs.tmux}/bin/tmux -f ${tmuxConf} $@
          '';
        default = tmux;
        };
      }
    );
  }
```

Here I'm creating a package named `tmux` that is a shell script wrapper around `pkgs.tmux` that uses my configuration file defined in the `${tmuxConf}` variable. Additionally, I'm setting the `tmux` package to be the default package you install in this flake.

To summarize, when you install/run this `tmux` package in this flake, it runs a shell script that wraps up the `tmux` binary provided by `nixpkgs` and points at my configuration.

## A "Meta" Flake -- or a "Flake of Flakes"

I wanted to figure out a way to create a primary flake in my repo that just pointed to other flakes. I term this a "meta" flake or "flake of flakes".

### The problem

When I first created my [my Flakes repository](https://github.com/heywoodlh/flakes), I initially created totally separate flakes that you'd have to consume independent of each other. For example, in [my nixos-configs repository](https://github.com/heywoodlh/nixos-configs) -- a totally separate flake where I consume most of these flakes -- if I wanted to refer to multiple flakes, I would have to do something like this in my inputs:

```
inputs.vim-flake.url = "github:heywoodlh/flakes?dir=vim";
inputs.tmux-flake.url = "github:heywoodlh/flakes?dir=tmux";
inputs.fish-flake.url = "github:heywoodlh/flakes?dir=fish";
inputs.wezterm-flake.url = "github:heywoodlh/flakes?dir=wezterm";
```

This approach is totally inefficient because each flake could have a totally different version of `inputs` in their `flake.lock`. For example, my `tmux` flake might have a completely different version of `nixpkgs` than my `fish` flake. This results in a lot of disk storage space being taken up by each flake.

So I wondered, could I make a "meta" flake that I could point to that pointed to my other flakes giving me the following benefits:
1. One input for all of my flakes, i.e. `inputs.myFlakes.url = "github:heywoodlh/flakes";`
2. A way to re-use inputs across each of those flakes to reduce redundancies in each input
3. A way to keep those flakes totally independent if desired -- not disrupting the ability to do this: `inputs.wezterm-flake.url = "github:heywoodlh/flakes?dir=wezterm";` if desired

### The solution

I was able to build a meta flake, and at the time of writing this is what it looks like: <https://github.com/heywoodlh/flakes/blob/f130c5c7a87fdaa24c8eaf78c44e4bf436a8e602/flake.nix>

```
{
  description = "meta-flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fish-flake = {
      url = "./fish";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vim-flake = {
      url = "./vim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fish-flake.follows = "fish-flake";
    };
    git-flake = {
      url = "./git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.vim-flake.follows = "vim-flake";
    };
    vscode-flake = {
      url = "./vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nushell-flake = {
      url = "./nushell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-flake = {
      url = "./tmux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fish-flake.follows = "fish-flake";
    };
    st-flake = {
      url = "./st";
      inputs.tmux-flake.follows = "tmux-flake";
    };
    wezterm-flake = {
      url = "./wezterm";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.tmux-flake.follows = "tmux-flake";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    fish-flake,
    git-flake,
    nushell-flake,
    vim-flake,
    tmux-flake,
    vscode-flake,
    st-flake,
    wezterm-flake,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        fish = fish-flake.packages.${system}.fish;
        nushell = nushell-flake.packages.${system}.nushell;
        git = git-flake.packages.${system}.git;
        tmux = tmux-flake.packages.${system}.tmux;
        vim = vim-flake.defaultPackage.${system};
        vscode = vscode-flake.packages.${system}.default;
        st = st-flake.packages.${system}.st;
        wezterm = wezterm-flake.packages.${system}.wezterm;
        wezterm-gl = wezterm-flake.packages.${system}.wezterm-gl;
      };
      formatter = pkgs.alejandra;
    });
}
```

I won't break down each piece like I did in the `tmux` example, but this configuration allows me to re-use redundant inputs within other inputs and create one flake that outputs all the other flakes. Nix is flexible enough that I was able to remedy all of the problems I was hoping to solve.

Here's how it looks currently when I run `nix flake show github:heywoodlh/flakes` (trimmed to show the produced outputs of my meta flake):

```
└───packages
    ├───aarch64-darwin
    │   ├───fish: package 'fish'
    │   ├───git: package 'git'
    │   ├───nushell: package 'nu'
    │   ├───st: package 'st'
    │   ├───tmux: package 'tmux'
    │   ├───vim: package 'neovim-0.9.4'
    │   ├───vscode: package 'code'
    │   ├───wezterm: package 'wezterm'
    │   └───wezterm-gl: package 'wezterm'
    ├───aarch64-linux
    │   ├───fish omitted (use '--all-systems' to show)
    │   ├───git omitted (use '--all-systems' to show)
    │   ├───nushell omitted (use '--all-systems' to show)
    │   ├───st omitted (use '--all-systems' to show)
    │   ├───tmux omitted (use '--all-systems' to show)
    │   ├───vim omitted (use '--all-systems' to show)
    │   ├───vscode omitted (use '--all-systems' to show)
    │   ├───wezterm omitted (use '--all-systems' to show)
    │   └───wezterm-gl omitted (use '--all-systems' to show)
    ├───x86_64-darwin
    │   ├───fish omitted (use '--all-systems' to show)
    │   ├───git omitted (use '--all-systems' to show)
    │   ├───nushell omitted (use '--all-systems' to show)
    │   ├───st omitted (use '--all-systems' to show)
    │   ├───tmux omitted (use '--all-systems' to show)
    │   ├───vim omitted (use '--all-systems' to show)
    │   ├───vscode omitted (use '--all-systems' to show)
    │   ├───wezterm omitted (use '--all-systems' to show)
    │   └───wezterm-gl omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───fish omitted (use '--all-systems' to show)
        ├───git omitted (use '--all-systems' to show)
        ├───nushell omitted (use '--all-systems' to show)
        ├───st omitted (use '--all-systems' to show)
        ├───tmux omitted (use '--all-systems' to show)
        ├───vim omitted (use '--all-systems' to show)
        ├───vscode omitted (use '--all-systems' to show)
        ├───wezterm omitted (use '--all-systems' to show)
        └───wezterm-gl omitted (use '--all-systems' to show)
```

Note: I ran this from my M2 Macbook Air, which is why only the `aarch64-darwin` packages are fully populated with metadata. On other systems/architectures, the configuration belonging to the current system would be populated.

## Another example: nix-managed Kubernetes deployments

I recently saw YouTube video that, for me, was mind-blowing: [NixCon2023 Nix and Kubernetes: Deployments Done Right](https://www.youtube.com/watch?v=SEA1Qm8K4gY)

My day job is working with Kubernetes and I'm very invested in Nix -- so extending my ability to manage Kubernetes deployments with Nix was a revelation for me. As of writing, my `kube` flake lives here: <https://github.com/heywoodlh/flakes/tree/fc4f7f62c79b3512c0b28a4b6590ce928921bae9/kube>

Despite living in my flakes repo, I omitted the `kube` flake from my meta flake because it is so different from my other flakes in this repo: I want it to be self-contained and isolated from the rest of my flakes.

### How this flake works

Thankfully, [farcaller](https://github.com/farcaller) -- the speaker in the NixCon2023 video above -- has made a bunch of nice tooling for nix-managed Kubernetes:
- [nix-kube-generators](https://github.com/farcaller/nix-kube-generators): a set of functions helping to generate k8s yaml
- [nixhelm](https://github.com/farcaller/nixhelm): a collection of helm charts in a nix-digestable format

At the time of writing, I am mostly relying on the functions provided in `nix-kube-generators` to define Kubernetes from external Helm charts. An example `flake.nix` could look like this:

```
{
  description = "An example ";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-kube-generators.url = "github:farcaller/nix-kube-generators";
  inputs.nixhelm.url = "github:farcaller/nixhelm";
  inputs.tailscale.url = "github:tailscale/tailscale";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    nix-kube-generators,
    nixhelm,
    tailscale,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      kubelib = nix-kube-generators.lib { inherit pkgs; };
    in {
      packages = {
        # Use the 1password-connect Helm chart in nixhelm: https://github.com/farcaller/nixhelm/blob/bc093e92be7f9c91f46ce8b733978ff24f33c7ad/charts/1password/connect/default.nix
        "1password-connect" = (kubelib.buildHelmChart {
          name = "1password-connect";
          chart = (nixhelm.charts { inherit pkgs; })."1password".connect;
          namespace = "default";
          values = {
            connect.credentials = builtins.readFile /tmp/1password-credentials.json;
          };
        });
        # Use the Helm chart specified here: https://github.com/tailscale/tailscale/tree/86c8ab7502a38b4de05308355fe0c847e4e78167/cmd/k8s-operator/deploy/chart
        tailscale-operator = (kubelib.buildHelmChart {
          name = "tailscale-operator";
          chart = "${tailscale}/cmd/k8s-operator/deploy/chart";
          namespace = "default";
        });
      };
      devShell = pkgs.mkShell {
        name = "kubernetes-shell";
        buildInputs = with pkgs; [
          kubectl
          kubernetes-helm
        ];
      };
      formatter = pkgs.alejandra;
    });
}
```

### Deployment

Currently, this is my workflow for deploying my nix-managed Kubernetes flakes (the `tailscale-operator` output as an example):

```
nix build -o ./result "github:heywoodlh/flakes?dir=kube#tailscale-operator"
```

This generates all of the YAML for this deployment in a file named `./result` that can then be applied:

```
kubectl apply -f ./result
```

## On-demand dev environments with Nix and Direnv

I have started using [direnv](https://direnv.net/) with my Nix setups to create on-demand development environments specific to projects I'm working on. Determinate Systems has a nice blog post on this: [Effortless dev environments with Nix and direnv](https://determinate.systems/posts/nix-direnv)

Utilizing this approach has allowed me to remove packages from my systems that are specific to projects I'm working on. For example, I don't always need `kubectl`, `k9s`, `helm` or other Kubernetes-specific tooling. However, when I'm working on my kube flake, I _do_ want those packages available.

### Example: direnv+nix in my kube flake

[I have a `devShell` output in my kube flake](https://github.com/heywoodlh/flakes/blob/fc4f7f62c79b3512c0b28a4b6590ce928921bae9/kube/flake.nix#L149C1-L156C9) with the following configuration:

```
      devShell = pkgs.mkShell {
        name = "kubernetes-shell";
        buildInputs = with pkgs; [
          k9s
          kubectl
          kubernetes-helm
        ];
      };
```

I have my shell configured (in [my fish flake](https://github.com/heywoodlh/flakes/blob/fc4f7f62c79b3512c0b28a4b6590ce928921bae9/fish/flake.nix#L64-L65)) to use `direnv` automatically, like so:

```
        # Direnv
        eval (${pkgs.direnv}/bin/direnv hook fish)
```

So, in the directory of my `kube` flake I can create a file named `.envrc` with the following contents:

```
use flake
```

Once I run `direnv allow`, my shell will automatically add the `buildInputs` that I specified in my `devShell`. This example shell snippet shows how this looks when I `cd` into my `kube` flake (notice that I don't have `kubectl` in my `$PATH` -- but I do after I `cd` in the `kube` directory):

```
flakes on  main
❯ which kubectl

flakes on  main [?]
❯

flakes on  main [?]
❯ cd kube
direnv: loading ~/opt/flakes/kube/.envrc
direnv: using flake

flakes/kube on  main via ❄️ impure (kubernetes-shell-env)
❯ which kubectl
/nix/store/0sw7cwa3aizy1dak55cfahzrr148bbi3-kubectl-1.28.3/bin/kubectl
```

## Managing NixOS and MacOS with Nix+flakes

I won't dive into this point too deeply, but I have my entire NixOS and MacOS (via [Nix-Darwin](http://daiderd.com/nix-darwin/)) configuration codified and managed with Nix. This allows me to configure literally every aspect of my systems using Nix.

At the time of writing, this is my flake repository for NixOS and MacOS: <https://github.com/heywoodlh/nixos-configs/tree/9a68e2eb1f50a9a0280ac33a9c5093b0febb264a>

It's very unorganized (it makes sense to me), but the desired effect is amazing. Essentially, on NixOS I can run the following to setup my entire system:

```
sudo nixos-rebuild switch --flake github:heywoodlh/nixos-configs#nixos-desktop-intel
```

On MacOS I can run the following (after Nix-Darwin is installed):

```
darwin-rebuild switch --flake github:heywoodlh/nixos-configs#nix-macbook-air
```

In both cases, I've configured nearly everything I care about on a new system. After I run this, it usually takes about 15 minutes for me to setup a brand new system (not including logging into and configuring each app that doesn't support being configured externally).

### A note on Home Manager for dotfiles management on non-NixOS/MacOS operating systems

Home-Manager is a Nix tool that I use in my nixos-config flake that further extends the capabilities of Nix to managing apps that are configured in your home directory: <https://nix-community.github.io/home-manager/>

Unlike Nix-Darwin and NixOS modules, Home-Manager can run on any operating system that can run Nix. If you're not interested in using Nix-Darwin on MacOS or NixOS, I would highly recommend looking into Nix+Home-Manager for dotfiles management.

I would say the majority of my meaningful configuration in my nixos-configs repo occurs in Home-Manager. I'm able to run the following to deploy my Home-Manager configuration on any Linux distribution with Nix installed:

```
nix run github:heywoodlh/nixos-configs#homeConfigurations.heywoodlh.activationPackage --impure
```

## Conclusion

Utilizing Nix has been not only really fun but also really useful for me in all areas that I use my computers. Since fully committing to Nix as my target development environment, I find that I care a lot less about my underlying operating system and can instead focus on any environment that can run Nix.

I hope you, dear reader, become as obsessed with Nix as I am.
