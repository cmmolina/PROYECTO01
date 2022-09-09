;*******************************************************************************
;Universidad del Valle de Guatemala
;IE2023 Programación de Microncontroladores
;Autor: Carlos Mauricio Molina López
;Compilador: PIC-AS (v2.40), MPLAB X IDE (v6.00)
;Proyecto: Proyecto 01
;Creado: 03/09/2022
;Última Modificación: 08/09/2022
;*******************************************************************************
PROCESSOR 16F887
#include <xc.inc>
;******************************************************************************* 
; Palabra de configuración    
;******************************************************************************* 
 ; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator
                                ; : I/O function on RA6/OSC2/CLKOUT pin, I/O 
				; function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and 
                                ; can be enabled by SWDTEN bit of the WDTCON 
				; register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin 
                                ; function is digital input, MCLR internally 
				; tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code 
                                ; protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code 
                                ; protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit 
                                ; Internal/External Switchover mode is disabled
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe 
                                ; Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin 
                                ; has digital I/O, HV on MCLR must be used for 
				; programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset 
                                ; set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits 
                                ; (Write protection off)
;******************************************************************************* 
; Variables    
;******************************************************************************* 
PSECT udata_bank0
BANDERAS: DS 1
W_TEMP: DS 1
STATUS_TEMP: DS 1
cont60ms: DS 1
VANDERAS: DS 1
cont5ms: DS 1
cont500ms: DS 1
FLAG: DS 1
variablex: DS 1
BANDOLERO: DS 1

    
;Display 0
contadorseg: DS 1
;Display 1
contadorsec: DS 1
;Display 2
contadormin: DS 1
contadormin2: DS 1
contadormeses1: DS 1
;Display 3
contadorminuten: DS 1
contadorminuten2: DS 1    
contadormeses2: DS 1
;Display 4
contadorhrs: DS 1
contadorhrs2: DS 1
contadordias1: DS 1
;Display 5
contadorstd: DS 1
contadorstd2: DS 1  
contadordias2: DS 1

;Variables Para Llevar Cuenta del Tiempo Elapsado
contadorsegundos: DS 1
contadorminutos: DS 1
contadorhoras: DS 1
contadormeses: DS 1
contadordias: DS 1

;Variables Para Display de Alarma
contadorhoras2: DS 1
BANDOLERO2: DS 1
FLAG2: DS 1
    
;Variables Para Activar Alarma
contadorvariable: DS 1
contadorvariable2: DS 1
contadorvariable1: DS 1
contadorvariable3: DS 1
contadorvariable4: DS 1
contadorvariable5: DS 1
contadorvariable6: DS 1
contadorvariable7: DS 1
LASTFLAG: DS 1
      
;******************************************************************************* 
; Vector Reset  
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto MAIN
;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004
PUSH: 
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP           ;Guardamos lo que tenía W al momento de la 
                                ;interrupción
     
ISR: 
    BTFSS INTCON, 2             ;Si hay interrupción del TMR0, se salta la 
                                ;siguiente linea.
    GOTO ISRRBIF          
    
    BSF BANDERAS, 5             ;Esta bandera habilita que se realice un barrido
                                ;de numeros para los displays de acuerdo a la 
				;frecuencia del TMR1
    
    INCF cont5ms, F             ;Se incrementa el contador.
    MOVF cont5ms, W        
    SUBLW 160 
    BTFSC STATUS, 2      
    GOTO pushTIMER0             ;Revisamos si han pasado aproximadamente x ms, 
                                ;160 veces. Es decir, si han pasado 500ms.

    MOVLW 253
    MOVWF TMR0                  ;Volvemos a cargar el delay.
    
    BCF INTCON, 2               ;Limpiamos la interrupción del TMR0.
    GOTO ISRRBIF
pushTIMER0: 
    BTFSS BANDERAS, 0           ;Se chequea si estamos en modo reloj.
    
    GOTO OHIO                   ;Si si estamos en modo reloj, vamos a la linea 
                                ;designada como OHIO.
				
    GOTO MOMENTO                ;Si no estamos en modo reloj, vamos a la linea 
                                ;designada como MOMENTO.
				
				;Esto se hace con el próposito de no permitir
				;que el tiempo pase cuando se está en otros 
				;mdoos que no sean el modo reloj. 
    
OHIO:
    CLRF cont5ms                ;Se limpia el contador de 5ms.
    CLRF cont500ms              ;Se limpia el contador de 500ms.
    
    MOVLW 253                
    MOVWF TMR0                  ;Se vuelve a cargar el delay.
    BCF INTCON, 2               ;Limpiamos la interrupción del TMR0.
    
    GOTO ISRRBIF                ;Revisamoss por interrupciones de los 
                                ;PushButtons
    
MOMENTO: 
    INCF cont500ms, F           ;Se incrementa la variable de 500ms.
    
    BSF PORTA, 0                  
    BSF PORTA, 1
    BSF PORTA, 2
    BSF PORTA, 3                ;Encendemos TODOS los LEDS titilantes.
    
    MOVF cont500ms, W           
    SUBLW 2
    BTFSC STATUS, 2             ;Chequeamos si han pasado dos veces 500ms. 
    GOTO ISRTMR0                ;Si si ha pasado dos veces, vamos a la linea 
                                ;desgnada como ISRTMR0.
				
    CLRF cont5ms                ;En caso contrario, se limpia el contador de 
                                ;5ms.
				
    GOTO ISRRBIF                ;Revisamoss por interrupciones de los 
                                ;PushButtons.
    
ISRTMR0:
    CLRF cont500ms              ;Se limpia el contador de 500ms. 
    BSF BANDERAS, 4             ;Se hace a entender que ha pasado 1 segundo.
    
    BTFSC BANDERAS, 4           ;Revisamos si si ha pasado 1 segundo.
    INCF contadorseg, F         ;Se incrementa el contador de segundos globales
                                ;en caso que haya pasado 1 segundo.
    
    MOVLW 253       
    MOVWF TMR0                  ;Volvemos a cargar el delay.
   
    CLRF cont5ms                ;Se limpia el contador de 5ms.
    BCF INTCON, 2               ;Se limpia la interrupción del TMR0.
    GOTO ISRRBIF             
ISRRBIF:
    BTFSS INTCON, 0             ;Si hay interrupción del PushButton, se salta 
                                ;la siguiente linea.
				
    GOTO POP                    ;Salimos de la interrupción
    
    BANKSEL PORTB               
    BTFSC PORTB, 0              ;¿Se presionó el botón de Display1 Up?
    GOTO ANTIRREBOTE0
    GOTO NEXTOLISTO1
ANTIRREBOTE0: 
    BTFSC PORTB, 0
    GOTO ANTIRREBOTE0
    GOTO DISPLAY1UP
NEXTOLISTO1:
    BTFSC PORTB, 1              ;¿Se presionó el botón de Display1 Down?
    GOTO ANTIRREBOTE1
    GOTO NEXTOLISTO2
ANTIRREBOTE1:                   ;Antirrebote para Display1 Down
    BTFSC PORTB, 1
    GOTO ANTIRREBOTE1
    GOTO DISPLAY1DOWN
    
NEXTOLISTO2:
    BTFSC PORTB, 2              ;¿Se presionó el botón de Display2 Up?
    GOTO ANTIRREBOTE2
    GOTO NEXTOLISTO3
ANTIRREBOTE2:                   ;Antirrebote para Display2 Up
    BTFSC PORTB, 2
    GOTO ANTIRREBOTE2
    GOTO DISPLAY2UP
    
