
;DEBUG    EQU       1                        ; příznak testovacího módu

X        EQU       0bah                     ; kódovací klíč hesel

MAXSCEN  EQU       50                       ; maximální číslo scény

FRSTSCEN EQU       1                        ; inicializační scéna

DELKOBR  EQU       (16*16/8)*4              ; délka jednoho obrázku

POCVECI  EQU       18                       ; počet věcí

LOK      EQU       1                        ; lokomotiva
LO1      EQU       LOK + 0                  ; lokomotiva VLEVO
LO2      EQU       LOK + 1                  ; lokomotiva NAHORU
LO3      EQU       LOK + 2                  ; lokomotiva VPRAVO
LO4      EQU       LOK + 3                  ; lokomotiva DOLŮ

LO5      EQU       LOK + 4                  ; lokomotiva VLEVO
LO6      EQU       LOK + 5                  ; lokomotiva NAHORU
LO7      EQU       LOK + 6                  ; lokomotiva VPRAVO
LO8      EQU       LOK + 7                  ; lokomotiva DOLŮ

LO9      EQU       LOK + 8                  ; lokomotiva VLEVO
LOA      EQU       LOK + 9                  ; lokomotiva NAHORU
LOB      EQU       LOK + 10                 ; lokomotiva VPRAVO
LOC      EQU       LOK + 11                 ; lokomotiva DOLŮ

SRAZKA   EQU       LOK+12                   ; srážka (10 fází)
SR1      EQU       SRAZKA+0
SR2      EQU       SRAZKA+1
SR3      EQU       SRAZKA+2
SR4      EQU       SRAZKA+3
SR5      EQU       SRAZKA+4
SR6      EQU       SRAZKA+5
SR7      EQU       SRAZKA+6
SR8      EQU       SRAZKA+7
SR9      EQU       SRAZKA+8
SRA      EQU       SRAZKA+9

ZED      EQU       SRAZKA+10                ; zeď

VRA      EQU       ZED+1                    ; vrata (6 fází)

VAGONY   EQU       VRA+6                    ; vagony (každý vagon 4 směry)

VECI     EQU       VAGONY + 4*POCVECI       ; věci

KRY      EQU       0  * 3 + VECI            ; 1: krystal
KOR      EQU       1  * 3 + VECI            ; 2: koruna
STO      EQU       2  * 3 + VECI            ; 3: strom
JAB      EQU       3  * 3 + VECI            ; 4: jablko
KRA      EQU       4  * 3 + VECI            ; 5: kráva
TRE      EQU       5  * 3 + VECI            ; 6: třešně
RYB      EQU       6  * 3 + VECI            ; 7: rybník
ZIR      EQU       7  * 3 + VECI            ; 8: žirafa
ZMR      EQU       8  * 3 + VECI            ; 9: zmrzlina
DOR      EQU       9  * 3 + VECI            ; 10: dort
POC      EQU       10 * 3 + VECI            ; 11: počítač
AUT      EQU       11 * 3 + VECI            ; 12: auto
BAL      EQU       12 * 3 + VECI            ; 13: balón
BUD      EQU       13 * 3 + VECI            ; 14: budík
SLO      EQU       14 * 3 + VECI            ; 15: slon
VIN      EQU       15 * 3 + VECI            ; 16: víno
PEN      EQU       16 * 3 + VECI            ; 17: peníze
LET      EQU       17 * 3 + VECI            ; 18: letadlo

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ test karty

Start:   mov       ah,12h
         mov       bx,7a10h
         int       10h
         cmp       bh,1
         ja        Start10
         cmp       bl,3
         jbe       Start1

Start10: mov       dx,offset CardTxt
         mov       ah,9
         push      cs
         pop       ds
         int       21h
         int       20h


Start1:  mov       ax,0dh
         int       10h
         call      CekInit                  ; inicializace hodin

; ------ demonstrace

Start2: ; call      Clear                    ; vymazání obrazovky
         mov       al,0
         call      InitScen                 ; inicializace scény AL (0=DEMO)
         mov       byte ptr ds:[Demon],1    ; je demonstrace
         call      ClearInf
         call      DispScen                 ; zobrazení scény
         mov       byte ptr ds:[CitTit],0

         mov       si,offset DemoPos
Start23:
         call      TestTime                 ; inicializace čítače času
         jc        Start3                   ; není krok

;         mov       ah,1
;         int       16h
;         jz        Start232
;
;         or        ax,ax
;         jz        Start302
;         cmp       al,27
;         je        Start302
;
;Start232:
         call      IncFaze                  ; zvýšení fáze

         call      OpenVrat                 ; otevření vrat

         cmp       byte ptr ds:[Faze],0
         jne       Start3

         cmp       word ptr ds:[MapVlak+1],11*256 + 9
         jne       Start24

         jmp       Start2

Start24:
         mov       dx,ds:[si]
         inc       si
         inc       si
         call      PosVlak

         mov       al,ds:[MapVlak+1]
         shl       al,1
         sub       al,4
         jbe       Start25
         cmp       al,32
         ja        Start25
         cmp       byte ptr ds:[CitTit],32
         jae       Start25
         mov       ds:[CitTit],al
         call      DispTit
Start25:

Start3:  mov       ah,1
         int       16h
         jz        Start23

Start302:mov       ah,0
         int       16h
         or        ax,ax
         jz        Start38
         cmp       al,27
         jne       Start4

Start38: call      SoundOff
         mov       ax,3
         int       10h

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

         int       20h

; ------ start scény

Start4:
         mov       byte ptr ds:[Demon],0    ; není demonstrace
         mov       al,ds:[AktScen]
         call      InitScen                 ; inicializace scény AL (0=DEMO)
         call      DispScen
         call      DispInf                  ; zobrazení informačního řádku

Start41: call      FlushKey

Start5:  call      TestTime                 ; inicializace čítače času
         jc        Start5                   ; není krok

         mov       ah,1
         int       16h
         jz        Start532

         cmp       ax,3e00h
         jne       Start530
         mov       ah,0
         int       16h
         jmp       Heslo

