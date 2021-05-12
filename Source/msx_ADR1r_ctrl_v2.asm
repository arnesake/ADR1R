;-------------------------------------------------------------------------------
; Project: msx_ADR1r_ctrl_v2.zdsp
; Main File: msx_ADR1r_ctrl_v2.asm
; Date: 17/03/2021 10:10:37
;
; Desenvolvido por: Eng. Marcio Jose Soares
;
; Plataforma de testes: MSX Hotbit HB8000 1.1 / MSX Panasonic FS-A1WSX 2.0+
; Placas extras: Placa Projeto Hardware, placa robo_tx_rf_msx e robo ADR1-R
;
; Proposta: Criar o controle via RF do robo ADR1-R para o MSX!!!
;           usa setas para controle do robo
;           Teclando ESC retorna ao BASIC!
;
; pasmo -d -v --msx msx_ADR1r_ctrl_v2.asm msx_ADR1r_ctrl_v2.bin
; Created with zDevStudio - Z80 Development Studio.
;
;-------------------------------------------------------------------------------
; Ultimas alteracoes na v2 - rs232_t2.asm:
;
; em 16/04/2021:
;       - criado esse programa
;       - inseridas principais funcoes
;
; em 23/04/2021
;       - testada versao 1.6 24/04/2021 no MSX usando LEDs
;       - testada versao 1.6 24/04/2021 no MSX usando comunicacao com robo
;
; em 26/04/2021:
;       - alterada versao para controle segurando botao das setas
;       - alterada versao para capturar o joystick tambem
;       - alterada versao para aceitar selecao entre teclado e joystick
;       - testada nova versao 2.0 26/04/2021 no MSX usando LEDs
;       - testada nova versao 2.0 26/04/2021 no MSX usando comunicacao com robo
;
; a fazer:
;       - arredondar tela?!
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Inclui arquivos
;
include "../MSX_libs/msx1bios.asm"        ;chamadas para BIOS
include "../MSX_libs/msx1variables.asm"   ;variaveis do sistema

;-------------------------------------------------------------------------------
; Declara enderecos das portas do 8255 a serem utilizadas aqui
;
_8255_CFG       equ     003FH           ;endereco para configuracao (apenas escrita)
_8255_OA        equ     003CH           ;endereco para entrada/saida no portA do 8255
_8255_OB        equ     003DH           ;endereco para entrada/saida no portB do 8255
_8255_OC        equ     003EH           ;endereco para entrada/saida no portC do 8255

_HT12E          equ     _8255_OB        ;porta de saida/controle do HT12E

;-------------------------------------------------------------------------------
; Declara constantes
;
CFGBYTE         equ     80H             ;todos ports do 8255 sao saida! modo 0!
CR              equ     0DH             ;ENTER
LF              equ     0AH             ;Line Feed
BS              equ     08H             ;tecla backspace
ESC             equ     1BH             ;tecla ESC
EH1             equ     31H             ;tecla 1
EH2             equ     32H             ;tecla 2

CFGWORD         equ     80H             ;palavra de config para 8255

SOMALIN         equ     01H

LININI          equ     0AH             ;linha/coluna do inicio
COLINI          equ     01H

LINTOP          equ     02H+SOMALIN              ;
COLTOP          equ     01H

LINMENU         equ     04H+SOMALIN     ;linha 5
COLMENU         equ     01H             ;coluna 1

LINSEL          equ     10H     ;linha 10
COLSEL          equ     01H                     ;coluna 5

LINMSG          equ     0EH+SOMALIN+2
COLMSG          equ     02H

LINDBG          equ     LINMSG+02H
COLDBG          equ     02H

LINENV          equ     LINDBG          ;enviando na primeira linha do debug
COLENV          equ     COLDBG+0CH      ;coluna mais o tamanho da msg


LASTPOSCOL      equ     24+4              ;ultima posicao para bytes env/rec

;-------------------------------------------------------------------------------
; Declara constantes globais do protocolo e setas
;
_HEADER         equ     24H             ;header
_UP             equ     01H             ;seta para cima ou FWD
_DOWN           equ     02H             ;seta para baixo ou RWD
_RIGHT          equ     04H             ;seta para direita
_LEFT           equ     08H             ;seta para esquerda
_STOP           equ     00H             ;para robo
_NRRECEIVER     equ     02H             ;nr do receiver