NEXTOLISTO3: 
    BTFSC PORTB, 3              ;¿Se presionó el botón de Display2 Down?
    GOTO ANTIRREBOTE3
    GOTO NEXTOLISTO4
ANTIRREBOTE3:                   ;Antirrebote para Display2 Down
    BTFSC PORTB, 3
    GOTO ANTIRREBOTE3
    GOTO DISPLAY2DOWN
    
NEXTOLISTO4:    
    BTFSC PORTB, 4              ;¿Se presionó el botón de Modo (Hora/Fecha/Config.Hora/Config. Alarma/Config.Fecha)?
    GOTO ANTIRREBOTE4
    GOTO NEXTOLISTO5
ANTIRREBOTE4:                   ;Antirrebote para Cambio de Modo
    BTFSC PORTB, 4
    GOTO ANTIRREBOTE4
    GOTO MODO
    
NEXTOLISTO5:
    BTFSC PORTB, 5              ;¿Se presionó el botón de ACTIVAR?
    GOTO ACTIVAR
    BTFSC PORTB, 6              ;¿Se presionó el botón de DESACTIVAR?
    GOTO DESACTIVAR

    GOTO resetRBIF 
    
ACTIVAR:                        ;Comando si se presiona activar alarma
    BSF VANDERAS, 3
    GOTO resetRBIF 
DESACTIVAR:                     ;Comando si se presiona desactivar alarma
    BCF VANDERAS, 3
    BCF PORTA, 7
    GOTO resetRBIF 
DISPLAY1UP:                     ;Comando si se presiona para subir horas o dias
    BSF FLAG, 0
    GOTO resetRBIF
DISPLAY1DOWN:                   ;Comando si se presiona para bajar horas o dias
    BSF FLAG, 1
    GOTO resetRBIF
DISPLAY2UP:                     ;Comando si se presiona para subir minutos o 
                                ;meses
    BSF FLAG, 2
    GOTO resetRBIF
DISPLAY2DOWN:                   ;Comando si se presiona para bajar minutos o 
                                ;meses
    BSF FLAG, 3
    GOTO resetRBIF
MODO: 
    BTFSC BANDERAS, 0           ;Se selecciona Modo Fecha
    GOTO COMANDO1
    BTFSC BANDERAS, 1           ;Se selecciona Modo Configuración de Hora
    GOTO COMANDO2
    BTFSC BANDERAS, 2           ;Se selecciona Modo Configuración de Fecha
    GOTO COMANDO3
    BTFSC VANDERAS, 4           ;Se selecciona Modo Configuración de Alarma
    GOTO COMANDO4
    BTFSC BANDERAS, 3           ;Se selecciona Modo Reloj
    GOTO COMANDO5            
   
    GOTO resetRBIF
    
COMANDO1:                       ;En caso estemos en Modo Reloj continuamos a 
                                ;Modo Fecha
    BSF BANDERAS, 1
    BCF BANDERAS, 0
    GOTO resetRBIF
    
COMANDO2:                       ;En caso estemos en Modo Fecha continuamos a 
                                ;Modo Configuración de Hora
    BSF BANDERAS, 2
    BCF BANDERAS, 1
    GOTO resetRBIF
COMANDO3:                       ;En caso estemos en Modo Configuración de 
                                ;Hora continuamos a Modo Configuración de 
				;Alarma
    BSF VANDERAS, 4
    BCF BANDERAS, 2
    GOTO resetRBIF 
COMANDO4:                       ;En caso estemos en Modo Configuración de 
                                ;Alarma continuamos a Modo Configuración de 
				;Fecha
    BSF BANDERAS, 3
    BCF VANDERAS, 4
    GOTO resetRBIF 
COMANDO5:                       ;En caso estemos en Modo Configuración de Fecha
                                ;volvemos a Modo Rleoj
    BSF BANDERAS, 0
    BCF BANDERAS, 3
    GOTO resetRBIF
resetRBIF: 
    BCF INTCON, 0               ;Limpiamos la bandera de las interrupciones del
                                ;Puerto B
POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W             ;Regresamos a W el valor que tenía antes de la 
                                ;interrupción
    RETFIE
;******************************************************************************* 
; Código Principal    
;******************************************************************************* 
PSECT CODE, delta=2, abs
ORG 0x0100
MAIN: 
    CALL CONFIG_IO            ;Configuramos las entradas y salidas 
    CALL CONFIG_INTERRUPTS    ;Configuramos las Interrupciones
    CALL CONFIG_TMR0          ;Configuramos el TMR0
    
LOOP:     
    BTFSC BANDERAS, 0         ;Si está en set el bit 0 de BANDERAS vamos al Modo
                              ;Reloj
    GOTO MODO_RELOJ
    
    BTFSC BANDERAS, 1         ;Si está en set el bit 1 de BANDERAS vamos al Modo
                              ;Fecha
    GOTO MODO_FECHA
    
    BTFSC BANDERAS, 2         ;Si está en set el bit 2 de BANDERAS vamos al Modo
                              ;Configuración de Hora
    GOTO MODO_CONFIGHORA
    
    BTFSC VANDERAS, 4         ;Si está en set el bit 4 de VANDERAS vamos al Modo
                              ;Configuración de Alarma
    GOTO MODO_CONFIGALARMA
    
    BTFSC BANDERAS, 3         ;Si está en set el bit 3 de BANDERAS vamos al Modo
                              ;Configuración de Fecha
    GOTO MODO_CONFIGFECHA
  
    GOTO LOOP                 ;Regresamos al Loop
;---------------------------------------1---------------------------------------
;Modo Reloj 
;-------------------------------------------------------------------------------
MODO_RELOJ:     
    BCF PORTA, 6             
    
    ;A continuación analizaremos los cambio de valores del tiempo cada vez que 
    ;pase 1 segundo. 
    
    MOVF contadorseg, W
    SUBLW 10
    BTFSC STATUS, 2           ;Verificamos si han pasado 10 segundos.
    GOTO SEGUNDOS             ;Si ya pasaron 10 segundos, vamos a la linea 
                              ;designada como SEGUNDOS
			      
    GOTO NOCHANGE             ;En caso contrario, nos dirigimos a la linea
                              ;designada como NOCHANGE
SEGUNDOS:
    CLRF contadorseg          ;Si ya pasaron 10 segundos, limpiamos el contador 
                              ;que va al Display 0
    INCF contadorsec, F       ;Incrementamos el conta
    
    BANKSEL contadorsec      
    MOVF contadorsec, W        
    SUBLW 6
    BTFSC STATUS, 2           ;Verificamos si han pasado el contador que va al 
                              ;Display 1 ha llegado. En otras palabras, si los 
			      ;segundos han llegado a 60. 
			      
    GOTO MINUTOS              ;Si si han pasado 60 segundos vamos a la linea 
                              ;desginada MINUTOS.
    GOTO NOCHANGE             ;Si no han pasado 60 segundos vamos a la linea 
                              ;designada NOCHANGE.
MINUTOS: 
    CLRF contadorsec          ;Estamos aquí ya que pasaron 60 segundos 
                              ;nuevamente, en cual caso limpiamos el contador de 
			      ;segundos que va al Display 1.
			      
    INCF contadormin, F       ;Incrementamos el contador que va al Display 2.
    
    INCF contadorminutos, F   ;También incrementamos la variable de minutos
                              ;globales.
    
    MOVF contadormin, W      
    SUBLW 10
    BTFSC STATUS, 2           ;Revisamos si el contador que va al Display 2 ha 
                              ;llegado a 10.
			      
    GOTO MINUTOS2             ;En caso haya llegado a 10, vamos a linea 
                              ;designada como MINUTOS2.
			      
    GOTO NOCHANGE             ;En caso no haya llegado a 10, vamos a la linea 
                              ;designada como NOCHANGE.
