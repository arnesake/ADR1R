;-------------------------------------------------------------------------------
; Project: msx_ADR1r_ctrl.zdsp
; File: mensagens.asm
; Date: 17/03/2021 10:27:00
;
; Created with zDevStudio - Z80 Development Studio.
;
; Mensagens incluidas no modulo!
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;Mensagem inicial
;
msgini:         db      '     MSX TX ADR1 v2.0 by Arne        ',CR,LF
                db      '   CONTROLE DO ROBO ADR1-R VIA MSX   ',CR,LF
                db      '  REQUER PLACA PROJ HARDWARE by Arne ',CR,LF
                db      ' Desenv. com compilador PASMO v0.5.3 ',CR,LF,0

;-------------------------------------------------------------------------------
;Mensagem tela term - parte superior
;
msgtop:         db      ' MSX TX ADR1 by Arne - v2.0 26/04/2021',CR,LF,0

;-------------------------------------------------------------------------------
;Mensagem para ajuda
;
msgmenuK:       db      ' Controle via teclado           ',CR,LF
                db      '                                ',CR,LF
                db      ' Seta para cima     - FWD       ',CR,LF
                db      ' Seta para baixo    - RWD       ',CR,LF
                db      ' Seta para esquerda - LEFT      ',CR,LF
                db      ' Seta para direita  - RIGHT     ',CR,LF
                db      '                                ',CR,LF
                db      '                                ',CR,LF
                db      ' ESC sai                        ',CR,LF,0

msgmenuJ:       db      ' Controle via JoyStick          ',CR,LF
                db      '                                ',CR,LF
                db      ' JoyStick UP     - FWD          ',CR,LF
                db      ' JoyStick DOWN   - RWD          ',CR,LF
                db      ' JoyStick LEFT   - LEFT         ',CR,LF
                db      ' JoyStick RIGHT  - RIGHT        ',CR,LF
                db      '                                ',CR,LF
                db      '                                ',CR,LF
                db      ' ESC sai                        ',CR,LF,0

msgCRLF:        db      CR, LF,0

msgselect       db      '     1 - controle via teclado  ',CR,LF
                db      '     2 - controle via joystick ',CR,LF
                db      '                               ',CR,LF
                db      '     Escolha sua opcao         ',CR,LF,0
;-------------------------------------------------------------------------------
;Mensagens para mostrar detino do robo na tela
;
msgFWD:         db      'Movendo robo para frente....',0

msgRWD:         db      'Movendo robo para tras......',0

msgRIGHT:       db      'Movendo robo para direita...',0

msgLEFT:        db      'Movendo robo para esquerda..',0

msgSTOP:        db      'Robo parado...              ',0

msgENV:         db      'Enviando... ',0

;msgREC:         db      'Recebendo...',0