SETAUP          equ     1EH             ;tecla seta para cima
SETADOWN        equ     1FH             ;tecla seta para baixo
SETARIGHT       equ     1CH             ;tecla seta para direita
SETALEFT        equ     1DH             ;tecla seta para esquerda
ESPACO          equ     20H             ;tecla espaco

CURS            equ     00H             ;0 cursores; 1 - porta 1; 2 - porta 2
JOY1            equ     01H             ;
JOY2            equ     02H
SPACE           equ     00H             ;0 - barra espaÃ§o
BTN1            equ     01H             ;1 - botao A no port 1
BTN2            equ     03H             ;3 - botao B no port 1

UP              equ     01H             ;valores devolvidos para CURS
DOWN            equ     05H
RIGHT           equ     03H
LEFT            equ     07H

;-------------------------------------------------------------------------------
; Declara vars
;
                org     0C100H          ;endereco inicial do programa

mydata          db      0
counter         db      0               ;contador
counter2        db      0               ;contador 2

aux             db      0               ;var auxiliar para contar pos de indexchar
aux2            db      0
aux3            db      0

pcolenv         db      0               ;posicao da coluna do enviado

myjoy           db      0
myaux           db      0

;-------------------------------------------------------------------------------
; Funcao main (principal)
;
                ;---------------------------------------------------------------
                ; zera vars
                ;
                ld      a,00H           ;zera a
                ld      hl,mydata       ;pega end da var
                ld      (hl),a          ;zera var

                ld      hl,counter
                ld      (hl),a

                ld      hl,counter2
                ld      (hl),a

                ld      hl,aux
                ld      (hl),a

                ld      hl,aux2
                ld      (hl),a

                ld      hl,myaux
                ld      (hl),a

                ld      hl,pcolenv      ;carrega nas vars posicoes iniciais
                ld      a,COLENV
                ld      (hl),a

                ld      hl,myjoy
                ld      a,CURS
                ld      (hl),a

                ;---------------------------------------------------------------
                ; inicia configuracao do 8255
                ;
                call    cfg8255         ;configura 8255!
                call    _50ms           ;aguarda 50ms

;---------------------------------------------------------------
                ; prepara tela de abertura
                ;
                call    ERAFNK          ;apaga a linha das teclas de funcao
                call    INITXT          ;screen0

                ;jr      lcmain0_00     ;apenas para testes, pula introducao

                ld      a,COLINI        ;coluna 1
                ld      h,a
                ld      a,LININI        ;linha 10
                ld      l,a
                call    POSIT           ;posiciona

                ld      hl,msgini       ;carrega mensagem /inicial
                call    wrmsg           ;escreve mensagem inicial

                ld      b,2
                call    _delaySeg       ;aguarda 2 segundos

lcmain0_00:     ld      a,COLSEL        ;coluna 1
                ld      h,a
                ld      a,LINSEL        ;linha
                ld      l,a
                call    POSIT           ;posiciona

                ld      hl,msgselect    ;insere selecao
                call    wrmsg

lcmain0_01:     call    CHSNS           ;testa buffer do teclado
                jr      z,lcmain0_01    ;se flag z setado, buffer vazio

                call    CHGET           ;pega a tecla - ASCII code
                cp      EH1             ;compara com 1
                jr      z,lctecla1      ;se 1 escolheu teclado

                cp      EH2             ;compara com 1
                jr      z,lctecla2      ;se 2 escolheu joystick

                cp      ESC             ;compara com ESC
                jp      z,lcmainend     ;se eh ESC, aceita sair aqui e fim!

                jr      lcmain0_01      ;tecla invalida, fica ate tecla valida

lctecla1:       ld      hl,myjoy        ;carrega var
                ld      a,CURS          ;carrega opcao teclado
                ld      (hl),a          ;grava opcao escolhida
                jr      lcmain0         ;desvia

lctecla2:       ld      hl,myjoy        ;carrega var
                ld      a,JOY1          ;carrega opcao joystick
                ld      (hl),a          ;grava opcao escolhida