Start530:
         or        ax,ax
         jz        Start531
         cmp       al,27
         jne       Start532

Start531:mov       ah,0
         int       16h
         jmp       short Start61

Start532:

         call      IncFaze                  ; zvýšení fáze

         call      OpenVrat                 ; otevření vrat

         cmp       byte ptr ds:[Faze],0
         jne       Start5


STart60: mov       ah,1
         int       16h
         jz        Start69                  ; není klávesa

Start603:mov       ah,0
         int       16h

         cmp       ax,3e00h
         jne       Start606
         jmp       Heslo                    ; zadání hesla

Start606:
         or        ax,ax
         jz        Start61
         cmp       al,27
         jne       Start62

Start61: call      SoundOff
         jmp       Start2

Start62: cmp       ah,48h
         jne       Start63
         mov       dx,0ff00h                ; nahoru
         jmp       short Start652

Start63: cmp       ah,4bh
         jne       Start64
         mov       dx,0ffh                  ; vlevo
         jmp       short Start652

Start64: cmp       ah,4dh
         jne       Start65
         mov       dx,1                     ; vpravo
         jmp       short Start652

Start65: cmp       ah,50h
         jne       Start60
         mov       dx,1*256                 ; dolů

Start652:cmp       dx,word ptr ds:[Smer]
         je        Start60                  ; směr je již nastaven
         mov       ds:[Smer],dx             ; nový směr

Start69: mov       dx,ds:[Smer]
         or        dx,dx
         jz        Start6

; ------ test, zda vlak do něčeho narazí

         push      dx
         add       dl,ds:[MapVlak+1]
         add       dh,ds:[MapVlak+2]
         mov       al,20                    ; počet pozic
         mul       dh                       ; přepočet řádku na offset
         add       al,dl
         adc       ah,0
         add       ax,offset Pole
         xchg      ax,si                    ; SI <- adresa v poli
         mov       al,ds:[si]               ; prvek na nové pozici
         pop       dx

         cmp       al,0
         je        Start6A
         cmp       al,VECI
         jae       Start6A1
         cmp       al,VRA
         jbe       Start6a2
         cmp       al,VRA+6
         jb        Start6A
Start6a2:jmp       Start8                   ; havárie

Start6A1:mov       word ptr ds:[AdrSound],offset TabSVec
         mov       word ptr ds:[CitSound],offset(TabSVec0-TabSVec) + 1
         jmp       short Start6a4

Start6A:
         mov       word ptr ds:[AdrSound],offset TabSLok
         mov       word ptr ds:[CitSound],offset(TabSLok0-TabSLok) + 1
;ţ
Start6a4:call      PosVlak

         mov       dx,word ptr ds:[MapVlak+1]
         cmp       dx,ds:[PozVrat]
         je        Start7                   ; konec hry

Start6:  jmp       Start5

; ------ úspěšné ukončení scény

Start7:
         mov       word ptr ds:[CitSound],0

         mov       bx,2200
         mov       ax,800
         mov       dx,250
         mov       cx,2
Start711:call      SetSound
         xchg      ax,bx
         call      Cekej
         call      SetSound
         xchg      ax,bx
         call      Cekej
         sub       bx,8
         dec       dx
         jnz       Start711

         call      SoundOff

         call      ClosScen
         call      ClearInf

         inc       byte ptr ds:[AktScen]
         cmp       byte ptr ds:[AktScen],MAXSCEN
         jbe       Start72
         mov       byte ptr ds:[AktScen],1
         jmp       Absol                    ; absolutní vítěz hry

Start72:
         mov       dx,(24/2-1)*256+(40-10)/2
         mov       si,offset ScenTxt
         mov       ah,10
         call      DispTxt

         mov       al,ds:[AktScen]
         mov       ah,0
         mov       ch,14
         call      DispNum

         mov       al," "
         call      DispChr

         mov       dx,(24/2+1)*256+(40-13)/2
         mov       ah,10
         mov       si,offset Hes2Txt
         call      DispTxt

         mov       al,5
         mul       byte ptr ds:[AktScen]
         add       ax,offset TabHesel-5
         xchg      ax,si
         mov       ah,14
         mov       cx,5
Start73: cld
         lodsb
         xor       al,X
         call      DispChr
         loop      Start73

         mov       al," "
         call      DispChr

         call      FlushKey

         mov       ah,0
         int       16h

         mov       al,ds:[AktScen]
         call      InitScen                 ; inicializace scény AL

         call      OpenScen

         call      DispInf                  ; zobrazení informačního řádku

         jmp       Start41


; ------ havárie

Start8:  mov       byte ptr ds:[MapVlak],0  ; příznak srážky

         mov       word ptr ds:[CitVyb],120  ; čítač výbuchu

         mov       al,SR1                   ; srážka
Start80: mov       dx,word ptr ds:[MapVlak+1]
         call      DispObr

Start81:
         cmp       word ptr ds:[CitVyb],0
         je        Start86
         dec       word ptr ds:[CitVyb]
         jnz       Start85
         call      SoundOff
         jmp       short Start86

Start85: push      ax
         mov       bx,ds:[CitVyb]
         mov       ax,420
         sub       ax,ds:[CitVyb]
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         mov       bx,word ptr ds:[bx+Start]
         and       bx,0fffh
         add       ax,bx
         call      SetSound
         pop       ax

Start86:
         mov       cx,9
         call      Cekej

         call      TestTime
         jc        Start81

         call      IncFaze

         inc       ax
         cmp       al,SRA+1
         jb        Start80

         mov       al,SR8

         push      ax
         mov       ah,1
         int       16h
         pop       ax
         jz        Start80

         call      SoundOff

Start82: call      FlushKey
Start83: jmp       Start4

