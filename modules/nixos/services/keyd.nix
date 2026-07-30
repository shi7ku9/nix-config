{ ... }:
{
  flake.nixosModules."services/keyd" =
    { ... }:
    {
      services.keyd = {
        enable = true;

        keyboards = {
          default = {
            ids = [ "*" ];
            settings = {
              main = {
                capslock = "f13"; # I dont need capslock!
                rightshift = "rightshift"; # I need right!
                rightcontrol = "rightcontrol";
                rightalt = "rightalt";
              };
            };
          };
        };
      };

      # keyd 靠 udev + systemd DeviceAllow 才能存取 input 裝置，
      # 但部分鍵盤（如 i8042 AT 鍵盤）沒有 :systemd: tag，
      # 導致 systemd 擋掉 keyd 的 open()。這條規則補上 tag。
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", TAG+="systemd"
      '';
    };

}
