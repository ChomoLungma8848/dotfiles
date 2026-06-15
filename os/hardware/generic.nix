{ lib, ... }:
{
  boot.initrd.availableKernelModules = [
    # NVMe / SATA
    "nvme"
    "ahci"
    "sd_mod"
    # USB
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "uas"
    # Intel VMD
    "vmd"
    # 仮想環境
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

  # CPU マイクロコード
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
