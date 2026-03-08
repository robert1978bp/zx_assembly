; loads 8x8 Sprite from y/x coordinates
; applies attribute (color) based on y/x coordinates
; use multiples of 8 for y/x otherwise 'colorclash' occurs

; BC for y/x coordinates
; IX hold sprite data
; DE for screen address
; H as line draw loop (8)


org 33000

; B = Y pixel, C = X pixel
ld b, 40
ld c, 80

main
    ld ix, sprite_data
    call draw_udg
    call get_attr_address ; from y/x coordinates
	ld a, %11001011 ; now we color
	ld (de), a

jp main

    ret

; Draw 8x8 UDG using Get_Pixel_Address
draw_udg
    ld h, 8
draw_loop
    push bc
    push hl
    call Get_Pixel_Address
    ld a, (ix+0)
    ld (de), a
    inc ix
    pop hl
    pop bc
    inc b
    dec h
    jp nz, draw_loop
    ret

; Color the same 8x8 block with attribute
get_attr_address
; attr address = 22528 + (INT(Y / 8) × 32) + INT(X / 8) 

ld h, 0 	; clear H
ld a, b
sub 8		; back to original y (B)
ld b, a
ld a, b
rra
rra
rra
ld l, a
add hl, hl
add hl, hl
add hl, hl
add hl, hl
add hl, hl
ld DE, 22528
add HL, DE
ex DE, HL
ld h, 0
ld l, 0
ld a, c
rra
rra
rra
ld l, a
add HL, DE
ex DE, HL
ret   
 

; Get_Pixel_Address: B=Y, C=X › DE=screen address
Get_Pixel_Address:
    ld a, b
    and %00000111
    or %01000000
    ld d, a
    ld a, b
    rra
    rra
    rra
    and %00011000
    or d
    ld d, a
    ld a, b
    rla
    rla
    and %11100000
    ld e, a
    ld a, c
    rra
    rra
    rra
    and %00011111
    or e
    ld e, a
    ret

sprite_data:
    defb %11000011 
    defb %10000001 
    defb %00000000 
    defb %00011000 
    defb %00011000 
    defb %00000000 
    defb %10000001
    defb %11000011    
