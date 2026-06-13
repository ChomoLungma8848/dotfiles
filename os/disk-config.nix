{
  # disko によるディスク宣言（パーティション・マウント・フォーマット）
  # nixos-install 時に nix run github:nix-community/disko または apps.install ラッパー経由で使用
  #
  # 【新規マシンへの適用前に確認】
  # `lsblk` でディスク名を確認し、device を実機に合わせて書き換えること。
  # /dev/disk/by-id/... を使うと名前が安定して安全。
  disko.devices.disk.main = {
    device = "/dev/nvme0n1"; # ← lsblk で確認して実機のデバイスに書き換える
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        # ESP（EFI System Partition）
        # NixOS は generation ごとに kernel/initrd を /boot に置くため大きめに確保
        ESP = {
          size = "1536M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        # ルートパーティション
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
