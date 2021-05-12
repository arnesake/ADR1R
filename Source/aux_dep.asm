;-------------------------------------------------------------------------------
; Project: JoyTest.zdsp
; Main File: aux_dep.asm  - rotinas auxiliares e debug
; Date: 26/04/2021 10:46:37
;
; Desenvolvido por: Eng. Marcio Jose Soares
;
; Plataforma de testes: MSX Hotbit HB8000 1.1 / MSX Panasonic FS-A1WSX 2.0+
;
; Created with zDevStudio - Z80 Development Studio.
;
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Subrotina para escrever na tela
;
wrmsg:          ld      a,(hl)          ;carrega no acumulador o conteudo
                and     a               ;faz um AND
                ret     z               ;retorna se flag z estiver setado, senao pula
                call    CHPUT           ;chama rotina para escrever char
                inc     hl              ;incrementa HL (ponteiro)
                jr      wrmsg           ;continua ate o final da string

;-------------------------------------------------------------------------------
; Subrotina para imprimir um dado na tela em formato hexadecimal
; Parametros: em DE o endereco do dado a ser convertido!
;
bin2hex:        push    de              ;salva de
                ld      a,(de)          ;pega dado
                and     0F0H            ;separa apenas mais significativo
                rra                     ;gira para colocar MSB no LSB
                rra                     ;sao 4 bits
                rra
                rra
                and     0FH             ;limpa o MSB
                ld      c,a
                ld      b,00H
                ld      hl,_BCD         ;pega endereco do BDC
                add     hl,bc           ;soma o ponteiro
                ld      a,(hl)
                call    CHPUT           ;envia dado

                pop     de              ;restaura
                ld      a,(de)          ;pega dado
                and     0FH             ;separa apenas menos significativo
                ld      c,a
                ld      b,00H
                ld      hl,_BCD         ;pega endereco do BDC
                add     hl,bc           ;soma o ponteiro
                ld      a,(hl)
                call    CHPUT           ;envia dado

                ret                     ;retorna

;-------------------------------------------------------------------------------
; Outras constantes do modulo
;
_BCD            db  30H, 31H, 32H, 33H, 34H, 35H, 36H, 37H
                db  38H, 39H, 41H, 42H, 43H, 44H, 45H, 46H
