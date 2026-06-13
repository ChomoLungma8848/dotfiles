{ lib, ... }:
{
  # 汎用ハードウェアモジュール（マシンごとの hardware-configuration.nix を不要にする）
  # disko が fileSystems を生成するため、ここでは起動に必要なカーネルモジュールのみを担う

  boot.initrd.availableKernelModules = [
    # NVMe / SATA
    "nvme"
    "ahci"
    "sd_mod"
    # USB（インストールUSBからのブートや外付けストレージ）
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "uas"
    # Intel VMD（VMD 有効のノートPC で無いとルートを検出できず起動失敗する）
    "vmd"
    # 仮想環境（QEMU/KVM 等）
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
  ];

  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
  ];

  boot.extraModulePackages = [ ];

  # ファームウェア（Wi-Fi / GPU 等のプロプライエタリ firmware）
  hardware.enableRedistributableFirmware = true;

  # CPU マイクロコード（ベンダ非依存にするため両方 mkDefault で設定; 合致しない方は無効化される）
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
