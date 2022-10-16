GLOBAL addition
GLOBAL subtraktion
GLOBAL multiplikation
GLOBAL division
SECTION .text

addition:           ;addition Funktion mit den Parametern in RCX und RDX
    ADD RCX, RDX    ;Addiert RCX und RDX und speichert das Ergebnis in RCX
    MOV RAX, RCX    ;Kopiert das Ergebnis von RCX nach RAX
    RET         

subtraktion:
    SUB RCX, RDX    ;Subtrahiert RDX von RCX und speichert das Ergebnis in RCX
    MOV RAX, RDX    ;wie zuvor Ergebnis kopieren für die Rückgabe
    RET

; IMUL und IDIV sind eigentlich für vorzeichenbehaftete Multiplikation und Division,
; aber funktionieren quasi wie die ADD und SUB Befehle, daher hier MUL und DIV

multiplikation:
    MOV RAX,RCX     ;Der erste Faktor wird nach RAX verschoben
    MUL RDX         ;Der zweite Faktor ist der Operand von RDX
                    ;MUL multipliziert RAX mit dem Operanden, also RDX
    RET             ;Das Ergbenis befindet sich bereits in RAX 
                    ;also können wir direkt RET nutzen
    
division:
    MOV RAX,RCX     ;Der Dividend befindet sich in RAX
                    ;Allerdings ist der DIV Befehl für sehr große Zahlen ausgelegt, 
                    ;und RAX ist nicht der ganze Divdend sondern RDX und RAX zusammen
                    ;Für diese Operation werden RDX und RAX aneinandergehängt zu einer 
                    ;16 Byte (128bit) Zahl statt zweier 8 Byte Zahlen
    MOV R8, RDX     ;Daher können wir RDX auch nicht als Divisor verwenden
                    ;und kopieren den Divisor nach R8
    MOV RDX, 0      ;Da RDX und RAX zusammengefügt werden, muss RDX = 0 sein, damit 
                    ;wir nicht einen deutlich größeren Dividenden haben
    DIV R8          ;Dividieren durch den Divisor in R8
    RET             ;Der Quotient ist in RAX also verwenden wir direkt RET
                    ;DIV speichert den Rest der Division in RDX, 
                    ;womit sich auch Modulo hätte implementieren lassen