; -----------------------------------------------------------------------------
;        celkové ukončení hry - absolutní vítěz
; -----------------------------------------------------------------------------
;ţ
Absol    PROC      NEAR

         mov       dx,9*256+5
         mov       si,offset Bla1Txt
         mov       ah,14
         call      DispTxt
         mov       dx,10*256+5
         call      DispTxt
         mov       dx,11*256+5
         push      si
         mov       si,offset Bla1Txt
         call      DispTxt
         pop       si
         mov       ah,10
         mov       dx,12*256+5
         call      DispTxt
         mov       dx,13*256+5
         call      DispTxt
         mov       si,offset Bla1Txt
         mov       dx,14*256+5
         call      DispTxt

         call      FlushKey
         mov       ah,0
         int       16h
         jmp       Start2                   ; návrat k demonstraci

Absol    ENDP

; -----------------------------------------------------------------------------
;        zadání hesla
; -----------------------------------------------------------------------------
;ţ
Heslo    PROC      NEAR

         push      ds
         pop       es

; ------ načtení aktivního hesla

         mov       al,5
         mul       byte ptr ds:[AktScen]
         add       ax,offset TabHesel-5
         xchg      ax,si
         mov       cx,5
         mov       di,offset BuffHes
         cld
         rep       movsb

; ------ zobrazení hesla

         mov       di,offset BuffHes        ; ukazatel v bufferu hesla

Heslo2:  mov       dx,24*256+14
         mov       ah,12
         mov       si,offset Hes2Txt
         call      DispTxt

         mov       si,offset BuffHes
         mov       cx,5
Heslo23: mov       ah,14
         cmp       si,di
         jne       Heslo232

         mov       ah,9
         mov       al," "
         call      DispChr
         dec       dx

         mov       ah,14 XOR 9 + 80h

Heslo232:cld
         lodsb
         xor       al,X
         call      DispChr
         loop      Heslo23

; ------ čekání na zadání klávesy

Heslo24: call      TestTime                 ; inicializace čítače času
         jc        Heslo25                  ; není krok
         call      IncFaze                  ; zvýšení fáze
         call      OpenVrat                 ; otevření vrat

Heslo25: mov       ah,1
         int       16h
         jz        Heslo24
         mov       ah,0
         int       16h

         cmp       al,13
         je        Heslo5

; ------ přerušení zadání ESC (nebo neplatné heslo)

         or        ax,ax
         jz        Heslo27
         cmp       al,27
         jne       Heslo3

Heslo27:
         call      DispInf
         jmp       Start60                  ; přerušení bez další funkce

; ------ kurzor vpravo

Heslo3:  cmp       ax,4d00h
         je        Heslo42

; ------ kurzor vlevo

         cmp       al,8
         je        Heslo31
         cmp       al,7fh
         je        Heslo31
         cmp       ax,5300h
         je        Heslo31
         cmp       ax,4b00h
         jne       Heslo32
Heslo31: cmp       di,offset BuffHes
         jbe       Heslo43
         dec       di
         jmp       short Heslo43

; ------ vložení znaku

Heslo32: cmp       al,"a"
         jb        Heslo33
         cmp       al,"z"
         ja        Heslo33
         sub       al,32
Heslo33: cmp       al,"A"
         jb        Heslo24
         cmp       al,"Z"
         ja        Heslo24
         xor       al,X
         mov       ds:[di],al

Heslo42: cmp       di,offset BuffHes+4
         jae       Heslo43
         inc       di
Heslo43: jmp       Heslo2

; ------ ukončení zadání hesla ENTER

Heslo5:  mov       si,offset TabHesel
         mov       dx,1                     ; ukazatel čísla scény
         cld
Heslo52: mov       di,offset BuffHes
         mov       cx,5
         push      si
         repe      cmpsb
         pop       si
         je        Heslo55
         add       si,5
         inc       dx
         cmp       dx,MAXSCEN
         jbe       Heslo52
         jmp       short Heslo27

Heslo55: mov       ds:[AktScen],dl
         jmp       Start4

Heslo    ENDP

; -----------------------------------------------------------------------------
;        uzavření scény
; -----------------------------------------------------------------------------

ClosScen PROC      NEAR

         mov       dh,0
         mov       al,ZED
ClosScn1:mov       cx,20
         mov       dl,0
ClosScn2:call      DispObr
         inc       dx
         loop      ClosScn2
         mov       cx,60
         call      Cekej
         inc       dh
         cmp       dh,12
         jne       ClosScn1
         ret

ClosScen ENDP

; -----------------------------------------------------------------------------
;        otevření scény
; -----------------------------------------------------------------------------

OpenScen PROC      NEAR

         mov       si,offset Pole+12*20-20
         mov       dh,11
OpenScn1:mov       cx,20
         mov       dl,0
OpenScn2:cld
         lodsb
         call      DispObr
         inc       dx
         loop      OpenScn2
         sub       si,2*20
         mov       cx,60
         call      Cekej
         dec       dh
         jns       OpenScn1
         ret

OpenScen ENDP

; -----------------------------------------------------------------------------
;        zobrazení scény
; -----------------------------------------------------------------------------

DispScen PROC      NEAR

         mov       si,offset Pole
         mov       dh,0
DispScn1:mov       cx,20
         mov       dl,0
DispScn2:cld
         lodsb
         call      DispObr
         inc       dx
         loop      DispScn2
         inc       dh
         cmp       dh,12
         jne       DispScn1
         ret

DispScen ENDP

; -----------------------------------------------------------------------------
;        vymazání informačního řádku
; -----------------------------------------------------------------------------

ClearInf PROC      NEAR

         mov       dx,24*256
         mov       ax,15*256+" "
         mov       cx,40
ClearIn1:call      DispChr
         loop      ClearIn1
         ret

ClearInf ENDP

; -----------------------------------------------------------------------------
;        zobrazení informačního řádku
; -----------------------------------------------------------------------------

DispInf  PROC      NEAR

         call      ClearInf                 ; vymazání informačního řádku

