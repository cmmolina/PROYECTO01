;*******************************************************************************
;Universidad del Valle de Guatemala
;IE2023 Programación de Microncontroladores
;Autor: Carlos Mauricio Molina López
;Compilador: PIC-AS (v2.40), MPLAB X IDE (v6.00)
;Proyecto: Prelaboratorio 03
;Creado: 09/08/2022
;Última Modificación: 09/08/2022
;*******************************************************************************
PROCESSOR 16F887
#include <xc.inc>
;******************************************************************************* 
; Palabra de configuración    
;******************************************************************************* 
 ; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
;******************************************************************************* 
; Variables    
;******************************************************************************* 
PSECT udata_bank0
 BANDERAS:
    DS 1
 cont60ms: 
    DS 1
 W_TEMP:
    DS 1
 STATUS_TEMP:
    DS 1
 contadorsegundos:
    DS 1
 contadorseg:
    DS 1
 contadorsec:
    DS 1
 contadorminutos: 
    DS 1
 contadormin: 
    DS 1
 contadorminuten:
    DS 1
 contadorhoras: 
    DS 1
 contadorhrs:
    DS 1
 contadorstd: 
    DS 1
 contadordias:
    DS 1
 contadordias1: 
    DS 1
 contadordias2: 
    DS 1
 contadorvar:
    DS 1
 contadormeses:
    DS 1
 contadormeses1:
    DS 1
 contadormeses2:
    DS 1
 FLAG:
    DS 1
 BANDOLERO:
    DS 1
 variablex:
    DS 1
 contadordiasx:
    DS 1
;******************************************************************************* 
; Vector Reset  
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto SETUP
;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004

PUSH: 
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP   
ISR: 
    BTFSS INTCON, 2             ;Si hay interrupción del TMR0, se salta la siguiente linea.
    GOTO pushButtons          
    
    BSF BANDERAS, 5
    
    
    INCF cont60ms, F
    MOVF cont60ms, W
    SUBLW 2
    BTFSC STATUS, 2      
    GOTO TIMER0                 ;Revisamos si han pasado 20ms, 50 veces. Es decir, si ha pasado 1 minuto.

    MOVLW 200
    MOVWF TMR0                  ;Volvemos a cargar el delay.
    
    BCF INTCON, 2
    GOTO pushButtons
TIMER0: 
    BSF BANDERAS, 4             ;Se hace entender que ha pasado 1 segundo
    
    MOVLW 200          
    MOVWF TMR0                  ;Volvemos a cargar el delay
   
    CLRF cont60ms               ;Se limpia el contador 
    BCF INTCON, 2               ;Se limpia la interrupción del TMR0
    GOTO pushButtons             

pushButtons:
    BTFSS INTCON, 0             ;Si hay interrupción del PushButton, se salta la siguiente linea.
    GOTO POP
    
    BANKSEL PORTB               ;*Se toma como set el push que se seleccione...
    BTFSC PORTB, 0              ;¿Se presionó el botón de Display1 Up?
    GOTO DISPLAY1UP
    BTFSC PORTB, 1              ;¿Se presionó el botón de Display1 Down?
    GOTO DISPLAY1DOWN
    BTFSC PORTB, 2              ;¿Se presionó el botón de Display2 Up?
    GOTO DISPLAY2UP
    BTFSC PORTB, 3              ;¿Se presionó el botón de Display2 Down?
    GOTO DISPLAY2DOWN
    BTFSC PORTB, 4              ;¿Se presionó el botón de Modo (Hora/Fecha/Config.Hora/Config.Fecha)?
    GOTO MODO

    GOTO resetRBIF
DISPLAY1UP:
    BSF FLAG, 0
    GOTO resetRBIF
DISPLAY1DOWN:
    BSF FLAG, 1
    GOTO resetRBIF
DISPLAY2UP:
    BSF FLAG, 2
    GOTO resetRBIF
DISPLAY2DOWN:
    BSF FLAG, 3
    GOTO resetRBIF
MODO: 
    BTFSC BANDERAS, 0           ;Se selecciona Modo Fecha
    GOTO COMANDO1
    BTFSC BANDERAS, 1           ;Se selecciona Modo Configuración de Hora
    GOTO COMANDO2
    BTFSC BANDERAS, 2           ;Se selecciona Modo Configuración de Fecha
    GOTO COMANDO3
    BTFSC BANDERAS, 3           ;Se selecciona Modo Hora
    GOTO COMANDO4            
    
    GOTO resetRBIF
COMANDO1:
    BSF BANDERAS, 1
    BCF BANDERAS, 0
    GOTO resetRBIF
