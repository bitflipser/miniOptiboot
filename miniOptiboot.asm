; ################################################################################ ;
;                                                                                  ;
; miniOptiboot - bootloader for ATmega88/168                                       ;
;               (https://github.com/bitflipser/miniOptiboot)                       ;
;                                                                                  ;
; by bitflipser, 2018                                                              ;
;                                                                                  ;
; based on Optiboot (https://github.com/Optiboot/optiboot)                         ;
;                                                                                  ;
;  "Although it has evolved considerably, Optiboot builds on the original work     ;
;   of Jason P. Kyle (stk500boot.c), Arduino group (bootloader),                   ;
;   Spiff (1K bootloader), AVR-Libc group and Ladyada (Adaboot).                   ;
;                                                                                  ;
;   Optiboot is the work of Peter Knight (aka Cathedrow). Despite some             ;
;   misattributions, it is not sponsored or supported by any organisation          ;
;   or company including Tinker London, Tinker.it! and Arduino.                    ;
;   Maintenance of optiboot was taken over by Bill Westfield (aka WestfW) in 2011.";
;                                                                                  ;
; fits into 128 words of FLASH                                                     ;
;                                                                                  ;
; MIT License                                                                      ;
;                                                                                  ;
; Copyright (c) 2018 bitflipser                                                    ;
;                                                                                  ;
; Permission is hereby granted, free of charge, to any person obtaining a copy     ;
; of this software and associated documentation files (the "Software"), to deal    ;
; in the Software without restriction, including without limitation the rights     ;
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell        ;
; copies of the Software, and to permit persons to whom the Software is            ;
; furnished to do so, subject to the following conditions:                         ;
;                                                                                  ;
; The above copyright notice and this permission notice shall be included in all   ;
; copies or substantial portions of the Software.                                  ;
;                                                                                  ;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR       ;
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,         ;
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE      ;
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER           ;
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,    ;
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE    ;
; SOFTWARE.                                                                        ;
;                                                                                  ;
; ################################################################################ ;

; 1 - ###############7
;     select MCU type

;.equ ATmega =168		; needs 1 more word
.equ ATmega = 88

; 2 - ###################
;     select MCU sub type

.equ subType=0			; (no) and V
;.equ subType=1			; A
;.equ subType=2			; P and PV
;.equ subType=3			; PA
;.equ subType=4			; PB

; 3 - ################
;     select frequency

;.equ F_CPU=20			; ATmega at 20 MHz
;.equ F_CPU=16			; ATmega at 16 MHz
;.equ F_CPU=10			; ATmega at 10 MHz
.equ F_CPU= 8			; ATmega at  8 MHz
;.equ F_CPU= 1			; ATmega at  1 MHz 

; 4 - ##############################################
;     select standard or high-speed USART connection

;.equ USARTspeed=0			; standard baud rates 
.equ USARTspeed=1			; increased USART speed: more accurate and faster

; 5 - ########################
;     select Watchdog Time Out

;.equ WDtimeOut = 0x0c		; 250 ms
;.equ WDtimeOut = 0x0d		; 500 ms
.equ WDtimeOut = 0x0e		;   1 s
;.equ WDtimeOut = 0x0f		;   2 s
;.equ WDtimeOut = 0x28		;   4 s
;.equ WDtimeOut = 0x29		;   8 s

; 6 - ##################
;     memsaving specials

.equ allPARAM_0x14 = 1		; save 1 word: reply all params '0x14' (instead of Optiboot's 0x03)
;.equ noSW_MINOR_Major =1	; save 1 word: by NOT placing SW_MAJOR, SW_MINOR at FLASHEND (Optiboot convention)
;.equ allFUSE_LOCK_0x14=1	; save 1 word: all these replies 0x14 (instead of 0x00)
;.equ overrideSIGNATURE=1	; save 3 word: return SIGNATURE '0x14 0x14 0x14' 
							;             (run avrdude with '-u -F' options or modify 'avrdude.conf')

; 7 - ################
;     check baud rates		; Baud = 0x0000 saves 2 word, doubleSpeed = 0 saves 1 word

.if F_CPU == 20
	.if USARTspeed == 0
		; standard baud rates 							 Error
		.set Baud = 0x000a				;  115.200 baud: -1,4%
		.set doubleSpeed = 0
	.elif USARTspeed == 1
		; high-speed baud rates
		.set Baud = 0x0004				;  250.000 baud:  0,0%
		;.set Baud = 0x0000				;1.250.000 baud:  0,0%
		.set doubleSpeed = 0
	.endif
.endif

.if F_CPU == 16
	.if USARTspeed == 0
		; standard baud rates 							 Error

		.set Baud = 0x0010				;   57.600 baud:  2,1%
		.set doubleSpeed = 0
		/*
		.set Baud = 0x0010				;  115.200 baud:  2,1%
		.set doubleSpeed = 1
		*/
	.elif USARTspeed == 1
		; high-speed baud rates
		;.set Baud = 0x0003				;  250.000 baud:  0,0%
		;.set Baud = 0x0001				;  500.000 baud:  0,0%
		.set Baud = 0x0000				;1.000.000 baud:  0,0%
		.set doubleSpeed = 0
	.endif
.endif

.if F_CPU == 10
	.if USARTspeed == 0
		; standard baud rates 							 Error
		
		.set Baud = 0x000a				;   57.600 baud: -1,4%
		.set doubleSpeed = 0		
		/*
		.set Baud = 0x000a				;  115.200 baud: -1,4% 
		.set doubleSpeed = 1
		*/
	.elif USARTspeed == 1
		; high-speed baud rates
		
		.set Baud = 0x0004				;  125.000 baud:  0,0%
		.set doubleSpeed = 0
		/*
		.set Baud = 0x0004				;  250.000 baud:  0,0%
		.set doubleSpeed = 1
		*/
	.endif
.endif

.if F_CPU == 8
	.if USARTspeed == 0
		; standard baud rates 							 Error

		.set Baud = 0x000c				;   38.400 baud:  0,2%
		.set doubleSpeed = 0
		/*
		.set Baud = 0x0010				;   57.600 baud: -0,8%
		.set doubleSpeed = 1
		*/
	.elif USARTspeed == 1
		; high-speed baud rates
		;.set Baud = 0x0001				;  250.000 baud:  0,0%
		.set Baud = 0x0000				;  500.000 baud:  0,0%
		.set doubleSpeed = 0
	.endif
.endif

.if F_CPU == 1
	.if USARTspeed == 0
		; standard baud rates 							 Error

		.set Baud = 0x000c				;    4.800 baud:  0,2%
		;.set Baud = 0x0000				;   57.600 baud:  8,5%(not recommended)
		.set doubleSpeed = 0
		/*
		.set Baud = 0x000c				;    9.600 baud: -0,8%
		.set doubleSpeed = 1
		*/
	.elif USARTspeed == 1
		; high-speed baud rates
		.set Baud = 0x0000				;  125.000 baud:  0,0%
		.set doubleSpeed = 1
	.endif
.endif

.equ SW_MAJOR = 207
.equ SW_MINOR = 0

.equ SIG_1=0x1e

.if ATmega == 168
 .NOLIST
 .include "m168def.inc"
 .LIST
 .equ SIG_2=0x94
 .if subType == 0
	.equ SIG_3=0x06
 .elif subType == 1
	.equ SIG_3=0x06
 .elif subType == 2
	.equ SIG_3=0x0b
 .elif subType == 3
	.equ SIG_3=0x0b
 .elif subType == 4
 	.equ SIG_3=0x15
 .endif
.endif

.if ATmega == 88
 .NOLIST
 .include "m88def.inc"
 .LIST
 .equ SIG_2=0x93
 .if subType == 0
	.equ SIG_3=0x0a
 .elif subType == 1
	.equ SIG_3=0x0a
 .elif subType == 2
	.equ SIG_3=0x0f
 .elif subType == 3
	.equ SIG_3=0x0f
 .elif subType == 4
 	.equ SIG_3=0x16
 .endif
.endif

.equ USARTbase	= UCSR0A
.equ oUCSR0A	= UCSR0A-USARTbase		; register offsets to be accessed with ldd/std and Y+d
.equ oUCSR0B	= UCSR0B-USARTbase
.equ oUCSR0C	= UCSR0C-USARTbase
.equ oUBRR0L	= UBRR0L-USARTbase
.equ oUBRR0H	= UBRR0H-USARTbase
.equ oUDR0		= UDR0  -USARTbase

.include "macros.inc"


.cseg
.org FLASHEND-0x7f

BOOT:
	clr R25
	LOAD YH, MCUSR
	STORE MCUSR, R25
	andi YH, 0x0d
	breq extReset				; const YH = 0 (fix all program)
appStart:						; no external reset
;	ldi R25, 0x00				; (still there)
	rcall watchdogConfig
.if ATmega == 88
	rjmp 0x0000
.else
	jmp 0x0000					; start app
.endif

extReset:
	ldi YL, LOW(USARTbase)		; use Y as IObase pointer (fix all program)
;	ldi YH,HIGH(USARTbase)		; (already there)

	ldi XH,HIGH(buff)			; const XH = 0x02 (fix all program - do not change)
.if doubleSpeed == 1
	std Y+oUCSR0A, XH			; USART0 double speed
.endif
;	ldi R16, 0x06				; reset value - don't need to write
;	std Y+oUCSR0C, R16			; 8.1 no parity
.if Baud == 0
;	ldi R25, 0x00				; (still there)
;	std Y+oUBRR0L, R25			; reset value - don't need to write	
.else
	ldi R25, Baud
	std Y+oUBRR0L, R25
.endif
	ldi R18, 0x18				; const R18 = 0x18 (fix all program - do not change)
	std Y+oUCSR0B, R18			; RX enable, TX enable

	ldi R25, WDtimeOut
	rcall watchdogConfig		; trigger after ... ms (uses const R18 = 0x18)

foreverLoop:
	rcall getch
checkA:
	cpi R24, 0x41				; 'A' - STK_GET_PARAMETER
	brne checkB

getParameter:
	rcall getch					; drop parameter no.
	rcall verifySpace
.ifndef allPARAM_0x14
	ldi R24, 3					; all parameters 0x03 (Optiboot standard)
.else							; return 0x14 for all parameters (last value in R24 = STK_INSYNC)
.endif
byte_response_R24:
	rcall putch					; send response
	rjmp putchSTK_OK			; send 'OK'

checkB:
	cpi R24, 0x42				; 'B' - STK_SET_DEVICE
	ldi R25, 0x14
	breq getThat				; go ignore cmd by ..

checkE:
	cpi R24, 0x45				; 'E' - STK_SET_DEVICE_EXT
	brne checkU

setDeviceExt:
	ldi R25, 0x05				; ignore cmd by ..
getThat:
	rcall getNch_R25			; .. dropping next #R25 chars + verifySpace
	rjmp putchSTK_OK			; send 'OK'

checkU:
	cpi R24, 0x55				; 'U' - STK_LOAD_ADDRESS
	brne checkV

loadAddress:					; little endian, in words
	rcall getch
	mov ZL, R24					; addressH:L in Z
	rcall getch
	mov ZH, R24
	lsl ZL						; make it byte address
	rol ZH
	rjmp nothing_response		; verifySpace + STK_OK

checkV:
	cpi	R24, 0x56				; 'V' - STK_UNIVERSAL
	brne check_d

Universal:
	ldi R25, 4
	rcall getNch_R25
.ifndef allFUSE_LOCK_0x14
	ldi R24, 0					; 0x00 to all UNIVERSAL commands (FUSE, LOCK bits, chip erase ...)
.else							; reply 0x14 instead as it is the last value of R24 (STK_INSYNC)
.endif
	rjmp byte_response_R24

check_d:
	cpi R24, 0x64				; 'd' - STK_PROG_PAGE
	brne check_t
	
progPage:
	rcall page_header 			; get lengthL, drop lenghtH and memtype

	ldi XL, LOW(buff)			; XL = 0 -> buff on page boundary !!
;	ldi XH,HIGH(buff)			; const XH = 2 (fix all program)
fillBuff:
	rcall getch
	st X+, R24
	cp R19, XL					; keep lengthL (R19) -> buff on page boundary !!
	brne fillBuff

	ldi XL, LOW(buff)			; XL = 0 -> buff on page boundary !!
;	ldi XH,HIGH(buff)			; const XH = 2 (fix all program)

	rcall verifySpace
progPage_memtype:				; memtype ignored
; FLASH			
progPage_flash:
	movw R23:R22, Z				; save target address

	rcall _page_erase
loadPageBuf:
	ld R0, X+					; Data from Buffer
	ld R1, X+
	ldi R25, 1<<SELFPRGEN
	rcall _doSPM
	adiw Z, 2
	subi R19,2					; lengthL (scratched)
	brne loadPageBuf

writePage:
	movw Z, R23:R22				; get address

	ldi R25, 1<<PGWRT | 1<<SELFPRGEN
	rcall _doSPM
	ldi R25, 1<<RWWSRE | 1<<SELFPRGEN
	rcall _doSPM

	rjmp putchSTK_OK

check_t:
	cpi R24, 0x74				; 't' - STK_READ_PAGE
	brne check_u

readPage:
	rcall page_header
	rcall verifySpace
readPage_memtype:				; memtype ignored
read_flash:
	lpm	R24, Z+					; read flash
	rcall putch					; send 
	dec R19						; lengthL (scratched)
	brne read_flash

	rjmp putchSTK_OK			; STK_OK

check_u:
	cpi R24, 0x75				; 'u' - STK_READ_SIGN
	brne checkQ

readSignature:
	rcall verifySpace
.ifdef overrideSIGNATURE		; take value in R24 (STK_INSYNC)
	rcall putch					; 0x14
	rcall putch					; 0x14
	rcall putch					; 0x14
.else
	ldi R24, SIG_1				; 0x1e - Atmel
	rcall putch
	ldi R24, SIG_2				; 0x9. - ATmega ...
	rcall putch
	ldi R24, SIG_3
	rcall putch
.endif
	rjmp putchSTK_OK

checkQ:
;	cpi	R24, 0x51				; 'Q' - STK_LEAVE_PROGMODE
;	breq leaveProgmode

allElse:
nothing_response:
	rcall verifySpace
putchSTK_OK:
	ldi	R24, 0x10				; STK_OK
	rcall putch
	rjmp foreverLoop

page_header:
	rcall getch					; drop lengthH
	rcall getch					; get  lengthL - big endian
	mov R19, R24				; R19 = lengthL
	rcall getch					; drop memtype
	ret

putchSTK_INSYNC:
	ldi	R24, 0x14				; STK_INSYNC

putch:
	ldd	R25, Y+oUCSR0A			; wait USART Data Register empty
	sbrs R25, UDRE0
	rjmp putch
	std Y+oUDR0, R24			; put Data
	ret

getch:
	ldd	R24, Y+oUCSR0A			; wait USART Receive complete
	sbrs R24, RXC0
	rjmp getch

;	sbrs R24, FE0				; skip WDR on Framing Error
	wdr

	ldd	R24, Y+oUDR0			; get char received
return:
	ret

watchdogConfig:
;	ldi	R18, (1>>WDE | 1>>WDCE)	;(fix all program - do not change)
	STORE WDTCSR, R18			; const R18 = 0x18 
	STORE WDTCSR, R25
	ret

getNch_R25:
	rcall getch
	dec R25
	brne getNch_R25
;	rjmp verifySpace

verifySpace:
	rcall getch
	cpi	R24, 0x20				; ' '
 	breq putchSTK_INSYNC
not_INSYNC:
;	ldi	R24, 0x08				; force WD-RESET w/i 16 ms
;	rcall watchdogConfig
wait_watchdog:
	rjmp wait_watchdog

_page_erase:
	ldi R25, 1<<PGERS | 1<<SELFPRGEN
_doSPM:
	SKBC SPMCSR, SELFPRGEN, R24
	rjmp _doSPM

	STORE SPMCSR, R25
	spm
	ret

.org FLASHEND

.ifndef noSW_MINOR_Major
.db SW_MINOR, SW_MAJOR
.endif

.dseg
.org 0x0200					; change ONLY when doubleSpeed = 0 !!!!!
buff:
.byte PAGESIZE*2