; ------ úvodní text

         mov       dx,24*256
         mov       ah,10
         mov       si,offset SkorTxt
         call      DispTxt

         mov       dl,40-6-3
         call      DispTxt

         mov       dl,16
         mov       ah,12
         call      DispTxt

         mov       ch,14
         mov       al,ds:[AktScen]
         mov       ah,0
         mov       dl,40-2
         call      DispNum

         call      DispSkor                 ; zobrazení skóre
         ret

DispInf  ENDP

; -----------------------------------------------------------------------------
;        zobrazení skóre
; -----------------------------------------------------------------------------

DispSkor PROC      NEAR

         push      ax
         push      cx
         push      dx

         cmp       byte ptr ds:[Demon],0
         jne       DispSko6

         mov       dx,24*256+6
         mov       ch,14
;         mov       cl,5
         mov       ax,ds:[Skore]
         or        ax,ax
         jz        DispSko4
;         jnz       DispSko3
;         mov       cl,6
DispSko3:call      DispNum
DispSko4:mov       al,"0"
         mov       ah,14
;         mov       dl,6+5
         call      DispChr

DispSko6:pop       dx
         pop       cx
         pop       ax
         ret

DispSkor ENDP

; -----------------------------------------------------------------------------
;        otevření vrat
; -----------------------------------------------------------------------------

OpenVrat PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si

         cmp       word ptr ds:[CitVeci],0
         jne       OpenVr8

         mov       dx,ds:[PozVrat]
         mov       al,20                    ; počet pozic
         mul       dh                       ; přepočet řádku na offset
         add       al,dl
         adc       ah,0
         add       ax,offset Pole
         xchg      ax,si                    ; SI <- adresa v poli
         mov       al,ds:[si]
         cmp       al,VRA
         jb        OpenVr8
         cmp       al,VRA+5
         jae       OpenVr8

         inc       ax
         mov       ds:[si],al               ; nová fáze vrat
         call      DispObr

OpenVr8: pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

OpenVrat ENDP

; -----------------------------------------------------------------------------
;        zvýšení fáze objektů
; -----------------------------------------------------------------------------

IncFaze  PROC      NEAR

; ------ úschova registrů

         push      ax
         push      cx
         push      dx
         push      si

; ------ obsluha objektů

         mov       dh,0
         mov       si,offset Pole
         inc       byte ptr ds:[Faze]       ; čítač fází
         cmp       byte ptr ds:[Faze],3
         jb        IncFaze1
         mov       byte ptr ds:[Faze],0
IncFaze1:mov       dl,0
IncFaze2:cld
         lodsb
         cmp       al,VECI
         jae       IncFaze3
         cmp       al,LO1
         jb        IncFaze5
         cmp       al,LOC
         ja        IncFaze5
         cmp       byte ptr ds:[MapVlak],0
         je        IncFaze5
         sub       al,LO1
         and       al,3
         mov       ah,ds:[Faze]
         shl       ah,1
         shl       ah,1
         add       al,ah
         inc       ax
         jmp       short IncFaze4
IncFaze3:inc       ax                       ; zvýšení fáze
         cmp       byte ptr ds:[Faze],0
         jne       IncFaze4
         sub       al,3
IncFaze4:mov       ds:[si-1],al
         call      DispObr
IncFaze5:inc       dl
         cmp       dl,20
         jne       IncFaze2
         inc       dh
         cmp       dh,12
         jne       IncFaze1

; ------ návrat registrů

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

IncFaze  ENDP

; -----------------------------------------------------------------------------
;        čítání času pro jeden krok (CY=není krok)
; -----------------------------------------------------------------------------
;ţ
TestTime PROC      NEAR

         sti

         push      cx
         mov       cx,1
         call      Cekej
         pop       cx

         cmp       word ptr ds:[CitSound],0
         je        TestTim1

         dec       word ptr ds:[CitSound]
         jnz       TestTim0
TestT05: call      SoundOff
         jmp       short TestTim1

TestTim0:
         push      ax
         push      si
         mov       si,ds:[AdrSound]
         cld
         lodsw
         mov       ds:[AdrSound],si
         call      SetSound

         pop       si
         pop       ax

TestTim1:

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         pop       ds
         sub       ax,ds:[LastTime]

IFDEF    DEBUG
         cmp       ax,3                     ; krok
ELSE
         cmp       ax,2                     ; krok
ENDIF

         jb        TestTim3                 ; není krok
         add       ds:[LastTime],ax         ; zvýšení čítače času
         clc                                ; příznak kroku
TestTim3:pop       ax
         ret

TestTime ENDP

;; -----------------------------------------------------------------------------
;;        vymazání obrazovky
;; -----------------------------------------------------------------------------
;
;Clear    PROC      NEAR
;
;; ------ úschova registrů
;
;         push      ax
;         push      cx
;         push      dx
;         push      di
;         push      es
;
;; ------ nastavení zápisových rovin
;
;         mov       dx,3c4h
;         mov       al,2
;         out       dx,al
;         inc       dx
;         mov       al,0fh
;         out       dx,al
;
;; ------ vymazání videopaměti
;
;         mov       ax,0a000h
;         mov       es,ax
;         xor       di,di
;         mov       cx,40*200/2
;         xor       ax,ax
;         rep       stosw
;
;; ------ návrat registrů
;
;         pop       es
;         pop       di
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;Clear    ENDP

; -----------------------------------------------------------------------------
;        posun vlaku ve směru DX (DH=0,1,-1, DL=0,1,-1)
; -----------------------------------------------------------------------------

PosVlak  PROC      NEAR

; ------ úschova registrů

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ příprava registrů

         mov       si,offset MapVlak
         add       dl,ds:[si+1]             ; nová souřadnice lokomotivy
         add       dh,ds:[si+2]

; ------ posun souřadnic objektu

PosVlak2:mov       cx,ds:[si+1]             ; úschova starých souřadnic
         mov       ds:[si+1],dx             ; nová souřadnice objektu

