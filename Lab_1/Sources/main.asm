;*******************************************************************
;*	  Filename      : main.asm									   *
;*	  Created On    : 31/01/2017								   *
;*	  Last Modified : 01/02/2017								   *
;*	  Revision      : 1.1a								 		   *
;*	  Author        : Prof Martha Perez / Javier Pose			   *
;*	  Description   : EC2721 - Arquitectura del Computador II	   *
;*	                        Lab 2: Lenguaje Ensamblador		  	   *
;*******************************************************************

;-------------------------------------------------
; Include derivative-specific definitions
;-------------------------------------------------
                INCLUDE 'derivative.inc'

;-------------------------------------------------
; export symbols
;-------------------------------------------------
                XDEF _Startup
                ABSENTRY _Startup

;-------------------------------------------------
; variable/data section
;-------------------------------------------------
                ORG     Z_RAMStart			; Pagina Zero Dir = $0080
Resultado1:     DS.B    1		  			; Esta variable se encuentra guardada en la dir = 0x0080
Resultado2:     DS.B    1					; Esta variable se encuentra guardada en la dir = 0x0081

VARIABLEtemp:   DS.B    1					; Esta variable se encuentra guardada en la dir = 0x0082
CUENTA:         DS.B    1					; Esta variable se encuentra guardada en la dir = 0x0083
HXtemp:			DS.B	2					; Esta variable se encuentra guardada en las dir = 0x0084 - 0x0085
HZtemp:         DS.B   	2					; Esta variable se encuentra guardada en las dir = 0x0086 - 0x0087
MAGIC:			DS.B	1					; Esta variable se encuentra guardada en la dir = 0x0088

				ORG	$90						; Dir = $0090
MENSAJE:        DS.B    16					; Aqui se reservan los 16 bytes del mensaje. Desde 0x90 hasta 0x9F
			

;-------------------------------------------------
; code section
;-------------------------------------------------
                
                ORG     ROMStart			; El programa se carga a partir de la direccion $8000
_Startup:       LDA     #$42				; _Startup = $42
                STA     SOPT1          		; disable watchdog
                LDHX    #RAMEnd+1      		; RAMEnd = $00FF , HX = $0100
                TXS                     	; Se inicializa el stack pointer en la direccion SP = $0100 

Prologo_rutina:
                LDA     NUM1				; Se carga NUM1 = $00 en el Acumulador
                PSHA						; Se Guarda el contenido del Acumulador ($00) en $00FF (Ahi estaba el Stack Pointer)
                							; El Stack pointer se mueve a la posicion $00FE
                LDA     NUM2				; Se carga NUM2 = $00 en el Acumulador
                PSHA						; Se Guarda el cont. del Acumulador ($00) en $00FE (Ahi estaba el Stack Pointer)
               								; El Stack pointer se mueve a la posicion $OOFD
Salto_Rutina:
                JSR     Rutina				; Se ejecuta un salto a la Subrutina "Rutina"
                							; La Direccion del PC se guarda en el Stack, PCL en $00FC y PCH en $00FD
                							; Ahora el SP apuinta a $00FC
Epilogo_Rutina:
                PULA						; Se saca del Stack lo que esta en $00FC (posicion siguiente al SP) y se guarda en A
                							; El SP queda en $00FD
                STA     Resultado1			; Se guarda A=$00FC en la direcci�n Resultado1=$0080
                PULA                   		; Se saca del Stack lo que esta en $00FD (posicion siguiente al SP) y se guarda en A
                							; El SP queda en $00FE
                STA     Resultado2			; Se guarda A=$00FD en la direcci�n Resultado2=$0081
                CLI			        		; Se activan las interrupciones

;-----------------------------------------------------------------------------------
; Escribir una rutina que mueva el mensaje de su grupo a MENSAJE en RAMStart
;-----------------------------------------------------------------------------------
INICIALIZAR:
				MOV		#$F,CUENTA			;Se inicializa la variable cuenta en $F = 15
				LDA		Resultado1			;Se carga Resultado1 = $FF en el Acumulador 
				STA		MAGIC				;Se guarda A=$FF en MAGIC
				LDHX 	#MESSG1				;Se cargar en el registro HX la direccion donde comienzan los mensajes = $4010
				LDX		MAGIC				;Se cargar en el registro X con el offset de nuestro mensaje.
				STHX 	HXtemp				;Se guarda la direccion $4010 en la variable HXtemp
				LDHX 	#MENSAJE			;Se carga en el registro HX  la direccion donde se guardara nuestro mensaje = $0090
				STHX 	HZtemp				;Se guarda la direccion $0090 en la variable HZtemp
