[org 0x7c00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    mov si, welcome_msg
    call print_string

shell_loop:
    mov si, prompt
    call print_string
    mov di, input_buffer

read_char:
    mov ah, 0x00
    int 0x16
    cmp al, 13
    je process_command
    mov ah, 0x0e
    int 0x10
    stosb
    jmp read_char

process_command:
    xor al, al
    stosb
    call newline_func
    mov si, input_buffer

    ; ALL COMANDS
    
    ; 1. CLS
    mov di, cmd_cls
    call compare_strings
    je do_cls

    ; 2. PLASMA
    mov di, cmd_plasma
    call compare_strings
    je do_plasma

    ; 3. VER
    mov di, cmd_ver
    call compare_strings
    je do_ver

    ; 4. REBOOT
    mov di, cmd_reboot
    call compare_strings
    je do_reboot

    ; 5. HELP
    mov di, cmd_help
    call compare_strings
    je do_help

    mov si, unknown_msg
    call print_string
    jmp shell_loop

; COMANDS IMPLEMENTS

do_cls:
    mov ax, 0x0003
    int 0x10
    jmp shell_loop

do_ver:
    mov si, ver_text
    call print_string
    mov eax, 0
    cpuid
    mov [cpu_vendor], ebx
    mov [cpu_vendor+4], edx
    mov [cpu_vendor+8], ecx
    mov si, cpu_vendor
    call print_string
    call newline_func
    jmp shell_loop

do_reboot:
    jmp 0xFFFF:0000

do_plasma:
    mov ax, 0x0013
    int 0x10
    mov ax, 0xA000
    mov es, ax
.plasma_loop:
    mov dx, 0
.loop_y:
    mov cx, 0
.loop_x:
    mov ax, cx
    add ax, dx
    add ax, [frame_var]
    mov di, dx
    imul di, 320
    add di, cx
    mov [es:di], al
    inc cx
    cmp cx, 320
    jne .loop_x
    inc dx
    cmp dx, 200
    jne .loop_y
    inc word [frame_var]
    mov ah, 0x01
    int 0x16
    jz .plasma_loop
    mov ax, 0x0003
    int 0x10
    jmp shell_loop

do_help:
    mov si, help_msg
    call print_string
    jmp shell_loop

; CORE FUNCTIONS

compare_strings:
    push si
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .done
    cmp al, 0
    je .done
    inc si
    inc di
    jmp .loop
.done:
    pop si
    ret

print_string:
    mov ah, 0x0e
.lp:
    lodsb
    or al, al
    jz .en
    int 0x10
    jmp .lp
.en: ret

newline_func:
    mov si, newline
    call print_string
    ret

; DATA
welcome_msg db 'Welcome to HydrogenDOS v0.1 - Type HELP to see all comands', 13, 10, 0
prompt      db '> ', 0
newline     db 13, 10, 0
unknown_msg db 'ERROR: UNKNOWN COMAND', 13, 10, 0
help_msg    db 'CLS, PLASMA, VER, REBOOT', 13, 10, 0
ver_text    db 'HydrogenDOS 0.1 - CPU: ', 0
cmd_cls     db 'cls', 0
cmd_plasma  db 'plasma', 0
cmd_ver     db 'ver', 0
cmd_reboot  db 'reboot', 0
cmd_help    db 'help', 0
cpu_vendor  db '            ', 13, 10, 0
frame_var   dw 0
input_buffer equ 0x8000

times 510-($-$$) db 0
dw 0xaa55