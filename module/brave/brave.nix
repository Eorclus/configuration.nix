{ stdenv, lib, fetchurl
, dpkg
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gnome2
, gnome
, gsettings-desktop-schemas
, gtk3
, libpulseaudio
, libuuid
, libdrm
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libxkbcommon
, libXrandr
, libXrender
, libXScrnSaver
, libxshmfence
, libXtst
, mesa
, nspr
, nss
, pango
, pipewire
, udev
, xorg
, zlib
, xdg-utils
, wrapGAppsHook
, wayland
, commandLineArgs ? ""
}:

let

rpath = lib.makeLibraryPath [
  alsa-lib
  at-spi2-atk
  at-spi2-core
  atk
  cairo
  cups
  dbus
  expat
  fontconfig
  freetype
  gdk-pixbuf
  glib
  gnome2.GConf
  gtk3
  libdrm
  libpulseaudio
  libX11
  libxkbcommon
  libXScrnSaver
  libXcomposite
  libXcursor
  libXdamage
  libXext
  libXfixes
  libXi
  libXrandr
  libXrender
  libxshmfence
  libXtst
  libuuid
  mesa
  nspr
  nss
  pango
  pipewire
  udev
  wayland
  xdg-utils
  xorg.libxcb
  zlib
];

in

stdenv.mkDerivation rec {
  pname = "brave-beta";
  version = "1.33.78";

  src = fetchurl {
    url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser-beta_${version}_amd64.deb";
    sha256 = "12rvlg1nwpg2wv95x1p5r8y15xi6shn4568fxa3adhrmm4n6ri2x";
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  doInstallCheck = true;

  nativeBuildInputs = [ dpkg wrapGAppsHook ];

  buildInputs = [ glib gsettings-desktop-schemas gnome.adwaita-icon-theme ];

  unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

  installPhase = ''
      runHook preInstall
      mkdir -p $out $out/bin
      cp -R usr/share $out
      cp -R opt/ $out/opt
      export BINARYWRAPPER=$out/opt/brave.com/brave-beta/brave-browser-beta
      # Fix path to bash in $BINARYWRAPPER
      substituteInPlace $BINARYWRAPPER \
          --replace /bin/bash ${stdenv.shell}
      ln -sf $BINARYWRAPPER $out/bin/brave-beta
      for exe in $out/opt/brave.com/brave-beta/{brave,chrome_crashpad_handler}; do
      patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${rpath}" $exe
      done
      # Fix paths
      substituteInPlace $out/share/applications/brave-browser-beta.desktop \
          --replace /usr/bin/brave-browser-beta $out/bin/brave
      substituteInPlace $out/share/gnome-control-center/default-apps/brave-browser-beta.xml \
          --replace /opt/brave.com $out/opt/brave.com
      substituteInPlace $out/share/menu/brave-browser-beta.menu \
          --replace /opt/brave.com $out/opt/brave.com
      substituteInPlace $out/opt/brave.com/brave-beta/default-app-block \
          --replace /opt/brave.com $out/opt/brave.com
      # Correct icons location
      icon_sizes=("16" "22" "24" "32" "48" "64" "128" "256")
      for icon in ''${icon_sizes[*]}
      do
          mkdir -p $out/share/icons/hicolor/$icon\x$icon/apps
          ln -s $out/opt/brave.com/brave-beta/product_logo_$icon.png $out/share/icons/hicolor/$icon\x$icon/apps/brave-browser-beta.png
      done
      # Replace xdg-settings and xdg-mime
      ln -sf ${xdg-utils}/bin/xdg-settings $out/opt/brave.com/brave-beta/xdg-settings
      ln -sf ${xdg-utils}/bin/xdg-mime $out/opt/brave.com/brave-beta/xdg-mime
      runHook postInstall
  '';

  preFixup = ''
    # Add command line args to wrapGApp.
    gappsWrapperArgs+=(--add-flags ${lib.escapeShellArg commandLineArgs})
  '';

  installCheckPhase = ''
    # Bypass upstream wrapper which suppresses errors
    $out/opt/brave.com/brave-beta/brave --version
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    homepage = "https://brave.com/";
    description = "Privacy-oriented browser for Desktop and Laptop computers";
    changelog = "https://github.com/brave/brave-browser/blob/master/CHANGELOG_DESKTOP.md";
    longDescription = ''
      Brave browser blocks the ads and trackers that slow you down,
      chew up your bandwidth, and invade your privacy. Brave lets you
      contribute to your favorite creators automatically.
    '';
    license = licenses.mpl20;
    maintainers = with maintainers; [ uskudnik rht jefflabonte nasirhm ];
    platforms = [ "x86_64-linux" ];
  };
}
