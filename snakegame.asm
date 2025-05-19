;Ali Saleem (23L-2638)
;Ammar Hassan (23L-2614)

[org 0x0100]

start: 
        call    hide_cursor
	call 	clrscr
        jmp     start_game

start_game:
        call    show_title
        call    start_playing
        call    show_game_over
        jmp     start_game

; Waits for specified clock ticks (55.56ms each)
sleep:
        mov     ah, 0
        int     1ah
        mov     bx, dx
sleep_wait:
        mov     ah, 0
        int     1ah
        sub     dx, bx
        cmp     dx, si
        jl      sleep_wait
        ret
; subroutine to clear the screen
clrscr: 
	push es
	push ax
	push di
	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov di, 0 ; point di to top left column

nextloc: mov word [es:di], 0x0720 ; clear next char on screen
	add di, 2 ; move to next screen location
	cmp di, 4000 ; has the whole screen cleared
	jne nextloc ; if no clear next position
	
	pop di
	pop ax
	pop es
	ret
	
; Hides text cursor
hide_cursor:
        mov     ah, 02h
        mov     bh, 0
        mov     dh, 25
        mov     dl, 0
        int     10h
        ret

; Clears all pending keyboard input
clear_keyboard_buffer:
        mov     ah, 1
        int     16h
        jz      clr_kbd_end
        mov     ah, 0
        int     16h
        jmp     clear_keyboard_buffer
clr_kbd_end:
        ret

; Terminates program execution
exit_process:
        mov     ah, 4ch
        int     21h
        ret

; ===== BUFFER OPERATIONS =====

; Clears screen buffer with spaces
buffer_clear:
        mov     bx, 0
buffer_clr_next:
        mov     byte [buffer+bx], ' '
        inc     bx
        cmp     bx, 2000  	; 80x25 screen
        jnz     buffer_clr_next
        ret

buffer_write:
        push    ax
        push    di
       
        mov     di, buffer
        mov     al, 80
        mul     dl			; AL * DL = row * 80        
        add     ax, cx		; Add column
        add     di, ax
        mov     [di], bl	; Write character
       
        pop     di
        pop     ax
        ret

; Reads character from buffer position

buffer_read:
        push    ax
        push    di
       
        mov     di, buffer
        mov     al, 80
        mov     dh, 0		; Clear high byte of DX
        mul     dl			; AL * DL = row * 80
        add     ax, cx
        add     di, ax
        mov     bl, [di]	; Read character
       
        pop     di
        pop     ax
        ret

; Prints null-terminated string to buffer
buffer_print_string:
        push    ax
buffer_print_next:
        mov     al, [si]
        cmp     al, 0		; Check for null terminator
        jz      buffer_print_end
        mov     byte [buffer+di], al
        inc     di
        inc     si
        jmp     buffer_print_next
buffer_print_end:
        pop     ax
        ret
	
; Renders buffer to video memory
buffer_render:
        push    ax
        push    bx
        push    di
        push    si
       
        mov     ax, 0b800h	 ; Video memory segment
        mov     es, ax
        mov     di, buffer	
        mov     si, 0		; Video memory offset
buffer_render_next:
        mov     bl, [di]		; Get character from buffer
        cmp     bl, 8		; Check if snake (up)
        jz      buffer_render_snake
        cmp     bl, 4		; Check if snake (down)
        jz      buffer_render_snake
        cmp     bl, 2		; Check if snake (left)
        jz      buffer_render_snake
        cmp     bl, 1		; Check if snake (right)
        jz      buffer_render_snake
        jmp     buffer_render_write
buffer_render_snake:
        mov     bl, 2		; snake body character
buffer_render_write:
        mov     byte [es:si], bl	; Write to video memory
        inc     di
        add     si, 2
        cmp     si, 4000	; 2000 chars * 2 bytes
        jnz     buffer_render_next
       
        pop     si
        pop     di
        pop     bx
        pop     ax
        ret

; ===== UI FUNCTIONS =====

; Displays title screen and waits for key press
show_title:
        call    buffer_clear
        mov     si, text_start
        mov     di, 1388		; Center screen position (80*17+68)
        call    buffer_print_string
        call    buffer_render
        call    clear_keyboard_buffer
title_wait_key:
        mov     ah, 1
        int     16h				; Check keyboard status
        jz      title_wait_key
        mov     ah, 0			; Get key
        int     16h
        ret

; Displays current score at top of screen
print_score:
        mov     si, text_score
        mov     di, 0			; Screen position 0 (top-left)
        call    buffer_print_string
        mov     ax, [score]
        mov     di, 13			; Score digits position