MINUTOS2: 
    CLRF contadormin          ;Estamos aquí ya que pasaron 10 minutos. En cual
                              ;caso limpiamos el contador que va al DISPLAY2
			      
    INCF contadorminuten, F   ;Incrementamos el contador que va al DISPLAY3. 
    
    MOVF contadorminuten, W
    SUBLW 6 
    BTFSC STATUS, 2           ;Revisamos si en el contador que va al DISPLAY3 
                              ;ya ha llegado 6. Es decir, si ya ha pasado 1 
			      ;hora. 
			      
    GOTO HORAS                ;Si si ha pasado a 1 hora, vamos a la linea 
                              ;designada como HORAS. 
			      
                              
    GOTO NOCHANGE             ;Si no ha pasado a 1 hora, vamos a la linea 
                              ;designada como NOCHANGE.
			      
HORAS: 
    CLRF contadorminuten      ;Estamos aquí ya que ha pasado 1 hora. En cuyo 
                              ;caso limpiamos el contador que va al DISPLAY3. 
			      
    CLRF contadorminutos      ;Además, limpiamos el contador que va al DISPLAY 2
                              ;también. 
			      
    INCF contadorhrs, F       ;Incrementamos el contador que va al Display 4. 
    INCF contadorhoras, F     ;También incrementamos la variable global del 
                              ;contador de horas. 
    
    MOVF contadorhoras, W     
    SUBLW 24
    BTFSC STATUS, 2           ;Revisamos con la variable global del contador de 
                              ;horas si ya han pasado más de 24. 
    GOTO DIASX                ;Si ya pasaron 24 horas, vamos a la linea 
                              ;designada como DIASX.
    
    MOVF contadorhrs, W 
    SUBLW 10
    BTFSC STATUS, 2           ;Revisamos si el contador que va al DISPLAY4 ya ha
                              ;llegado a 10. 
    GOTO HORAS2               ;En caso ya llegí a 10, lo cual significa 10 horas
                              ;elapsadas, va a la linea designada como 
			      ;HORAS2.
    GOTO NOCHANGE             ;Si no han pasado 10 horas, va a la linea 
                              ;desginada como NOCHANGE.
HORAS2:  
    CLRF contadorhrs          ;Si estamos aquí es porque han pasado 10 horas (o 
                              ;bien 20 horas en total). Limpiamos el contador 
			      ;que va al DISPLAY4
    INCF contadorstd, F       ;Incrementamos el contador que va al DISPLAY5. 
    GOTO NOCHANGE             ;Vamos a la linea designada como NOCHANGE.
DIASX: 
    PAGESEL DIAS
    CALL DIAS                 ;LLAMAMOS A LA SUBRUTINA DE DIAS. 
    PAGESEL MODO_RELOJ
NOCHANGE: 
    CALL DELAY                ;LLAMAMOS LA SUBRUTINA DE DELAY. 
    
    BSF PORTD, 0              ;Activamos el DISPLAY0.
    MOVF contadorseg, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY0.
    PAGESEL MODO_RELOJ
    MOVWF PORTC               ;Mandamos el número al DISPLAY0.
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 0              ;Desactivamos el DISPLAY0. 
    
    BSF PORTD, 1              ;Activamos el DISPLAY1
    MOVF contadorsec, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY1.
    PAGESEL MODO_RELOJ 
    MOVWF PORTC               ;Mandamos el número al DISPLAY1.
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 1              ;Desactivamos el DISPLAY1. 
    
    BSF PORTD, 2              ;Activamos el DISPLAY2. 
    MOVF contadormin, W   
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY2.
    PAGESEL MODO_RELOJ 
    MOVWF PORTC               ;Mandamos el número al DISPLAY2.
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 2              ;Desactivamos el DISPLAY2. 
    
    BSF PORTD, 3              ;Activamos el DISPLAY3.
    MOVF contadorminuten, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY3.
    PAGESEL MODO_RELOJ 
    MOVWF PORTC               ;Mandamos el número al DISPLAY3. 
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 3              ;Desactivamos el DISPLAY3. 
    
    BSF PORTD, 4              ;ACTIVAMOS EL DISPLAY4. 
    MOVF contadorhrs, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY4. 
    PAGESEL MODO_RELOJ 
    MOVWF PORTC               ;Mandamos el número al DISPLAY4. 
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 4              ;Desactivamos el DISPLAY4. 
    
    BSF PORTD, 5              ;ACTIVAMOS EL DISPLAY5.
    MOVF contadorstd, W
    PAGESEL TABLA 
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY5. 
    PAGESEL MODO_RELOJ  
    MOVWF PORTC               ;Mandamos el número al DISPLAY5.
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 5              ;Desactivamos el DISPLAY5. 
    
     
    BTFSS VANDERAS, 3         ;¿La alarama está encencida o apagada?
    GOTO ONOPUES              ;Si está apagada, vamos a la linea designada 
                              ;ONOPUES. 
    PAGESEL REVISION_CONSTANTE
    CALL REVISION_CONSTANTE   ;Si está encendida, vamos a la linea designada 
                              ;REVISION_CONSTANTE. 
    PAGESEL MODO_RELOJ

ONOPUES:
    BCF PORTA, 0
    BCF PORTA, 1
    BCF PORTA, 2
    BCF PORTA, 3
    BCF PORTA, 5              ;Apagamos los LEDS titilantes.
    BCF BANDERAS, 4           ;Limpiamos la bandera de los s. 
    BCF BANDERAS, 5           ;Limpiamos la banderas de los ms.
    GOTO LOOP                 ;Regresamos al loop. 
;---------------------------------------2---------------------------------------
;Modo Fecha 
;-------------------------------------------------------------------------------
MODO_FECHA:
    BCF PORTA, 0
    BCF PORTA, 1   
    BCF PORTA, 2
    BCF PORTA, 3              ;Nos aseguramos que los LEDS de estados de 
                              ;configuración estén apagados.
    
    BTFSC variablex, 7        ;Chequemos si estamos en modo fecha o en modo 
                              ;configuración de fecha. 
    GOTO ARREGLO              ;Si estamos en modo de configuración de fecha, 
                              ;vamos a la linea designada como ARREGLO.
			      
    BTFSS variablex, 7        
    GOTO MODITO_NORMAL        ;Si estamos en modo fecha, vamos a la linea 
                              ;designada como MODITO_NORMAL. 
    
ARREGLO:
    BTFSC FLAG, 0             ;¿Se presionó para incrementar dias?
    CALL INCREMENTARDIAS      ;Si si, llamamos a la subrutina INCREMENTARDIAS. 
    
    BTFSC FLAG, 1             ;¿Se presionó para decrementar dias?
    CALL DECREMENTARDIAS      ;Si si, llamamos a la subrutina DECREMENTARDIAS.

    BTFSC FLAG, 2             ;¿Se presionó para incrementar los meses?
    CALL INCREMENTARMESES     ;Si si, llamamos a la subrutina de 
                              ;INCREMENTARMESES.
   
    BTFSC FLAG, 3             ;¿Se presionó para decrementar los meses?
    CALL DECREMENTARMESES     ;Si si, llamamos a la subrutina de 
                              ;DECREMENTARMESES. 
     
    BCF variablex, 7          ;Reseteamos el bit 7 de la variable "variablex".
    
    BCF FLAG, 0
    BCF FLAG, 1
    BCF FLAG, 2
    BCF FLAG, 3               ;Nos aseguramos de contabilizar la acción de 
                              ;presionar un botón al limpia la interrupcion 
			      ;de botón de UP o DOWN. 
    
