# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{ 
    imports =
    [# Include the results of the hardware scan
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
    /home/nate/musnix/clone 
    ];
    
    musnix.enable = true;
  # Your existing configuration options

  # Specify the root file system
    fileSystems."/" = {
    device = lib.mkForce "/dev/nvme0n1p2";  # Replace /dev/sdX1 with your actual root partition
    fsType = "ext4";       # Replace with your actual file system type
 };
   
    fileSystems."/boot" = {
    device = lib.mkForce "/dev/nvme0n1p1";
    fsType = "vfat"; 
 }; 
    users.users.natem = {
    isNormalUser = true;
    home = "/home/nate";
    extraGroups = [ "wheel" "networkmanager" "audio" ];
  };
  
    home-manager.users.natem = { pkgs, ... }: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    programs.bash.enable = true;
    home.stateVersion = "25.05"; 
  }; 

    security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    };

    # Enable OpenGL
    hardware.graphics = {
    enable = true;
    };

    services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH = 75;
      STOP_CHARGE_THRESH = 80;
      # Add other TLP settings as needed
    };
  };
  
    systemd.services.tlp = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {

    # Modesetting is required
    modesetting.enable = true;

    # Nvidia power managment. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bar essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUS (turing or newer).
    powerManagement.finegrained = false;

    # Use the Nvidia open source kernel module ( not to be confused with the
    # indpendent third-party "nouveau" open source driver.)
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # acessible via 'nvidia-settings'.
    nvidiaSettings = true;

    #Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
};

    hardware.nvidia.prime = {
    nvidiaBusId = "PCI:1:0:0";
};

  # Bootloader.
  boot.loader.grub = {
  enable = true;
  device = "nodev";
  efiSupport = true;
  efiInstallAsRemovable = true;
  };

  networking.hostName = "DOPPELGANGER"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain"; 

  # Enable networking
  networking.networkmanager.enable = true;

  #Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Fonts
  fonts.packages = with pkgs; [
  # Include all available Nerd Fonts
] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;
  

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
  enable = true;
  wayland.enable = true; 
  };  

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
   # Configure ALSA to use the Focusrite 2i2
  environment.sessionVariables = {
    ALSA_CARD = "Focusrite";  # Replace "Focusrite" with the actual card name or identifier
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # Install hyprland and other programs
  programs.hyprland.enable = true;  

  programs.waybar.enable = true;

  environment.sessionVariables = {
  WAYBAR_CONFIG = "home/nate/.config/waybar/"; 
  }; 
  
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
};

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
  ];
 
  nixpkgs.config.permittedInsecurePackages = [
  "ventoy-1.1.05"
  ];   

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   security.polkit.enable = true;
   environment.systemPackages = with pkgs; [
   # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   vim
   wget
   librewolf
   kitty
   spotify
   usbutils
   alsa-utils
   pipewire
   standardnotes
   anytype
   git
   clementine
   thunderbird-latest
   albert
   hyprpaper
   xdg-desktop-portal-hyprland
   waybar
   hyprshot
   fastfetch
   vesktop
   kdePackages.kate
   kdePackages.konsole
   freetube
   protonvpn-gui
   soulseekqt
   nh
   gedit
   lshw
   dunst
   libnotify
   fd
   ventoy 
   xen
   logger
   util-linux
   hyprland
   nautilus
   xorg.xrandr
   alsa-utils
   pavucontrol
   networkmanagerapplet
   reaper
   audacity
   tlp 
   unzip
   (import <nixos-unstable> {}).protonmail-desktop
  ];

  system.stateVersion = "25.05";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # Did you read the comment?
}
