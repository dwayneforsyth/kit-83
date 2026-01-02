;**********************************************************************
;   Copyright (C) 2005,2006,2007 Dwayne Forsyth
;                                 
;   This program is free software; you can redistribute it and/or
;   modify it under the terms of the GNU General Public License
;   as published by the Free Software Foundation; either version 2
;   of the License, or (at your option) any later version.
; 
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to the
; 
;      Free Software Foundation, Inc.
;      51 Franklin Street, Fifth Floor
;      Boston, MA  02110-1301, USA.
;
;**********************************************************************

;**********************************************************************
table_type_7
;**********************************************************************
;
;  1 bytes
;
;  ABBCCCCC
;
;  A = shire Right/Left
;  BB = two bit intensity to shift on
;  CCCCC = Number of shifts to loop
;
;  if CCCCC = 0x11111, specical case: turn all LEDs off.
;

    var t7count

    call         get_next_pattern_entry
    movwf        in0

    movlw        b'00011111'
    andwf        in0,w
    movwf        t7count

    movlw        b'00011111'  ; if shiftcount is 31, then clear all LEDs
    subwf        t7count,w
    btfss        STATUS,Z
    goto         t7_loop
    
    clrf         in0           ; quick way to clear all the LEDS.
    clrf         in1
    clrf         in2
    call         display_1bit
    goto         t7_return


t7_loop
    btfsc        in0,7
    goto         t7_set19
;
;   set LED 1


	movfw		 A5_A1_reg        ; 16 -> 17
	movwf		 A1_A0_reg

	movfw	 	 A2_A0_reg        ; 15 -> 16
	movwf		 A5_A1_reg

	movfw		 A1_A2_reg        ; 14 -> 15
	movwf	 	 A2_A0_reg

	movfw		 A2_A1_reg        ; 13 -> 14
	movwf		 A1_A2_reg 

	movfw	 	 A2_A5_reg        ; 12 -> 13
	movwf		 A2_A1_reg

	movfw		 A0_A4_reg        ; 11 -> 12
	movwf	 	 A2_A5_reg

	movfw		 A1_A5_reg        ; 10 -> 11
	movwf		 A0_A4_reg

	movfw	 	 A4_A1_reg        ; 09 -> 10
	movwf		 A1_A5_reg 

        movfw		 A0_A5_reg        ; 08 -> 09
	movwf	 	 A4_A1_reg

	movfw		 A5_A4_reg        ; 07 -> 08
        movwf		 A0_A5_reg

	movfw	 	 A1_A4_reg        ; 06 -> 07
	movwf		 A5_A4_reg 

	movfw		 A2_A4_reg        ; 05 -> 06
	movwf	 	 A1_A4_reg

	movfw		 A5_A0_reg        ; 04 -> 05
	movwf		 A2_A4_reg

	movfw		 A5_A2_reg        ; 03 -> 04
	movwf		 A5_A0_reg 

	movfw		 A4_A0_reg        ; 02 -> 03
	movwf		 A5_A2_reg

	movfw		 A0_A2_reg        ; 01 -> 02
	movwf		 A4_A0_reg

	movfw		 A4_A2_reg        ; 00 -> 01
	movwf		 A0_A2_reg

	clrf		 A4_A2_reg        ; new -> 00
        movlw            BRIGHT1
        btfsc            in0,5
        addwf            A4_A2_reg,f
        movlw            BRIGHT2
        btfsc            in0,6
        addwf            A4_A2_reg,f

        goto         t7_cont
;
;   set LED 19
t7_set19
	movfw		 A0_A2_reg        ; 01 -> 00
	movwf		 A4_A2_reg

	movfw		 A4_A0_reg        ; 02 -> 01
	movwf		 A0_A2_reg

	movfw		 A5_A2_reg        ; 03 -> 02
	movwf		 A4_A0_reg

	movfw		 A5_A0_reg        ; 04 -> 03
    movwf		 A5_A2_reg

	movfw		 A2_A4_reg        ; 05 -> 04
	movwf		 A5_A0_reg

	movfw	 	 A1_A4_reg        ; 06 -> 05
	movwf		 A2_A4_reg 

	movfw		 A5_A4_reg        ; 07 -> 06
	movwf	 	 A1_A4_reg

    movfw		 A0_A5_reg        ; 08 -> 07
	movwf		 A5_A4_reg 

	movfw	 	 A4_A1_reg        ; 09 -> 08
    movwf		 A0_A5_reg

	movfw		 A1_A5_reg        ; 10 -> 09
	movwf	 	 A4_A1_reg

	movfw		 A0_A4_reg        ; 11 -> 10
	movwf		 A1_A5_reg

	movfw	 	 A2_A5_reg        ; 12 -> 11
	movwf		 A0_A4_reg

	movfw		 A2_A1_reg        ; 13 -> 12
	movwf	 	 A2_A5_reg

	movfw		 A1_A2_reg        ; 14 -> 13
	movwf		 A2_A1_reg

	movfw	 	 A2_A0_reg        ; 15 -> 14
	movwf		 A1_A2_reg

	movfw		 A5_A1_reg        ; 16 -> 15
	movwf	 	 A2_A0_reg

	movfw		 A1_A0_reg        ; 17 -> 16
	movwf		 A5_A1_reg

	clrf		 A1_A0_reg
        movlw            BRIGHT1
        btfsc            in0,5
        addwf            A1_A0_reg,f
        movlw            BRIGHT2
        btfsc            in0,6
        addwf            A1_A0_reg,f

t7_cont

    movf         pspeed,w
    call         strobe_delay
;
;   This is a quick hack, because without this button presses are not seen for minutes
;   This early exit might impact the pattern getting displayed.
;
    btfsc        button,0    ; if putton pressed show pattern id
    goto         t7_return

    btfsc        IR_in_good,0
    goto         t7_return

    decfsz       t7count,f
    goto         t7_loop

t7_return
    return