print_score_next:
        xor     dx, dx
        mov     bx, 10
        div     bx
        push    ax
        mov     al, dl
        add     al, 48
        mov     byte [buffer+di], al
        pop     ax
        dec     di
        cmp     ax, 0
        jnz     print_score_next
        ret

; ===== INPUT HANDLING =====
; Updates snake direction based on keyboard input
update_snake_direction:
        mov     ah, 1
        int     16h				; Check keyboard status
        jz      update_dir_end	; No key pressed
        mov     ah, 0			; Get key
        int     16h
        cmp     al, 27			; ESC key
        jz      exit_process
		
		; Check arrow keys
        cmp     ah, 48h			; Up arrow
        jz      update_dir_up
        cmp     ah, 50h			; Down arrow
        jz      update_dir_down
        cmp     ah, 4bh			; Left arrow
        jz      update_dir_left
        cmp     ah, 4dh			; Right arrow
        jz      update_dir_right	
        jmp     update_snake_direction  ; Ignore other keys
update_dir_up:
        mov     byte [snake_direction], 8
        jmp     update_snake_direction
update_dir_down:
        mov     byte [snake_direction], 4
        jmp     update_snake_direction
update_dir_left:
        mov     byte [snake_direction], 2
        jmp     update_snake_direction
update_dir_right:
        mov     byte [snake_direction], 1
        jmp     update_snake_direction
update_dir_end:
        ret


; ===== SNAKE MOVEMENT =====

; Updates snake head position based on current direction
update_snake_head:
		; Save current head position
        mov     al, [snake_head_y]
        mov     [snake_head_prev_y], al
        mov     al, [snake_head_x]
        mov     [snake_head_prev_x], al
       
		; Move head based on direction
        mov     ah, [snake_direction]
        cmp     ah, 8			; Up
        jz      update_head_up
        cmp     ah, 4			; Down
        jz      update_head_down
        cmp     ah, 2			; Left
        jz      update_head_left
        cmp     ah, 1			; Righ
        jz      update_head_right
update_head_up:
        dec     byte [snake_head_y]
        jmp     update_head_end
update_head_down:
        inc     byte [snake_head_y]
        jmp     update_head_end
update_head_left:
        dec     byte [snake_head_x]
        jmp     update_head_end
update_head_right:
        inc     byte [snake_head_x]
update_head_end:
		; Mark previous head position with current direction
        mov     bl, [snake_direction]
        xor     ch, ch
        mov     cl, [snake_head_prev_x]
        mov     dl, [snake_head_prev_y]
        call    buffer_write
        ret

; ===== COLLISION DETECTION =====
	
; Checks new head position for collisions
check_snake_new_position:
        xor     ch, ch
        mov     cl, [snake_head_x]
        xor     dh, dh
        mov     dl, [snake_head_y]
        call    buffer_read			; BL = character at new position
        cmp     bl, 8
        jle     check_collision
        cmp     bl, '*'				; Food
        je      check_food
        cmp     bl, ' '				; Empty space
        je      check_empty
check_collision:
        mov     al, 1
        mov     [is_game_over], al	; Set game over flag
check_write_head:
        mov     bl, 1
        xor     ch, ch
        mov     cl, [snake_head_x]
        mov     dl, [snake_head_y]
        call    buffer_write
        ret
check_food:
        inc     word [score]		; Increase score
        call    check_write_head
        call    create_food			; Spawn new food
        jmp     check_end
check_empty:
        call    update_snake_tail	 ; Move tail for normal movement
        call    check_write_head
check_end:
        ret


; ===== TAIL MOVEMENT =====

; Updates snake tail position
update_snake_tail:
	
		; Save current tail position
        mov     al, [snake_tail_y]
        mov     [snake_tail_prev_y], al
        mov     al, [snake_tail_x]
        mov     [snake_tail_prev_x], al
       
		; Read direction at current tail position
        xor     ch, ch
        mov     cl, [snake_tail_x]
        xor     dh, dh
        mov     dl, [snake_tail_y]
        call    buffer_read
       
		; Move tail based on direction
        cmp     bl, 8
        jz      update_tail_up
        cmp     bl, 4
        jz      update_tail_down
        cmp     bl, 2
        jz      update_tail_left
        cmp     bl, 1
        jz      update_tail_right
        jmp     exit_process
update_tail_up:
        dec     byte [snake_tail_y]
        jmp     update_tail_end
update_tail_down:
        inc     byte [snake_tail_y]
        jmp     update_tail_end
update_tail_left:
        dec     byte [snake_tail_x]
        jmp     update_tail_end