MUEVE_MENSAJE:

				LDHX 	HXtemp				;Se Carga en el registro HX el contenido de HXtemp
				MOV 	X+,VARIABLEtemp		;Se copia lo que esta en HX hacia VARIABLEtemp, Se incrementa en 1 el registro HX
				STHX 	HXtemp				;Se vuelve a guardar ya incrementado el valor de HX en la variable HXtemp
				
				LDHX 	HZtemp				;Se Carga en el registro HX el contenido de HZtemp
				MOV 	VARIABLEtemp,X+		;Se copia lo que esta VARIABLEtemp hasta la direccion de HX, Se incrementa en 1 el registro HX
				STHX 	HZtemp				;Se vuelve a guardar ya incrementado el valor de HX en la variable HZtemp
				
				DBNZ 	CUENTA,MUEVE_MENSAJE;Decrementa en 1 el contenido de CUENTA, si no ha llegago a "0" hace un salto
											;relativo hasta MUEVE_MENSAJE, si Cuenta llega a "0" sigue. 


;-----------------------------------------------------------------------------------
;                
;-----------------------------------------------------------------------------------
mainLoop:
                NOP
                BRA     mainLoop
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                ORG     $4000						; Constantes globales
NUM1:           DC.B    $00							; RECUERDEN COLOCAR NUM1 !!!
NUM2:           DC.B    $00							; RECUERDEN COLOCAR NUM2 !!!
                ORG     $4010
MESSG1:     	DC.B    "BIENVENIDO",$20,"GR01",0   ; Mensaje Guardado desde $4010 hasta $401F (Grupo 01)
MESSG2:    		DC.B    "BIENVENIDO",$20,"GR02",0   ; Mensaje Guardado desde $4020 hasta $402F (Grupo 02)
MESSG3:     	DC.B    "BIENVENIDO",$20,"GR03",0   ; Mensaje Guardado desde $4030 hasta $403F (Grupo 03)
MESSG4:     	DC.B    "BIENVENIDO",$20,"GR04",0   ; Mensaje Guardado desde $4040 hasta $404F (Grupo 04)
MESSG5:     	DC.B    "BIENVENIDO",$20,"GR05",0   ; Mensaje Guardado desde $4050 hasta $405F (Grupo 05)
MESSG6:     	DC.B    "BIENVENIDO",$20,"GR06",0   ; Mensaje Guardado desde $4060 hasta $406F (Grupo 06)
MESSG7:     	DC.B    "BIENVENIDO",$20,"GR07",0   ; Mensaje Guardado desde $4070 hasta $407F (Grupo 07)
MESSG8:     	DC.B    "BIENVENIDO",$20,"GR08",0   ; Mensaje Guardado desde $4080 hasta $408F (Grupo 08)
MESSG9:     	DC.B    "BIENVENIDO",$20,"GR09",0   ; Mensaje Guardado desde $4090 hasta $409F (Grupo 09)
MESSG10:    	DC.B    "BIENVENIDO",$20,"GR10",0   ; Mensaje Guardado desde $40A0 hasta $40AF (Grupo 10)
MESSG11:    	DC.B    "BIENVENIDO",$20,"GR11",0   ; Mensaje Guardado desde $40B0 hasta $40BF (Grupo 11)
MESSG12:    	DC.B    "BIENVENIDO",$20,"GR12",0   ; Mensaje Guardado desde $40C0 hasta $40CF (Grupo 12)
MESSG13:    	DC.B    "BIENVENIDO",$20,"GR13",0   ; Mensaje Guardado desde $40D0 hasta $40DF (Grupo 13)
MESSG14:    	DC.B    "BIENVENIDO",$20,"GR14",0   ; Mensaje Guardado desde $40E0 hasta $40EF (Grupo 14)
MESSG15:    	DC.B    "BIENVENIDO",$20,"GR15",0   ; Mensaje Guardado desde $40F0 hasta $40FF (Grupo 15)


