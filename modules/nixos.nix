{
  lib,
  config,
  ...
}: let
  cfg = config.programs.mconnect;
in {
  options = {
    programs.mconnect = {
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable default firewall ports for basic functionality";
      };
    };
  };

  config = {
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