; ------ stanovení nové fáze objektu

         mov       al,ds:[si]               ; báze objektu
         cmp       cl,-1
         jne       PosVlk22
         add       al,bh
         jmp       short PosVlak4
PosVlk22:mov       ah,dl                    ; nová pozice
         mov       bh,0
         sub       ah,cl                    ; posun pozice
         je        PosVlak3                 ; pozice se nezměnila
         js        PosVlak4                 ; posun vlevo
         mov       bh,2
         add       al,2
         jmp       short PosVlak4           ; posun vpravo
PosVlak3:inc       ax                       ; posun nahoru
         mov       bh,1
         mov       ah,dh                    ; nový řádek
         sub       ah,ch                    ; posun řádku
         js        PosVlak4                 ; je posun nahoru
         add       al,2                     ; jinak posun dolů
         mov       bh,3

; ------ zobrazení objektu na nové pozici

PosVlak4:call      DispObr                  ; zobrazení obrázku

; ------ uložení objektu do mapy

         push      ax
         mov       al,20                    ; počet pozic
         mul       dh                       ; přepočet řádku na offset
         add       al,dl
         adc       ah,0
         add       ax,offset Pole
         xchg      ax,di                    ; DI <- adresa v poli
         pop       ax
         xchg      al,ds:[di]               ; uložení objektu do mapy

; ------ při zrušení věci vytvoření nového vagonu

         sub       al,VECI                  ; byla to věc ?
         jb        PosVlak6                 ; nebyla to věc

         dec       word ptr ds:[CitVeci]    ; čítání věcí
         cmp       byte ptr ds:[Demon],0
         jne       PosVla42
         cmp       word ptr ds:[Skore],-1
         je        PosVla41
         inc       word ptr ds:[Skore]
PosVla41:call      DispSkor                 ; zobrazení skóre
PosVla42:mov       ah,0
         mov       bl,3
         div       bl                       ; číslo věci
         shl       al,1
         shl       al,1                     ; vagon * 4
         add       al,VAGONY                ; číslo vagonu
         push      si
PosVlak5:add       si,3
         cmp       byte ptr ds:[si],0
         jne       PosVlak5
         mov       ds:[si],al
         mov       word ptr ds:[si+1],-1
         mov       byte ptr ds:[si+3],0
         pop       si

; ------ příprava pro další objekt

PosVlak6:add       si,3                     ; adresa dalšího objektu
         mov       dx,cx                    ; stará pozice předešlého objektu
         mov       al,0
         cmp       ds:[si],al               ; je již konec vlaku ?
         je        PosVlak7
         jmp       PosVlak2                 ; není konec - další vagon

; ------ vymazání posledního vagonu

PosVlak7:cmp       dl,-1
         je        PosVlak8
         call      DispObr                  ; vymazání posledního vagonu
         mov       al,20                    ; počet pozic
         mul       dh                       ; přepočet řádku na offset
         add       al,dl
         adc       ah,0
         add       ax,offset Pole
         xchg      ax,di                    ; DI <- adresa v poli
         mov       byte ptr ds:[di],0

; ------ návrat registrů

PosVlak8:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

PosVlak  ENDP

; -----------------------------------------------------------------------------
;        inicializace scény AL pro hru
; -----------------------------------------------------------------------------

InitScen PROC      NEAR

         call      CekInit                  ; inicializace hodin

; ------ úschova registrů

         push      ax
         push      cx
         push      dx
         push      si
         push      di

; ------ přenesení definice scény

         cld
         mov       ah,0
         mov       cx,12*20                 ; délka definice jedné scény
         mul       cx                       ; offset definice scény
         add       ax,offset Sceny          ; adresa definice scény
         xchg      ax,si                    ; SI <- adresa definice scény
         mov       di,offset Pole           ; začátek pole
         rep       movsb                    ; přenos pole

         mov       word ptr ds:[CitVeci],0

; ------ inicializace scény

         mov       dh,0
         mov       si,offset Pole
InitScn4:mov       dl,0
InitScn5:cld
         lodsb
;         call      DispObr
         cmp       al,VRA
         jne       InitSc52
         mov       ds:[PozVrat],dx          ; pozice vrat
InitSc52:cmp       al,VECI
         jb        InitScn6
         inc       word ptr ds:[CitVeci]
InitScn6:cmp       al,LO1
         jb        InitScn7
         cmp       al,LO4
         ja        InitScn7
         mov       ds:[MapVlak],al          ; typ lokomotivy (směr)
         mov       word ptr ds:[MapVlak+1],dx ; souřadnice lokomotivy
         mov       byte ptr ds:[MapVlak+3],0  ; označení konce vlaku
InitScn7:inc       dl
         cmp       dl,20
         jne       InitScn5
         inc       dh
         cmp       dh,12
         jne       InitScn4

         mov       byte ptr ds:[MapVlak],LO1 ; báze lokomotivy
         mov       byte ptr ds:[Faze],0     ; ukazatel fáze
         mov       word ptr ds:[Smer],0

; ------ návrat registrů

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

InitScen ENDP

; -----------------------------------------------------------------------------
;        zobrazení obrázku AL na pozici DL, řádek DH
; -----------------------------------------------------------------------------

DispObr  PROC      NEAR

; ------ úschova registrů

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ výpočet adresy obrázku

         mov       ah,0
         mov       cl,7                     ; počet rotací
         shl       ax,cl                    ; offset obrázku
         add       ax,offset Obrazky        ; adresa obrázku
         xchg      ax,si                    ; SI <- adresa obrázku

; ------ adresa k uložení obrázku

         mov       cx,dx                    ; úschova DX
         mov       dl,dh
         mov       dh,0
         mov       ax,16*40                 ; offset řádku
         mul       dx                       ; přepočet řádku na offset
         mov       ch,0
         shl       cx,1                     ; přepočet pozice na offset
         add       ax,cx                    ; adresa ve videopaměti
         xchg      ax,di                    ; DI <- adresa ve videopaměti
         mov       ax,0a000h
         mov       es,ax                    ; ES <- adresa ve videopaměti