COMANDO2: 
    BSF BANDERAS, 2
    BCF BANDERAS, 1
    GOTO resetRBIF
COMANDO3:
    BSF BANDERAS, 3
    BCF BANDERAS, 2
    GOTO resetRBIF 
COMANDO4: 
    BSF BANDERAS, 0
    BCF BANDERAS, 3
    GOTO resetRBIF
resetRBIF:
    BCF INTCON, 0
POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE
    
;******************************************************************************* 
; Código Principal    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ;ORG 0x0100
SETUP: 
    CALL CONFIG_IO
    CALL CONFIG_INTERRUPTS
    CALL CONFIG_TMR0 
    
    BANKSEL BANDERAS
    MOVLW 0b00000001
    MOVWF BANDERAS
    
    ;BSF FLAG, 6
    
    MOVLW 0
    MOVWF contadordias1
    
    MOVLW 0
    MOVWF contadordias2
    
    MOVLW 1
    MOVWF contadormeses1
    
    MOVLW 0
    MOVWF contadormeses2
    
    ;Empezar los meses en 1 
    MOVLW 1
    MOVWF contadormeses
    
    MOVLW 1
    MOVWF contadordias
    
    MOVLW 1
    MOVWF contadordias1
    
LOOP:
    ;BTFSC BANDERAS, 0 
    ;GOTO MODO_HORA
    BTFSC BANDERAS, 0
    GOTO MODO_DISPLAY
    BTFSC BANDERAS, 1
    GOTO MODO_FECHA
    BTFSC BANDERAS, 2
    GOTO MODO_CONFIGHORA
    BTFSC BANDERAS, 3
    GOTO MODO_CONFIGFECHA
    GOTO LOOP
MODO_DISPLAY: 
    BTFSS BANDERAS, 5
    GOTO LOOP
   
    BTFSC BANDERAS, 4
    INCF contadorseg, F
    
    BSF PORTA, 0
    BSF PORTA, 1
    BSF PORTA, 2
    BSF PORTA, 3
    
    ;Check Por Cada Segundo
    MOVF contadorseg, W
    SUBLW 10
    BTFSC STATUS, 2
    CALL SEGUNDOS
    
    CALL DELAY
    
    BSF PORTD, 0 
    MOVF contadorseg, W
    CALL TABLA 
    MOVWF PORTC 
    CALL DELAY
    BCF PORTD, 0
    
    BSF PORTD, 1
    MOVF contadorsec, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 1
    
    BSF PORTD, 2
    MOVF contadormin, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 2
    
    BSF PORTD, 3
    MOVF contadorminuten, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 3
    
    BSF PORTD, 4
    MOVF contadorhrs, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 4
    
    BSF PORTD, 5
    MOVF contadorstd, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 5
    
    
    BCF PORTA, 0
    BCF PORTA, 1
    BCF PORTA, 2
    BCF PORTA, 3
    BCF BANDERAS, 4
    BCF BANDERAS, 5
    GOTO LOOP
MODO_FECHA:
    BTFSC variablex, 7
    GOTO ARREGLO
    BTFSS variablex, 7
    GOTO MODITO_NORMAL
    
ARREGLO:
    BTFSC FLAG, 0
    CALL INCREMENTARDIAS
    ;INCF contadordias, F
    
    BTFSC FLAG, 1
    CALL DECREMENTARDIAS
    ;DECF contadordias, F

    BTFSC FLAG, 2
    CALL INCREMENTARMESES
    ;INCF contadormeses, F
   
    BTFSC FLAG, 3
    CALL DECREMENTARMESES
    ;DECF contadormeses, F
    
    ;SAFE ZONE B*TCH
    
    ;Asegurate que no se pase de maleta con los meses
    ;MOVF contadormeses, W
    ;SUBLW 13
    ;BTFSC STATUS, 2
    ;CLRF contadormeses
    
;LOOPERBREAKER: 
    ;Tal vez haya que disminuir el día extra bro.
    
    
    BCF variablex, 7
    
    BCF FLAG, 0
    BCF FLAG, 1
    BCF FLAG, 2
    BCF FLAG, 3
    
MODITO_NORMAL:
    CALL DELAY
    
    ;Filtro de Días
    ;MOVF contadordias, W
    ;SUBLW 10
    ;BTFSC STATUS, 2
    ;CALL DIAS
    
    BSF PORTD, 2
    MOVF contadormeses1, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 2
    
    BSF PORTD, 3
    MOVF contadormeses2, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 3
    
    BSF PORTD, 4
    MOVF contadordias1, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 4
    
    BSF PORTD, 5
    MOVF contadordias2, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 5
    
    ;BCF FLAG, 0
    ;BCF FLAG, 1
    ;BCF FLAG, 2
    ;BCF FLAG, 3
    GOTO LOOP
    
