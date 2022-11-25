GLOBAL main
EXTERN addition
EXTERN GetStdHandle
EXTERN WriteConsoleA

DEFAULT REL

SECTION .data

message:	db  "Hello World!", 13, 10
msglen:		equ $-message

SECTION .text

main:
	MOV RCX, -11			; -11 als Parameter um STD_OUTPUT_HANDLE zu bekommen
	CALL GetStdHandle
	MOV RCX, RAX			; Der Handle als erster Parameter für den nächsten Aufruf
	MOV RDX, message		; Pointer auf den String
	MOV R8, msglen			; Länge des Strings
	MOV R9, 0				; Null als vierter Paramter
	MOV dword [RSP+20h],0	; Fünfter Paramter auf den Stack, auch Null
	CALL WriteConsoleA		

	MOV RCX, 42				; 42 als erster Parameter
	MOV RDX, 7				; 7 als zweiter Parameter
	CALL addition			; unsere Additionsfunktion aufrufen
	RET						; Als exit code unseres Programms sollte
							; uns nun 49 angezeigt werden