MODITO_NORMAL:
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    
    BSF PORTD, 2              ;Activamos el DISPLAY2
    MOVF contadormeses1, W     
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY2. 
    PAGESEL MODITO_NORMAL
    MOVWF PORTC               ;Movemos el número al DISPLAY2. 
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 2              ;Desactivamos el DISPLAY2. 
    
    BSF PORTD, 3              ;Activamos el DISPLAY3.
    MOVF contadormeses2, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY3. 
    PAGESEL MODITO_NORMAL
    MOVWF PORTC               ;Movemos el número al DISPLAY3.
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 3              ;Desacitvamos el DISPLAY3.  
    
    BSF PORTD, 4              ;Activamos el DISPLAY4. 
    MOVF contadordias1, W
    PAGESEL TABLA 
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY4. 
    PAGESEL MODITO_NORMAL
    MOVWF PORTC               ;Movemos el número al DISPLAY4. 
    CALL DELAY                ;LLAMAMOS A LA SUBRTUINA DE DELAY. 
    BCF PORTD, 4              ;Desactivamos el DISPLAY4. 
    
    BSF PORTD, 5              ;Activamos el DISPLAY5. 
    MOVF contadordias2, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY5.
    PAGESEL MODITO_NORMAL
    MOVWF PORTC               ;Movemos el número al DISPLAY5.
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 5              ;Desactivamos el DISPLAY5. 
    
    GOTO LOOP                 ;Regresamos al LOOP.
    
TABLA: 
    CLRF PCLATH
    BSF PCLATH, 0
    ANDLW 0X0F
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
    RETURN
    
;---------------------------------------3---------------------------------------
;Modo Configuración de Hora 
;-------------------------------------------------------------------------------
MODO_CONFIGHORA:
    ;Configuración de LEDs
    BSF PORTA, 4              ;Activamos el LED que indica que estamos en 
                              ;configuración de hora.
    BCF PORTA, 5              ;Apagamos el otro LED.
    BCF PORTA, 6              ;Apagamos el otro LED. 
    
    BSF PORTD, 2              ;Activamos el DISPLAY2.
    MOVF contadormin, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY2.
    PAGESEL MODO_CONFIGHORA
    MOVWF PORTC               ;Mandamos el número al DISPLAY2. 
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 2              ;Desactivamos el DISPLAY2. 
    
    BSF PORTD, 3              ;Activamos el DISPLAY3. 
    MOVF contadorminuten, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY3. 
    PAGESEL MODO_CONFIGHORA
    MOVWF PORTC               ;Mandamos el número al DISPLAY3. 
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 3              ;Desactivamos el DISPLAY3. 
    
    BSF PORTD, 4              ;Activamos el DISPLAY4. 
    MOVF contadorhrs, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY4. 
    PAGESEL MODO_CONFIGHORA
    MOVWF PORTC               ;Mandamos el número al DISPLAY4. 
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY.
    BCF PORTD, 4              ;Desactivamos el DISPLAY4.
    
    BSF PORTD, 5              ;Activamos el DISPLAY5.
    MOVF contadorstd, W
    PAGESEL TABLA
    CALL TABLA                ;Obtenemos la combinación que va al DISPLAY5.
    PAGESEL MODO_CONFIGHORA
    MOVWF PORTC               ;Mandamos el número al DISPLAY5. 
    CALL DELAY                ;LLAMAMOS A LA SUBRUTINA DE DELAY. 
    BCF PORTD, 5              ;Desactivamos el DISPLAY5.
        
    ;Incrementar Horas 
    BTFSC FLAG, 0             ;¿Se presionó para incrementar las horas?
    CALL INCREMENTARHORAS     ;Si si, llamamos a la subrutina de 
                              ;INCREMENTARHORAS.
    
    ;Decrementar Horas
    BTFSC FLAG, 1             ;¿Se presionó para decrementar las horas?
    CALL DECREMENTARHORAS     ;Si si, llamamos a la subrutina de 
                              ;DECREMENTARHORAS.

    ;Incrementar Minutos
    BTFSC FLAG, 2             ;¿Se presionó para incrementar los minutos?
    CALL INCREMENTARMINUTOS   ;Si si, llamamos a la subrutina de
                              ;INCREMENTARMINUTOS.
   
    ;Decrementar Minutos
    BTFSC FLAG, 3             ;¿Se presionó para decrementar los minutos?
    CALL DECREMENTARMINUTOS   ;Si si, llamamos a la subrutina de
                              ;DECREMENTARMINUTOS.

    ;Reset de los segundos
    CLRF contadorseg          
    CLRF contadorsec          ;Reseteamos los segundos.

    BCF FLAG, 0
    BCF FLAG, 1
    BCF FLAG, 2
    BCF FLAG, 3               ;Se borra cualquier botón que se haya presionado.
    GOTO LOOP   
;---------------------------------------4---------------------------------------
;Modo Configuración de Alarma 
;-------------------------------------------------------------------------------
MODO_CONFIGALARMA: 
    BCF PORTA, 4             ;Apagamos el otro LED.
    BSF PORTA, 5             ;Se enciende el LED que indica que estamos en 
                             ;configuración de alarma. 
    BCF PORTA, 6             ;Apagamos el otro LED. 
        
    CALL DELAY               ;LLAMAMOS A LA SUBRUTINA DE DELAY. 
    
    BSF PORTD, 2             ;Activamos el DISPLAY2.
    MOVF contadormin2, W
    PAGESEL TABLA
    CALL TABLA               ;Obtenemos la combinación a cargar.
    PAGESEL MODO_RELOJ 
    MOVWF PORTC              ;Movemos el número al DISPLAY2. 
    CALL DELAY               ;LLAMAMOS A LA SUBRUTINA DE DELAY. 
    BCF PORTD, 2             ;Desactivamos el DISPLAY2. 
    
    BSF PORTD, 3             ;Activamos el DISPLAY3. 
    MOVF contadorminuten2, W
    PAGESEL TABLA
    CALL TABLA               ;Obtenemos la combinación a cargar. 
    PAGESEL MODO_RELOJ 
    MOVWF PORTC              ;Movemos el número al DISPLAY3. 
    CALL DELAY               ;LLAMAMOS A LA SUBRUTINA DE DELAY. 
    BCF PORTD, 3             ;Desactivamos el DISPLAY3. 
    
    BSF PORTD, 4             ;Activamos el DISPLAY4. 
    MOVF contadorhrs2, W 
    PAGESEL TABLA
    CALL TABLA               ;Obtenemos la combinación a cargar.
    PAGESEL MODO_RELOJ 
    MOVWF PORTC              ;Movemos el número al DISPLAY4. 
    CALL DELAY               ;LLAMAMOS A LA SUBRUTINA DE DELAY. 
    BCF PORTD, 4             ;Desactivamos el DISPLAY4.
    
    BSF PORTD, 5             ;Activamos el DISPLAY5. 
    MOVF contadorstd2, W
    PAGESEL TABLA
    CALL TABLA               ;Obtenemos la combinación a cargar.
    PAGESEL MODO_RELOJ 
    MOVWF PORTC              ;Movemos el número al DISPLAY5. 
    CALL DELAY               ;LLAMAMOS A LA SUBRUTINA DE DELAY. 
    BCF PORTD, 5             ;Desactivamos el DISPLAY5.
    
    ;Incrementar Horas 
    BTFSC FLAG, 0            ;¿Se presionó para incrementar las horas?
    CALL INCREMENTARHORAS2   ;Si si, llamamos a la subrutina de
                             ;INCREMENTARHORAS2.
    
    ;Decrementar Horas
    BTFSC FLAG, 1            ;¿Se presionó para decrementar las horas?
    CALL DECREMENTARHORAS2   ;Si si, llamamos a la subrutina de
                             ;DECREMENTARHORAS2.
    
    ;Incrementar Minutos
    BTFSC FLAG, 2            ;¿Se presionó para incrementar los minutos?
    CALL INCREMENTARMINUTOS2 ;Si si, llamamos a la subrutina de
                             ;INCREMENTARMINUTOS2.
   
    ;Decrementar Minutos
    BTFSC FLAG, 3            ;¿Se presionó para decrementar los minutos?
    CALL DECREMENTARMINUTOS2 ;Si si, llamamos a la subrutina de
                             ;DECREMENTARMINUTOS2.
 
    ;Reset de los segundos
    CLRF contadorseg
    CLRF contadorsec         ;Se reinician los segundos. 

    ;Borración de cualquier botón que se haya presionado 
    BCF FLAG, 0
    BCF FLAG, 1
    BCF FLAG, 2
    BCF FLAG, 3              ;Se borra cualquier botón que se haya presionado.
    BCF BANDERAS, 4          ;Limpiamos la bandera de los s. 
    BCF BANDERAS, 5          ;Limpiamos la bandera de los ms. 
    
    GOTO LOOP