MODO_CONFIGHORA:
;FLAG, 0 -> DISPLAY1UP (Hora)
;FLAG, 1 -> DISPLAY1DOWN (Hora)

;FLAG, 2 -> DISPLAY2UP (Minutos)
;FLAG, 3 -> DISPLAY2DOWN (Minutos)

    BSF PORTD, 2
    MOVF contadormin, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 2
    
    BSF PORTD, 3
    MOVF contadorminuten, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 3
    
    BSF PORTD, 4
    MOVF contadorhrs, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 4
    
    BSF PORTD, 5
    MOVF contadorstd, W
    CALL TABLA 
    MOVWF PORTC
    CALL DELAY
    BCF PORTD, 5
    
    ;Incrementar Horas 
    BTFSC FLAG, 0
    CALL INCREMENTARHORAS
    
    ;Decrementar Horas
    BTFSC FLAG, 1
    CALL DECREMENTARHORAS

    ;Incrementar Minutos
    BTFSC FLAG, 2
    CALL INCREMENTARMINUTOS
   
    ;Decrementar Minutos
    BTFSC FLAG, 3
    CALL DECREMENTARMINUTOS

    ;Reset de los segundos
    CLRF contadorseg
    CLRF contadorsec

    ;Borración de cualquier botón que se haya presionado 
    BCF FLAG, 0
    BCF FLAG, 1
    BCF FLAG, 2
    BCF FLAG, 3
    GOTO LOOP
    
MODO_CONFIGFECHA:
    BSF variablex, 7
    GOTO MODO_FECHA

    
;*********************************Tablas****************************************
TABLA:
    ADDWF PCL, F
    RETLW 0b0111111	;0
    RETLW 0b0000110	;1 
    RETLW 0b1011011	;2 
    RETLW 0b1001111	;3 
    RETLW 0b1100110	;4 
    RETLW 0b1101101	;5 
    RETLW 0b1111101	;6 
    RETLW 0b0000111	;7 
    RETLW 0b1111111	;8 
    RETLW 0b1101111	;9 
    RETLW 0b1110111	;A 
    RETLW 0b1111100	;b
    RETLW 0b0111001	;C 
    RETLW 0b1011110	;d 
    RETLW 0b1111001	;E
    RETLW 0b1110001	;F 

TABLA2: 
    ADDWF PCL, F
    RETLW 31	        ;Enero
    RETLW 28     	;Febrero
    RETLW 31     	;Marzo
    RETLW 30     	;Abril
    RETLW 31	        ;Mayo
    RETLW 30	        ;Junio
    RETLW 31            ;Julio
    RETLW 31  	        ;Agosto
    RETLW 30    	;Septiembre
    RETLW 31     	;Octubre
    RETLW 30     	;Noviembre
    RETLW 31     	;Diciembre    

;******************************Subrutinas***************************************
SEGUNDOS: 
    CLRF contadorseg
    INCF contadorsec, F
    
    MOVF contadorsec, W
    SUBLW 6
    BTFSC STATUS, 2
    GOTO MINUTOS
    RETURN 
MINUTOS: 
    CLRF contadorsec 
    INCF contadormin, F
    INCF contadorminutos, F
    
    MOVF contadormin, W
    SUBLW 10
    BTFSC STATUS, 2
    GOTO MINUTOS2
    RETURN
MINUTOS2:
    CLRF contadormin
    INCF contadorminuten, F
    
    MOVF contadorminuten, W
    SUBLW 6 
    BTFSC STATUS, 2
    GOTO HORAS
    RETURN
HORAS: 
    CLRF contadorminuten
    CLRF contadorminutos
    INCF contadorhrs, F
    INCF contadorhoras, F
    
    MOVF contadorhoras, W
    SUBLW 24
    BTFSC STATUS, 2
    GOTO DIAS
    
    MOVF contadorhrs, W
    SUBLW 10
    BTFSC STATUS, 2
    GOTO HORAS2
    RETURN 

HORAS2: 
    CLRF contadorhrs
    INCF contadorstd, F
    
    RETURN 
DIAS: 
    ;AQUI CAMPEON!
    CLRF contadorstd
    CLRF contadorhrs
    CLRF contadorhoras
    
    MOVF contadormeses, W
    SUBLW 1
    BTFSS STATUS, 2
    GOTO NEXXT1
    
    GOTO MESSETEADO31
    
