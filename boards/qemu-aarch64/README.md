# QEMU AArch64 Board

This board uses Buildroot's `qemu_aarch64_virt_defconfig` as the base and appends `buildroot_fragment` for this course.

Generated images are expected under:

```text
output/qemu-aarch64/images/Image
output/qemu-aarch64/images/rootfs.ext2
```

The QEMU runner boots with:

```text
console=ttyAMA0 root=/dev/vda rw panic=-1
```