; ------ příprava k zobrazení obrázku

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru zápisových rovin
         mov       ah,1                     ; ukazatel zápisové roviny
         inc       dx
         cld

; ------ zobrazení jedné roviny obrázku

DispObr2:mov       al,ah
         out       dx,al                    ; volba zápisové roviny
         mov       cx,16                    ; počet linek
         push      di
DispObr3:movsw                              ; přenos jedné linky
         add       di,40-2
         loop      DispObr3
         pop       di

; ------ příprava pro další rovinu

         shl       ah,1
         cmp       ah,10h
         jne       DispObr2                 ; další rovina

; ------ návrat registrů

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispObr  ENDP

; -----------------------------------------------------------------------------
;        zobrazení titulku
; -----------------------------------------------------------------------------

DispTit  PROC      NEAR

; ------ úschova registrů

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ příprava k zobrazení titulku

         mov       si,offset Titulek
         mov       ax,0a000h
         mov       es,ax                    ; ES <- adresa ve videopaměti
         mov       di,9*16*40+4
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru zápisových rovin
         mov       ah,1                     ; ukazatel zápisové roviny
         inc       dx
         cld

; ------ zobrazení jedné roviny titulku

DispTit2:mov       al,ah
         out       dx,al                    ; volba zápisové roviny
         mov       cx,16                    ; počet linek

         push      di
         push      si

DispTit3:push      cx
         push      si
         push      di

         mov       cl,ds:[CitTit]
         rep       movsb                    ; přenos jedné linky

         pop       di
         pop       si
         pop       cx
         add       si,32
         add       di,40

         loop      DispTit3

         pop       si
         pop       di

; ------ příprava pro další rovinu

         add       si,16*32
         shl       ah,1
         cmp       ah,10h
         jne       DispTit2                 ; další rovina

; ------ návrat registrů

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispTit  ENDP

; -----------------------------------------------------------------------------
;        zobrazení čísla AX (pozice DL, řádek DH, barva CH)
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ úschova registrů

         push      ax
         push      bx
         push      cx
         push      si
         push      di

         mov       bx,dx                    ; úschova pozice
         xor       di,di                    ; čítač znaků

; ------ dekódování čísla do zásobníku

         mov       si,10
DispNum1:xor       dx,dx
         div       si
         push      dx
         inc       di
         mov       dx,bx
;         dec       cl
;         jz        DispNum3
         or        ax,ax
         jnz       DispNum1

;         mov       al," "
;         mov       ah,0
;DispNum2:call      DispChr
;         dec       cl
;         jnz       DispNum2

; ------ zobrazení čísla

DispNum3:pop       ax
         add       al,"0"
         mov       ah,ch
         call      DispChr
         dec       di
         jnz       DispNum3

; ------ návrat registrů

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazení textu SI (barva AH, pozice DL, řádek DH)
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

DispTxt1:cld
         lodsb
         cmp       al,0
         je        DispTxt2
         call      DispChr
         jmp       short DispTxt1

DispTxt2:ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazení znaku AX (pozice DL, řádek DH)
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ úschova registrů

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ nastavení kurzoru

         push      ax
         mov       bh,0
         mov       ah,2
         int       10h                      ; nastavení kurzoru
         pop       ax

; ------ zobrazení znaku

         mov       bl,ah
         mov       bh,0
         mov       ah,9
         mov       cx,1
         int       10h                      ; zobrazení znaku

; ------ návrat registrů

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       dx
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        nastavení zvukového generátoru na AX
; -----------------------------------------------------------------------------

SetSound PROC      NEAR

         push      ax
         cli
         mov       al,0b6h
         out       [43h],al
         pop       ax
         push      ax
         out       [42h],al                 ; LOW
         xchg      ah,al
         out       [42h],al                 ; HIGH
         in        al,[61h]
         or        al,3
         out       [61h],al
         sti
         pop       ax
         ret

SetSound ENDP

; -----------------------------------------------------------------------------
;        vypnutí zvukového generátoru
; -----------------------------------------------------------------------------

SoundOff PROC      NEAR

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al
         pop       ax
         ret

SoundOff ENDP

; -----------------------------------------------------------------------------
;        cejchování hodin
; -----------------------------------------------------------------------------
; VSTUP: DS=datový segment
; -----------------------------------------------------------------------------

CekInit  PROC      NEAR

; ------ úschova registrů

         push      ax
         push      bx
         push      dx
         push      di

         push      ds

; ------ příprava registrů

         sti
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax
         xor       dx,dx                    ; DX <- 0
         mov       di,46ch

; ------ čekání na začátek impulsu hodin

         mov       bx,ds:[di]
CekInit1:cmp       bx,ds:[di]
         je        CekInit1                 ; čekání na začátek hodin

; ------ měření času

         mov       bx,ds:[di]
         EVEN                               ; zarovnání na sudou adresu
CekInit2:add       ax,1                     ; čítač nižšího slova času
         adc       dx,0                     ; přenos do vyššího slova
         cmp       bx,ds:[di]               ; byla změna ?
         je        CekInit2                 ; čekání na změnu hodin

; ------ výpočet konstanty

         mov       bx,55                    ; dělitel
         cmp       dx,bx                    ; přetečení čísla ?
         jb        CekInit3                 ; není přetečení čísla
         mov       dx,54                    ; omezení čísla
CekInit3:div       bx                       ; výpočet konstanty
         or        ax,ax                    ; je = 0 ?
         jnz       CekInit4                 ; není = 0
         inc       ax                       ; korekce na 1
CekInit4:
         pop       ds
         mov       ds:[Cit1ms],ax           ; konstanta hodin

; ------ návrat registrů

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

CekInit  ENDP

