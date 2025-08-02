; bootloader.asm
[BITS 16]
[ORG 0x7C00]

start:
    ; 设置段寄存器
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; 加载第二阶段引导加载器到内存地址0x0000:0x0800
    mov bx, 0x0800  ; 目标段地址
    mov dh, 0       ; 磁头号
    mov dl, 0       ; 驱动器号 (A盘)
    mov ch, 0       ; 柱面号
    mov cl, 2       ; 扇区号（加载第2个扇区）
    mov ah, 0x02    ; BIOS 读扇区功能号
    mov al, 8       ; 读取8个扇区
    int 0x13        ; 调用BIOS中断
    jc read_error   ; 如果读取失败，跳转到错误处理

    ; 跳转到第二阶段引导加载器
    jmp 0x0000:0x0800

read_error:
    ; 显示错误信息并挂起
    mov si, read_error_msg
    call print_string
    hlt

print_string:
    mov ah, 0x0E
.next_char:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .next_char
.done:
    ret

read_error_msg db 'Disk read error', 0

times 510-($-$$) db 0
dw 0xAA55