NEXXT1:
    MOVF contadormeses, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO NEXXT2
   
    GOTO MESSETEADO28

NEXXT2:
    MOVF contadormeses, W
    SUBLW 3
    BTFSS STATUS, 2
    GOTO NEXXT3
    
    GOTO MESSETEADO31
    
NEXXT3: 
    MOVF contadormeses, W
    SUBLW 4
    BTFSS STATUS, 2
    GOTO NEXXT4
    
    GOTO MESSETEADO30

NEXXT4:
    MOVF contadormeses, W
    SUBLW 5
    BTFSS STATUS, 2
    GOTO NEXXT5
    
    GOTO MESSETEADO31
    
NEXXT5:
    MOVF contadormeses, W
    SUBLW 6
    BTFSS STATUS, 2
    GOTO NEXXT6
    
    GOTO MESSETEADO30
NEXXT6:
    MOVF contadormeses, W
    SUBLW 7
    BTFSS STATUS, 2
    GOTO NEXXT7
    
    GOTO MESSETEADO31
NEXXT7:
    MOVF contadormeses, W
    SUBLW 8
    BTFSS STATUS, 2
    GOTO NEXXT8
    
    GOTO MESSETEADO31
NEXXT8:
    MOVF contadormeses, W
    SUBLW 9
    BTFSS STATUS, 2
    GOTO NEXXT9
    
    GOTO MESSETEADO30
NEXXT9: 
    MOVF contadormeses, W
    SUBLW 10
    BTFSS STATUS, 2
    GOTO NEXXT10
    
    GOTO MESSETEADO31
NEXXT10:
    MOVF contadormeses, W
    SUBLW 11
    BTFSS STATUS, 2
    GOTO NEXXT11
    
    GOTO MESSETEADO30
NEXXT11:
    GOTO MESSETEADO31
    
MESSETEADO31: 
    MOVF contadordias, W
    SUBLW 31
    BTFSC STATUS, 2
    GOTO ERASADOR31

    INCF contadordias, F
    INCF contadordias1, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    INCF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    CLRF contadordias1
    GOTO NOMBREBRO
    
ERASADOR31: 
    MOVLW 1
    MOVWF contadordias
    MOVLW 1
    MOVWF contadordias1
    MOVLW 0
    MOVWF contadordias2
    
    ;INCF contadormeses1, F
    
    MOVF contadormeses, W
    SUBLW 12
    BTFSC STATUS, 2
    GOTO TRANQUILO
    
    INCF contadormeses, F
    INCF contadormeses1, F
    
    GOTO NOMBREBRO

TRANQUILO:
    ;Reseteo de los Meses
    MOVLW 0 
    MOVWF contadormeses2
    MOVLW 1
    MOVWF contadormeses1
    MOVLW 1
    MOVWF contadormeses
    GOTO NOMBREBRO
    
MESSETEADO28:
    MOVF contadordias, W
    SUBLW 28
    BTFSC STATUS, 2
    GOTO ERASADOR28

    INCF contadordias, F
    INCF contadordias1, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    INCF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    CLRF contadordias1
    GOTO NOMBREBRO
    
ERASADOR28: 
    MOVLW 1
    MOVWF contadordias
    MOVLW 1
    MOVWF contadordias1
    MOVLW 0
    MOVWF contadordias2
    
    INCF contadormeses, F
    INCF contadormeses1, F
    GOTO NOMBREBRO
    
MESSETEADO30: 
    MOVF contadordias, W
    SUBLW 30
    BTFSC STATUS, 2
    GOTO ERASADOR30

    INCF contadordias, F
    INCF contadordias1, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    INCF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    CLRF contadordias1
    GOTO NOMBREBRO
    
ERASADOR30: 
    MOVLW 1
    MOVWF contadordias
    MOVLW 1
    MOVWF contadordias1
    MOVLW 0
    MOVWF contadordias2
            
    MOVF contadormeses1, W
    SUBLW 9
    BTFSC STATUS, 2 
    GOTO EXCEPCIONCITA
    
    INCF contadormeses1, F
    INCF contadormeses, F
    
    GOTO NOMBREBRO

EXCEPCIONCITA: 
    MOVLW 0
    MOVWF contadormeses1
    MOVLW 1
    MOVWF contadormeses2
    MOVLW 10
    MOVWF contadormeses
    
    GOTO NOMBREBRO
    
NOMBREBRO:
    RETURN
    
DELAY: 
    BTFSS BANDERAS, 5
    GOTO DELAY
    BCF BANDERAS, 5
    RETURN 
    
