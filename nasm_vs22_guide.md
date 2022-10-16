# x64 NASM mit Visual Studio 2022 Guide

## Vorrausetzungen

- nasm
- Visusl Studio 2022 inklusive CMake
- ein paar C Kennntnisse

## Einführung zu Registern und der Calling Convention
Anders als in gewöhlichen Programmiersprachen arbeitet man in Assembler nicht mit Variablen sondern mit Prozzesorregistern. Ein Register ist eine kleine Speichereinheit im Prozessor mit einer Größe von 8 Byte (auf einem x64 System), in denen beliebige 8 Byte große Werte gespeichert werden können. Da 8 Byte wahrscheinlich ziemlich wenig wären gibt es zum Glück 16 Register im Prozessor, diese haben die folgenden Namen:
- RAX
- RCX
- RDX
- R8
- R9
- R10
- R11
- R12
- R13
- R14
- R15
- RBX
- RBP
- RDI
- RSI
- RSP

Es gibt noch einige weitere Register, die nicht aber nicht direkt veränderlich sind oder nur für bestimmte Operationen gebraucht werden, dazu kommen wir aber zu gegebener Zeit. Außerdem möchte ich noch davor warnen die unteren 9 Register, also alles unter R11 in dieser Liste, einfach so zu überschrieben, sofern man nicht weiß was man da tut, dazu werden auch noch im Einzelnen später kommen.

Wenn man in Assembler eine Funktion aufruft müssen auch die Parameter dieser Funktion mithilfe von Registern übergeben werden. Dazu werden die Paramter der Funktion in Registern gespeichert bevor die Funktion aufgerufen wird. Die aufgerufene Funktion findet ihre Parameter dann in den entsprechenden Registern. Um zu regeln welche Parameter in welches Register gespeichert werden, gibt es die Calling Convention. Windows und Linux haben jeweils eine eigene Calling Convention. Für den Anfang reicht es aber erstmal zu wissen, wie auf Windows Parameter übergeben werden. Der erste Parameter einer Funktion wird im Register RCX gespeichert, der zweite im Register RDX, der dritte in R8 und der vierte in R9 oder übersichtlicher so:

<table>
  <tr>
    <td>Parameter</td>
    <td>1</td>
    <td>2</td>
    <td>3</td>
    <td>4</td>
  </tr>
  <tr>
    <td>Register</td>
    <td>RCX</td>
    <td>RDX</td>
    <td>R8</td>
    <td>R9</td>
  </tr>
</table>

Auch der Rückgabewert einer Funktion muss in ein Register gespeichert, in das Register RAX um genau zu sein. Bevor eine Funktion endet und mit return zurückkehrt, wird der Rückgabewert in RAX abgelegt.

Wenn man also eine Funktion hat, die in C so aussähe:
```C
int func1(int a, int b, int c, int d);
```
hätte man den Parameter a in RCX, b in RDX, c in R8 und d in R9.

Weiteres zur Windows Calling Convention kann man [hier](https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170) finden, aber für den Anfang reicht es den hier erkläten Teil zu kennen.

## Erste Schritte

### Ein neues Projekt anlegen
Zuerst legen wir ein neues Projekt in Visual Studio an und wählen dabei CMake als Vorlage aus

![neues CMake Projekt](images/newproject.png)

Visual Studio legt dabei auch direkt einen Unterordner mit einem cpp Hello World Programm an. Das brauchen wir aber nicht und entfernern es daher direkt zusammen mit der Header Datei. 
Stattdessen legen wir dort eine C Datei mit dem Namen ```main.c``` an, die wir benutzen werden um unsern Assembler Code auszuführen. Das sollte dann so aussehen:

![Dateien](images/files1.png)

### Das erste Assembler Programm
Anders als bei den meisten Programmiertutorials fangen wir nicht mit einem Hello World an, sondern wir implementieren die Grundrechenarten in Assembler. Das Arbeiten mit Zahlen ist in Assembler nämlich deutlicher leicher als das Arbeiten mit Strings oder gar Konsolenausgaben.

Um diese Funktionen auch in C später benutzen zu können, legen wir eine Header Datei an und deklarieren darin folgende Funktionen:
```C
int addition(int a, int b);
int subtraktion(int a, int b);
int multiplikation(int a, int b);
int division(int a, int b);
```

