.include "m128Adef.inc"
.include "LIN_AT128.inc"

.dseg
.org		SRAM_START
#ifdef  master_lin

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

#elif	slave_lin
flags1:			.byte 1
	.equ		Sync_break_rx_ok 		= 0			; 1 - Принят отрицательный синхроимпульс
	.equ		falling_edge			= 1			; 1 - falling edge, 0 - rising edge
	.equ		Start_Ttimout			= 2			; 1 - старт таймера таймаута
	.equ		Syn0x55RX				= 3
	.equ		CMD1RX					= 4
	.equ		Response				= 5
	.equ		start_byte1				= 6
	.equ		start_byte2				= 7

flags2:			.byte 1
	.equ		Update_buf				= 0

TCNT0_byte1:		.byte 1
TCNT0_byte2:		.byte 1
Synk_stime_l:		.byte 1							; время начала импульса синхронизации
Synk_stime_h:		.byte 1
Synk_stp_time_l:	.byte 1							; время окончания импульса синхронизации
Synk_stp_time_h:	.byte 1							; и начала таймаута
RXbufUS1:			.byte bufUS1_size
TXbufUS1:			.byte bufUS1_size
RXbufsize:			.byte 1
TXbufsize:			.byte 1
#endif

.cseg
.org		0x00
			rjmp	RESET     ; Reset Handler			$0002
.org		0x02
	reti	;jmp	EXT_INT0  ; IRQ0 Handler			$0004
.org		0x04
	reti	;jmp	EXT_INT1  ; IRQ1 Handler			$0006
.org		0x06

#ifdef  master_lin
	reti	;jmp	EXT_INT2  ; IRQ2 Handler			$0008
#elif	slave_lin
	rjmp	EXT_INT2
#endif

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

#ifdef master_lin
;*********************************************************************
;********* Подпрограммы обработки прерываний MASTER *******
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
;********* Подпрограммы обработки прерываний SLAVE *******
;*********************************************************************
#elif	slave_lin

TIM0_OVF:
	in		i_sreg,			SREG
	push	temp0
	push	temp1

	lds		temp0,			TCNT0_byte1						;	TCNT0_byte0 -> TCNT0
	lds		temp1,			TCNT0_byte2
	subi	temp0,			0xFF
	sbci	temp1,			0xFF
	sts		TCNT0_byte1,	temp0
	sts		TCNT0_byte2,	temp1

	pop		temp1
	pop		temp0
	out		SREG,			i_sreg
	reti

USART0_RXC:
	in		i_sreg,			SREG
	push	temp0
	push	temp1
	push	temp2
	push	temp3
	push	XL
	push	XH

	lds		temp0,			flags1
	in		temp1,			UDR0
	sbrc	temp0,			start_byte1
	rjmp	start_byte1_OK
	ldi		temp2,			's'
	cpse	temp1,			temp2
	rjmp	start_byte1_NO
	sbr		temp0,			(1<<start_byte1)
	rjmp	USART0_RXC_out

start_byte1_OK:
	sbrc	temp0,			start_byte2
	rjmp	start_byte2_OK
	ldi		temp2,			't'
	cpse	temp1,			temp2
	rjmp	start_byte2_NO
	sbr		temp0,			(1<<start_byte2)
	sts		RXbufsize,		zero
	rjmp	USART0_RXC_out

start_byte2_OK:
	lds		temp2,			RXbufsize
	ldi		XL,				low (RXbufUS1)
	ldi		XH,				high(RXbufUS1)
	add		XL,				temp2
	adc		XH,				zero
	inc		temp2
	sts		RXbufsize,		temp2
	st		X,				temp1
	ldi		temp1,			4
	cpse	temp2,			temp1
	rjmp	USART0_RXC_out
	clr		temp2
	
	ldi		XL,				low (RXbufUS1)
	ldi		XH,				high(RXbufUS1)
CRC:
	ld		temp3,			X+
	add		temp2,			temp3
	brbc	SREG_C,			CRC1
	inc		temp2
CRC1:
	dec		temp1
	brne	CRC
	com		temp2
	st		X,				temp2
	cbr		temp0,			(1<<start_byte1)|(1<<start_byte2)
	lds		temp1,			flags2
	sbr		temp1,			(1<<Update_buf)
	sts		flags2,			temp1
	rjmp	USART0_RXC_out

start_byte2_NO:
	cbr		temp0,			(1<<start_byte1)
start_byte1_NO:


USART0_RXC_out:
	sts		flags1,			temp0
	pop		XH
	pop		XL
	pop		temp3
	pop		temp2
	pop		temp1
	pop		temp0
	out		SREG,			i_sreg
	reti

USART1_RXC:
	in		i_sreg,			SREG
	push	temp0
	push	temp1
	push	temp2

	lds		temp0,			flags1
	lds		temp1,			UDR1
	sbrc	temp0,			Syn0x55RX
	rjmp	Syn0x55RX_OK
	ldi		temp2,			0x55
	cpse	temp1,			temp2
	rjmp	Syn0x55NO_EQ
	sbr		temp0,			(1<<Syn0x55RX)
	rjmp	USART1_RXC_out

