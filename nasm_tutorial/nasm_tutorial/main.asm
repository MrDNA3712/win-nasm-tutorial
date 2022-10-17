GLOBAL main
EXTERN addition
SECTION .text

main:
	MOV RCX, 42		; 42 als erster Parameter
	MOV RDX, 7		; 7 als zweiter Parameter
	CALL addition	; unsere Additionsfunktion aufrufen
	RET				; Als exit code unseres Programms sollte
					; uns nun 49 angezeigt werden