INCREMENTARMINUTOS:
    INCF contadormin, F

    MOVF contadormin, W
    SUBLW 10 
    BTFSC STATUS, 2
    INCF contadorminuten, F

    MOVF contadormin, W
    SUBLW 10 
    BTFSC STATUS, 2
    CLRF contadormin

    MOVF contadorminuten, W
    SUBLW 6
    BTFSC STATUS, 2
    CLRF contadorminuten
    
    RETURN 
INCREMENTARHORAS: 
    INCF contadorhrs, F
    INCF contadorhoras, F

    MOVF contadorhoras, W
    SUBLW 24
    BTFSC STATUS, 2
    GOTO OJITO
    
    MOVF contadorhrs, W
    SUBLW 10 
    BTFSC STATUS, 2
    INCF contadorstd, F

    MOVF contadorhrs, W
    SUBLW 10 
    BTFSC STATUS, 2
    CLRF contadorhrs

    MOVF contadorstd, W
    SUBLW 6
    BTFSC STATUS, 2
    CLRF contadorstd
    RETURN 
OJITO: 
    CLRF contadorhrs
    CLRF contadorstd
    CLRF contadorhoras
    RETURN 

DECREMENTARMINUTOS:
    ;Decremento de Display 2 (Unidades)
    MOVF contadormin, W
    SUBLW 0 
    BTFSC STATUS, 2
    CALL PRIORITIZE
    
    MOVF contadormin, W
    SUBLW 0 
    BTFSS STATUS, 2
    BCF FLAG, 6

    BTFSS FLAG, 6
    CALL NORMALCOURSE
    
    BTFSC FLAG, 6  
    CALL CASO9
        
    BTFSS FLAG, 7
    GOTO FINALITO
    
    ;Decrementeo de Display 2 (Decenas)
    MOVF contadorminuten, W
    SUBLW 0 
    BTFSC STATUS, 2
    CALL PRIORITIZE2
    
    MOVF contadorminuten, W
    SUBLW 0 
    BTFSS STATUS, 2
    BCF FLAG, 5
    
    BTFSS FLAG, 5
    CALL NORMALCOURSE2
    
    BTFSC FLAG, 5 
    CALL CASO5
    
FINALITO:
    BCF FLAG, 7
    BCF FLAG, 6
    BCF FLAG, 5
    RETURN 
NORMALCOURSE:
    DECF contadormin, F
    RETURN
NORMALCOURSE2:
    DECF contadorminuten, F
    RETURN
PRIORITIZE: 
    BSF FLAG, 6 
    RETURN
PRIORITIZE2: 
    BSF FLAG, 5 
    RETURN
CASO9: 
    MOVLW 9
    MOVWF contadormin
    BSF FLAG, 7
    RETURN
CASO5:
    MOVLW 5
    MOVWF contadorminuten
    RETURN

DECREMENTARHORAS:
    
    ;Decrementeo de Display 4 (Unidades)
    
    ;Venimos de 24 horas?
    MOVF contadorhoras, W
    SUBLW 0
    BTFSC STATUS, 2
    BSF BANDOLERO, 0
    
    ;Venimos de una hora diferente a las 24 horas?
    MOVF contadorhoras, W
    SUBLW 0
    BTFSS STATUS, 2
    BSF BANDOLERO, 1
    
    ;Estamos en 0?
    MOVF contadorhrs, W
    SUBLW 0 
    BTFSC STATUS, 2
    CALL PRIORITIZE3
    
    ;Estamos en 0?
    MOVF contadorhrs, W
    SUBLW 0 
    BTFSS STATUS, 2
    BCF BANDOLERO, 2
  
    BTFSS BANDOLERO, 2
    CALL NORMALCOURSE3
    
    BTFSC BANDOLERO, 2  
    CALL FILTROCASO
   
    ;Decrementeo de Display 5 (Decenas)
    BTFSS BANDOLERO, 3
    GOTO FINALITOGOL
    
    MOVF contadorstd, W
    SUBLW 0 
    BTFSC STATUS, 2
    CALL PRIORITIZE4
    
    MOVF contadorstd, W
    SUBLW 0 
    BTFSS STATUS, 2
    BCF BANDOLERO, 4
    
    BTFSS BANDOLERO, 4
    CALL NORMALCOURSE4
    
    BTFSC BANDOLERO, 4
    CALL FILTROCASO2
    
FINALITOGOL:
    BCF BANDOLERO, 0
    BCF BANDOLERO, 1
    BCF BANDOLERO, 2
    BCF BANDOLERO, 3
    BCF BANDOLERO, 4
    RETURN 
NORMALCOURSE3: 
    DECF contadorhrs, F
    DECF contadorhoras, F
    RETURN