update_tail_right:
        inc     byte [snake_tail_x]
update_tail_end:
		; Clear previous tail position
        mov     bl, ' '
        xor     ch, ch
        mov     cl, [snake_tail_prev_x]
        mov     dl, [snake_tail_prev_y]
        call    buffer_write
        ret

; ===== GAME LOGIC =====

; Creates new food at random position
create_food:
		; Remove existing food
        mov     cx, 2000
        mov     di, buffer
create_food_remove:
        cmp     byte [di], '*'
        jne     create_food_next
        mov     byte [di], ' '		; Clear existing food
create_food_next:
        inc     di
        loop    create_food_remove

create_food_try:
		; Get random number
        mov     ah, 0
        int     1ah		; Get system time in CX:DX
        mov     ax, dx		; Use low word of timer
        and     ax, 0fffh
        mul     dx
        mov     dx, ax
        mov     ax, dx
        mov     cx, 2000
        xor     dx, dx
        div     cx			; DX = random index [0-1999]
        mov     bx, dx
        mov     di, buffer
        mov     al, [di+bx]
		
		; Verify position is empty
        cmp     al, ' '
        jne     create_food_try
		
		; Place food if empty
        mov     byte [di+bx], '*'
        ret

; Resets game to initial state
reset:
        xor     ax, ax
        mov     [score], ax
        mov     [is_game_over], al
		
		; Initialize snake position and direction
        mov     al, 8					; Start moving up
        mov     [snake_direction], al
        mov     al, 40				
        mov     [snake_head_x], al
        mov     [snake_head_prev_x], al
        mov     [snake_tail_prev_x], al
        mov     [snake_tail_x], al
        mov     al, 15
        mov     [snake_head_y], al
        mov     [snake_head_prev_y], al
        mov     [snake_tail_y], al
        mov     [snake_tail_prev_y], al
        ret

; ===== MAIN GAME LOOP =====
; Starts new game
start_playing:
        call    reset
        call    buffer_clear
        call    draw_border
        call    create_food
main_game_loop:
        mov     si, 2		; 111ms delay (2 ticks)
        call    sleep
       
        call    update_snake_direction
        call    update_snake_head
        call    check_snake_new_position
        call    print_score
        call    buffer_render
       
        mov     al, [is_game_over]
        cmp     al, 0
        jz      main_game_loop	; Continue while game not over
        ret

; ===== SCREEN DRAWING =====
; Draws border around play area
draw_border:
		; Draw horizontal borders
        mov     di, 0
border_top:
        mov     byte [buffer+di], 255
        mov     byte [buffer+80+di], 196		; Second line
        mov     byte [buffer+1920+di], 196		; Bottom line
        inc     di
        cmp     di, 80
        jnz     border_top
       
		; Draw vertical borders
        mov     di, 0
border_sides:
        mov     byte [buffer+80+di], 179	; Left border
        mov     byte [buffer+159+di], 179	; Right border
        add     di, 80
        cmp     di, 2000
        jnz     border_sides
       
	   ; Draw corner pieces
        mov     byte [buffer+80], 218		; Top-left
        mov     byte [buffer+159], 191		; Top-righ
        mov     byte [buffer+1920], 192		; Bottom-left
        mov     byte [buffer+1999], 217		; Bottom-right
        ret
		
; ===== GAME OVER SCREEN =====
; Displays game over message
show_game_over:
		; Center game over text vertically
        mov     si, text_gameover1
        mov     di, 912
        call    buffer_print_string
       
        mov     si, text_gameover2
        mov     di, 992
        call    buffer_print_string
       
        mov     si, text_gameover1
        mov     di, 1072
        call    buffer_print_string
       
        call    buffer_render
       
		; Wait before accepting input
        mov     si, 48		; ~2.5 second delay
        call    sleep
        call    clear_keyboard_buffer
		
		; Wait for any key
        mov     ah, 0
        int     16h
        ret

; ===== DATA SECTION =====

score           dw      0
is_game_over    db      0
snake_direction db      0
snake_head_x    db      0
snake_head_y    db      0
snake_head_prev_x db    0
snake_head_prev_y db    0
snake_tail_x    db      0
snake_tail_y    db      0
snake_tail_prev_x db    0
snake_tail_prev_y db    0

; UI Strings
text_score      db      ' SCORE: 000000', 0
text_gameover1  db      '               ', 0
text_gameover2  db      '   Game Over :(   ', 0
text_start      db      'press any key to start...', 0

; Screen buffer (80x25 characters)
buffer: times 2000 db 0