;---------------------------------------5---------------------------------------
;Modo Configuración de Fecha 
;-------------------------------------------------------------------------------
MODO_CONFIGFECHA: 
    BCF PORTA, 4             ;Apagamos el otro LED.
    BCF PORTA, 5             ;Apagamos el otro LED.
    BSF PORTA, 6             ;Encendemos el otro LED que indica que estamos en 
                             ;modo de configuración de fecha. 
    
    BSF variablex, 7         ;Encendemos el bit 7 de "variablex"
    GOTO MODO_FECHA          ;Vamos a la linea designada MODO_FECHA
    
;******************************************************************************* 
; Subrutinas    
;******************************************************************************* 
DELAY:
   BTFSS BANDERAS, 5        ;Si ya pasaron los x ms, se ejecuta la siguiente linea. 
   GOTO DELAY               ;Entramos otra vez al delay.
   BCF BANDERAS, 5          ;Limpiamos la bandera de los ms.
   RETURN                   ;Regresamos al loop.
;-------------------------------------------------------------------------------  
;Subrutina Para Config. De Meses y Dias
;-------------------------------------------------------------------------------
INCREMENTARDIAS:
    ;Tenemos que saber con que mes trabajamos para poder marcar los
    ;limites. 
    
    MOVF contadormeses, W          
    SUBLW 1
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Enero?
    GOTO NEXT1              ;Si no, vamos a revisar por Febrero.
    
    GOTO BIGBOYTEMPO        ;Si si, vamos a la linea designada como 
                            ;BIGBOYTEMPO. 
    
NEXT1:
    MOVF contadormeses, W
    SUBLW 2
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Febrero?
    GOTO NEXT2              ;Si no, vamos a revisar por Marzo.
    
    GOTO MEDIUMBOYTEMPO     ;Si si, vamos a la linea designada como 
                            ;MEDIUMBOYTEMPO.

NEXT2:
    MOVF contadormeses, W  
    SUBLW 3
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Marzo?
    GOTO NEXT3              ;Si no, vamos a reviar por Abril.
    
    GOTO BIGBOYTEMPO        ;Si si, vamos a la linea designada como 
                            ;BIGBOYTEMPO.
    
NEXT3: 
    MOVF contadormeses, W
    SUBLW 4
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Abril?
    GOTO NEXT4              ;Si no vamos a revisar por Mayo.
    
    GOTO LITTLEBOYTEMPO     ;Si si, vamos a la linea desginada como 
                            ;LITTLEBOYTEMPO.

NEXT4:
    MOVF contadormeses, W
    SUBLW 5
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Mayo?
    GOTO NEXT5              ;Si no vamos a revisar por Junio. 
    
    GOTO BIGBOYTEMPO        ;Si si, vamos a la linea designada como 
                            ;BIGBOYTEMPO.
    
NEXT5:
    MOVF contadormeses, W
    SUBLW 6
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Junio?
    GOTO NEXT6              ;Si no vamos a revisar por Julio.
    
    GOTO LITTLEBOYTEMPO     ;Si si, vamos a la linea designada como 
                            ;LITTLEBOYTEMPO.
NEXT6:
    MOVF contadormeses, W
    SUBLW 7
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Julio?
    GOTO NEXT7              ;Si no vamos a revisar por Agosto.
    
    GOTO BIGBOYTEMPO        ;Si si, vamos a la linea designada como 
                            ;BIGBOYTEMPO. 
NEXT7:
    MOVF contadormeses, W   
    SUBLW 8
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Agosto?
    GOTO NEXT8              ;Si no vamos a revisar por Septiembre. 
    
    GOTO BIGBOYTEMPO        ;Si si, vamos a la linea designada como
                            ;BIGBOYTEMPO.
NEXT8:
    MOVF contadormeses, W
    SUBLW 9
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Septiembre?
    GOTO NEXT9              ;Si no vamos a revisar por Octubre.
    
    GOTO LITTLEBOYTEMPO     ;Si si, vamos a la linea designada como 
                            ;LITTLEBOYTEMPO. 
NEXT9: 
    MOVF contadormeses, W
    SUBLW 10
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Octubre?
    GOTO NEXT10             ;Si no vamos a revisar por Noviembre.
     
    GOTO BIGBOYTEMPO        ;Si si, vamos a la linea designada como 
                            ;BIGBOYTEMPO. 
NEXT10:
    MOVF contadormeses, W
    SUBLW 11
    BTFSS STATUS, 2         ;Revisamos si estamos en ¿Noviembre?
    GOTO NEXT11             ;Si no vamos a revisar por Diciembre.
    
    GOTO LITTLEBOYTEMPO     ;Si si, vamos a la linea designada como 
                            ;LITTLEBOYTEMPO.
NEXT11:
    MOVLW 31
    GOTO BIGBOYTEMPO        ;Si llegamos a este punto entonces estamos en 
                            ;Diciembre, por lo que vamos a la linea designada 
			    ;como BIGBOYTEMPO. 
    
MEDIUMBOYTEMPO: 
                            ;Si estamos aquí es porque el mes con el que 
			    ;trabajamos tiene 28 dias. 
    MOVF contadordias, W    
    SUBLW 28
    BTFSC STATUS, 2        
    GOTO BORRA1             ;Si pasamos de 28 dias, reiniciamos. 
    
    INCF contadordias, F    ;Incrementamos el contador de dias global. 
    INCF contadordias1, F   ;Incrementamos el contador de dias que va al 
                            ;DISPLAY4. 
    
    MOVF contadordias1, W   
    SUBLW 10
    BTFSC STATUS, 2         ;¿Pasamos de 10 dias?
    INCF contadordias2, F   ;Incrementamos el contador que va al DISPLAY5. 
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2         
    CLRF contadordias1      ;Si pasamos de 10 dias, limpiamos el contador que va
                            ;al DISPLAY4. 
     
    GOTO OKIDOKI            ;Vamos a la linea denominada OKIDOKI. 
    
    