NORMALCOURSE4:
    DECF contadorstd, F
    RETURN
PRIORITIZE3:
    BSF BANDOLERO, 2 
    RETURN
PRIORITIZE4: 
    BSF BANDOLERO, 4
    RETURN
FILTROCASO: 
    BTFSC BANDOLERO, 0
    CALL CASO4
    BTFSC BANDOLERO, 1
    CALL CASO92
    RETURN 
FILTROCASO2: 
    BTFSC BANDOLERO, 0
    CALL CASO2
    BTFSC BANDOLERO, 1
    CALL CASOMEH
    RETURN
CASOMEH:
    DECF contadorstd, F
    RETURN 
CASO2: 
    MOVLW 2
    MOVWF contadorstd
    RETURN 
CASO92:
    DECF contadorhoras, F
    MOVLW 9
    MOVWF contadorhrs 
    BSF BANDOLERO, 3
    RETURN
CASO4: 
    MOVLW 23
    MOVWF contadorhoras
    MOVLW 3
    MOVWF contadorhrs 
    BSF BANDOLERO, 3
    RETURN
INCREMENTARDIAS:
    
    MOVF contadormeses, W
    SUBLW 1
    BTFSS STATUS, 2
    GOTO NEXT1
    
    GOTO BIGBOYTEMPO
    
NEXT1:
    MOVF contadormeses, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO NEXT2
    
    GOTO MEDIUMBOYTEMPO

NEXT2:
    MOVF contadormeses, W
    SUBLW 3
    BTFSS STATUS, 2
    GOTO NEXT3
    
    GOTO BIGBOYTEMPO
    
NEXT3: 
    MOVF contadormeses, W
    SUBLW 4
    BTFSS STATUS, 2
    GOTO NEXT4
    
    GOTO LITTLEBOYTEMPO

NEXT4:
    MOVF contadormeses, W
    SUBLW 5
    BTFSS STATUS, 2
    GOTO NEXT5
    
    GOTO BIGBOYTEMPO
    
NEXT5:
    MOVF contadormeses, W
    SUBLW 6
    BTFSS STATUS, 2
    GOTO NEXT6
    
    GOTO LITTLEBOYTEMPO
NEXT6:
    MOVF contadormeses, W
    SUBLW 7
    BTFSS STATUS, 2
    GOTO NEXT7
    
    GOTO BIGBOYTEMPO
NEXT7:
    MOVF contadormeses, W
    SUBLW 8
    BTFSS STATUS, 2
    GOTO NEXT8
    
    GOTO BIGBOYTEMPO
NEXT8:
    MOVF contadormeses, W
    SUBLW 9
    BTFSS STATUS, 2
    GOTO NEXT9
    
    GOTO LITTLEBOYTEMPO
NEXT9: 
    MOVF contadormeses, W
    SUBLW 10
    BTFSS STATUS, 2
    GOTO NEXT10
    
    GOTO BIGBOYTEMPO
NEXT10:
    MOVF contadormeses, W
    SUBLW 11
    BTFSS STATUS, 2
    GOTO NEXT11
    
    GOTO LITTLEBOYTEMPO
NEXT11:
    MOVLW 31
    GOTO BIGBOYTEMPO
    
MEDIUMBOYTEMPO: 
    MOVF contadordias, W
    SUBLW 28
    BTFSC STATUS, 2
    GOTO BORRA1
    
    INCF contadordias, F
    INCF contadordias1, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    INCF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    CLRF contadordias1
    
    GOTO OKIDOKI
    
    
LITTLEBOYTEMPO: 
    MOVF contadordias, W
    SUBLW 30
    BTFSC STATUS, 2
    GOTO BORRA1
    
    INCF contadordias, F
    INCF contadordias1, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    INCF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    CLRF contadordias1
    
    GOTO OKIDOKI
    
BIGBOYTEMPO: 
    MOVF contadordias, W
    SUBLW 31
    BTFSC STATUS, 2
    GOTO BORRA1
    
    INCF contadordias, F
    INCF contadordias1, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    INCF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    CLRF contadordias1
    
    GOTO OKIDOKI
    
BORRA1: 
    MOVLW 1
    MOVWF contadordias
    
    MOVLW 1
    MOVWF contadordias1
    
    MOVLW 0
    MOVWF contadordias2
    
    GOTO OKIDOKI
    
OKIDOKI:
    RETURN

DECREMENTARDIAS:
    BANKSEL contadordias1
    DECF contadordias, F
    
NEXT0:
    MOVF contadormeses, W
    SUBLW 1
    BTFSS STATUS, 2
    GOTO NEXT1X
    
    GOTO MODO31
    
