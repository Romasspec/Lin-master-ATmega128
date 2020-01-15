.include "m128Adef.inc"
.include "LIN_AT128.inc"

.dseg
.org		SRAM_START
flags1:			.byte 1
	.equ		RXB0 					= 0
	.equ		RXB1 					= 1
	.equ		Sync_break_tx_ok 		= 2
	.equ		Sync_break_ris_time 	= 3
	.equ		Time_out			 	= 4
	.equ		timer0_ovf				= 5
RXbufUS1:		.byte RXbufUS1_size
RXbufUS1_pos:	.byte 1
TXbufUS1_pos:	.byte 1
Tout_timer_l:	.byte 1
Tout_timer_h:	.byte 1

.cseg
.org		0x00
			rjmp	RESET     ; Reset Handler			$0002
.org		0x02
	reti	;jmp	EXT_INT0  ; IRQ0 Handler			$0004
.org		0x04
	reti	;jmp	EXT_INT1  ; IRQ1 Handler			$0006
.org		0x06
	reti	;jmp	EXT_INT2  ; IRQ2 Handler			$0008
.org		0x08
	reti	;jmp	EXT_INT3  ; IRQ3 Handler			$000A
.org		0x0A
	reti	;jmp	EXT_INT4  ; IRQ4 Handler			$000C
.org		0x0C
	reti	;jmp	EXT_INT5  ; IRQ5 Handler			$000E
.org		0x0E
	reti	;jmp	EXT_INT6  ; IRQ6 Handler			$0010
.org		0x10   
	reti	;jmp	EXT_INT7  ; IRQ7 Handler			$0012
.org		0x12      
	reti	;jmp	TIM2_COMP ; Timer2 Compare Handler	$0014
.org		0x14        
	reti	;jmp	TIM2_OVF  ; Timer2 Overflow Handler	$0016
.org		0x16
	reti	;jmp	TIM1_CAPT ; Timer1 Capture Handler	$0018
.org		0x18   
	reti	;jmp	TIM1_COMPA; Timer1 CompareA Handler	$001A
.org		0x1A    
	reti	;jmp	TIM1_COMPB; Timer1 CompareB Handler	$001C
.org		0x1C     
	reti	;jmp	TIM1_OVF  ; Timer1 Overflow Handler	$001E
.org		0x1E     
	reti	;jmp	TIM0_COMP ; Timer0 Compare Handler	$0020
.org		0x20  
			rjmp	TIM0_OVF  	; Timer0 Overflow Handler		$0022
.org		0x22
	reti	;jmp	SPI_STC   ; SPI Transfer Complete Handler	$0024
.org		0x24
			rjmp	USART0_RXC; USART0 RX Complete Handler		$0026
.org		0x26
	reti	;jmp	USART0_DRE; USART0,UDR Empty Handler		$0028
.org		0x28
	reti	;jmp	USART0_TXC; USART0 TX Complete Handler		$002A
.org		0x2A
	reti	;jmp	ADC_INT   ; ADC Conversion Complete Handler				$002C
.org		0x2C
	reti	;jmp	EE_RDY    ; EEPROM Ready Handler						$002E
.org		0x2E
	reti	;jmp	ANA_COMP  ; Analog Comparator Handler					$0030
.org		0x30
	reti	;jmp	TIM1_COMPC; Timer1 CompareC Handler						$0032
.org		0x32
	reti	;jmp	TIM3_CAPT ; Timer3 Capture Handler						$0034
.org		0x34
	reti	;jmp	TIM3_COMPA; Timer3 CompareA Handler						$0036
.org		0x36
	reti	;jmp	TIM3_COMPB; Timer3 CompareB Handler						$0038
.org		0x38
	reti	;jmp	TIM3_COMPC; Timer3 CompareC Handler						$003A
.org		0x3A
	reti	;jmp	TIM3_OVF  ; Timer3 Overflow Handler						$003C
