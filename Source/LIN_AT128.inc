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
.equ LED			= PC1

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
.equ Time_out_time	= 213			; мс
.equ Synk_time		= 1200			; мс


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