NEXT1X:
    MOVF contadormeses, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO NEXT2X
    
    GOTO MODO28

NEXT2X:
    MOVF contadormeses, W
    SUBLW 3
    BTFSS STATUS, 2
    GOTO NEXT3X
    
    GOTO MODO31
    
NEXT3X: 
    MOVF contadormeses, W
    SUBLW 4
    BTFSS STATUS, 2
    GOTO NEXT4X
   
    GOTO MODO30

NEXT4X:
    MOVF contadormeses, W
    SUBLW 5
    BTFSS STATUS, 2
    GOTO NEXT5X
    
    GOTO MODO31
    
NEXT5X:
    MOVF contadormeses, W
    SUBLW 6
    BTFSS STATUS, 2
    GOTO NEXT6X
    
    GOTO MODO30
NEXT6X:
    MOVF contadormeses, W
    SUBLW 7
    BTFSS STATUS, 2
    GOTO NEXT7X
    
    GOTO MODO31
NEXT7X:
    MOVF contadormeses, W
    SUBLW 8
    BTFSS STATUS, 2
    GOTO NEXT8X
    
    GOTO MODO31
NEXT8X:
    MOVF contadormeses, W
    SUBLW 9
    BTFSS STATUS, 2
    GOTO NEXT9X
    
    GOTO MODO30
NEXT9X: 
    MOVF contadormeses, W
    SUBLW 10
    BTFSS STATUS, 2
    GOTO NEXT10X
    
    GOTO MODO31
NEXT10X:
    MOVF contadormeses, W
    SUBLW 11
    BTFSS STATUS, 2
    GOTO NEXT11X
    
    GOTO MODO30
NEXT11X:
    GOTO MODO31

MODO31:
    ;Underflow
    MOVF contadordias, W
    SUBLW 0
    BTFSC STATUS, 2
    GOTO ERASER31
    
    ;Modo Normal
    MOVF contadordias1, W
    SUBLW 0
    BTFSC STATUS, 2
    DECF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 0
    BTFSS STATUS, 2
    GOTO BROCOCONDOSOJOS3
    
    MOVLW 9
    MOVWF contadordias1 
    GOTO OJITOSLINDOS

BROCOCONDOSOJOS3:
    DECF contadordias1, F
    GOTO OJITOSLINDOS
    
MODO28:
    ;Underflow
    MOVF contadordias, W
    SUBLW 0
    BTFSC STATUS, 2
    GOTO ERASER28
    
    ;Modo Normal
    MOVF contadordias1, W
    SUBLW 0
    BTFSC STATUS, 2
    DECF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 0
    BTFSS STATUS, 2
    GOTO BROCOCONDOSOJOS2
    
    MOVLW 9
    MOVWF contadordias1 
    GOTO OJITOSLINDOS

BROCOCONDOSOJOS2:
    DECF contadordias1, F
    GOTO OJITOSLINDOS
    
MODO30:
    ;Underflow
    MOVF contadordias, W
    SUBLW 0
    BTFSC STATUS, 2
    GOTO ERASER30
    
    ;Modo Normal
    MOVF contadordias1, W
    SUBLW 0
    BTFSC STATUS, 2
    DECF contadordias2, F
    
    MOVF contadordias1, W
    SUBLW 0
    BTFSS STATUS, 2
    GOTO BROCOCONDOSOJOS
    
    MOVLW 9
    MOVWF contadordias1 
    GOTO OJITOSLINDOS

BROCOCONDOSOJOS:
    DECF contadordias1, F
    GOTO OJITOSLINDOS
    
ERASER30:
    MOVLW 30
    MOVWF contadordias
    MOVLW 0
    MOVWF contadordias1
    MOVLW 3
    MOVWF contadordias2
    GOTO OJITOSLINDOS
ERASER31:
    MOVLW 31
    MOVWF contadordias
    MOVLW 1
    MOVWF contadordias1
    MOVLW 3
    MOVWF contadordias2
    GOTO OJITOSLINDOS
ERASER28:
    MOVLW 28
    MOVWF contadordias
    MOVLW 8
    MOVWF contadordias1
    MOVLW 2
    MOVWF contadordias2
    GOTO OJITOSLINDOS
OJITOSLINDOS:
    RETURN 
    
INCREMENTARMESES:
    INCF contadormeses, F
    INCF contadormeses1, F
    
    MOVF contadormeses, W
    SUBLW 13 
    BTFSC STATUS, 2
    GOTO MANO 
    GOTO CONTINUE
MANO:
    CLRF contadormeses2
    MOVLW 1
    MOVWF contadormeses1
    MOVLW 1
    MOVWF contadormeses
