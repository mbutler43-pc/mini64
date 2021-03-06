CC=gcc
LD=ld
NASM=nasm

CFLAGS=-Wall -Wextra -pedantic -Werror

KERNEL_CFLAGS=-ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -nostdlib

KERNEL_OBJS=\
	kernel/console.o \
	kernel/gdt.o \
	kernel/idt.o \
	kernel/isrs.o \
	kernel/main.o \
	kernel/paging.o \
	kernel/panic.o \
	kernel/serial.o \
	kernel/start.o \
	kernel/string.o \
	kernel/virt.o \

.PHONY: all clean

all: floppy.img

clean:
	rm -f floppy.img loader/loader.bin kernel/kernel.bin kernel/*.o

floppy.img: loader/loader.bin kernel/kernel.bin
	@echo writing floppy.img
	@dd of=$@ if=/dev/zero bs=512 count=2880 status=none
	@dd of=$@ if=loader/loader.bin bs=512 seek=0 conv=notrunc status=none
	@dd of=$@ if=kernel/kernel.bin bs=512 seek=1 conv=notrunc status=none

loader/loader.bin: loader/loader.asm
	@echo nasm $@
	@$(NASM) -f bin -o $@ $<

kernel/kernel.bin: $(KERNEL_OBJS)
	@echo ld $@
	@$(LD) -T kernel/linker.ld -o $@ $^

kernel/%.o: kernel/%.asm
	@echo nasm $@
	@$(NASM) -f elf64 -o $@ $<

kernel/%.o: kernel/%.c kernel/*.h
	@echo cc $@
	@$(CC) -o $@ $(KERNEL_CFLAGS) $(CFLAGS) -c $<