LITTLEBOYTEMPO: 
                            ;Si estamos aquí es porque el mes con el que
			    ;trabajamos tiene 30 dias. 
    MOVF contadordias, W    
    SUBLW 30
    BTFSC STATUS, 2         
    GOTO BORRA1             ;Si pasamos de 30 dias, reiniciamos. 
    
    INCF contadordias, F    ;Incrementamos el contador de dias globales. 
    INCF contadordias1, F   ;Incrementamos el contador de dias que va al 
                            ;DISPLAY3. 
    
    MOVF contadordias1, W 
    SUBLW 10
    BTFSC STATUS, 2         ;Si pasamos de 10 dias, limpiamos el contador que va 
                            ;al DISPLAY 4.
			    
    INCF contadordias2, F   ;Incrementamos el contador que va al DISPLAY5. 
    
    MOVF contadordias1, W
    SUBLW 10
    BTFSC STATUS, 2
    CLRF contadordias1      ;Limpiamos el contador que va al DISPLAY4 una vez 
                            ;hayamos pasado cada 10 dias. 
    
    GOTO OKIDOKI            ;Vamos a la linea desginada OKIDOKI. 
     
BIGBOYTEMPO: 
    
    MOVF contadordias, W
    SUBLW 31
    BTFSC STATUS, 2
    GOTO BORRA1             ;Si llegamos a 31 dias, reiniciamos los contadores.
    
    INCF contadordias, F
    INCF contadordias1, F
    
                            ;Revisión para incremento de decenas y unidades de dias
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
                            ;Al tener un reinicio se establece el dia como 1. 
    MOVLW 1
    MOVWF contadordias
    
    MOVLW 1
    MOVWF contadordias1
    
    MOVLW 0
    MOVWF contadordias2
    
    GOTO OKIDOKI
    
OKIDOKI:
    RETURN                    ;Regresamos

DECREMENTARDIAS:
    BANKSEL contadordias1
    DECF contadordias, F
   
                              ;Nuevamente volvemos a revisar con cuantos dias 
			      ;se tratan dependiendo del mes.
			      ;NO SE COMENTA ESTA PARTE YA QUE 
			      ;SE COMENTÓ PREVIAMENTE EL MISMO PROCESO. 
			      
NEXT0:
    MOVF contadormeses, W
    SUBLW 1
    BTFSS STATUS, 2           ;¿Enero?
    GOTO NEXT1X
    
    GOTO MODO31
    
NEXT1X:
    MOVF contadormeses, W
    SUBLW 2
    BTFSS STATUS, 2           ;¿Febrero?
    GOTO NEXT2X
    
    GOTO MODO28

NEXT2X:
    MOVF contadormeses, W
    SUBLW 3
    BTFSS STATUS, 2           ;¿Marzo?
    GOTO NEXT3X
    
    GOTO MODO31
    
NEXT3X: 
    MOVF contadormeses, W
    SUBLW 4
    BTFSS STATUS, 2           ;¿Abril?
    GOTO NEXT4X
   
    GOTO MODO30

NEXT4X:
    MOVF contadormeses, W
    SUBLW 5
    BTFSS STATUS, 2           ;¿Mayo?
    GOTO NEXT5X
    
    GOTO MODO31
    
NEXT5X:
    MOVF contadormeses, W
    SUBLW 6
    BTFSS STATUS, 2           ;¿Junio?
    GOTO NEXT6X
    
    GOTO MODO30
NEXT6X:
    MOVF contadormeses, W
    SUBLW 7
    BTFSS STATUS, 2           ;¿Julio?
    GOTO NEXT7X
    
    GOTO MODO31
NEXT7X:
    MOVF contadormeses, W
    SUBLW 8
    BTFSS STATUS, 2           ;¿Agosto?
    GOTO NEXT8X
    
    GOTO MODO31
NEXT8X:
    MOVF contadormeses, W
    SUBLW 9
    BTFSS STATUS, 2           ;¿Septiembre?
    GOTO NEXT9X
    
    GOTO MODO30
NEXT9X: 
    MOVF contadormeses, W
    SUBLW 10
    BTFSS STATUS, 2           ;¿Octubre?
    GOTO NEXT10X
    
    GOTO MODO31
NEXT10X:
    MOVF contadormeses, W
    SUBLW 11
    BTFSS STATUS, 2           ;¿Noviembre?
    GOTO NEXT11X
    
    GOTO MODO30
NEXT11X:
    GOTO MODO31               ;¿Diciembre?

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
    ;Establecemos 30 como el numero cuando hay underflow.
    MOVLW 30
    MOVWF contadordias
    MOVLW 0
    MOVWF contadordias1
    MOVLW 3
    MOVWF contadordias2
    GOTO OJITOSLINDOS
ERASER31:
    ;Establecemos 31 como el numero cuando hay underflow. 
    MOVLW 31
    MOVWF contadordias
    MOVLW 1
    MOVWF contadordias1
    MOVLW 3
    MOVWF contadordias2
    GOTO OJITOSLINDOS
ERASER28:
    ;Establecemos 28 como el numero cuando hay underflow. 
    MOVLW 28
    MOVWF contadordias
    MOVLW 8
    MOVWF contadordias1
    MOVLW 2
    MOVWF contadordias2
    GOTO OJITOSLINDOS
OJITOSLINDOS:
    RETURN                    ;Regresamos 
    
INCREMENTARMESES:
    INCF contadormeses, F
    INCF contadormeses1, F
    
    ;¿Nos hemos pasado de los 12 meses?
    MOVF contadormeses, W
    SUBLW 13 
    BTFSC STATUS, 2
    GOTO MANO 
    GOTO CONTINUE
MANO:
    ;Reinicio de meses cuando llegamos a mas de 12.
    CLRF contadormeses2
    MOVLW 1
    MOVWF contadormeses1
    MOVLW 1
    MOVWF contadormeses
CONTINUE: 
    ;Continuamos sumando los meses de manera normal. 
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
    ;Decrementamos los meses 
    BANKSEL contadormeses
    DECF contadormeses, F
    
    
    ;¿Hay underflow u overflow?
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
    ;Underflow
    MOVLW 12
    MOVWF contadormeses     
    MOVLW 2
    MOVWF contadormeses1
    MOVLW 1
    MOVWF contadormeses2
    GOTO FINAL
    
EXCEPTION: 
    ;Transición de mes 10 a 9
    MOVLW 0
    MOVWF contadormeses2
    MOVLW 9
    MOVWF contadormeses1
    
FINAL:
    ;Reseteo de los dias 
    MOVLW 1
    MOVWF contadordias
    MOVLW 1
    MOVWF contadordias1
    CLRF contadordias2
    BCF BANDOLERO, 6
    RETURN
;-------------------------------------------------------------------------------
;Subrutinas Para Configuración de Minutos y Horas
;-------------------------------------------------------------------------------
INCREMENTARMINUTOS:
    INCF contadormin, F              ;Incrementamos el contador de minutos 
                                     ;globales. 

    
                                     ;¿Hay underflow u overflow?
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
    INCF contadorhrs, F                  ;Incrementamos contador que va a 
                                         ;DISPLAY4.
    INCF contadorhoras, F                ;Incrementamos global de horas.

    MOVF contadorhoras, W
    SUBLW 24
    BTFSC STATUS, 2
    GOTO OJITO
    
                                          ;¿
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
                                    ;¿Venimos de 24 horas?
    MOVF contadorhoras, W
    SUBLW 0
    BTFSC STATUS, 2
    BSF BANDOLERO, 0
    
                                    ;¿Venimos de una hora diferente a las 24 
				    ;horas?
    MOVF contadorhoras, W
    SUBLW 0
    BTFSS STATUS, 2
    BSF BANDOLERO, 1
    
                                    ;¿Estamos en 0?
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
    RETURN                              ;Regresamos
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
;*******************************************************************************
;Subrutinas Para Configuración de Alarma
;*******************************************************************************
INCREMENTARHORAS2: 
    INCF contadorhrs2, F
    INCF contadorhoras2, F

    MOVF contadorhoras2, W
    SUBLW 24
    BTFSC STATUS, 2
    GOTO OJITO2
    
    MOVF contadorhrs2, W
    SUBLW 10 
    BTFSC STATUS, 2
    INCF contadorstd2, F

    MOVF contadorhrs2, W
    SUBLW 10 
    BTFSC STATUS, 2
    CLRF contadorhrs2

    MOVF contadorstd2, W
    SUBLW 6
    BTFSC STATUS, 2
    CLRF contadorstd2
    RETURN 
