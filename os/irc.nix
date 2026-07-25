let
  address = "219.104.138.21";
  adminEmail = "chomo_lungma@icloud.com";
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = adminEmail;
  };

  service.ergo = {
    enable = true;
    serverName = "address";

    sslCert = "/var/lib/acme/${address}/fullchain.pem";
    sslKey = "/var/lib/acme/${address}/key.pme";

    settings = {
      network = {
        name = "myNet";
      };

      listeners = {
        ":6697" = {
          tls = true;
        };
      };
    };

    accounts = {
      registration = {
        enable = true;
        require-verification = false;
      };
    };

    limits = {
      "ip-limits" = {
        "total" = 5;
      };
    };
  };

  users.users.ergo.extraGroups = [ "acme" ];
  networking.firewall.allowedTCPPorts = [
    80
    6697
  ];
}