; -----------------------------------------------------------------------------
;        čekání na uplynutí zadaného času
; -----------------------------------------------------------------------------
; VSTUP: CX=požadovaná doba v milisekundách
;        DS=datový segment
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ úschova registrů

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ čekání po zadanou dobu

         jcxz      Cekej9                   ; není žádné čekání
         mov       di,offset Cit1ms         ; konstanta hodin
Cekej1:  xor       ax,ax                    ; nižší slovo čítače hodin
         xor       dx,dx                    ; vyšší slovo čítače hodin

; ------ čítání doby 1 ms

         EVEN                               ; zarovnání na sudou adresu
Cekej2:  add       ax,1                     ; čítač nižšího slova času
         adc       dx,0                     ; přenos do vyššího slova
         cmp       ax,ds:[di]               ; dosaženo doby 1 ms ?
         jne       Cekej2                   ; čítání doby 1 ms

         loop      Cekej1                   ; čekání na další 1 ms

; ------ návrat registrů

Cekej9:  pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        vyprázdnění bufferu klávesnice
; -----------------------------------------------------------------------------

FlushKey PROC      NEAR

         push      ax
FlushKe2:mov       ah,1
         int       16h
         jz        FlushKe3
         mov       ah,0
         int       16h
         jmp       short FlushKe2
FlushKe3:pop       ax
         ret

FlushKey ENDP

; *****************************************************************************
;
;                               Data
;
; *****************************************************************************

CardTxt  db        'Lituji, ale program vyzaduje grafikou kartu EGA nebo VGA !',13,10,'$'

UvTxt    db        ' ————————————————  Zalibila se vam hra ? ———————————————— ',13,10
         db        '  Pokud ano, darujte ji i svym znamym. Muzete ji i volne  ',13,10
         db        '  distribuovat se svymi programy, nebot je to FREEWARE !  ',13,10
         db        '  Firma GOLEM bude potesena, budete-li se zajimat o jeji  ',13,10
         db        '  dalsi produkty. Hlavnimi kriterii nasich programu jsou  ',13,10
         db        '  nizka cena, minimalni naroky na pamet a misto na disku  ',13,10
         db        '  a predevsim jednoduchost obsluhy. Proto pouzivame jako  ',13,10
         db        '  nas hlavni programovaci jazyk assembler.  Seznamite-li  ',13,10
         db        '  se s nasimi produkty (ovladace narodniho prostredi pro  ',13,10
         db        '  displej, klavesnici, tiskarnu,  nadstavba systemu typu  ',13,10
         db        '  NORTON COMMANDER, editory,  antivirove programy,  hry,  ',13,10
         db        '  programy  pro  prenos  po seriove ci paralelni lince a  ',13,10
         db        '  desitky dalsich programu a utilit)  jsme  presvedceni,  ',13,10
         db        '  ze u nasich  produktu  jiz  zustanete.  Muzeme vas tez  ',13,10
         db        '  kompletne vybavit  veskerou pocitacovou technikou a to  ',13,10
         db        '  jiz od nejlevnejsi sestavy pocitace pripojitelne pouze  ',13,10
         db        '  k televizoru a pozdeji  rozsiritelne  na plnohodnotnou  ',13,10
         db        '  verzi bez financni ztraty.                              ',13,10
         db        '                                                          ',13,10
         db        '  Nase adresa: GOLEM, P.O.Box 66, 756 61 Roznov p. Radh.  ',13,10
         db        ' ———————————————————————————————————————————————————————— ',13,10
         db        '$'

BuffHes  db        '     '                  ; buffer hesla

                                            ; posun při demonstraci
DemoPos  db        19 dup(1,0)
         db        8 dup(0,-1)
         db        3 dup( 19 dup(-1,0), 0,1, 19 dup(1,0), 0,1)
         db        19 dup(-1,0)
         db        0,1, 0,1, 0,1
         db        9 dup(1,0), 0,1

SkorTxt  db        'SKORE',0
ScenTxt  db        ' SCENA ',0
HeslTxt  db        'F4 HESLO',0
Hes2Txt  db        ' heslo ',0

Bla1Txt  db        '                              ',0
Bla2Txt  db        '    B L A H O P R E J I  !    ',0
         db        '   Stal jste se absolutnim    ',0
         db        '      vitezem teto hry !      ',0

; ------ časovač

         EVEN                               ; začíná na sudé adrese jako 0:46ch
Cit1ms   dw        0                        ; konstanta pro dobu 1 ms

AdrSound dw        0                        ; adresa zvuku
CitSound dw        0                        ; čítač délky zvuku (0=není)

CitVyb   dw        0                        ; čítač výbuchu

TabSLok  dw        166,254,365              ; zvuk lokomotivy
TabSLok0 label     byte

TabSVec  dw        400,600,800,1000,1200,1400,1600,1800,2000,1800,1600,1400,1200,1000,800,600,400,200 ; zvuk věci
TabSVec0 label     byte

Smer     dw        0                        ; směr pohybu

Demon    db        0                        ; 1=příznak demonstrace

CitTit   db        0                        ; čítač šířky titulku
CitVeci  dw        0                        ; čítač věcí
PozVrat  dw        0                        ; pozice vrat
Skore    dw        0                        ; čítač skóre

MapVlak  db        3 * 12*20 dup(0)         ; mapa celého vlaku
                                            ;  0: (1) báze objektu (0=konec)
                                            ;  1: (1) souřadnice X
                                            ;  2: (1) souřadnice Y

LastTime dw        0                        ; uschovaný poslední čas

Faze     db        0                        ; čítač fáze

Pole     db        12*20 dup(0)             ; hrací pole

AktScen  db        FRSTSCEN                 ; aktivní scéna

Sceny    label     byte
INCLUDE  SCENY.ASM                          ; definice scén

