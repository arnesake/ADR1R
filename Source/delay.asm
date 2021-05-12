;-------------------------------------------------------------------------------
; Project: JoyTest.zdsp
; Main File: delay.asm  - rotinas de temporizacao
; Date: 26/04/2021 10:47:37
;
; Desenvolvido por: Eng. Marcio Jose Soares
;
; Plataforma de testes: MSX Hotbit HB8000 1.1 / MSX Panasonic FS-A1WSX 2.0+
;
; Created with zDevStudio - Z80 Development Studio.
;
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 1us
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; NOP consome 4 ciclos; -> 4 x 0,280us = 1.132us;
;
_1us:           nop                     ;nao faz nada, apenas consome tempo
                ret

;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 5us
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; NOP consome 4 ciclos -> 5 x (4x 0,280us) = 5.6us;
;
_5us:           nop                     ;nao faz nada, apenas consome tempo
                nop
                nop
                nop
                nop
                ret

;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 10us
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; NOP consome 4 ciclos -> 9 x (4x 0,280us) = 5.6us;
;
_10us:          nop                     ;nao faz nada, apenas consome tempo
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                ret

;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 50us
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; DEC consome 4 ciclos
; JRNZ consome 12 ciclos
; DEC + JRNZ consomente juntos 16 ciclos
;
; 11 x 16 x 0,280us ~= 49,28us (DEC L + JR NZ loop50us)
;
_50us:          ld      h,0BH           ;carrega H com 11
loop50us:       dec     h               ;decrementa H
                jr      nz,loop50us     ;continua ate ser zero
                ret

;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 250us 1/4ms
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; DEC consome 4 ciclos
; JRNZ consome 12 ciclos
; DEC + JRNZ consomente juntos 16 ciclos
;
; 50 x 16 x 0,280us ~= 224us (DEC L + JR NZ loop1_1ms)
; 5 x 16 x 0,280us ~= 22,4us (DEC H + JR NZ loop1ms)
;
; (224us + 22,4us) x 1 = 246,8us
;
_250us:         ld      h,01H           ;carrega H com 1
loop250us:      ld      l,32H           ;carrega L com 50
loop1_250us:    dec     l               ;decrementa L
                jr      nz,loop1_250us  ;continua ate ser zero
                dec     h               ;decrementa h
                jr      nz,loop250us    ;continua ate H ser zero
                ret                     ;retorna para subrotina de chamada

;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 500us 1/2ms
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; DEC consome 4 ciclos
; JRNZ consome 12 ciclos
; DEC + JRNZ consomente juntos 16 ciclos
;
; 50 x 16 x 0,280us ~= 224us (DEC L + JR NZ loop1_1ms)
; 5 x 16 x 0,280us ~= 22,4us (DEC H + JR NZ loop1ms)
;
; (224us + 22,4us) x 2 = 492,8us
;
_500us:         ld      h,02H           ;carrega H com 2
loop500us:      ld      l,32H           ;carrega L com 50
loop1_500us:    dec     l               ;decrementa L
                jr      nz,loop1_500us  ;continua ate ser zero
                dec     h               ;decrementa h
                jr      nz,loop500us    ;continua ate H ser zero
                ret                     ;retorna para subrotina de chamada

;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 1ms
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; DEC consome 4 ciclos
; JRNZ consome 12 ciclos
; DEC + JRNZ consomente juntos 16 ciclos
;
; 40 x 16 x 0,280us ~= 179,2us (DEC L + JR NZ loop1_1ms)
; 5 x 16 x 0,280us ~= 22,4us (DEC H + JR NZ loop1ms)
;
; (179,2us + 22,4us) x 5 = 1.008ms
;
_1ms:           ld      h,05H           ;carrega H com 5
loop1ms:        ld      l,28H           ;carrega L com 40
loop1_1ms:      dec     l               ;decrementa L
                jr      nz,loop1_1ms    ;continua ate ser zero
                dec     h               ;decrementa h
                jr      nz,loop1ms      ;continua ate H ser zero
                ret                     ;retorna para subrotina de chamada


;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 50ms
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; DEC consome 4 ciclos
; JRNZ consome 12 ciclos
; DEC + JRNZ consomente juntos 16 ciclos
;
; 175 x 16 x 0,280us = 784us (DEC L + JR NZ loop_50ms)
; 50 x 16 x 0,280us = 224us (DEC H + JR NZ loop50ms)
;
; (784us + 224us) x 50 = 50.4ms
;
_50ms:          ld      h,032H          ;carrega H com 50
loop50ms:       ld      l,0AFH          ;carrega L com 175
loop_50ms:      dec     l               ;decrementa L
                jr      nz,loop_50ms    ;continua ate ser zero
                dec     h               ;decrementa h
                jr      nz,loop50ms     ;continua ate H ser zero
                ret                     ;retorna para subrotina de chamada


;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 250ms
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; DEC consome 4 ciclos
; JRNZ consome 12 ciclos
; DEC + JRNZ consomente juntos 16 ciclos
;
; 82 x 16 x 0,280us = 367.36us (DEC L + JR NZ loop2_2500)
; 25 x 16 x 0,280us = 112us (DEC H + JR NZ loop1_2500)
; 5 x 16 x 0,280us = 22,4us (DEC E + JR NZ loop2500)
;
; (739,2us + 224us + 44,8us) x 500 ~= 250,88ms
;
_250ms:         ld      e,05H           ;carregqa e com 05
loop250:        ld      h,019H          ;carrega h com 25
loop1_250:      ld      l,052H          ;carrega l com 82
loop2_250:      dec     l               ;decrementa l
                jr      nz,loop2_250    ;continua ate ser zero
                dec     h               ;decrementa h
                jr      nz,loop1_250    ;recarrega l e faz ate h ser zero
                dec     e               ;decrementa e
                jr      nz,loop250
                ret                     ;retorna para subrotina de chamada


;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente 500ms
;
; T = 1/F => T = 1/3,57MHz => T = 0,280us
; DEC consome 4 ciclos
; JRNZ consome 12 ciclos
; DEC + JRNZ consomente juntos 16 ciclos
;
; 165 x 16 x 0,280us = 739,20us (DEC L + JR NZ loop2_500)
; 50 x 16 x 0,280us = 224us (DEC H + JR NZ loop1_500)
; 10 x 16 x 0,280us = 44,8us (DEC E + JR NZ loop500)
;
; (739,2us + 224us + 44,8us) x 500 ~= 504ms
;
_500ms:         ld      e,0AH           ;carregqa e com 10
loop500:        ld      h,032H          ;carrega h com 50
loop1_500:      ld      l,0A5H          ;carrega l com 165
loop2_500:      dec     l               ;decrementa l
                jr      nz,loop2_500    ;continua ate ser zero
                dec     h               ;decrementa h
                jr      nz,loop1_500    ;recarrega l e faz ate h ser zero
                dec     e               ;decrementa e
                jr      nz,loop500
                ret                     ;retorna para subrotina de chamada

;-------------------------------------------------------------------------------
; Subrotina para aguardar aproximadamente x segundos
; Quantidade de segundos deve ser carregado em b
;
_delaySeg:      call    _500ms          ;aguarda 0,5s aproximadamente
                call    _500ms          ;aguarda + 0,5s
                djnz    _delaySeg       ;decrementa b, se nÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o zero pula
                ret



