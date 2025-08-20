#!/bin/bash

mkdir -p build

if [ -f build/boot.o ]; then
    rm build/boot.o
fi
i686-elf-as src/boot.s -o build/boot.o

if [ -f build/kernel.o ]; then
    rm build/kernel.o
fi
i686-elf-gcc -c src/kernel.c -o build/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

if [ -f build/terminal.o ]; then
    rm build/terminal.o
fi
i686-elf-gcc -c src/terminal.c -o build/terminal.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

if [ -f build/m80os.bin ]; then
    rm build/m80os.bin
fi
i686-elf-gcc -T src/linker.ld -o build/m80os.bin -ffreestanding -O2 -nostdlib build/boot.o build/kernel.o build/terminal.o -lgcc

if [ -f build/m80os.iso ]; then
    rm build/m80os.iso
fi
mkdir -p build/isodir/boot/grub
cp build/m80os.bin build/isodir/boot/m80os.bin

cat > build/isodir/boot/grub/grub.cfg <<EOF
menuentry "M80OS" {
    multiboot /boot/m80os.bin
}
EOF

grub-mkrescue -o build/m80os.iso build/isodir

qemu-system-i386 -cdrom build/m80os.iso