lcmain0:        ;---------------------------------------------------------------
                ; prepara a tela do terminal
                call    CLS             ;apaga a tela

                ld      a,COLTOP        ;carrega linha e coluna para
                ld      h,a             ;mensagem superior
                ld      a,LINTOP
                ld      l,a             ;da tela
                call    POSIT           ;posiciona cursor
                ld      hl,msgtop       ;pega msg a ser inserida no topo
                call    wrmsg           ;escreve msg

                ld      a,COLMENU       ;carrega linha e coluna para
                ld      h,a             ;menu/instrucoes de uso
                ld      a,LINMENU
                ld      l,a             ;da tela
                call    POSIT           ;posiciona cursor

                ld      hl,myjoy        ;carrega myjoy
                ld      a,(hl)
                cp      JOY1            ;compara com joystick
                jr      z,lcmainmsg2    ;escreve menu para opcao escolhida

lcmainmsg1:     ld      hl,msgmenuK
                jr      lcmainwrmsg

lcmainmsg2:     ld      hl,msgmenuJ
lcmainwrmsg:    call    wrmsg

                ld      a,COLDBG        ;carrega linha e coluna com a
                ld      h,a             ;
                ld      a,LINENV
                ld      l,a             ;da tela
                call    POSIT           ;

                ld      hl,msgENV       ;coloca na tela enviando/recebendo
                call    wrmsg

                ld      a,COLMSG        ;carrega linha e coluna com a
                ld      h,a             ;
                ld      a,LINMSG
                ld      l,a             ;da tela
                call    POSIT           ;posiciona na linha 1, coluna 1

                ld      hl, msgSTOP     ;escreve a mensagem sobre movimento
                call    wrmsg
                call    outstop         ;envia STOP

                ;---------------------------------------------------------------
                ; laco principal
                ;

                ;---------------------------------------------------------------
                ; posiciona cursor para proxima mensagem
                ;
lcmain1:        ld      a,COLMSG        ;carrega linha e coluna com a
                ld      h,a             ;
                ld      a,LINMSG
                ld      l,a             ;da tela
                call    POSIT           ;posiciona na linha 1, coluna 1

                ;---------------------------------------------------------------
                ; testa teclado e JoyStick
                ;
lcmain1_1:      ld      hl,myjoy
                ld      a,(hl)          ;testa posicoes do teclado e joystic
                call    GTSTCK          ;inicia teste do joystick

                ld      hl,myaux        ;pega end da var
                ld      (hl),a          ;salva a
                cp      UP              ;testa em a pos UP
                jp      z,sndup         ;avisa condicao

                ld      hl,myaux        ;pega end da var
                ld      a,(hl)          ;carrega a var
                cp      DOWN
                jp      z,snddown       ;avisa condicao

                ld      hl,myaux        ;pega end da var
                ld      a,(hl)          ;carrega a var
                cp      LEFT            ;testa em a pos LEFT
                jp      z,sndleft       ;avisa condicao

                ld      hl,myaux        ;pega end da var
                ld      a,(hl)          ;carrega a var
                cp      RIGHT           ;testa em a pos RIGH
                jp      z,sndright      ;avisa condicao

                ld      hl,myaux         ;prepara para limpar end
                ld      a,00H
                ld      (hl),a
                jp      sndstop         ;avisa condicao
                jr      lcmain1         ;se nao eh tecla valida continua

                ;---------------------------------------------------------------
                ; funcoes de controle das teclas e tambem joystick
                ; eh a mesma coisa aqui!!!
                ;
sndup:          ld      hl, msgFWD      ;escreve a mensagem sobre movimento
                call    wrmsg
                call    outup           ;envia UP
                jr      lcmain1end      ;vai para o fim

snddown:        ld      hl, msgRWD      ;escreve a mensagem sobre movimento
                call    wrmsg
                call    outdown         ;envia DOWN
                jr      lcmain1end      ;vai para o fim

sndleft:        ld      hl, msgLEFT     ;escreve a mensagem sobre movimento
                call    wrmsg
                call    outleft         ;envia LEFT
                jr      lcmain1end      ;vai para o fim

sndright:       ld      hl, msgRIGHT    ;escreve a mensagem sobre movimento
                call    wrmsg
                call    outright        ;envia RIGHT
                jr      lcmain1end      ;vai para o fim

sndstop:        ld      hl, msgSTOP     ;escreve a mensagem sobre movimento
                call    wrmsg
                call    outstop         ;envia STOP