.org		0x3C
			rjmp	USART1_RXC; USART1 RX Complete Handler					$003E
.org		0x3E
	reti	;jmp	USART1_DRE; USART1,UDR Empty Handler					$0040
.org		0x40
	reti	;jmp	USART1_TXC; USART1 TX Complete Handler					$0042
.org		0x42
	reti	;jmp	TWI       ; Two-wire Serial Interface Interrupt Handler	$0044
.org		0x44
	reti	;jmp	SPM_RDY   ; SPM Ready Handler
.org		0x46


;*********************************************************************
;********* Подпрограммы обработки прерываний *******
;*********************************************************************
TIM0_OVF:
	in		i_sreg,			SREG
	push	temp0
	push	temp1
	push	XL
	push	XH

;	in		temp0,			PORT_LED
;	ldi		temp1, 			(1<<LED)
;	eor		temp0,			temp1
;	out		PORT_LED,		temp0

;	cbi		DDRP_LIN,		LIN_TX
;	sbi		PORT_LIN,		LIN_TX
;	lds		temp0,			flags1
;	sbr		temp0,			(1<<Sync_break_tx_ok)
;	sts		flags1,			temp0
	
	lds		temp0,			flags1
	sbrs	temp0,			Time_out
	rjmp	TIM0_OVF_1
	lds		XL,				Tout_timer_l
	lds		XH,				Tout_timer_h
	adiw	XL,				1
	cpi		XL,				low (F_CPU*10/1024/256/(10000/Time_out_time));(F_CPU/1024/256/(1000/Time_out_time))
	ldi		temp1,			high(F_CPU*10/1024/256/(10000/Time_out_time));(F_CPU/1024/256/(1000/Time_out_time))
	cpc		XH,				temp1
	brlo	TIM0_OVF_2
	out		TCCR0,			zero
	clr		XL
	clr		XH
	sbr		temp0,			(1<<RXB0)
	cbr		temp0,			(1<<Time_out)
	ldi		temp8,			0x03
TIM0_OVF_2:
	sts		Tout_timer_l,	XL
	sts		Tout_timer_h,	XH
	rjmp	TIM0_OVF_out

TIM0_OVF_1:
	out		TCCR0,			zero
	sbr		temp0,			(1<<timer0_ovf)
TIM0_OVF_out:
	sts		flags1,			temp0
	
	pop		XH
	pop		XL
	pop		temp1
	pop		temp0
	out		SREG,			i_sreg
	reti

USART0_RXC:
	in		i_sreg,			SREG
	push	temp0

	in		temp8,			UDR0
	lds		temp0,			flags1
	sbr		temp0,			(1<<RXB0)
	sts		flags1,			temp0

	pop		temp0
	out		SREG,			i_sreg
	reti

USART1_RXC:
	in		i_sreg,			SREG
	push	temp0
	push	XL
	push	XH

	ldi		XL,				low (RXbufUS1)
	ldi		XH,				high(RXbufUS1)
	lds		temp0,			RXbufUS1_pos
	
	add		XL,				temp0
	adc		XH,				zero
	lds		temp9,			UDR1
	st		X,				temp9
	inc		temp0
	cpi		temp0,			RXbufUS1_size
	brlo	USART1_RXC_1
	clr		temp0
USART1_RXC_1:
	sts		RXbufUS1_pos,	temp0
	
	pop		XH
	pop		XL
	pop		temp0
	out		SREG,			i_sreg
	reti

;*********************************************************************
;********* Подпрограммы инициализации переферии *******
;*********************************************************************
PORT_init:
	ldi		temp0,			(1<<LIN_Wake)|(1<<LED)
	out		DDRP_LED,		temp0
	out		PORT_LED,		temp0

	sbi		PORT_LIN,		LIN_TX
	sbi		PORT_LIN,		LIN_RX
	ret

TIM0_init:
;	ldi		temp0,			(1<<CS02)|(1<<CS01)|(1<<CS00)
	out		TCCR0,			zero;temp0

	ldi		temp0,			(1<<TOIE0)
	out		TIMSK,			temp0
	ret