OJITO2: 
    CLRF contadorhrs2
    CLRF contadorstd2
    CLRF contadorhoras2
    RETURN 
INCREMENTARMINUTOS2:
    INCF contadormin2, F

    MOVF contadormin2, W
    SUBLW 10 
    BTFSC STATUS, 2
    INCF contadorminuten2, F

    MOVF contadormin2, W
    SUBLW 10 
    BTFSC STATUS, 2
    CLRF contadormin2

    MOVF contadorminuten2, W
    SUBLW 6
    BTFSC STATUS, 2
    CLRF contadorminuten2
    
    RETURN 
DECREMENTARHORAS2:  
                                       ;Decrementeo de Display 4 (Unidades)
    
                                       ;Venimos de 24 horas?
    MOVF contadorhoras2, W
    SUBLW 0
    BTFSC STATUS, 2
    BSF BANDOLERO2, 0
    
                                      ;Venimos de una hora diferente a las 24 horas?
    MOVF contadorhoras2, W
    SUBLW 0
    BTFSS STATUS, 2
    BSF BANDOLERO2, 1
    
                                      ;Estamos en 0?
    MOVF contadorhrs2, W
    SUBLW 0 
    BTFSC STATUS, 2
    CALL PRIORITY3
    
                                      ;Estamos en 0?
    MOVF contadorhrs2, W
    SUBLW 0 
    BTFSS STATUS, 2
    BCF BANDOLERO2, 2
  
    BTFSS BANDOLERO2, 2
    CALL NORMALCURSO3
    
    BTFSC BANDOLERO2, 2  
    CALL FILTROCASE
   
                                      ;Decrementeo de Display 5 (Decenas)
    BTFSS BANDOLERO2, 3
    GOTO FINALITOGOL2
    
    MOVF contadorstd2, W
    SUBLW 0 
    BTFSC STATUS, 2
    CALL PRIORITY4
    
    MOVF contadorstd2, W
    SUBLW 0 
    BTFSS STATUS, 2
    BCF BANDOLERO2, 4
    
    BTFSS BANDOLERO2, 4
    CALL NORMALCURSO4
    
    BTFSC BANDOLERO2, 4
    CALL FILTROCASE2
    
FINALITOGOL2:
    BCF BANDOLERO2, 0
    BCF BANDOLERO2, 1
    BCF BANDOLERO2, 2
    BCF BANDOLERO2, 3
    BCF BANDOLERO2, 4
    RETURN 
    
NORMALCURSO3: 
    DECF contadorhrs2, F
    DECF contadorhoras2, F
    RETURN
NORMALCURSO4:
    DECF contadorstd2, F
    RETURN
PRIORITY3:
    BSF BANDOLERO2, 2 
    RETURN
PRIORITY4: 
    BSF BANDOLERO2, 4
    RETURN
FILTROCASE: 
    BTFSC BANDOLERO2, 0
    CALL CASO4_2
    BTFSC BANDOLERO2, 1
    CALL CASO92_2
    RETURN 
FILTROCASE2: 
    BTFSC BANDOLERO2, 0
    CALL CASO2_2
    BTFSC BANDOLERO2, 1
    CALL CASOMEH2
    RETURN
CASOMEH2:
    DECF contadorstd2, F
    RETURN 
CASO2_2: 
    MOVLW 2
    MOVWF contadorstd2
    RETURN 
CASO92_2:
    DECF contadorhoras2, F
    MOVLW 9
    MOVWF contadorhrs2 
    BSF BANDOLERO2, 3
    RETURN
CASO4_2: 
    MOVLW 23
    MOVWF contadorhoras2
    MOVLW 3
    MOVWF contadorhrs2
    BSF BANDOLERO2, 3
    RETURN
DECREMENTARMINUTOS2:
                                    ;Decremento de Display 2 (Unidades)
    MOVF contadormin2, W
    SUBLW 0 
    BTFSC STATUS, 2
    CALL PRIORITY1
    
    MOVF contadormin2, W
    SUBLW 0 
    BTFSS STATUS, 2
    BCF FLAG2, 6

    BTFSS FLAG2, 6
    CALL NORMALCURSO
    
    BTFSC FLAG2, 6  
    CALL CASO9_2
        
    BTFSS FLAG2, 7
    GOTO FINALITO2
    
                                    ;Decrementeo de Display 2 (Decenas)
    MOVF contadorminuten2, W
    SUBLW 0 
    BTFSC STATUS, 2
    CALL PRIORITY2
    
    MOVF contadorminuten2, W
    SUBLW 0 
    BTFSS STATUS, 2
    BCF FLAG2, 5
    
    BTFSS FLAG2, 5
    CALL NORMALCURSO2
    
    BTFSC FLAG2, 5 
    CALL CASO5_2
    
FINALITO2:
    BCF FLAG2, 7
    BCF FLAG2, 6
    BCF FLAG2, 5
    RETURN 
NORMALCURSO:
    DECF contadormin2, F
    RETURN
NORMALCURSO2:
    DECF contadorminuten2, F
    RETURN
PRIORITY1: 
    BSF FLAG2, 6 
    RETURN
PRIORITY2: 
    BSF FLAG2, 5 
    RETURN
CASO9_2: 
    MOVLW 9
    MOVWF contadormin2
    BSF FLAG2, 7
    RETURN
CASO5_2:
    MOVLW 5
    MOVWF contadorminuten2
    RETURN
;*******************************************************************************
;Subrutina de Alarma
;*******************************************************************************
REVISION_CONSTANTE:
                                    ;Movemos contadores (que se dirigen 
				    ;a los display) de modo reloj y 
				    ;modo configuración para compararlos. 
   MOVF contadormin, W
   MOVWF contadorvariable
   
   MOVF contadorminuten, W
   MOVWF contadorvariable2
   
   MOVF contadormin2, W
   MOVWF contadorvariable1
   
   MOVF contadorminuten2, W
   MOVWF contadorvariable3
   
   MOVF contadorhrs, W
   MOVWF contadorvariable4
   
   MOVF contadorhrs2, W
   MOVWF contadorvariable5
   
   MOVF contadorstd, W
   MOVWF contadorvariable6
   
   MOVF contadorstd2, W
   MOVWF contadorvariable7
   
PASO1:
    MOVF contadorvariable1, W              ;Matchean los minutos
    SUBLW 0
    BTFSC STATUS, 2
    GOTO ELPASOTEXAS
    DECF contadorvariable1, F
    
    DECF contadorvariable, F                        
    GOTO PASO1                                       
ELPASOTEXAS:               
    MOVF contadorvariable3, W             ;Matchaean los minutos 
    SUBLW 0
    BTFSC STATUS, 2
    GOTO NEXTO
    DECF contadorvariable3, F
    
    DECF contadorvariable2, F
    GOTO ELPASOTEXAS

NEXTO: 
    MOVF contadorvariable5, W             ;Matchean las horas
    SUBLW 0
    BTFSC STATUS, 2
    GOTO SNEAKY
    DECF contadorvariable5, F
    
    DECF contadorvariable4, F
    GOTO NEXTO