lcmain1end:     call    CHSNS           ;testa buffer do teclado
                jp      z,lcmain1       ;se flag z setado, buffer vazio

                call    CHGET           ;pega a tecla - ASCII code
                cp      ESC             ;compara com ESC
                jr      z,lcmainend     ;se eh ESC, fim!
                jp      lcmain1         ;mantem no laco!

lcmainend:      call    CLS             ;apaga a tela antes de retornar
                ret

;-------------------------------------------------------------------------------
; Subrotinas para controlar o robo
;
                ;---------------------------------------------------------------
                ; envia comando UP - FWD
outup:          call    wr_end          ;escreve o endereco na var
                ld      hl,mydata
                ld      a,(hl)
                ld      b,a             ;carrega a em b momentaneamente
                ld      a,_UP           ;em a UP - comando
                jr      outends

                ;---------------------------------------------------------------
                ; envia comando DOWN - RWD
outdown:        call    wr_end          ;escreve o endereco na var
                ld      hl,mydata
                ld      a,(hl)
                ld      b,a             ;carrega a em b momentaneamente
                ld      a,_DOWN         ;em a DWN - comando
                jr      outends

                ;---------------------------------------------------------------
                ; envia comando LEFT
outleft:        call    wr_end          ;escreve o endereco na var
                ld      hl,mydata
                ld      a,(hl)
                ld      b,a             ;carrega a em b momentaneamente
                ld      a,_LEFT         ;em a LEFT - comando
                jr      outends

                ;---------------------------------------------------------------
                ; envia comando RIGHT
outright:       call    wr_end          ;escreve o endereco na var
                ld      hl,mydata
                ld      a,(hl)
                ld      b,a             ;carrega a em b momentaneamente
                ld      a,_RIGHT        ;em a RIGHT - comando
                jr      outends

                ;---------------------------------------------------------------
                ; envia comando STOP
outstop:        call    wr_end          ;escreve o endereco na var
                ld      hl,mydata
                ld      a,(hl)
                ld      b,a             ;carrega a em b momentaneamente
                ld      a,_STOP        ;em a STOP - comando

                ;---------------------------------------------------------------
                ; fim das subrotinas de envio
outends:        or      b               ;pegou a var e fez um or
                ld      b,a             ;salva novamente
                OUT     (_HT12E),a      ;coloca o valor da var direto no port

                push    bc

                ld      a,COLENV        ;pega coluna
                ld      h,a             ;transfere para h a posicao da coluna
                ld      a,LINENV        ;pega a posicao da linha
                ld      l,a             ;transfere para l
                call    POSIT           ;posiciona cursor

                pop     bc

                ld      a,b             ;restaura em a o seu valor
                ld      de,aux3         ;em de o endereco da var
                ld      (de),a          ;coloca na var o conteudo e chama
                call    bin2hex         ;funcao para enviar para tela
                ld      a,'H'           ;completa valor com H de hexadecimal
                call    CHPUT

                call    _250ms          ;aguarda ate proximo comando

                ret                     ;return

                ;---------------------------------------------------------------
                ; Subrotina apenas para inserir end na var
wr_end:         ld      hl,mydata       ;pega end da var
                ld      a,_NRRECEIVER   ;pega o endereco do robo
                rla                     ;posiciona bits no MSB
                rla
                rla
                rla
                and     0F0H            ;limpa o LSB
                ld      (hl),a          ;carrega var com valor de a
                ret                     ;retorna

;-------------------------------------------------------------------------------
; Subrotina para configurar/limpar a 8255
;
cfg8255:        ld      a,CFGWORD
                out     (_8255_CFG),a   ;envia para 8255 palavra de config
clr8255:        ld      a,00H
                out     (_8255_OA),a    ;zera portas A e B
                out     (_8255_OB),a
                ld      a,01H
                out     (_8255_OC),a    ;mantem 1 na porta C para desab. 74LS154

                ret                     ;retorna

;-------------------------------------------------------------------------------
; inclui arquivos complementares para o modulo
;
include "aux_dep.asm"           ;inclui rotinas auxiliares e outras dependencias
include "delay.asm"            ;inclui rotinas de temporizacao
include "mensagens.asm"

;-------------------------------------------------------------------------------
; Fim do programa
;
stop:
                end