USART0_init:
	ldi		temp1,			high((F_CPU/(8*USART0_BAUD))-1)
	ldi		temp0,			low ((F_CPU/(8*USART0_BAUD))-1)
	sts		UBRR0H,			temp1
	out		UBRR0L,			temp0

	ldi		temp0,			(1<<U2X0)
	out		UCSR0A,			temp0

	ldi		temp0,			(1<<RXCIE0)|(1<<RXEN0)|(1<<TXEN0)
	out		UCSR0B,			temp0

	ldi		temp0,			(1<<UCSZ01)|(1<<UCSZ00)
	sts		UCSR0C,			temp0
	ret

USART1_init:
	ldi		temp1,			high((F_CPU/(16*USART1_BAUD))-1)
	ldi		temp0,			low ((F_CPU/(16*USART1_BAUD))-1)
	sts		UBRR1H,			temp1
	sts		UBRR1L,			temp0

	sts		UCSR1A,			zero

;	ldi		temp0,			(1<<RXCIE1)|(1<<RXEN1)
	sts		UCSR1B,			zero;	temp0

	ldi		temp0,			(1<<UCSZ11)|(1<<UCSZ10)
	sts		UCSR1C,			temp0
	ret

;*********************************************************************
;********* Подпрограммы *******
;*********************************************************************
USART0_Transmit:
	sbis	UCSR0A,			UDRE0
	rjmp	USART0_Transmit
	out		UDR0,			temp8
	ret

USART1_Transmit:
	
	lds		temp9,			UCSR1A
	sbrs	temp9,			UDRE1
	rjmp	USART1_Transmit
;	rcall	USART0_Transmit
	ldi		temp9,			0x55
	sts		UDR1,			temp9

USART1_Transmit1:
	lds		temp9,			UCSR1A
	sbrs	temp9,			UDRE1
	rjmp	USART1_Transmit1
	sts		UDR1,			temp8

USART1_Transmit2:
	lds		temp0,			UCSR1A
	sbrs	temp0,			TXC1
	rjmp	USART1_Transmit2
	sbr		temp0,			(1<<TXC1)
	sts		UCSR1A,			temp0
	lds		temp0,			UCSR1B
	sbr		temp0,			(1<<RXEN1)|(1<<RXCIE1)
	sts		UCSR1B,			temp0


Start_timer0:
	lds		temp0,			flags1
	sbr		temp0,			(1<<Time_out)
	sts		flags1,			temp0
	ldi		temp0,			(1<<CS02)|(1<<CS01)|(1<<CS00)
	out		TCCR0,			temp0

	ret

Test_reed_byte_usrt0:
	lds		temp0,			flags1
	sbrs	temp0,			RXB0
	rjmp	Test_reed_byte_usrt0_out

	cbr		temp0,			(1<<RXB0)
	sts		flags1,			temp0

	
	lds		temp0,			UCSR1B
	cbr		temp0,			(1<<TXEN1)|(1<<RXEN1)|(1<<RXCIE1)
	sts		UCSR1B,			temp0

	ldi		temp0,			(1<<CS02)|(1<<CS01)|(1<<CS00)
	ldi		temp1,			(255-21)
	out		TCNT0,			temp1
	sbi		DDRP_LIN,		LIN_TX
	cbi		PORT_LIN,		LIN_TX
	out		TCCR0,			temp0

Test_reed_byte_usrt0_out:
	ret

Time_synk_break:
	lds		temp0,			flags1
	sbrs	temp0,			timer0_ovf
	rjmp	Time_synk_break_out

	cbr		temp0,			(1<<timer0_ovf)
	sbrc	temp0,			Sync_break_ris_time
	rjmp	Time_synk_break_out1

	sbr		temp0,			(1<<Sync_break_ris_time)
	sts		flags1,			temp0
	sbi		PORT_LIN,		LIN_TX
	nop
	cbi		DDRP_LIN,		LIN_TX

	ldi		temp0,			(1<<CS02)|(1<<CS01)|(1<<CS00)
	ldi		temp1,			(255-2)
	out		TCNT0,			temp1
	out		TCCR0,			temp0
	rjmp	Time_synk_break_out

