{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.mconnect;

  # Get the options, settings and package
  shared = import ./shared.nix {
    inherit lib pkgs;
    userSettings = cfg.settings;
  };
in {
  options = {
    programs.mconnect = {
      enable = lib.mkEnableOption "Enable MConnect, a KDE connect server";

      package = lib.mkOption {
        type = lib.types.package;
        default = shared.package;
      };

      settings = shared.options;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services = {
      mconnect = {
        Unit = {
          Description = shared.description;
          Documentation = shared.documentation;
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${cfg.package}/bin/mconnect";
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };

    xdg.configFile."mconnect/mconnect.conf".text = shared.settings;
  };
}