Dann legen wir die eigentliche Assembler Datei an und nennen sie ```calc.asm```. Die erste Zeile sollte lauten:
```asm
SECTION .text
```
Eine Assembler Code Datei besteht aus mehreren Sektionen, die vermutlich wichtigste ist ```.text```, darin befindet sich der Code nacher ausgeführt wird. Später werden wir noch andere Sektionen kennenlernen, die andere Teile des Programms beinhalten, die z.B. reservierte Bereiche im Arbeitsspeicher anlegen. Fürs erste werden wir aber nur ```.text``` brauchen.

Fangen wir an mit der Funktion für die Addition: Um eine Funktion zu schreiben, die auch aus unserem C Programm aufgerufen werden kann, müssen wir kenntlich machen wo im Code unsere Funktion beginnt. Das machen wir mit einem Label. Ein Label besteht aus einem Bezeichner gefolgt von einem Doppelpunkt. Wir können beliebig viele Labels erstellen, aber wir brauchen ein Label mit dem Namen der Funktion als Bezeichner, damit die Funktion nachher beim Kompilieren vom Linker gefunden wird. Wir legen also so ein entsprechendes Label für unsere Funktion an:
```asm
SECTION .text

addition:

```
Damit ist jetzt gekennzeichnet ab wo der Code für die Funktion ```addition``` beginnt. Aber Label sind nicht für externe Dateien sichtbar, d.h. der Linker würde unsere Funktion immer noch nicht finden. Mithilfe des Keywords ```GLOBAL``` können wir ein Label aber auch nach außen hin sichtbar machen. Dazu schrieben wir oben an den Anfang unserer Datei das Keyword ```GLOBAL``` und dann unser Label:
```asm
GLOBAL addition
SECTION .text

addition:
```

Nun fehlt aber noch der eigentliche Code. Der Assmbler Befehl für das addieren zweier Ganzzahlen ist ```ADD``` und hat zwei Operanden ```dest``` und ``src``, getrennt durch ein Komma. Der ```ADD``` Befehl addiert die Werte von ```src``` und ```dest``` und speichert das Ergebnis in ```dest```. Wenn wir also ```ADD RAX, RCX``` als Befehl schreiben, werden die Werte in RAX und RCX addiert und das Ergebnis in RAX gespeichert. Der Befehl überschreibt dabei den ursprünglichen Wert in RAX. Um ```ADD``` für unsere Funktion zu benuzten, müssen wir nun nur noch wissen welche Register wir als Operanden hinzufügen müssen. Wenn wir uns also nochmal an die Calling Convention erinnern, sehen wir, dass die beiden Parameter für unsere Funktion in RCX und RDX finden werden, also fügen wir diese beiden als Operanden hinzu:
```asm
GLOBAL addition
SECTION .text

addition:
    ADD RCX, RDX

```
(Die Einrückung des Befehls ist optisch und nicht zwingend nötig.)

Wenn dieser Befehl nun ausgeführt wird, werden die beiden Parameter unserer Funktion, die in den Registern RCX und RDX zu finden sind, addiert und das Ergebnis in RCX gespeichert.

Unsere Funktion ist damit aber noch nicht fertig. Wir müssen das Ergebnis unserer Rechnung auch noch als Rückgabewert zurückgeben. Laut Calling Convention wird der Rückgabewert in RAX gespeichert, also müssen wir unser Ergebnis von RCX nach RAX kopieren. Dazu gibt es den ```MOV``` Befehl, der ebenfalls die Operanden ```dest``` und ```src``` hat. Wie die Namen schon vermuten lassen, wird hier der Wert von ```src``` nach ```dest``` kopiert. Ganz zum Ende unserer Funktion fügen wir dann noch den Befehl ```RET``` ein. Der funktioniert ähnlich wie die ```return``` Anweisung in vielen Sprachen und beendet die Ausführung der Funktion. Anders als in vielen Sprachen ist diese Anweisung hier aber explizit notwendig und das Program würde nicht funktionieren wenn man das ```RET``` einfach weglässt. Am Ende sieht unsere Funktion also so aus:
```asm
GLOBAL addition
SECTION .text

addition:
    ADD RCX, RDX
    MOV RAX, RCX
    RET

```
Für etwas bessere Verstänlichkeit können wir noch Kommentare zu unserem Code hinzufügen. In nasm beginnen Kommentare mit einem Semicolon:
```asm
GLOBAL addition
SECTION .text

addition:           ;addition Funktion mit den Parametern in RCX und RDX
    ADD RCX, RDX    ;Addiert RCX und RDX und speichert das Ergebnis
    MOV RAX, RCX    ;Kopiert das Ergebnis von RCX nach RAX
    RET             ;Ende der Funktion

```
### Der C Teil unseres Programms
Bevor wir mit den übrigen Funktionen weitermachen, werden wir erstmal unseren C Teil hinzufügen und unser Programm kompilieren und austesten. Da das hier kein C Tutorial ist, gebe ich den C Code hier einfach mal vor.
```C
#include <stdio.h>
#include <stdlib.h>
#include "calc.h"

int main(int argc, char* argv[]) {
	int a, b;
	if (argc >= 3) {
		a = atoi(argv[1]);
		b = atoi(argv[2]);
	}
	else
	{
		a = 12;
		b = 3;
	}
	int add = addition(a, b);
	printf("%i + %i = %i\n", a, b, add);
	
}
```
Der Code ruft unsere ```addition``` Funktion auf mit Parametern aus der Kommandozeile oder sonst mit den Werten 12 und 3 als Beispiel.

