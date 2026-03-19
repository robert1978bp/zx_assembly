; ZX Spectrum Line Drawing - Full Code
; Uses recursive divide-and-conquer method
; Call with: DE = (x1,y1), HL = (x2,y2) defined in 'start' section

        org 32768           ; Load at 32768

start:
        ld de, 10 + (20 << 8)   ; Point 1: (10,20)
        ld hl, 100 + (80 << 8)  ; Point 2: (100,80)
        call DRAW
        ret

; ---------------------------
; DRAW: Recursive line routine
; Input: DE = end1 (x,y), HL = end2 (x,y)
DRAW:
        call PLOT           ; Plot midpoint
        push hl             ; Save end2

        ; Calculate HL = midpoint
        ld a, l             ; HL = y2
        add a, e            ; + y1
        rra                 ; /2
        ld l, a
        ld a, h             ; HL = x2
        add a, d            ; + x1
        rra                 ; /2
        ld h, a

        ; If DE == HL (midpoint), we're done
        or a
        sbc hl, de
        jr z, exit
        add hl, de          ; Restore HL

        ex de, hl
        call DRAW           ; Draw from centre to end1
        ex (sp), hl         ; Swap stack with end2
        ex de, hl
        call DRAW           ; Draw from end2 to centre
        ex de, hl
        pop de
        ret

exit:
        pop hl
        ret

; ---------------------------
; PLOT: Plot pixel at D=x, E=y
; Sets bit in screen memory
PLOT:
        push hl
        ld a, d             ; X coord
        and 7
        ld b, a
        inc b               ; B = bit position + 1
        ld a, e             ; Y coord
        rra
        scf
        rra
        or a
        rra                 ; A = character row * 8
        ld l, a
        xor e
        and 248
        xor e               ; L = screen line offset
        ld h, a
        ld a, l
        xor d
        and 7
        xor d               ; H = screen block
        rrca
        rrca
        rrca
        ld l, a
        ld a, 1
plotbit:
        rrca
        djnz plotbit        ; A = bit mask
        or (hl)
        ld (hl), a
        pop hl
        ret   
