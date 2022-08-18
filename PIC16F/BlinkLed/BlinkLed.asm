PROCESSOR 16F648A
    
    ; PIC16F648A Configuration Bit Settings
; Assembly source line config statements
; CONFIG
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is digital input, MCLR internally tied to VDD)
  CONFIG  BOREN = OFF           ; Brown-out Detect Enable bit (BOD disabled)
  CONFIG  LVP = OFF             ; Low-Voltage Programming Enable bit (RB4/PGM pin has digital I/O function, HV on MCLR must be used for programming)
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

// config statements should precede project file includes.
#include <xc.inc>
;#include <pic16f648a.inc>

;***** Constantes --------------------------------------------------------------
#define TIMER_0_MAX_INTERRUPT 15
  
;***** Variáveis ---------------------------------------------------------------
TIMER_0_COUNT_INTERRUPT EQU 0020H
 
;***** PROGRAMA ----------------------------------------------------------------
PSECT resetVect, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
   
PSECT code
interrupt:    
    BANKSEL(INTCON)
    BCF	    GIE	    ; desativa interrupção global 
    BCF	    T0IF    ; limpa a flag de interrupção do Timer0
    
    ; Decrementa o contador de interrupções
    BANKSEL(TIMER_0_COUNT_INTERRUPT) 
    DECFSZ  TIMER_0_COUNT_INTERRUPT, F
    RETFIE		;retorna se TIMER_0_COUNT_INTERRUPT maior que zero
    MOVLW   TIMER_0_MAX_INTERRUPT   ; caso TIMER_0_COUNT_INTERRUPT igual a zero 
    MOVWF   TIMER_0_COUNT_INTERRUPT ; reestabelece o contador de interrrupções
   
    ; Muda o estado do pino PB7
    BANKSEL(PORTB)
    MOVLW   10000000B
    XORWF   PORTB, F
    
    BSF	    GIE
    RETFIE
    
PSECT code
main:

    ;Configura o PORTB como Output	
	BANKSEL(TRISB)    
	; Todos os pinos como saída
	CLRF    BANKMASK(TRISB)

    ;Configura o Timer0 e Pull-ups do PORTB
	; Prescaler com taxa de 1:256
	; PreScale ligado ao Timer0
	; Timer0 fonte de clock interno
	; PORTB pull-ups desativados
	MOVLW	10000111B
	MOVWF	OPTION_REG
	
    ;Habilita a interrupção do Timer0 	
	MOVLW   10100000B  
	BANKSEL(INTCON)
	MOVWF   BANKMASK(INTCON)
	MOVLW   TIMER_0_MAX_INTERRUPT
	MOVWF   TIMER_0_COUNT_INTERRUPT

;    ;Ativa apenas o pino PB7
;	BANKSEL(PORTB)
;	CLRF    PORTB 
;	MOVLW   10000000B
;	XORWF   PORTB, F

    FIM: 
	GOTO    FIM ;Aguarda interrupção do Timer0
END

   
    