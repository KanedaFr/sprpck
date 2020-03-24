***************
* RAW.ASM
* simple body of a Lynx-program
*
* created : 24.04.96
* changed : 13.07.97
****************


Baudrate        set 62500       ; define baudrate for serial.inc

_1000HZ_TIMER   set 7           ; timer#

BRKuser         set 1           ; if defined BRK #x support is enabled
DEBUG		set 1


	include <includes/hardware.inc>
* macros
                include <macros/help.mac>
                include <macros/if_while.mac>
                include <macros/mikey.mac>
                include <macros/suzy.mac>

                include <macros/font.mac>
                include <macros/irq.mac>
                include <macros/debug.mac>
* variables
                include <vardefs/debug.var>
                include <vardefs/help.var>
                include <vardefs/mikey.var>
                include <vardefs/suzy.var>
                include <vardefs/serial.var>
                include <vardefs/font.var>
                include <vardefs/irq.var>
*
* local MACROs
*
                MACRO CLS
                lda \0
                jsr cls
                ENDM

*
* vars only for this program
*

 BEGIN_ZP
 END_ZP

 BEGIN_MEM
                ALIGN 4
screen0         ds SCREEN.LEN
irq_vektoren    ds 16
 END_MEM
                 run  LOMEM                      ; code directly after variables

Start::                                         ; Start-Label needed for reStart
                START_UP                        ; set's system to a known state
                CLEAR_MEM                       ; clear used memory (definded with BEGIN/END_MEM)
                CLEAR_ZP                        ; clear zero-page

                INITMIKEY
                INITSUZY

                INITIRQ irq_vektoren            ; set up interrupt-handler
                INITFONT SMALLFNT,RED,WHITE
                jsr InitComLynx
                INITBRK                         ; if we're using BRK #X, init handler

                SETIRQ 2,VBL                    ; set irq-vector and enable IRQ
//->                SETIRQ 0,HBL


                cli                             ; allow interrupts
                SCRBASE screen0                 ; set screen, single buffering
                CLS #4                          ; clear screen with color #0
                SETRGB pal                      ; set palette

                SET_MINMAX 0,0,160,102          ; screen-dim. for FONT.INC

	LDAY bgSCB
	jsr DrawSprite
 IF 0
	LDAY bg2SCB
	jsr DrawSprite
 ENDIF
loop:
	nop
	bra	loop

VBL::
//->	dec $fda0
                END_IRQ

HBL::
                END_IRQ
****************
bgSCB:
	dc.b SPRCTL0_16_COL|SPRCTL0_BACKGROUND_SHADOW
	dc.b SPRCTL1_DEPTH_SIZE_RELOAD
	dc.b 0
	dc.w 0,bg_data
;;->	dc.w 80,51
	dc.w 0,0
 IF 1
	dc.w $100,$100
	dc.b $01,$23,$45,$67,$89,$ab,$cd,$ef
 ELSE
	dc.w $400,$400
	dc.b $01,$23,$45,$67,$89,$ab,$cd,$ef


bg2SCB:
	dc.b SPRCTL0_16_COL|SPRCTL0_BACKGROUND_SHADOW
	dc.b SPRCTL1_DEPTH_SIZE_RELOAD
	dc.b 0
	dc.w 0,bg2_data
	dc.w 0,20
	dc.w $400,$400
	dc.b $01,$23,$45,$67,$89,$ab,$cd,$ef
 ENDIF
****************
cls::           sta cls_color
                LDAY clsSCB
                jmp DrawSprite

clsSCB          dc.b $c0,$90,$00
                dc.w 0,cls_data
                dc.w 0,0                        ; X,Y
                dc.w 160*$100,102*$100          ; size_x,size_y
cls_color       dc.b $00

cls_data        dc.b 2,$10,0


****************
* INCLUDES
                include <includes/debug.inc>
                include <includes/serial.inc>
                include <includes/font.inc>
                include <includes/irq.inc>
                include <includes/font2.hlp>
                include <includes/hexdez.inc>
                include <includes/draw_spr.inc>

//->pal:
//->	STANDARD_PAL
//->	DP 000,842,AC8,484,E4E,FFF,446,84E,ACE,888,CC6,448,0FF,00F,773,855
	include "../pic/bg24bit.pal"
bg_data:
 IF 0
	ibytes "../pack.spr"
bg2_data:
	ibytes "../pack_old.spr"
 ELSE
	ibytes "../pic/bg24bit.spr"
//->	ibytes "../../BG.spr"
 ENDIF
