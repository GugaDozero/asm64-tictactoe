section .bss
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
    
    overlap_message db "POSICAO OCUPADA, ESCOLHA OUTRA", 10, 0
    om_size equ $-overlap_message

    win_message db " GANHOU!", 10, 0
    wm_size equ $-win_message
    
    type_message db "ENTRE COM UMA POSICAO NO TABULEIRO: ", 0
    tm_size equ $-type_message
    
    clear_screen_ASCII_escape db 27,"[H",27,"[2J"      ; <ESC> [H  <ESC>  [2J
    cs_size equ $-clear_screen_ASCII_escape
    
section .text 
    global _start 
    
_start:
nop
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

    call print
    
    mov rsi, new_line
    mov rdx, nl_size
    call print

    request_input:
    
    mov rsi, type_message
    mov rdx, tm_size
    call print
    
    .repeat_read:
        call read_keyboard               ; Vamos ler a posição que o usuário vai passar
    
    cmp rax, 0
    je .repeat_read
    
    mov al, [key]
    sub al, 48                       ; 48 equivale a "0" em ASCII, eu faço essa subtração porque eu quero converter ASCII para inteiro
    
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
    jz read_end
    
    mov rdi, 0
    mov rsi, garbage
    mov rdx, 1
    
    flush_loop:
        mov rax, 0
        syscall
        
        cmp byte[garbage], 0x0A
        jz read_end
        jmp flush_loop
        
    read_end:
    
    ret
    
clear_screen:
    mov rsi, clear_screen_ASCII_escape
    mov rdx, cs_size
    call print
    ret
    
update_draw:
    
    cmp rax, 1
    je first_pos
    
    cmp rax, 2
    je second_pos
    
    cmp rax, 3
    je third_pos
    
    cmp rax, 4
    je fourth_pos
    
    cmp rax, 5 
    je fifith_pos
    
    cmp rax, 6
    je sixth_pos
    
    cmp rax, 7
    je seventh_pos
    
    cmp rax, 8
    je eighth_pos
    
    cmp rax, 9
    je nineth_pos
    
    jmp end_update 
    
    first_pos:
        mov rax, 0
        jmp continue_update
        
    second_pos:
        mov rax, 2
        jmp continue_update
        
    third_pos:
        mov rax, 4
        jmp continue_update
        
    fourth_pos:
        mov rax, 6
        jmp continue_update
        
    fifith_pos:
        mov rax, 8
        jmp continue_update
    
    sixth_pos:
        mov rax, 10
        jmp continue_update
        
    seventh_pos:
        mov rax, 12
        jmp continue_update
    
    eighth_pos:
        mov rax, 14
        jmp continue_update
        
    nineth_pos:
        mov rax, 16
        jmp continue_update
        
    continue_update:

    lea rbx, [game_draw + rax]
    
    mov al, [rbx]
    cmp al, "_"
    jne request_again

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
    
    end_update:
    
    ret

request_again:
    mov rsi, overlap_message
    mov rdx, om_size
    call print

    jmp request_input

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
            mov rsi, 6
            jmp do_check_line
            
        third_line:
            mov rsi, 12 
            jmp do_check_line
            
        do_check_line:
            inc rcx
            
            lea rbx, [game_draw + rsi]
            
            mov al, [ebx]
            cmp al, "_"
            je check_line_loop
            
            add rsi, 2
            lea rbx, [game_draw + rsi]

            cmp al, [rbx]
            jne check_line_loop
            
            add rsi, 2
            lea rbx, [game_draw + rsi]
            
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
            mov rsi, 2
            jmp do_check_column
            
        third_column:
            mov rsi, 4
            jmp do_check_column
            
        do_check_column:
            inc rcx
            
            lea rbx, [game_draw + rsi]
            
            mov al, [rbx]
            cmp al, "_"
            je check_colum_loop
            
            add rsi, 6
            lea rbx, [game_draw + rsi]
            
            cmp al, [rbx]
            jne check_colum_loop
            
            add rsi, 6
            lea rbx, [game_draw + rsi]
            
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
        mov rdx, 8          ; tamanho do pulo que vamos dar para o meio da diagonal 
        jmp do_check_diagonal
        
    second_diagonal:
        mov rsi, 4
        mov rdx, 4
        jmp do_check_diagonal
        
    do_check_diagonal:
        inc rcx
        
        lea rbx, [game_draw + rsi]
        
        mov al, [rbx]
        cmp al, "_"
        je check_diagonal_loop
        
        add rsi, rdx
        lea rbx, [game_draw + rsi]
        
        cmp al, [rbx]
        jne check_diagonal_loop
        
        add rsi, rdx
        lea rbx, [game_draw + rsi]
        
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
