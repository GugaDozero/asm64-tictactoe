section .bss
    game_position_pointer resq 9
    key resb 1
    garbage resb 1    ; trash from stdin (\n)

section .data
    new_line db 10
    nl_size equ $-new_line
    
    game_draw db "_|_|_", 10 
              db "_|_|_", 10
              db "_|_|_", 10, 0
    gd_size equ $-game_draw
              
    win_flag db 0
   
    player db "0", 0
    p_size equ $-player
    
    game_over_message db "FIM DE JOGO AMIGOS", 10, 0
    gom_size equ $-game_over_message
    
    game_start_message db "JOGO DA VELHA"
    gsm_size equ $-game_start_message
    
    player_message db "JOGADOR ", 0
    pm_size equ $-player_message
    
    win_message db " GANHOU!", 0
    wm_size equ $-win_message
    
    type_message db "ENTRE COM UMA POSICAO NO TABULEIRO: ", 0
    tm_size equ $-type_message
    
    clear_screen_ASCII_escape db 27,"[H",27,"[2J"      ; <ESC> [H  <ESC>  [2J
    cs_size equ $-clear_screen_ASCII_escape
    
section .text 
    global _start 
    
_start:
    nop
    call set_game_pos_pointer
    
main_loop:
    call clear_screen
    
    mov rsi, game_start_message
    mov rdx, gsm_size
    call print
    
    mov rsi, new_line
    mov rdx, nl_size
    call print

    mov rsi, player_message
    mov rdx, pm_size
    call print
    
    mov rsi, player
    mov rdx, p_size
    call print
    
    mov rsi, new_line
    mov rdx, nl_size
    call print
    
    mov rsi, game_draw
    mov rdx, gd_size
    ;mov rsi, game_position_pointer
    ;mov rdx, 9*8
    call print
    
    mov rsi, new_line
    mov rdx, nl_size
    call print
    
    mov rsi, type_message
    mov rdx, tm_size
    call print
    
    call read_keyboard               ; Vamos ler a posição que o usuário vai passar
    
    mov al, [key]
    sub al, 49                       ; 49 equivale a "1" em ASCII, eu faço essa subtração porque eu quero converter ASCII para inteiro, ao mesmo tempo que faço subtraio de 1 o valor inteiro
    
    
    call update_draw
    
    call check
    
    cmp byte[win_flag], 1
    je game_over
    
    call change_player
    
    jmp main_loop
    
change_player:
    
    xor byte[player], 1  ; Tipo um xor swap :)
    
    ret
    
print:
    mov rax, 1
    mov rdi, 1
    syscall
    ret
    
read_keyboard:
    mov rax, 0
    mov rdi, 0
    mov rsi, key 
    mov rdx, 1
    syscall
    
    cmp byte[key], 0x0A
    jz flush_end
    
    mov rdi, 0
    mov rsi, garbage
    mov rdx, 1
    
    flush_loop:
        mov rax, 0
        syscall
        
        cmp byte[garbage], 0x0A
        jz flush_end
        jmp flush_loop
    
    flush_end:
    
    ret
    
clear_screen:
    mov rsi, clear_screen_ASCII_escape
    mov rdx, cs_size
    call print
    ret
    
set_game_pos_pointer:
    mov rsi, game_draw
    mov rbx, game_position_pointer
    
    mov rcx, 9
    
    loop_1:
        mov [rbx], rsi
        add rsi, 2
        
        inc rbx
        loop loop_1
        
        
        
    ret
    
update_draw:
    mov rbx, [game_position_pointer + rax]
    
    
    mov rsi, player
    
    cmp byte[rsi], "0"
    je draw_x
    
    cmp byte[rsi], "1"
    je draw_o
    
    draw_x:
        mov cl, "x"
        jmp update
        
    draw_o:
        mov cl, "o"
        jmp update
        
    update:
        mov [rbx], cl
    
    ret
    
check:
    call check_line
    ret
    
check_line:

    mov rcx, 0
    
    check_line_loop:
        cmp rcx, 0
        je first_line
        
        cmp rcx, 1
        je second_line
        
        cmp rcx, 2
        je third_line
        
        call check_column
        ret
        
        first_line:
            mov rsi, 0
            jmp do_check_line
        
        second_line:
            mov rsi, 3
            jmp do_check_line
            
        third_line:
            mov rsi, 6
            jmp do_check_line
            
        do_check_line:
            inc rcx
            
            mov rbx, [game_position_pointer + rsi]
            mov al, [rbx]
            cmp al, "_"
            je check_line_loop
            
            inc rsi
            mov rbx, [game_position_pointer + rsi]
            cmp al, [rbx]
            jne check_line_loop
            
            inc rsi
            mov rbx, [game_position_pointer + rsi]
            cmp al, [rbx]
            jne check_line_loop
            
        mov byte[win_flag], 1
        ret
        
check_column:
    mov rcx, 0
    
    check_colum_loop:
        cmp rcx, 0
        je first_column
        
        cmp rcx, 1
        je second_column
        
        cmp rcx, 2
        je third_column
        
        call check_diagonal
        ret
        
        first_column:
            mov rsi, 0
            jmp do_check_column
            
        second_column:
            mov rsi, 1
            jmp do_check_column
            
        third_column:
            mov rsi, 2
            jmp do_check_column
            
        do_check_column:
            inc rcx
            
            mov rbx, [game_position_pointer + rsi]
            mov al, [rbx]
            cmp al, "_"
            je check_colum_loop
            
            add rsi, 3
            lea rbx, [game_position_pointer + rsi]
            cmp al, [rbx]
            jne check_colum_loop
            
            add rsi, 3
            mov rbx, [game_position_pointer + rsi]
            cmp al, [rbx]
            jne check_colum_loop
            
            mov byte[win_flag], 1
            ret
            
check_diagonal:
    mov rcx, 0
    
    check_diagonal_loop:
        cmp rcx, 0
        je first_diagonal
        
        cmp rcx, 1
        je second_diagonal
        
        ret
        
    first_diagonal:
        mov rsi, 0
        mov rdx, 4          ; tamanho do pulo que vamos dar para o meio da diagonal 
        jmp do_check_diagonal
        
    second_diagonal:
        mov rsi, 2
        mov rdx, 2
        jmp do_check_diagonal
        
    do_check_diagonal:
        inc rcx
        
        mov rbx, [game_position_pointer + rsi]
        mov al, [rbx]
        cmp al, "_"
        je check_diagonal_loop
        
        add rsi, rdx
        mov rbx, [game_position_pointer + rsi]
        cmp al, [rbx]
        jne check_diagonal_loop
        
        add rsi, rdx
        mov rbx, [game_position_pointer + rsi]
        cmp al, [rbx]
        jne check_diagonal_loop
        
    mov byte[win_flag], 1
    ret
    
game_over:
    call clear_screen
    
    mov rsi, game_start_message
    mov rdx, gsm_size
    call print
    
    mov rsi, new_line
    mov rdx, nl_size
    call print
    
    mov rsi, game_draw
    mov rdx, gd_size
    call print
    
    mov rsi, new_line
    mov rdx, nl_size
    call print
    
    mov rsi, game_over_message
    mov rdx, gom_size
    call print
    
    mov rsi, player_message
    mov rdx, pm_size
    call print
    
    mov rsi, player
    mov rdx, p_size
    call print
    
    mov rsi, win_message
    mov rdx, wm_size
    call print
    
    jmp fim
    
fim:
    mov rax, 60
    mov rdi, 0
    syscall