CONTINUE: 
    MOVF contadormeses1, W
    SUBLW 10
    BTFSC STATUS, 2
    INCF contadormeses2, F
    
    MOVF contadormeses1, W
    SUBLW 10
    BTFSC STATUS, 2
    CLRF contadormeses1
    
    BCF BANDOLERO, 6
    MOVLW 1
    MOVWF contadordias
    MOVLW 1
    MOVWF contadordias1
    CLRF contadordias2
    RETURN

DECREMENTARMESES:
    BANKSEL contadormeses
    DECF contadormeses, F
    
    MOVF contadormeses, W
    SUBLW 0 
    BTFSC STATUS, 2
    GOTO MOJITO
    
    MOVF contadormeses, W
    SUBLW 9 
    BTFSC STATUS, 2
    GOTO EXCEPTION
    
    DECF contadormeses1, F
   
    GOTO FINAL

MOJITO: 
    MOVLW 12
    MOVWF contadormeses     
    MOVLW 2
    MOVWF contadormeses1
    MOVLW 1
    MOVWF contadormeses2
    GOTO FINAL
    
EXCEPTION: 
    MOVLW 0
    MOVWF contadormeses2
    MOVLW 9
    MOVWF contadormeses1
    
FINAL:
    MOVLW 1
    MOVWF contadordias
    MOVLW 1
    MOVWF contadordias1
    CLRF contadordias2
    BCF BANDOLERO, 6
    RETURN
    
;****************************Configuraciones************************************
CONFIG_IO:
    BANKSEL TRISA    
    CLRF    TRISA               ;PORTA como OUTPUTS
    MOVLW   0b11111111
    MOVWF   TRISB               ;PORTB como INPUTS
    CLRF    TRISC               ;PORTC como OUTPUTS
    CLRF    TRISD               ;PORTD como OUTPUTS
    
    BANKSEL ANSEL
    CLRF    ANSEL               ;I/O Digitales
    CLRF    ANSELH              ;I/O Digitales
    
    ;BANKSEL WPUB 
    ;MOVLW 0b11111111
    ;MOVWF WPUB                 ;Todos los pines del PORTB con pull-up
    
    BANKSEL PORTA  
    CLRF    PORTA               ;Se inicializan los puertos de A
    CLRF    PORTB               ;Se inicializan los puertos de B
    CLRF    PORTC               ;Se inicializan los puertos de C
    ;MOVLW 0b11111111
    MOVLW   0b00000000
    MOVWF   PORTD
    RETURN

CONFIG_TMR0: 
    BANKSEL OSCCON
    BSF OSCCON, 6               ;OSCCON<6>  Oscillator 1
    BCF OSCCON, 5               ;OSCCON<5>  Oscillator 0
    BCF OSCCON, 4               ;OSCCON<4>  Oscillator 0 
                                ;Oscillator de 1MHz 
    
    BSF OSCCON, 0               ;OSCCON<0>  SCS como Reloj Interno
    
    BANKSEL TRISA
   ; BCF     OPTION_REG, 7       ;Pull-ups para pines del Puerto B se habilitan
    BCF     OPTION_REG, 5       ;OPTION_REG<5> Reloj como Fosc/4
    BCF     OPTION_REG, 3       ;OPTION_REG<3> Prescaler asignado al TMR0
    BSF     OPTION_REG, 2       ;OPTION_REG<2> Prescaler 1
    BSF     OPTION_REG, 1       ;OPTION_REG<1> Prescaler 1
    BSF     OPTION_REG, 0       ;OPTION_REG<0> Prescaler 1
                                ;Prescaler 1:256
    
    BANKSEL PORTA
    MOVLW   200
    ;MOVLW   63
    MOVWF   TMR0                ;Se carga el delay al TMR0
    BCF     INTCON, 2           ;La interrupción del TMR0 se borra al inicio
    RETURN 
    
CONFIG_INTERRUPTS:
    BSF INTCON, 5               ;INTCON<5> Se habilita la interrupción del TMR0
    BCF INTCON, 2               ;INTCON<2> Interrupción del TMR0 se borra al inicio
    
    BANKSEL IOCB 
    MOVLW 0b11111111
    MOVWF IOCB                  ;Todos los pines del PORTB tienen interrupciones
    BSF INTCON, 3               ;INTCON<3> Se habilitan las interrupciones del PORTB
    BCF INTCON, 0               ;INTCON<0> Las interrupciones de B se borran al inicio
    BSF INTCON, 7               ;INTCON<7> Se habilitan las interrupciones globales
    RETURN
    
    END