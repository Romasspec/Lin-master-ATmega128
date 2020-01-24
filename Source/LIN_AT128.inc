;#define		master_lin
#define		slave_lin

.def zero			= r0
.def i_sreg			= r1


.def temp0 			= r16
.def temp1			= r17
.def temp2 			= r18
.def temp3			= r19
.def temp4			= r20
.def temp5			= r21
.def temp6			= r22
.def temp7			= r23
.def temp8			= r24
.def temp9			= r25

.equ LIN_Wake		= PC0
.equ LED1			= PC1
.equ LED2			= PC2

.equ PORT_USART0	= PORTE
.equ PORT_USART1	= PORTD
.equ PORT_LED		= PORTC
.equ DDRP_LED		= DDRC
.equ PORT_LIN		= PORT_USART1
.equ DDRP_LIN		= DDRD
.equ LIN_TX			= PD3
.equ LIN_RX			= PD2


.equ F_CPU			= 16000000
.equ USART0_BAUD	= 115200
.equ USART1_BAUD	= 9600
.equ RXbufUS1_size	= 20
#ifdef	master_lin
.equ Time_out_time	= 213			; мс
#elif	slave_lin
.equ Time_out_time	= 10000			; мкс
#endif

.equ Synk_time		= 600			; мкс

.equ I_CH			= 0
.equ U_CH			= 1
.equ ADC2_CH		= 2
.equ ADC3_CH		= 3
.equ ADMUX_mask		= 0b11100000
.equ ADMUX_nmask	= 0b00011111
.equ length_buf		= 5
.equ Ind_loop		= 500	; цикл индикации 500 мс
.equ vtimer1		= 10	; цикл 10 мс
.equ adc_counter	= 4

.macro	led_on
	sbi		PORT_LED,		@0
.endmacro

.macro	led_off
	cbi		PORT_LED,		@0
.endmacro

.macro	led_meandr
	in		@0,			PORT_LED
	ldi		@1, 		(1<<LED)
	eor		@0,			@1
	out		PORT_LED,	@0
.endmacro

.macro	pc0_meandr
	in		@0,			PORT_LED
	ldi		@1, 		(1<<LIN_Wake)
	eor		@0,			@1
	out		PORT_LED,	@0
.endmacro
