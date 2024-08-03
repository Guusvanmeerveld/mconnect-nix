{
  pkgs,
  lib,
  userSettings,
  ...
}: let
  settingsFormat =
    pkgs.formats.ini {};

  # Adapt our settings format to the one needed for mconnect
  settings =
    {
      main = {
        debug =
          if userSettings.debug
          then 1
          else 0;

        devices =
          lib.concatStringsSep ";" (map (device: device.id) userSettings.devices);
      };

      commands = builtins.listToAttrs (map (command: {
          name = command.name;
          value = command.run;
        })
        userSettings.commands);
    }
    // builtins.listToAttrs (map (device: {
        name = device.id;
        value = {
          inherit (device) name type;

          allowed =
            if device.allowed
            then 1
            else 0;
        };
      })
      userSettings.devices);

  settingsFile = settingsFormat.generate "mconnect-settings" settings;
in {
  description = "KDE Connect protocol implementation in Vala/C";
  documentation = "https://github.com/grimpy/mconnect";

  # The mconnect package is not in nixpkgs.
  package = pkgs.callPackage ../package.nix {};

  # All possible settings for mconnect.
  # This is a different format from the one specified by mconnect, so we adapt it later.
  options = {
    debug = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable debug logging";
    };

    devices = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "The device's name";
          };

          id = lib.mkOption {
            type = lib.types.str;
            description = "The device's identifier";
          };

          type = lib.mkOption {
            type = lib.types.enum ["phone" "tablet" "computer"];
            default = "phone";
          };

          allowed = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to pair automatically with device";
          };
        };
      });

      default = [];
      description = "List of devices";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = '''';
      description = "Extra config, in case a desired option is missing";
    };

    commands = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "The commands name";
          };

          run = lib.mkOption {
            type = lib.types.str;
            description = "The command to run on the host";
          };
        };
      });

      default = [];
      description = "Adds commands that can be ran from the connected device";
    };
  };

  settings = ''
    ${settingsFile.text}
    ${userSettings.extraConfig}
  '';
}
