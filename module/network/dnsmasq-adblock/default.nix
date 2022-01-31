{ pkgs, ... }:
let
  adblockhost = pkgs.stdenv.mkDerivation {
    name = "adblockhost";
    host1 = (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt";
    });
    host2 = (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
    });

   phases = [ "installPhase" ];
   
   # Minify host file
   installPhase = ''
     ${pkgs.gawk}/bin/awk '!a[$2]++ { if ($1 == "0.0.0.0") { print "address=/"$2"/0.0.0.0/" }}' $host1 $host2 > $out
   '';
  };

in {
  services.dnsmasq = {
    enable = true;
    servers = ["127.0.0.1#5300"]; #dnscrypt-proxy2 port
    resolveLocalQueries = false;
    extraConfig = ''
      conf-file="${adblockhost}"
      conf-file="${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf"
      cache-size=1000
      domain-needed
      bogus-priv
      dnssec
    '';
  };
}