Syn0x55RX_OK:
	sbrc	temp0,			CMD1RX
	rjmp	CMD1RX_NO
	ldi		temp2,			0x03
	cpse	temp1,			temp2
	rjmp	CMDRX_NO_EQ
;	sbr		temp0,			(1<<CMD1RX)
	cbr		temp0,			(1<<Syn0x55RX)
	sbr		temp0,			(1<<Response)	

	lds		temp1,			UCSR1B
	sbr		temp1,			(1<<TXEN1)
	cbr		temp1,			(1<<RXCIE1)|(1<<RXEN1)
	sts		UCSR1B,			temp1

	rjmp	USART1_RXC_out

CMD1RX_NO:

CMDRX_NO_EQ:
	cbr		temp0,			(1<<Syn0x55RX)
	rjmp	USART1_RXC_out

Syn0x55NO_EQ:

USART1_RXC_out:
	sts		flags1,			temp0
	pop		temp2
	pop		temp1
	pop		temp0
	out		SREG,			i_sreg
	reti

EXT_INT2q:
	in		i_sreg,			SREG
	push	temp0
	push	temp1
	push	temp2

	lds		temp2,			TCNT0_byte1
	in		temp1,			TCNT0
	in		temp0,			TIFR
	sbrs	temp0,			TOV0
	rjmp	T0_NOVF1
;	cpi		temp1,			255
;	brne	T0_NOVF1
	inc		temp2
T0_NOVF1:
	lds		temp0,			flags1
	sbr		temp0,			(1<<Start_Ttimout)
;	sbr		temp0,			(1<<Sync_break_rx_ok)
	sts		flags1,			temp0
;led_on
	sts		Synk_stp_time_l,	temp1
	sts		Synk_stp_time_h,	temp2

	in		temp1,			EIMSK
	cbr		temp1,			(1<<INT2)						; выключить внешнее прерывание
	out		EIMSK,			temp1
	
	pop		temp2
	pop		temp1
	pop		temp0
	out		SREG,			i_sreg

	reti


EXT_INT2:
	in		i_sreg,			SREG
	push	temp0
	push	temp1
	push	temp2
	push	temp3
	push	temp4
	

	lds		temp2,			TCNT0_byte1
	in		temp1,			TCNT0
	in		temp0,			TIFR
	sbrs	temp0,			TOV0
	rjmp	T0_NOVF
	inc		temp2
T0_NOVF:
	lds		temp0,			flags1
	sbrc	temp0,			falling_edge
	rjmp	EXT_INT2_rising_edge
	sbr		temp0,			(1<<falling_edge)
	sts		Synk_stime_l,	temp1
	sts		Synk_stime_h,	temp2
	lds		temp1,			EICRA
	sbr		temp1,			(1<<ISC20)						; rising edge нарастающий фронт
	sts		EICRA,			temp1
	rjmp	EXT_INT2_out

EXT_INT2_rising_edge:
	cbr		temp0,			(1<<falling_edge)
	sts		Synk_stp_time_l,	temp1
	sts		Synk_stp_time_h,	temp2
	lds		temp3,			Synk_stime_l
	lds		temp4,			Synk_stime_h
	sub		temp1,			temp3
	sbc		temp2,			temp4

	cpi		temp1,			low (Synk_time*2)				; *2 потому что таймер ситает 0,5 мкс/тик
	ldi		temp3,			high(Synk_time*2)
	cpc		temp2,			temp3
	brlo	EXT_INT2_out1
	in		temp3,			EIMSK
	cbr		temp3,			(1<<INT2)						; выключить внешнее прерывание
	out		EIMSK,			temp3
	sbr		temp0,			(1<<Sync_break_rx_ok)

EXT_INT2_out1:
	lds		temp1,			EICRA
	cbr		temp1,			(1<<ISC20)						; falling edge спадающий фронт
	sts		EICRA,			temp1

EXT_INT2_out:
	sts		flags1,			temp0
	in		temp1,			EIFR
	sbr		temp1,			(1<<INTF2)						; сброс флага внешнего прерывания
	out		EIFR,			temp1

	pop		temp4
	pop		temp3
	pop		temp2
	pop		temp1
	pop		temp0
	out		SREG,			i_sreg
	reti

#endif

;*********************************************************************
;********* Подпрограммы инициализации переферии *******
;*********************************************************************
PORT_init:
	ldi		temp0,			(1<<LIN_Wake)|(1<<LED)
	out		DDRP_LED,		temp0

	cbr		temp0,			(1<<LED)
	out		PORT_LED,		temp0

	sbi		PORT_LIN,		LIN_TX
	sbi		PORT_LIN,		LIN_RX

	sbi		PORT_USART0,	US0_RX
	ret

