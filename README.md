# asm64-tictactoe
A tictactoe wrote in assembly 64 bits for linux

This an adaptation from a tictactoe game wrote in assembly 16 bits of DOS to a 64 bit assembly game using linux syscalls instead of DOS interruptions.

The original game: https://github.com/RobertoDebarba/tictactoe-8086

Build:

# nasm -f elf64 tictactoe.asm

# ld -o tictactoe tictactoe.o

Have fun!
