{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./module/systemd-boot/boot.nix
      ./module/network/networking.nix
      ./module/network/dnscrypt.nix
      ./module/neovim/neovim.nix
      ./module/sway/sway.nix
      ./thinkpad.nix
    ];

  services.earlyoom.enable = true;

  # Enable docker service
  virtualisation.docker.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    aria
    firefox-wayland
    gcc
    fd
    ffmpeg
    fzf
    git
    gnupg
    htop
    imagemagick
    keepassxc
    mpv
    p7zip
    ranger
    ripgrep
    rsync
    rclone
    rnix-lsp
    starship
    wget
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  # programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.master-x = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "audio" "networkmanager" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}
