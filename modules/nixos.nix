{
  lib,
  config,
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
      enable = lib.mkEnableOption "Enable MConnect";

      package = lib.mkOption {
        type = lib.types.package;
        default = shared.package;
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        description = "Enable default firewall ports for basic functionality";
      };

      settings = shared.options;
    };
  };

  config =
    # lib.optionalAttrs cfg.enable {
    #   environment.systemPackages = [cfg.package];
    #   systemd.services = {
    #     mconnect = {
    #       description = shared.description;
    #       documentation = [shared.documentation];
    #       partOf = ["graphical-session.target"];
    #       after = ["graphical-session.target"];
    #       wantedBy = ["graphical-session.target"];
    #       serviceConfig = {
    #         Type = "simple";
    #         Restart = "always";
    #         ExecStart = "${cfg.package}/bin/mconnect";
    #       };
    #     };
    #   };
    #   environment.etc."mconnect/mconnect.conf".text = shared.settings;
    # }
    {
      networking.firewall = {
        allowedUDPPorts = lib.optional cfg.openFirewall 1716;
        allowedTCPPortRanges =
          lib.optional cfg.openFirewall
          {
            from = 9970;
            to = 9975;
          };
      };
    };
}
