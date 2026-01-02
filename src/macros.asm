;**********************************************************************
; Macros
;**********************************************************************

var macro name
name equ  mem
mem = mem + 1
   if (mem >= mem2)
      error 'Too much var space used'
   endif
   endm

dupvar macro name, name2
name equ name2
   endm

var_all_bank macro name
name equ  mem2
mem2 = mem2 - 1
   if (mem >= mem2)
      error 'Too much var space used'
   endm

mem3 = 0xa0
var_bank2 macro name
name equ  mem3
mem3 = mem3 + 1
   if (mem3 >= 0xef)
      error 'Too much var space used'
   endm

patternc = 0
start_pattern macro typem, delaym

table#v(patternc)
    if (typem == 1) || (typem == 6) || (typem == 0x15) || (typem == 0x1c)|| (typem == 0x1d)||(typem == 0x01e)||(typem == 0x026)|| (typem == 0x28) || (typem == 0x2A)
leng = (endpat#v(patternc)-$-3)/3   ;tbltype1,speed,length
    else
    if (typem == 3) || (typem == 0x0b) || (typem == 0x10) || (typem == 0x13) || (typem == 0x14)|| (typem == 0x18) || (typem == 0x22)
leng = (endpat#v(patternc)-$-3)/2   ;tbltype1,speed,length
    else
    if (typem == 9) || (typem == 0x0e)
leng =(endpat#v(patternc)-$-3)/5   ;tbltype1,speed,length
    else
    if (typem == 0x29)
leng =(endpat#v(patternc)-$-3)/8   ;tbltype1,speed,length
    else
    if (typem == 0x0a)||(typem == 0x27)
leng =(endpat#v(patternc)-$-3)/4   ;tbltype1,speed,length
    else
    if (typem == 0x0d) || (typem == 0x21)
leng =(endpat#v(patternc)-$-3)/(9+1)   ;tbltype1,speed,length
    else
    if (typem == 0x0f) || (typem == 0x12)|| (typem == 0x17)||(typem == 0x1b)
leng =(endpat#v(patternc)-$-3)/(6)   ;tbltype1,speed,length
    else
    if (typem == 0x11)
leng = (endpat#v(patternc)-$-3)/(9+4)   ;tbltype1,speed,length
    else
    if (typem == 0x16) || (typem == 0x1a)
leng = (endpat#v(patternc)-$-3)/0x20   ;tbltype1,speed,length
    else    
    if (typem == 0x1f) 
leng = (endpat#v(patternc)-$-3)/0x18   ;tbltype1,speed,length
    else    
    if (typem == 0x20) 
leng = (endpat#v(patternc)-$-3)/0x19   ;tbltype1,speed,length
    else    
leng =(endpat#v(patternc)-$-3)
    endif
    endif
    endif
    endif
    endif
    endif
    endif
    endif
    endif
    endif
    endif
    expand
;    if ($ < 0x2100)
;    dt typem,delaym,(leng)
;    else
    de typem,delaym,(leng)
;    endif
   endm

storedata macro stuff
    if ($ < 0x2100)
    dt stuff
    else
    de stuff
    endif
   endm

end_pattern macro
endpat#v(patternc)
patternc = patternc + 1
   endm

mult_nop macro nup_count
  local i = nup_count
  while i > 3
    call    Lcontinue   ;4 cycles
i -= 4
  endw
  while i > 1
    goto    $+1         ;2 cycles
i -= 2
  endw
  if i > 0
    nop                 ;1 cycle
  endif
    endm

LedOut macro word,reg_dir,port
    movfw   TMR0
	subwf   word,w
	btfss   STATUS,C    
    bsf     reg_dir, port
   endm

LedOutInd macro word,reg_dir,port
    movlw   low word
    movwf   FSR0L         ; set indirect pointer to word
    movlw   high word
    movwf   FSR0H         ; set indirect pointer to word
    movfw   TMR0
	subwf   INDF0,w      
	btfss   STATUS,C    
    bsf     reg_dir, port
   endm

; Indirect Paged
LedOutIndP macro page,word,reg_dir,port
    if (page == 0)
      bcf   STATUS,IRP
    else
      bsf   STATUS,IRP
    endif
    movlw   (word & 0xff)
    movwf   FSR         ; set indirect pointer to word
    movfw   TMR0
	subwf   INDF,w      
	btfss   STATUS,C    
    bsf     reg_dir, port
   endm

LedOutL macro word,reg_dir,port
    swapf   word,w
    movwf   temp4
    movfw   TMR0
	subwf   temp4,w
	btfss   STATUS,C    
    bsf     reg_dir, port
   endm

LedOutH macro word,reg_dir,port
    nop
    nop
    movfw   TMR0
	subwf   word,w
	btfss   STATUS,C    
    bsf     reg_dir, port
   endm

state_tbl macro num,zero,one,flag
Lstate#v(num)
#ifndef MULTIBUTTON
    if (flag == 0)
       bcf  button,0                         
       movlw  0x30
       movwf  butcount
    endif 
    if (flag == 1)
       bsf  button,0
    endif
#endif
    btfsc        IR_in,0
    goto         Lstate#v(num)a

    movlw        zero
    movwf        instate

    goto         Lcontinue
      
Lstate#v(num)a
    movlw        one
    movwf        instate

    goto         Lcontinue    
    endm

state2_tbl macro num, name, offset
Lstate#v(num)
;   save the 1st half of word
    movf         IR_in,w    ; save 1st half
    movwf        IR_lhalf
    incf         instate,f

    goto         Lcontinue
      
Lstate#v(num+1)
;   save the 2nd half of word
;   check for protocal error should get 01 or 10
    movf         IR_lhalf,w
    xorwf        IR_in,w
    btfss        STATUS,Z
    goto         Lstate#v(num+1)a
    clrf         instate    ; error state = zero
 
    goto         Lcontinue

;   set the correct bit in output vars.
Lstate#v(num+1)a
    btfsc        IR_in,0
    bcf          name,offset
    btfss        IR_in,0
    bsf          name,offset

    incf         instate,f    
    goto         Lcontinue
    endm

entry macro a0,a1,a2
    dt      a0,a1,a2
    endm

tbltype1 macro speed,length
  if (length > 2) & (length < d'256')
    dt      0x01,speed,length
  else
    error   'pattern length must be > 2 and < 256'
  endif
    endm

make_mtab macro numtab
  local i = 0
  while i <= numtab
    dt      HIGH table#v(i), LOW table#v(i) 
i += 1
  endw
  endm

make_state_jump_table macro max_state
  local i = 0
  while i <= max_state
    goto    Lstate#v(i)
i += 1
  endw
  endm