TabHesel label     byte                     ; tabulka hesel
         db        'G' XOR X,'O' XOR X,'L' XOR X,'E' XOR X,'M' XOR X ; 1
         db        'K' XOR X,'R' XOR X,'O' XOR X,'N' XOR X,'E' XOR X ; 2
         db        'M' XOR X,'Y' XOR X,'D' XOR X,'L' XOR X,'O' XOR X ; 3
         db        'L' XOR X,'E' XOR X,'D' XOR X,'E' XOR X,'N' XOR X ; 4
         db        'S' XOR X,'T' XOR X,'R' XOR X,'O' XOR X,'P' XOR X ; 5
         db        'L' XOR X,'I' XOR X,'L' XOR X,'I' XOR X,'E' XOR X ; 6
         db        'R' XOR X,'Y' XOR X,'B' XOR X,'K' XOR X,'A' XOR X ; 7
         db        'K' XOR X,'L' XOR X,'A' XOR X,'U' XOR X,'N' XOR X ; 8
         db        'B' XOR X,'R' XOR X,'A' XOR X,'U' XOR X,'N' XOR X ; 9
         db        'W' XOR X,'H' XOR X,'I' XOR X,'T' XOR X,'E' XOR X ; 10
         db        'M' XOR X,'O' XOR X,'U' XOR X,'S' XOR X,'E' XOR X ; 11
         db        'D' XOR X,'R' XOR X,'E' XOR X,'A' XOR X,'M' XOR X ; 12
         db        'I' XOR X,'D' XOR X,'E' XOR X,'A' XOR X,'L' XOR X ; 13
         db        'I' XOR X,'L' XOR X,'U' XOR X,'Z' XOR X,'E' XOR X ; 14
         db        'S' XOR X,'A' XOR X,'I' XOR X,'N' XOR X,'T' XOR X ; 15
         db        'B' XOR X,'E' XOR X,'L' XOR X,'L' XOR X,'S' XOR X ; 16
         db        'T' XOR X,'R' XOR X,'O' XOR X,'J' XOR X,'A' XOR X ; 17
         db        'E' XOR X,'M' XOR X,'O' XOR X,'C' XOR X,'E' XOR X ; 18
         db        'B' XOR X,'A' XOR X,'S' XOR X,'T' XOR X,'L' XOR X ; 19
         db        'I' XOR X,'S' XOR X,'L' XOR X,'A' XOR X,'M' XOR X ; 20
         db        'J' XOR X,'E' XOR X,'A' XOR X,'N' XOR X,'S' XOR X ; 21
         db        'M' XOR X,'E' XOR X,'T' XOR X,'A' XOR X,'L' XOR X ; 22
         db        'M' XOR X,'I' XOR X,'K' XOR X,'R' XOR X,'O' XOR X ; 23
         db        'S' XOR X,'E' XOR X,'N' XOR X,'Z' XOR X,'A' XOR X ; 24
         db        'G' XOR X,'A' XOR X,'L' XOR X,'A' XOR X,'X' XOR X ; 25
         db        'S' XOR X,'T' XOR X,'O' XOR X,'N' XOR X,'E' XOR X ; 26
         db        'S' XOR X,'L' XOR X,'A' XOR X,'V' XOR X,'E' XOR X ; 27
         db        'F' XOR X,'O' XOR X,'R' XOR X,'T' XOR X,'E' XOR X ; 28
         db        'L' XOR X,'U' XOR X,'C' XOR X,'I' XOR X,'E' XOR X ; 29
         db        'N' XOR X,'A' XOR X,'T' XOR X,'U' XOR X,'R' XOR X ; 30
         db        'B' XOR X,'I' XOR X,'E' XOR X,'N' XOR X,'E' XOR X ; 31
         db        'K' XOR X,'A' XOR X,'T' XOR X,'Z' XOR X,'E' XOR X ; 32
         db        'H' XOR X,'Y' XOR X,'D' XOR X,'R' XOR X,'O' XOR X ; 33
         db        'F' XOR X,'A' XOR X,'U' XOR X,'N' XOR X,'A' XOR X ; 34
         db        'U' XOR X,'L' XOR X,'T' XOR X,'R' XOR X,'A' XOR X ; 35
         db        'T' XOR X,'O' XOR X,'D' XOR X,'A' XOR X,'Y' XOR X ; 36
         db        'H' XOR X,'O' XOR X,'R' XOR X,'O' XOR X,'R' XOR X ; 37
         db        'G' XOR X,'A' XOR X,'P' XOR X,'P' XOR X,'A' XOR X ; 38
         db        'R' XOR X,'E' XOR X,'T' XOR X,'A' XOR X,'L' XOR X ; 39
         db        'C' XOR X,'L' XOR X,'O' XOR X,'C' XOR X,'K' XOR X ; 40
         db        'H' XOR X,'O' XOR X,'M' XOR X,'E' XOR X,'R' XOR X ; 41
         db        'B' XOR X,'U' XOR X,'N' XOR X,'N' XOR X,'Y' XOR X ; 42
         db        'F' XOR X,'O' XOR X,'T' XOR X,'O' XOR X,'N' XOR X ; 43
         db        'Q' XOR X,'U' XOR X,'A' XOR X,'C' XOR X,'K' XOR X ; 44
         db        'H' XOR X,'A' XOR X,'F' XOR X,'I' XOR X,'K' XOR X ; 45
         db        'D' XOR X,'I' XOR X,'Z' XOR X,'Z' XOR X,'Y' XOR X ; 46
         db        'S' XOR X,'T' XOR X,'A' XOR X,'R' XOR X,'K' XOR X ; 47
         db        'Z' XOR X,'A' XOR X,'R' XOR X,'A' XOR X,'Z' XOR X ; 48
         db        'D' XOR X,'U' XOR X,'K' XOR X,'E' XOR X,'N' XOR X ; 49
         db        'S' XOR X,'T' XOR X,'O' XOR X,'R' XOR X,'Y' XOR X ; 50

Titulek  db        32*16*4 dup(?)           ; titulní obrázek

Obrazky  label     byte                     ; obrázky

Code     ENDS
         END       Start