SNEAKY:
    MOVF contadorvariable7, W              ;Matchean las horas
    SUBLW 0
    BTFSC STATUS, 2
    GOTO ADELANTO
    DECF contadorvariable7, F
    
    DECF contadorvariable6, F
    GOTO SNEAKY
ADELANTO: 
    MOVF contadorvariable, W               ;Si matchea todo, todas las lineas 
                                           ;siguientes dirigiran a la linea 
					   ;denominada SELOGROMANO. 
    SUBLW 0
    BTFSC STATUS, 2
    INCF LASTFLAG, F
    
    MOVF contadorvariable2, W
    SUBLW 0
    BTFSC STATUS, 2
    INCF LASTFLAG, F
    
    MOVF contadorvariable4, W
    SUBLW 0
    BTFSC STATUS, 2
    INCF LASTFLAG, F
    
    MOVF contadorvariable6, W
    SUBLW 0
    BTFSC STATUS, 2
    INCF LASTFLAG, F
    
    MOVF LASTFLAG, W
    SUBLW 4
    BTFSC STATUS, 2
    GOTO MANOSELOGRO
    CLRF LASTFLAG
    GOTO ONO
MANOSELOGRO: 
    BSF PORTA, 7                         ;La alarma se activa. 
    CLRF LASTFLAG                        ;Se limpia la bandera que indica match.
ONO:
    RETURN                               ;Regresamos.
;*******************************************************************************
;Subrutina porqué no
;*******************************************************************************
DIAS: 
    CLRF contadorstd
    CLRF contadorhrs
    CLRF contadorhoras
                                   ;NUEVAMENTE REVISAMOS EN QUÉ MES ESTAMOS...
    MOVF contadormeses, W
    SUBLW 1               
    BTFSS STATUS, 2                ;¿Enero?
    GOTO NEXXT1
    
    GOTO MESSETEADO31
                                  
NEXXT1:
    MOVF contadormeses, W
    SUBLW 2
    BTFSS STATUS, 2                 ;¿Febrero?
    GOTO NEXXT2
   
    GOTO MESSETEADO28

NEXXT2:
    MOVF contadormeses, W
    SUBLW 3
    BTFSS STATUS, 2                 ;¿Marzo?
    GOTO NEXXT3
    
    GOTO MESSETEADO31
    
NEXXT3: 
    MOVF contadormeses, W
    SUBLW 4
    BTFSS STATUS, 2                 ;¿Abril?
    GOTO NEXXT4
    
    GOTO MESSETEADO30

NEXXT4:
    MOVF contadormeses, W
    SUBLW 5
    BTFSS STATUS, 2                 ;¿Mayo?
    GOTO NEXXT5
    
    GOTO MESSETEADO31
    
NEXXT5:
    MOVF contadormeses, W
    SUBLW 6
    BTFSS STATUS, 2                 ;¿Junio?
    GOTO NEXXT6
    
    GOTO MESSETEADO30
NEXXT6:
    MOVF contadormeses, W
    SUBLW 7
    BTFSS STATUS, 2                 ;¿Julio?
    GOTO NEXXT7
    
    GOTO MESSETEADO31
NEXXT7:
    MOVF contadormeses, W
    SUBLW 8
    BTFSS STATUS, 2                 ;¿Agosto?
    GOTO NEXXT8
    
    GOTO MESSETEADO31
NEXXT8:
    MOVF contadormeses, W
    SUBLW 9
    BTFSS STATUS, 2                 ;¿Septiembre?
    GOTO NEXXT9
    
    GOTO MESSETEADO30
NEXXT9: 
    MOVF contadormeses, W
    SUBLW 10
    BTFSS STATUS, 2                 ;¿Octubre?
    GOTO NEXXT10
    
    GOTO MESSETEADO31
NEXXT10:
    MOVF contadormeses, W
    SUBLW 11
    BTFSS STATUS, 2                ;¿Noviembre?
    GOTO NEXXT11
    
    GOTO MESSETEADO30
NEXXT11:
    GOTO MESSETEADO31             ;¿Diciembre?
    
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
    ;Resetero de dias
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
    ;Reseteo de dias
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
    ;Reseteo de dias
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
;******************************************************************************* 
; Subrutinas de Configuración 
;******************************************************************************* 
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
    MOVLW   253
    ;MOVLW   63
    MOVWF   TMR0                ;Se carga el delay al TMR0
    BCF     INTCON, 2           ;La interrupción del TMR0 se borra al inicio
    RETURN 
CONFIG_TMR1: 
    BANKSEL T1CON
    BSF T1CON, 5
    BSF T1CON, 4	        ;Prescaler de 1:8
    
    BCF T1CON, 1	        ;TMR1CS Fosc/4 reloj interno
    
    BSF T1CON, 0	        ;TMR1ON enable
    
    BANKSEL TMR1L
    MOVLW 0x8F
    MOVWF TMR1L
    MOVLW 0xFD
    MOVWF TMR1H                 ;Cargamos el Delay
    
    BANKSEL INTCON
    BCF PIR1, 0		        ;Borrando la bandera de interrupción TMR1IF
    BSF PIE1, 0		        ;Se habilita la interrupcion del TMR1
    BSF INTCON, 6	        ;Se habilita la interrupción del PEIE
    
    RETURN
CONFIG_INTERRUPTS:
    BSF INTCON, 5               ;INTCON<5> Se habilita la interrupción del TMR0
    BCF INTCON, 2               ;INTCON<2> Interrupción del TMR0 se empieza en 0
    
    BANKSEL IOCB 0
    MOVLW 0b11111111
    MOVWF IOCB                  ;Todos los pines del PORTB tienen interrupciones
    BSF INTCON, 3               ;Se habilitan las interrupciones del Puerto B
    BCF INTCON, 0               ;Las interrupciones del Puerto B empiezan en 0
    BSF INTCON, 7               ;Se habilitan las interrupciones globales
    RETURN
    
CONFIG_VARIABLES: 
    ;Se limpian las variables
    CLRF contadorseg
    CLRF contadorsec
    CLRF contadormin
    CLRF contadorminuten
    CLRF contadorhrs
    CLRF contadorstd
    CLRF contadorminutos
    CLRF contadorhoras
    CLRF cont5ms
    CLRF cont500ms
    CLRF FLAG
    CLRF contadormin2
    CLRF contadorminuten2
    CLRF contadorhrs2
    CLRF contadorstd2
    CLRF FLAG2
    CLRF contadorhoras2
    CLRF BANDOLERO2
    CLRF contadorvariable
    CLRF contadorvariable2
    CLRF contadorvariable1
    CLRF contadorvariable3
    CLRF contadorvariable4
    CLRF contadorvariable5
    CLRF contadorvariable6
    CLRF contadorvariable7
    CLRF LASTFLAG
    
    ;Nos aseguramos que inicie en Modo Reloj
    BANKSEL BANDERAS
    MOVLW 0b00000001
    MOVWF BANDERAS
    
    ;Inicializar Meses y Dias (y respectivas variables a mostrarse en los
    ;displays en 1 de Enero)
    MOVLW 1
    MOVWF contadordias1
    
    MOVLW 0
    MOVWF contadordias2
    
    MOVLW 1
    MOVWF contadormeses1
    
    MOVLW 0
    MOVWF contadormeses2
    
    MOVLW 1
    MOVWF contadormeses
    
    MOVLW 1
    MOVWF contadordias
    
    RETURN
    
;*******************************************************************************
; Fin de Código
;*******************************************************************************
    END


D