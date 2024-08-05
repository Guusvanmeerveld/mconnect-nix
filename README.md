# MConnect for NixOS

[MConnect](https://github.com/grimpy/mconnect) is a cli program which aims to implement the KDE connect protocol so non-KDE users are also able to connect to their phones from the desktop. This repo contains a Nix flake that makes it easier to use this program on NixOS. It packages the program and has modules for both Home-Manager and NixOS.

## Installation

### With flakes

Add the following into the desired `flake.nix` file.

```nix
{
    inputs.mconnect-nix.url = "github:guusvanmeerveld/mconnect-nix";
}
```

## Usage

### Module import

When using home-manager (recommended), one can simply import the home-manager module:

```nix
{ inputs, ...}: {
    imports = [inputs.mconnect-nix.homeManagerModules.default];
}
```

When using NixOS, it is almost the same:

```nix
{ inputs, ...}: {
    imports = [inputs.mconnect-nix.nixosModules.default];
}
```

## Example config

Home-Manager:

```nix
 { pkgs, inputs, ... }: {
    imports = [inputs.mconnect-nix.homeManagerModules.default];

    programs.mconnect = {
        enable = true;

        devices = [
            {
                id = "pixel";
                name = "Pixel 6a";
            }
            {
                id = "samsung";
                name = "Samsung Tablet";
                # Device will not automatically connect
                allowed = false;
                # Can be any of 'phone', 'tablet' or 'computer'. 'phone' is default.
                type = "tablet";
            }
        ];

        commands = [
          {
            name = "Open Firefox";
            run = "${pkgs.firefox}/bin/firefox";
          }
        ];
    };
}
```

Nixos:

```nix
{
    imports = [inputs.mconnect-nix.nixosModules.default];

    programs.mconnect = {
        # Even when using home-manager, if the firewall is enabled, this is needed. The server runs on UDP port 1716, which is not open by default.
        openFirewall = true;
    }
}
```
