---
title: "S.T.A.L.K.E.R. 2 Settings on Linux (Steam)"
published: true
permalink: /stalker-2-linux-settings/
tags: [ linux, steam, stalker2, gaming ]
---

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