Time_synk_break_out1:
	cbr		temp0,			(1<<Sync_break_ris_time)
	sbr		temp0,			(1<<Sync_break_tx_ok)
	sts		flags1,			temp0
	
Time_synk_break_out:	
	ret

Test_synk_break_tx:
	lds		temp0,			flags1
	sbrs	temp0,			Sync_break_tx_ok
	rjmp	Test_synk_break_tx_out
	
	cbr		temp0,			(1<<Sync_break_tx_ok)
	sts		flags1,			temp0
	out		TCCR0,			zero
	
	

	lds		temp0,			UCSR1B
	sbr		temp0,			(1<<TXEN1)
	sts		UCSR1B,			temp0
	
	rcall	USART1_Transmit

Test_synk_break_tx_out:
	ret

Test_RXbufUS1:
	lds		temp0,			RXbufUS1_pos
	lds		temp1,			TXbufUS1_pos
	
	cp		temp0,			temp1
	breq	Test_RXbufUS1_out
	ldi		XL,				low (RXbufUS1)
	ldi		XH,				high(RXbufUS1)
	add		XL,				temp1
	adc		XH,				zero
	ld		temp8,			X
	inc		temp1
	cpi		temp1,			RXbufUS1_size
	brlo	Test_RXbufUS1_1
	clr		temp1
Test_RXbufUS1_1:
	sts		TXbufUS1_pos,	temp1
	rcall	USART0_Transmit

Test_RXbufUS1_out:
	ret

Test_RXC1_flag:
;	lds		temp0,			UCSR1A
;	sbrs	temp0,			RXC1
	sbic	PORTA,	PA4
	rjmp	Test_RXC1_flag_out
	lds		temp0,			UDR1

	in		temp0,			PORT_LED
	ldi		temp1, 			(1<<LED)
	eor		temp0,			temp1
	out		PORT_LED,		temp0

Test_RXC1_flag_out:
	ret
;*********************************************************************
;********* точка входа в программу *******
;*********************************************************************
RESET:
	clr		zero

	ldi		ZH,				high (RAMEND)			; установка стека
	out		SPH,			ZH
	ldi		ZL,				low (RAMEND)
	out		SPL,			ZL

	ldi		YH,				high (SRAM_START)
SRAM_clr:											; очистка SRAM и РОН
	st		-Z,				zero
	cpi		ZL,				low (SRAM_START)
	cpc		ZH,				YH
	brne	SRAM_clr1
	ldi		ZL,				29
	mov		ZH,				zero
SRAM_clr1:
	cp		ZL, zero
	cpc		ZH, zero
	brne	SRAM_clr

;*********************************************************************
;********* Инициализация переферии *******
;*********************************************************************
	rcall	PORT_init
	rcall	TIM0_init
	rcall	USART0_init
	rcall	USART1_init
	sei
	rcall	Start_timer0

;	ldi		XL,				low (RXbufUS1)
;	ldi		XH,				high(RXbufUS1)
;	ldi		temp0,			9
;	
;	add		XL,				temp0
;	adc		XH,				zero
;	st		X,				temp0
;	ldi		XL,			low(F_CPU*10/1024/256/(10000/Time_out_time))
;	ldi		XH,			high(F_CPU*10/1024/256/(10000/Time_out_time))
;*********************************************************************
;********* Основной цикл *******
;*********************************************************************
main:
	rcall	Test_reed_byte_usrt0
	rcall	Time_synk_break
	rcall	Test_synk_break_tx
;	rcall	Test_RXC1_flag
	rcall	Test_RXbufUS1
	rjmp	main