### CMake anpassen und kompilieren
Visual Studio hat für uns bei der Erstellung des Projekts zwei CMakeLists.txt angelegt. Wir brauchen aber nur die CMakeLists.txt, die in dem Ordner mit unserem Code liegt. 
Um unser Programm kompilieren zu können müssen wir CMake nur mitteilen, dass wir nasm verwenden und welche Dateien wir zur Exe hinzugefügt haben wollen.  Den von Visual Studio erstellten überschreiben wir einfach mit:
```CMake
cmake_minimum_required (VERSION 3.8)

enable_language(ASM_NASM)

add_executable (nasm_tutorial main.c calc.asm)
```
Nun können wir unser Programm kompilieren indem wir in Visual Studio auf Erstellen -> Alle erstellen drücken oder Strg+Shift+B drücken und können es dann mit F5 ausführen oder die Schaltfläche zum Debuggen drücken. Eventuel muss die erstellte exe noch als Startelement ausgewählt werden. 

![Die exe als Startelement](images/launch_select.png)

Und nun können wir das Ergebnis unserer Rechnung mithilfe unseres ersten Assembler Programms bewundern:

![12 + 3 = 15](images/run1.png)

### Die übrigen Funktionen
Nun fehlen noch die Funktionen für die anderen drei Rechenarten. Mit dem was wir beim Schreiben der ersten Funktion gelernt haben, sollte das nun kein Problem mehr darstellen. Nur brauchen wir neue Befehle um zu subtrahieren, multiplizieren und dividieren. An dieser Stelle möchte ich daher mal auf das Handbuch [hier](https://www.amd.com/system/files/TechDocs/24594.pdf) hinweisen. Darin findet sich unter anderm alles was man zu den Befehlen wissen muss (welche Operanden sie verwenden, was der Befehl macht, und was noch durch den Befehl beeinflusst wird). Das Inhaltsverzeichnis gibt eine gute Übersicht über alle Befehle (zu finden in Kapitel 3) und hilft die Erklärungen zu einzelnen Befehlen zu finden. Die Befehle für Addition und Substraktion sind ```ADD``` und ```SUB```, die Befehle für Multiplikation und Division sind ```MUL``` und ```DIV``` bzw. ```IMUL``` und ```IDIV``` für vorzeichenbehaftete Multiplikation und Division. Mit den Namen der Befehle, dem Handbuch, und bisher gelernten sollte es dann kann kein Problem sein selbst auf den Code für die übrigen Funktionen zu kommen.
Hier der C Code mit dem dann auch die übrigen Funktionen getest werden können:

```C
#include <stdio.h>
#include <stdlib.h>
#include "calc.h"

int main(int argc, char* argv[]) {
	int a, b;
	if (argc >= 3) {
		a = atoi(argv[1]);
		b = atoi(argv[2]);
	}
	else
	{
		a = 12;
		b = 3;
	}
	int add = addition(a, b);
	int sub = subtraktion(a, b);
	int mul = multiplikation(a, b);
	int div = division(a, b);
	printf("%i + %i = %i\n", a, b, add);
	printf("%i - %i = %i\n", a, b, sub);
	printf("%i * %i = %i\n", a, b, mul);
	printf("%i / %i = %i\n", a, b, div);
	
}
```
Am Ende dieses Guides findet sich auch eine Lösung mit dem Assembler Code für zum Nachprüfen oder falls Hilfe benötigt wird.

## Lösungen
### Die vier Grundrechenarten
```asm
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

```