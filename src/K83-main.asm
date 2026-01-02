    list b=4,n=0   ; declare processor, tabs, and lines/page

;**********************************************************************
;   Copyright (C) 2005-2016 Dwayne Forsyth
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
;
;   This is a merger of a number of Blinkie programs I created for different
;   www.2DKits.com boards using the newer PIC chips. This code does NOT
;   support the older 12F683, 16F688 and 16F886 2DKits chips.
;
;   Ported at MPLAB X IDE
;
;   The newer chips have enough enhancements and keeping backward compatibility
;   for is not worth the effort. The new chips are better, faster, and cheaper.
;   
;   Dwayne Forsyth wrote the original code, Dwayne pulled a number of updates,
;   code cleanup, and patterns from Dave Holle.
;                                                                     
;**********************************************************************
;                                                                     
;    Filename:      generic_2011.asm                                         
;    Date:         2011 (conaints code developed from 2004 onward.                                
;                                                         
;    Author:  Dwayne Forsyth
;    email:   Dwayne@2DKits.com                                         
;    Company: www.2DKits.com
;             502 Rue Orleanais
;             Deer Park, IL 60010    
;
;    Help from: Dave Holle <dav@serve-o-matic.com>                        
;                                                                      
;**********************************************************************

;    errorlevel  -302                ; suppress banking messages

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The labels following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.
; this SIM_DEBUG disables the buttons and IR inputs so the code will run the
; patterns.

;#define SIM_DEBUG

;*********************************
; K23 xtree
;*********************************

#define PATTERN6
#define PATTERN7
#define PATTERN8
#define PATTERN12
#define FLIPBYTE
#define RANDOM
#define DISPLAY_1BIT_D
#define NEWEEPROM
#include <P16F18313.inc>       ; processor specific variable definitions
; LIST P=P16F18313
NUM_TAB     equ d'21'   ;highest pattern table number
STROBE_LINES equ 0x05
DELAYTIMER equ 0x3A
MAX_IN_STORE equ d'3'

 __CONFIG _CONFIG1,  _FEXTOSC_OFF & _RSTOSC_HFINT32 & _CLKOUTEN_OFF 
 __CONFIG _CONFIG2,  _MCLRE_OFF & _WDTE_OFF & _STVREN_ON & _BOREN_OFF & _BORV_LOW
 __config _CONFIG3, _LVP_OFF


;**********************************************************************
; Macros
;**********************************************************************

mem = 20
mem2 = 0x7F
mem3 = 0xa0
#include macros.asm

    var button
    var command
    var out_pattern
    var IR_in_good
    var address
    var scount
    var IR_lhalf
    var instate
    var max_instate
    var toggle

;**********************************************************************
    ORG     0x000           ; processor reset vector
;**********************************************************************
    pagesel     main
    goto        main            ; go to beginning of program

;**********************************************************************
    ORG     0x004           ; interrupt vector location
;**********************************************************************

#include interupt.asm


#define DEBOUNCE 0x10

#include strobe_starry.asm

;--------------------------------------------------------------------------------------
read_button_in   ; 5 cycles
;--------------------------------------------------------------------------------------
; Portability : hardcoded button port
;
    clrf        button
    banksel     PORTA
    btfss       PORTA,3          ; 2 
    bsf         button,1         ; 3
    return                        

#include support.asm

;**********************************************************************
display_pattern_id
;**********************************************************************
;   banksel      WPUA
;   clrf         WPUA
;   bsf          WPUA,3

    banksel      pattern
    incf         pattern,w      ; W = pattern + 1
    
    call         flipbyte
    movwf        in1

    clrf         in0
    clrf         in2
    movlw        b'11000000'
    btfsc        demo_mode,0
    movwf        in2 
    
    movlw        0xff
    call         display_1bit
    movlw        0xff
    call         display_1bit
    movlw        0xff
    call         display_1bit
    movlw        0xff
    call         display_1bit

    

    return

#define INDF INDF0
FSR EQU FSR0L
#include "pattern_engine.asm"
#include "pattern_06.asm"
#include "pattern_07.asm"
#include "pattern_08.asm"
#include "pattern_12.asm"
;#include "flipbyte.asm"
;#include "ransom.asm"
#include "display_1bit_starry.asm"
;#include "display_2bit_c.asm"

;
; M A I N
;
;**********************************************************************
main
;**********************************************************************
    clrf        PORTA
    clrf        TMR0 
    clrf        pattern
    movlw       0x00   ;
    movwf       pattern
    clrf        scount
    clrf        toggle
    clrf        address
    clrf        command
    clrf        IR_lhalf
    clrf        instate
    clrf        max_instate
    clrf        IR_in_good
    clrf        dcycle
    movlw       0x04
    movwf       dcycle
    clrf        count1
    clrf        count2
    clrf        button
#ifdef PATTERN2
    clrf         delay1
    clrf         fad
    clrf         color
#endif


#define OSCCON OSCCON1
#define ANSEL ANSELA
#define T0IE TMR0IE
 
    BANKSEL OSCFRQ
    movlw  b'00000100'    ; 8 MHz clock
    movwf  OSCFRQ   

    BANKSEL  T0CON0    
; set up TMR0
;             +---------- TMR0 enable
;             |+--------- unused
;             ||+-------- TMR0 bit out
;             |||+------- TMR0  8/16 bit (0 = 8 bit ) 
;             ||||++++--- postscal set to 1 (0000)
;             |||||||| 
    movlw   b'10000000'
    movwf   T0CON0

    BANKSEL  T0CON1
;             +++-------- TMR0 source = internal clock (010) Fosc/4
;             |||+------- TMR0 sync
;             ||||++++--- prescaler set to 4X (0010)
;             |||||||| 
    movlw   b'01000010'
    movwf   T0CON1  
    
   BANKSEL ANSELA
   clrf    ANSELA
    
   BANKSEL TRISA
    movlw   b'00001000'
    movwf   TRISA   ; A3 Input

    BANKSEL      WPUA
    clrf         WPUA       ; disable all pullups:
    bsf          WPUA,3     ; enable pullup A3

    BANKSEL     button 
    clrf        button

#ifdef RANDOM
    movlw       0x1D
    movwf       random
#endif

;   enable timer0 interupt

    bsf     INTCON, PEIE
    BANKSEL PIE0
    bsf     PIE0,TMR0IE

    BANKSEL INTCON
    bsf     INTCON,GIE

;  flash all LEDs on     This kills some time, allowing us to sample the button and IR-Rxl
    
    movlw   b'11111111'
    movwf   in0
    movwf   in1
    movwf   in2
;    movwf   in3
;    movwf   in4
;    movwf   in5

    pagesel display_1bit
    movlw   0xff            ; allways flash once
    call    display_1bit
    movlw   0xff
    call    display_1bit

; Turn all the LEDs off
    BANKSEL in0
    clrf   in0
    clrf   in1
    clrf   in2
;    clrf   in3
;    clrf   in4
;    clrf   in5

    movlw   0xff
    call    display_1bit
    movlw   0xff
    call    display_1bit
    movlw   0xff
    call    display_1bit

    #ifndef NOEEPROM
    call read_demo_mode
    #endif

    btfss       button,1     
    call        toggle_demo     
    goto        pattern_driver


;**********************************************************************
MasterTable
;**********************************************************************
    make_mtab NUM_TAB

    
; These are the pattern tables
#include <patterns_starry.asm>


   end
