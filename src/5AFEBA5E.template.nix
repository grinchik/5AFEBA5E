{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
  ];

  boot.supportedFilesystems = [
    "zfs"
  ];

  environment.systemPackages = [
    pkgs.pciutils
    pkgs.nvme-cli
    pkgs.cryptsetup
    pkgs.lm_sensors
    pkgs.htop
    pkgs.intel-gpu-tools
    pkgs.hdparm
    pkgs.smartmontools
    pkgs.screen
  ];

  # network configuration
  networking.hostName = "$HOST_NAME";
  networking.hostId = "$HOST_ID";

  networking.interfaces.enp1s0.ipv4.addresses = [{
    address = "192.168.3.103";
    prefixLength = 24;
  }];

  # disabling NTP sync
  services.timesyncd.enable = false;

  # SSH server configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };

    hostKeys = [
      {
        path = "/etc/ssh/$SSH_HOST_KEY_FILE_NAME";
        type = "$SSH_HOST_KEY_TYPE";
      }
    ];
  };

  environment.etc = {
    "ssh/$SSH_HOST_KEY_FILE_NAME" = {
      mode = "0600";
      text = builtins.readFile ./$SSH_HOST_KEY_FILE_NAME;
    };
    "ssh/$SSH_HOST_KEY_FILE_NAME.pub" = {
      mode = "0644";
      text = builtins.readFile ./$SSH_HOST_KEY_FILE_NAME.pub;
    };
  };

  # user configuration
  users.users.user = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "$SSH_PUBLIC_KEY"
    ];
  };

  # passwordless sudo
  users.users.user.extraGroups = [ "wheel" ];
  security.sudo.wheelNeedsPassword = false;

  hardware.cpu.intel.updateMicrocode = true;

  # boot menu configuration
  boot.loader.timeout = lib.mkForce 1;
  isoImage.appendToMenuLabel = lib.mkForce " Live";

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # for qemu -nographic
  boot.kernelParams = [ "console=ttyS0,115200" ];

  system.stateVersion = "24.05";
}