#ifdef	slave_lin
EXT_init:
	ldi 	temp0,			(1<<ISC21)						; falling edge спадающий фронт
	sts		EICRA,			temp0

	ser		temp0
	out		EIFR,			temp0

	ldi		temp0,			(1<<INT2)
	out		EIMSK,			temp0

	ret
#endif

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

USART1_Transmit1:
	lds		temp9,			UCSR1A
	sbrs	temp9,			UDRE1
	rjmp	USART1_Transmit1
	sts		UDR1,			temp8
	ret

#ifdef master_lin

USART1_Transmit:
	
	lds		temp9,			UCSR1A
	sbrs	temp9,			UDRE1
	rjmp	USART1_Transmit
;	rcall	USART0_Transmit
	ldi		temp9,			0x55
	sts		UDR1,			temp9

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

#elif	slave_lin

Start_timer0:
	ldi		temp0,			(1<<CS01)
	out		TCCR0,			temp0
	ret

Test_Sync_break_rx:
	lds		temp0,			flags1
	sbrs	temp0,			Sync_break_rx_ok
	rjmp	Test_Sync_break_rx_out
	cbr		temp0,			(1<<Sync_break_rx_ok)
	sbr		temp0,			(1<<Start_Ttimout)

	lds		temp1,			UCSR1B
	sbr		temp1,			(1<<RXCIE1)|(1<<RXEN1)
	sts		UCSR1B,			temp1
	sts		flags1,			temp0
	led_on
Test_Sync_break_rx_out:
	ret

Test_Ttimout:
	lds		temp0,			flags1
	sbrs	temp0,			Start_Ttimout
	rjmp	Test_Ttimout_out

	cli
	lds		temp4,			TCNT0_byte1
	in		temp3,			TCNT0
	in		temp1,			TIFR
	sbrs	temp1,			TOV0
	rjmp	Test_Ttimout_T0_NOVF
;	cpi		temp3,			255
;	brne	Test_Ttimout_T0_NOVF
	inc		temp4
Test_Ttimout_T0_NOVF:
	sei
	lds		temp1,			Synk_stp_time_l
	lds		temp2,			Synk_stp_time_h
	sub		temp3,			temp1
	sbc		temp4,			temp2
	cpi		temp3,			low	(Time_out_time*2)
	ldi		temp1,			high(Time_out_time*2)
	cpc		temp4,			temp1
	brlo	Test_Ttimout_out

	cbr		temp0,			(1<<Start_Ttimout)|(1<<Syn0x55RX)|(1<<Response)
;rcall	USART0_Transmit
	lds		temp1,			UCSR1B
	cbr		temp1,			(1<<RXCIE1)|(1<<RXEN1)|(1<<TXEN1)
	sts		UCSR1B,			temp1
	LED_OFF
	sts		flags1,			temp0

	in		temp1,			EIMSK
	sbr		temp1,			(1<<INT2)						; Включить внешнее прерывание
	out		EIMSK,			temp1
Test_Ttimout_out:
	ret

Test_TX_response:
	lds		temp0,			flags1
	sbrs	temp0,			Response
	rjmp	Test_TX_response_out
	
	
	ldi		XL,				low (TXbufUS1)
	ldi		XH,				high(TXbufUS1)

	ldi		temp1,			5;				TXbufsize
TX_response:
	ld		temp8,			X+
	rcall	USART1_Transmit1
	dec		temp1
	brne	TX_response
	
	cbr	temp0,				(1<<Response)
	sts		flags1,			temp0

Test_TX_response_out:
	ret

Test_Update_buf:
	lds		temp0,			flags2
	sbrs	temp0,			Update_buf
	rjmp	Test_Update_buf_out
	ldi		temp1,			5

	ldi		XL,				low (TXbufUS1)
	ldi		XH,				high(TXbufUS1)

	ldi		YL,				low (RXbufUS1)
	ldi		YH,				high(RXbufUS1)
Update_buf1:
	ld		temp2,			Y+
	st		X+,				temp2
	dec		temp1
	brne	Update_buf1

	cbr		temp0,			(1<<Update_buf)
	sts		flags2,			temp0		
Test_Update_buf_out:
	ret
#endif
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
#ifdef slave_lin
	rcall	EXT_init
#endif
	rcall	TIM0_init
	rcall	USART0_init
	rcall	USART1_init
	rcall	Start_timer0
	sei
;	lds		temp0,			flags1
;	sbr		temp0,			(1<<Sync_break_rx_ok)
;	sts		flags1,			temp0
	
;	lds		temp0,			flags1
;	sbr		temp0,			(1<<Sync_break_rx_ok)
;	sts		flags1,			temp0

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
#ifdef master_lin

	rcall	Test_reed_byte_usrt0
	rcall	Time_synk_break
	rcall	Test_synk_break_tx
;	rcall	Test_RXC1_flag
	rcall	Test_RXbufUS1

#elif slave_lin
	rcall	Test_Sync_break_rx
	rcall	Test_Ttimout
	rcall	Test_TX_response
	rcall	Test_Update_buf
#endif

	rjmp	main
