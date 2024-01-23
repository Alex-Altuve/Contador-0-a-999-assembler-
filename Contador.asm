
;====================================================================
; DEFINITIONS
;====================================================================

#include p16f84a.inc                ; Include register definition file
   __CONFIG _XT_OSC & _PWRTE_ON & _CP_OFF & _WDT_OFF

;====================================================================
; VARIABLES
;====================================================================
        RADIX HEX

PUERTOA 				EQU 05H
PUERTOB 				EQU 06H ; Declaración del puerto B en la dirección 06 H
STATUS 					EQU 03H ; Declaración del registro de estado
;====================var de los digitos==============================
unidad					EQU 0FH ; contador de las unidades
decenas                                 EQU 10H ; Contador de la decenas
centenas				EQU 12H
;=====================VARIABLES PARA EL DELAY========================   
ContadorA				equ 0CH
ContadorB			        equ 0DH
ContadorC				equ 0EH

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

	ORG 	0
      	goto  Start
	ORG 	5
;====================================================================
; CODE SEGMENT
;====================================================================

Start	
    BSF STATUS,5 ; Cambio del banco de memoria. Banco 1 activado.
    CLRF TRISB ; Configuración de la puerta B como puerto de salida.
    CLRF TRISA
    BCF STATUS,5 ; Cambio del banco de memoria. Banco 0 activado    
    CLRF unidad 
    CLRF decenas
    CLRF centenas

loop
   call DesplegarDatos
   call ValidarUnidad
   goto loop

ValidarUnidad
   movlw d'10'
   subwf unidad,0
   btfsc STATUS, Z
   call ValidarDecenas ;llego a 10
   incf unidad, 1  ; no ha llegado a 10   
   return

ValidarDecenas  
  clrf unidad
  movlw d'10'
  subwf decenas,0
  btfsc STATUS,Z
  call ValidarCentenas ;si es 
  incf decenas, 1  ; si no es
  call DesplegarDatos 
  return

ValidarCentenas
  clrf decenas
  movlw d'10'
  subwf centenas,0
  btfsc STATUS,Z
  call Validar999 
  incf centenas, 1  ;si no es 
  call DesplegarDatos 
  return

Validar999
   CLRF unidad 
   CLRF decenas
   CLRF centenas
   call DesplegarDatos
   return

DesplegarDatos 
   movlw b'0111'
   movwf PUERTOA
   movf unidad, 0
   call TABLA
   movwf PUERTOB
   call Retardo_1s

   movlw b'1011'
   movwf PUERTOA
   movf decenas, 0
   call TABLA
   movwf PUERTOB
   call Retardo_1s
   
   movlw b'1101'
   movwf PUERTOA
   movf centenas, 0
   call TABLA
   movwf PUERTOB
   call Retardo_1s
  return  
    
TABLA
	ADDWF	PCL,F
	RETLW	h'3F'
	RETLW	h'06'
	RETLW	h'5B'
	RETLW	h'4F'
	RETLW	h'66'
	RETLW	h'6D'
	RETLW	h'7D'
	RETLW	h'07'
	RETLW	h'7F'
	RETLW	h'6F'

Retardo_1s            
	movlw	d'10'      
	movwf	ContadorC  
Retardo_BucleExterno2
	movlw	d'15'     
	movwf	ContadorB  
Retardo_BucleExterno
	movlw	d'40'     
	movwf	ContadorA  
Retardo_BucleInterno
	nop                
	decfsz	ContadorA,1 
	goto	Retardo_BucleInterno 
	decfsz	ContadorB,1    
	goto	Retardo_BucleExterno 
	decfsz	ContadorC,1  
	goto	Retardo_BucleExterno2 
	return  	

	END