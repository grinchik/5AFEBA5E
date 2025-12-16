{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = [
        pkgs.unrar
    ];
}
