; point coordinates defined in 'start' section

org 32768

start:
        call 3503           ; Clear screen
        ld de, 10 + (20 << 8) ; (x1,y1)
        ld hl, 100 + (80 << 8) ; (x2,y2)
        call bresenham
        ret

; ---------------------------
; Bresenham Line Algorithm
; Input: DE = (x1,y1), HL = (x2,y2)
bresenham:
        ld a, h
        sub d               ; ?x = x2 - x1
        jr nc, .dxpos
        neg
.dxpos:
        ld b, a             ; B = |?x|
        ld a, l
        sub e               ; ?y = y2 - y1
        jr nc, .dypos
        neg
.dypos:
        ld c, a             ; C = |?y|

        ; Determine step direction
        ld a, d
        cp h
        jr nc, .xdec
        ld a, 1
        jr .xstep_done
.xdec:
        ld a, 255
.xstep_done:
        ld (step_x), a

        ld a, e
        cp l
        jr nc, .ydec
        ld a, 1
        jr .ystep_done
.ydec:
        ld a, 255
.ystep_done:
        ld (step_y), a

        ; Choose X or Y dominant
        ld a, b
        sub c
        jr c, .ydominant

        ; X-dominant
        sra b               ; error = ?x/2
        ld a, b
        sub c               ; error -= ?y
        ld (error), a
        call .xloop
        ret

.ydominant:
        ; Y-dominant
        sra c               ; error = ?y/2
        ld a, c
        sub b               ; error -= ?x
        ld (error), a
        call .yloop
        ret

.xloop:
        call PLOT
        ld a, d
        cp h
        ret z               ; Done
        ld a, (step_x)
        add a, d
        ld d, a
        ld hl, error
        ld a, (hl)
        add a, c            ; error += ?y
        ld (hl), a
        jr c, .xskip
        ld a, (step_y)
        add a, e
        ld e, a
        ld a, (hl)
        sub b               ; error -= ?x
        ld (hl), a
.xskip:
        jp .xloop

.yloop:
        call PLOT
        ld a, e
        cp l
        ret z               ; Done
        ld a, (step_y)
        add a, e
        ld e, a
        ld hl, error
        ld a, (hl)
        add a, b            ; error += ?x
        ld (hl), a
        jr c, .yskip
        ld a, (step_x)
        add a, d
        ld d, a
        ld a, (hl)
        sub c               ; error -= ?y
        ld (hl), a
.yskip:
        jp .yloop

; ---------------------------
; PLOT: Plot pixel at D=x, E=y
PLOT:
        push hl
        ld a, d             ; X
        and 7
        ld b, a
        inc b
        ld a, e             ; Y
        rra
        scf
        rra
        or a
        rra
        ld l, a
        xor e
        and 248
        xor e
        ld h, a
        ld a, l
        xor d
        and 7
        xor d
        rrca
        rrca
        rrca
        ld l, a
        ld a, 1
plotbit:
        rrca
        djnz plotbit
        or (hl)
        ld (hl), a
        pop hl
        ret

; Variables
step_x: defb 0
step_y: defb 0
error:  defw 0   
