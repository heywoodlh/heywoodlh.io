---
title: "S.T.A.L.K.E.R. 2 Settings on Linux (Steam)"
published: true
permalink: /stalker-2-linux-settings/
tags: [ linux, steam, stalker2, gaming ]
---

> 2026 EDIT: most of this guide is not necessary, but I've outlined the changes I've still needed in 2026 [here](#2026-changes)

I've recently switched my gaming machine from Windows 11 to Linux. S.T.A.L.K.E.R. 2 is one of my new favorite games and seemed to run noticeably better on the same hardware running Windows 11. So, this is my attempt to document what I've done to fix performance under Linux.

One note: I'm lame and try to target 60FPS on 1080p so I can conveniently stream over my network via Sunshine and Moonlight.

# My Gaming Machine Specs

Operating System: NixOS Unstable, 6.11.2-zen kernel
CPU: AMD Ryzen 5 5600G with Radeon Graphics
GPU: Nvidia 3080 Ti
Nvidia Driver version: `565.57.01` with [nvidia-patch](https://github.com/keylase/nvidia-patch)
RAM: 32 GB
Drive: 1TB NVMe
Proton Version: [Proton-GloriousEggroll 9-22](https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/GE-Proton9-22)
Game Version: 1.1.3 (Steam)

One final thing is that booting with the kernel parameter of `mitigations=off` to disable CPU mitigations seemed to make a big impact in my configuration. I won't go into whether or not you should, this article was informative on about that topic: [How to Disable CPU Mitigations on Linux](https://fosspost.org/disable-cpu-mitigations-on-linux)

For more details on my NixOS setup, here's the relevant config files:
- [Host-specific configuration](https://github.com/heywoodlh/nixos-configs/blob/f31689a83632677b08108e65ee8c79c5e4b7c6f2/nixos/hosts/zalman/configuration.nix)
- [Nvidia-Patch implementation](https://github.com/heywoodlh/nixos-configs/blob/f31689a83632677b08108e65ee8c79c5e4b7c6f2/nixos/roles/gaming/nvidia-patch.nix)
- [Sunshine, steam and KDE configuration](https://github.com/heywoodlh/nixos-configs/blob/f31689a83632677b08108e65ee8c79c5e4b7c6f2/nixos/roles/gaming/sunshine.nix)
- [Proton-GE installer package](https://github.com/heywoodlh/nixos-configs/blob/f31689a83632677b08108e65ee8c79c5e4b7c6f2/nixos/roles/gaming/proton-ge.nix)

# Steam Launch Options:

```
DXVK_FRAME_RATE=60 PROTON_ENABLE_NVAPI=true %command% -xgeshadercompile -nothreadtimeout -NoVerifyGC
```

> Note: change `DXVK_FRAME_RATE=60` to your desired frame rate.

These options may be specific to GloriousEggroll Proton, so mileage may vary if you try a different Proton version.

# Mods:

The only proper mod I'm using specific to performance is the base version of [Optimized Tweaks S.2 - Improved Performance Reduced Stutter Lower Latency Better Frametimes](https://www.nexusmods.com/stalker2heartofchornobyl/mods/7?tab=files)

# Configuration files

On Linux with Proton, these files can be found in this folder in your steam library: `steamapps/compatdata/1643320/pfx/drive_c/users/steamuser/AppData/Local/Stalker2/Saved/Config/Windows`

- `Engine.ini`:

```
; https://steamcommunity.com/app/1643320/discussions/0/4626980689722585014/
[SystemSettings]
r.DynamicGlobalIlluminationMethod=2
r.ContactShadows=0
r.Lumen.Reflections.Allow=0
r.MaterialQualityLevel=0
r.Nanite.MaxPixelsPerEdge=4
r.Shadow.CSM.MaxCascades=0
r.ShadowQuality=0
r.VolumetricCloud=0
r.Volumetricfog=0
r.OneFrameThreadLag=0

[/script/engine.renderersettings]
r.GraphicsAdapter=0
r.TextureStreaming=0
r.DepthOfFieldQuality=0
r.BloomQuality=0
r.FilmGrain=0
r.DisableDistortion=1
r.LensFlareQuality=0
r.Fog=0

[/script/engine.gameengine]
DisplayGamma=2.056000
GlobalNetTravelCount=6
bEnableMouseSmoothing=False
bViewAccelerationEnabled=False
bDisableMouseAcceleration=False
```

> The `r.OneFrameThreadLag=0` parameter seems to make a big difference with input lag when using frame generation.

# In-Game Settings:

Preset: Medium

These are the settings I changed outside of the preset:
- Textures: High
- Hair: low
- Motion blur strength: 0
- Depth of field: low
- Light shafts: disabled
- Upscaling method: DLSS
- Upscaling quality: Performance

It also seemed to help my FPS just a bit to switch to Fullscreen Bordless instead of Exclusive Fullscreen.

# 2026 changes

I'm not using the majority of the above as S.T.A.L.K.E.R. 2 seems to run relatively well on Linux now.

I'll outline the main performance-related changes on Linux I've made.

## Hardware

Operating System: NixOS Unstable, 7.0.0-cachyos kernel
CPU: AMD Ryzen 7 5700X3D
GPU: Nvidia 5070 Ti
Nvidia Driver version: `595.80` with [nvidia-patch](https://github.com/keylase/nvidia-patch)

## NixOS gaming configuration

For my gaming configuration at the time of writing, see:
- [gaming.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/gaming.nix)
- [nvidia-patch.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/nvidia-patch.nix)
- [sunshine.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/sunshine.nix)

I'm using KDE as my desktop environment for dedicated gaming machines, with a relatively minimal config here: [kde.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/kde.nix)

For general purpose Linux machines I use Hyprland (i.e. on my Razer Blade 14 away from home):
- [[nixos] hyprland.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/hyprland.nix)
- [[home-manager] hyprland.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/home/modules/hyprland.nix)
- [Razer Blade 14 configuration](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/flake.nix#L1011-1043)

## Steam Launch options

```
WINEDLLOVERRIDES="gameinput=n,b" MESA_SHADER_CACHE_MAX_SIZE=10G PROTON_NO_STEAMINPUT=1 PROTON_VKD3D_HEAP=1 PROTON_ENABLE_WAYLAND=1 PROTON_ENABLE_HDR=1 PROTON_DLSS_UPGRADE=1 PROTON_LOCAL_SHADER_CACHE=1 %command%
```

Some of these settings may be specific to [proton-cachyos](https://github.com/CachyOS/proton-cachyos).

## Engine.ini for fixing smeared/blurry foliage on 5070 Ti

This is based on [Lumen Foliage Fixes Vanilla plus](https://www.nexusmods.com/stalker2heartofchornobyl/mods/2265?tab=posts)

```ini
[SystemSettings]

r.ViewDistanceScale=2.5
foliage.LODDistanceScale=3.0
foliage.DitheredLOD=2
r.StaticMeshLODDistanceScale=0.4
r.Foliage.DensityScale=1.8
grass.DensityScale=1.6

fg.CullDistanceScale.Bushes=2.0
fg.CullDistanceScale.Grass=1.8
fg.CullDistanceScale.DistantGrass=1.6
fg.CullDistanceScale.Trees=1.7

r.Lumen.Reflections.ScreenTraces=1
r.Lumen.Reflections.DownsampleFactor=1
r.Lumen.DiffuseIndirect.AsyncCompute=1
r.Lumen.Reflections.AsyncCompute=1
r.Lumen.ScreenProbeGather.DownsampleFactor=16

r.Tonemapper.GrainQuantization=0
r.FilmGrain=0
r.Tonemapper.Quality=2
r.TSR.History.R11G11B10=1
r.TSR.ShadingRejection.Flickering=1
r.TSR.RejectionAntiAliasingQuality=2

r.Shadow.DistanceScale=1.6
r.Shadow.CSMDepthBias=0.5
r.ShadowQuality=3

r.SceneColorFringeQuality=0
r.MotionBlurQuality=1
r.BloomQuality=3
r.DepthOfFieldQuality=2
r.ReflectionCaptureResolution=1024
r.SSR.Quality=3
r.AmbientOcclusion.Method=1

r.Streaming.PoolSize=10240
r.Streaming.Boost=3.0

r.CreateShadersOnLoad=1
r.FastVRam.GBufferVelocity=1
```

This has been the only fix I've found for preventing foliage from being a horribly blurry mess on my 5070 Ti.

## Gamepad/Controller Support

I'm not sure if it was Moonlight + Sunshine streaming or something else, but I had to install [gameinput2xinput.dll](https://github.com/andrew-ld/gameinput2xinput/releases/download/1.0.4/gameinput2xinput.dll) for my Xbox Elite 2 controller to work properly (i.e. if I was in the inventory menu I couldn't move items to quick access, button presses were inconsistent, and aiming was extremely choppy based on what was under my crosshair/sights).

Follow these instructions to install: <https://github.com/ValveSoftware/Proton/issues/8260#issuecomment-2509483841>

## "DX12 RHI use is required by the project, but it is not supported, or failed to choose a valid graphics adapter" error

> TL;DR run `winecfg` in Protontricks, set default Windows version to Windows 10

I have been successfully playing S.T.A.L.K.E.R. 2 on Linux for a long while, but started running into this issue on June 22, 2026:

> DX12 RHI use is required by the project, but it is not supported, or failed to choose a valid graphics adapter

Tried the suggestion at [#8260 (comment)](https://github.com/ValveSoftware/Proton/issues/8260#issuecomment-2558236243) and setting `VKD3D_VULKAN_DEVICE=0` which did not work. I even uninstalled the game and reinstalled without success.

Per this [reddit comment](https://www.reddit.com/r/LinuxCrackSupport/comments/1hke7il/comment/m3gtkxk) I was able to resolve it by opening winecfg in Protontricks for the game and setting the Windows version to Windows 10 -- for whatever reason it was set to Windows 7. I do not recall manually changing this value -- I'm unsure what might have caused the change.

Corresponding GitHub issue comment by me: <https://github.com/ValveSoftware/Proton/issues/8260#issuecomment-4813018490>

## CachyOS settings

This isn't specific to S.T.A.L.K.E.R. 2, but I'm replicating CachyOS configuration on my gaming machine.

The following links will be helpful:
- [CachyOS-Settings repository](https://github.com/CachyOS/CachyOS-Settings)
- [CachyOS Kernel](https://wiki.cachyos.org/features/kernel/) on NixOS via [github:xddxdd/nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel)
- [Proton CachyOS](https://github.com/CachyOS/proton-cachyos) fetched via my custom script [proton-custom.sh](https://tangled.org/heywoodlh.io/nixos-configs/blob/82b05e519f236e9b9fc75fafd94c920a6fef5276/nixos/modules/gaming.nix#L17-82)
- My `git` diff for my NixOS configuration replicating their settings: <https://github.com/heywoodlh/nixos-configs/compare/68cdc39..f43d984>