;-----------------------------------------------------------------------------------
; Rutina que recibe 2 parametros en el STACK
;-----------------------------------------------------------------------------------
; ---------
; SP--->Empty
; ---------
; LOCAL2
; ---------
; LOCAL1
; ---------
; PCH
; ---------
; PCL
; ---------
; PARAM2
; ---------
; PARAM1
; ---------
;-----------------------------------------------------------------------------------
PARAM1:     	EQU 6 						;Parameters passed in
PARAM2:     	EQU 5
LOCAL1:     	EQU 2 						;Local variables
LOCAL2:     	EQU 1
;-----------------------------------------------------------------------------------

Rutina:     	AIS     #-2					; Se rueda el SP dos posiciones hacia atras, Queda en $00FA
            	LDA     PARAM1,SP   		; Carga en el acumulador lo que se encuentra en la posicion del SP con un offset de PARAM1=6
            								; SP + 6 = $0100, Es decir carga $00 en el Acumulador
            	ASRA               			; Realiza un shift aritmético hacia la derecha de lo que tenia el acumulador
            								; El numero cambia de (00000000B)=$00 a (00000000B)=$00
            	STA     LOCAL1,SP   		; Guarda el acumulador=($00) en SP + (LOCAL1=2) = $00FC
            	LDA     PARAM2,SP   		; Carga en el acumulador lo que se encuantra en SP + (PARAM2=5) = $00FF (ahi esta $00 guardado)
            	DECA						; Decrementa en 1 el acumulador=($00), ahora es $FF
            	STA     LOCAL2,SP   		; Guarda el acumulador en SP + (LOCAL2=1) = 00FB
          		LDA     LOCAL1,SP   		; Carga en el acumulador lo que esta en SP + (LOCAL1=2) = $00FC (ahi esta $00)
            	STA     PARAM1,SP   		; Guarda el acumulador=$00 en SP + PARAM1=6 = $0100
            	LDA     LOCAL2,SP			; Carga en el Acumulador lo que esta en SP + (LOCAL2=1) = $00FB (ahi esta $FF)
            	STA     PARAM2,SP   		; Guarda el acumulador=$FF en SP + PARAM2=5 = $00FF
            	AIS     #2					; Mueve el SP dos posiciones, hacia adelante. Queda en $00FC
            	RTS                 		; Retorna de la Subrutina
            								; se Saca del Stack PCH y PCL para guardarlos en el PC, El SP queda en $00FE 

;	    		ORG     ROM1Start   		; Direccion $0C000  aqui colocaremos rutinas de servicio a INT

;**************************************************************
;* spurious - Spurious Interrupt Service Routine.             *
;*             (unwanted interrupt)                           *
;**************************************************************
spurious:									; placed here so that security value
			NOP								; does not change all the time.
			RTI

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG	    Vtpm3ovf
            DC.W    spurious          		; TPM3 overflow
            DC.W    spurious          		; TPM3 CH5
            DC.W    spurious          		; TPM3 CH4
            DC.W    spurious         		; TPM3 CH3
            DC.W    spurious         		; TPM3 CH2
            DC.W    spurious         		; TPM3 CH1
            DC.W    spurious         		; TPM3 CH0
            DC.W    spurious          		; RTI
            DC.W    spurious          		; SCI2 Tx
            DC.W    spurious          		; SCI2 Rx
            DC.W    spurious          		; SCI2 Error
            DC.W    spurious          		; Analog comparator X
            DC.W    spurious          		; ADC
            DC.W    spurious          		; Keyboard
            DC.W    spurious          		; IICx Control
            DC.W    spurious          		; SCI1 Tx
            DC.W    spurious          		; SCI1 Rx
            DC.W    spurious          		; SCI1 Error
            DC.W    spurious          		; SPI1
            DC.W    spurious          		; SPI2
            DC.W    spurious          		; TPM2 overflow
            DC.W    spurious          		; TPM2 CH2
            DC.W    spurious          		; TPM2 CH1
            DC.W    spurious          		; TPM2 CH0
            DC.W    spurious          		; TPM1 overflow
            DC.W    spurious          		; TPM1 CH2
            DC.W    spurious          		; TPM1 CH1
            DC.W    spurious          		; TPM1 CH0
            DC.W    spurious          		; Low Voltage
            DC.W    spurious          		; IRQ
            DC.W    spurious          		; SWI
            DC.W    _Startup          		; Reset

;**************************************************************
; 
;**************************************************************

