# MacOS
MacOS Shellcode

rvsh.asm is x86_64 shellcode that spawn a reverse shell. This was adapted from the bind shell example in OffSec's EXP-312 course in to an interactive reverse shell

Assemble with: nasm -f macho64 rvsh.asm
Link with: ld -L /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -lSystem rvsh.o -o rvsh
