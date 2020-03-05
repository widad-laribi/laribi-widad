section .data
mess_merci: db 10,13,'Merci de votre utilisation. Au revoir!',10,13,'$'	
section .text
message_merci:
		pusha
		mov ah,0x9
		mov dx, mess_merci
		int 0x21
		popa
		ret

section .data
mess_somme: db 10,13,'Le resultat de la somme est : ','$'	
section .text
message_somme:
		pusha
		mov ah,0x9
		mov dx, mess_somme
		int 0x21
		popa
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Procedure de trace d'une ligne separatrice              ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data
trait: db 10,13,'---------------------------------',10,13,'$'	
section .text
tracerLigne:
		pusha
		mov ah,0x9
		mov dx, trait
		int 0x21
		popa
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Procedure d'impression dumessage entrer un nombre       ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  section .data
message_entrer_entier: db 10,"Entrer un nombre entier:",'$'

section .text
mess_pour_lire_entier: ;; Procedure affichant le message : Entrer un nombre:
	pusha
	mov dx, message_entrer_entier
	mov ah,0x9
	int 0x21
	popa
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Procedure d'impression d'un message                     ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .text
printMess: 
; Sauvegrade contexte
  pusha
; Récupération de la valeur du parametre
  mov bp, sp
  add bp, 18
  mov dx,[bp] ;; Bx localise le paramètre
  inc dx
  MOV AH, 0X9
  INT 0X21
  popa 
  ret

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Procedure de lecture d'un nombre entier                ;;;;;
;;;   sous forme de chaine de caractèrese                     ;;;;
;;;   forme java: void readIntAsString(String nb)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procédure de lecture de caractère appartenat à l'ensemble entre 0 et 9
section .text
readIntAsString: 
; Sauvegrade contexte
  pusha
; Récupération de la valeur du parametre
  mov bp, sp
  add bp, 18
  mov bx,[bp] ;; Bx localise le paramètre
  mov di, 1 ;; Registre d'index: La position 0 contient la taille
; Lecture sans echo d‘1 caractère:AH = 7, Res -> AL
readAnotherChar:
  mov ah, 0x7
  int  0x21
  ; tester si le caractère est un return
  cmp al, 13
  je finreadIntAsString
  cmp al, 48
  jl readAnotherChar
  cmp al, 58
  jg readAnotherChar
  ; Sauvegarde du caractère lu
  mov byte [bx + di], al
  inc di
  ; Ecriture du caractère lu: AH = 2, DL -> ecran
  mov ah,0x2
  mov dl, al
  int 0x21
  
  jmp readAnotherChar
finreadIntAsString:
  dec di
  mov ax, di
  ;;add ax, 48 ;; Juste pour vérification.. Commenter cette ligne
  mov byte [bx], al
  popa  
  ret
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Procedure de conversion string vers entier            ;;;;;
;;;      Forme java: int str2Int(String nombre)              ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
dix_readint: dw 10

section .text

  ;; Convertit une chaine de caractère donnée comme paramètre
  ;; en un entier qui sera retourné
  ;; 1er paramete spécifié est l'adrese de la chaine de caractère
  ;; Le deuxieme est la zone ou sera mise la valeur de retour
str2Int:  ;; Renvoie la valeur du nombre lu
		pusha;
		mov bp, sp ;;;
		add bp, 18 ;;; bp localise maintenant la variable de retour, 
		           ;;; bp + 2 localise l'adresse de l achaine de caractère a convertir  
		mov word [bp], 0 ;; Initialisation du resultat à 0
        
		;; Récuperation de la taille de l achaine de caractère 
		mov si, [bp +2]
		mov cx, 0  ;; Mise a zero du compteur, pour assurer que ch = 0
		mov cl, [si]
		cmp cl,0 ;; Chaine vide, aller a fin
		je  fin_str2Int
		;; La chaine n'est pas vide.. Aller sur le premier octet
		inc si ;; se positionner sur le premier octet
		;; Utilisation de bx pour récuperer le digit suivant dans bl; bh doit etre à zéro
		mov bx, 0 ;; Initialisation de bh et bl à 0
suivant:	; Recupération dans bl du caractere en cours
		mov bl, [si]
		sub bl, 48 ;; Transformation du digit dans sa valeur binaire
		mov ax, [bp]  ;; Récupération de l avaleur en cour du résultat
		mul word [dix_readint]
		add ax, bx ;; Ajouter dl (ici dx)
		mov [bp], ax  ;; remettre le resultat a sa place
		inc si
    	loop suivant
fin_str2Int: 
        ;; la valeur de retour est deja dans sa position
		popa
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Print d'un entier fourni en parametre           ;;;;;
;; Utilise la fonction de transformation           ;;;;;
;; d'un entier en chaine  de caractère             ;;;;;
;; Prend un entier comme paramètre                 ;;;;;
;;;;; Forme java: void print(int nombre)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .bss 
printIntBuffer:  resb 20
section .data
printIntBuffer1: db "                             "
section  .text
printInt: 
		pusha;
		mov bp, sp ;;;
		add bp, 18 ;;; bp localise maintenant la variable à imprimer, 
		mov ax, [bp]
		;; Preparation des parametres et zone de retour de fonction
	    push ax    ;; 1er Parametre  selon le prototype à JAva
		mov bx, printIntBuffer
		push bx   ;; Zone de retour
		call int2Str
	         
		pop dx   ;; Recuperation de l'adresse de la chaine resultante
		add sp,2 ;; Retabllir la pile dans son etat correct				 
		mov dx, bx
		inc dx   ;; se deplacer pour pouvoir faire un impression. 
	             ;; Le premier caractere etant le nombre de caractere de 
                 ;; la réponse. Le premier octet est le nombre d'octets
		mov ax, 0
		mov al, [bx]
		mov si, ax
		mov byte [bx+ si+1], '$'
		mov ah,0x9
		int 0x21
		popa
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  Fonction qui convertit un entier en une chaine de caractère        ;;;;;;;
;;;;   Nécessitre 2 Parametre:                                           ;;;;;;;
;;;;          - Le nombre a convertir en chaine de caractères            ;;;;;;;
;;;;          - L'adresse de la zone ou déposer la chaine produite        ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
;; Zone mémoire interne à la fonction
int2Str_buffer_01: db "                              ", 10,13,10,13,'$'
      ;; La constante 10
dix: dw 10

;;  Fin espace reservé pour func_intToStr

section .text		
int2Str:      ; 1 parametre en entrée et le resultat
              ; Type de retour: Chaine de caractère
		pusha ; Sauvegarde du contexte
		mov bp, sp 
		add bp, 18    ; bp +2 contient la valeur à convertir
		              ; bp    contient l'adresse de la zone ou déposer le résultat
		
		; Positionner bx sur la zone temporaire:  ce Resultat est a inverser
		mov bx, int2Str_buffer_01
		
		mov dx, 0         ; Necessaire pour la multiplication
		mov ax, [bp + 2]  ; valeur a coder
		mov byte [bx], 0  ;; Initialisation de la longeur de la chaine : Zone contenant le compteur de chaine
		inc bx
		mov cl, 0 ; Compteur

int2Str_rediv:	
        div word [dix]				  
        add dx, 48
		mov byte [bx], dl
		inc bx
        inc cl		
		mov dx, 0
		cmp ax, 0
		jne int2Str_rediv  

		mov bx, int2Str_buffer_01   ;; La chaine est produite mais en sens inverse
		mov byte [bx], cl; 
		
		;; Appel de la procedure revert
        ;; 1er parametre:  Chaine inversee: Localisee par func_int2str_buffer_01
        ;; 2eme parametre: Chaine correcte: Localisee par 2ème ârametre dans [bp]  		
		push int2Str_buffer_01
		mov bx, [bp]
		push bx
		call proc_revert
		add  sp, 4
		popa
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; inversion de l'ordre des caracteres dans une chaine ;;;;;
;;; revert chaine1, chaine 2: resultat dans chaine 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Le premier octet d'une chaine contient le nombre de caractère
; la chaine commence au 2ème caractère
proc_revert:
		pusha		  
		mov bp, sp
		add bp, 18  
		; bp     localise la chaine resultat   (2ème argument)
		; bp +2  localise la chaine a inverser (1er argument)
		; faire une boucle qui decremente
		mov di,[bp]
		mov si,[bp+2]
		mov cx, 0
		mov cl,[si]
		add si, cx
		mov [di], cx 
        cmp cx, 0
		je   proc_revert_reco_fin
proc_revert_reco:   
		inc di
        mov  byte al, [si] 
		mov  byte [di], al
        dec si		
        loop proc_revert_reco
proc_revert_reco_fin:    
		popa 		
        ret	  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;;;; Fonction de lecture d'un entier dans le format entier  de 16 bits        ;;
;;;;; La forme java: int lireUnEntier()                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
bufferReadInteger:   resb 40 	
section .text
readInteger:   ;;   
        pusha ; Sauvegarde du contexte
		mov bp, sp 
		add bp, 18 ;; Zone de retour du nombre lu
	    mov bx, bufferReadInteger  ; Preparation du parametre de retour de readIntAsString
		
		push bx
		call readIntAsString
		add sp, 2 ;; Remise en etat de la pile
        
		;; Transformation de la chaine lu en un entier
	    mov bx, bufferReadInteger
	    
		push bx
		sub  sp, 2 ;; retour
		call str2Int
		pop ax  ;; Récuperation du resiltat dabs ax
		add sp, 2
       
	   ;; Retourner la valeur obtenue
        mov [bp], ax
		popa
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ci dessous qudelques fonctions utilitaires
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
erreurTableauVide: db  10,13,"Erreur, le tableau est vide!!!",10,13,'$'
section .text
messagetableauVide:
        pusha
		mov ah,0x9
		mov dx, erreurTableauVide
		int 0x21
		popa
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
tailleDuTableauEst: db  "La taille du tableau est : ",'$'
affichageTabPartiel: db 10,10,13,'Affichage seulement  des elements lu du tableau',10,13,'$'	
section .text
affichagePartielDuTableau:
		pusha
		mov ah,0x9
		mov dx, affichageTabPartiel
		int 0x21
		popa
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
affichageTabEntier: db 10,10,13,'Affichage de tous les elements du tableau',10,13,'$'	
section .text
affichageDeToutLeTableau:
		pusha
		mov ah,0x9
		mov dx, affichageTabEntier
		int 0x21
		popa
		ret

section .data
buffsautDeLIgne: db 10,13,'$'	
section .text
sautDeLIgne:
		pusha
		mov ah,0x9
		mov dx, buffsautDeLIgne
		int 0x21
		popa
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; foncton int readIntArray(int[] ia      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; La fonction readIntegerArray rempli le tableau fourni en parametre et retourne ;;
;;; le nombre d'entiers lu. Dans le cas oule tableau donné ne contien aucune case  ;;
;;; c'est à dire que sa taille est 0, cette fonction retourne 999                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

readIntArray:
    pusha
	mov bp, sp
	add bp, 18   ;; positionnement de bp sur la valeur à retourner.. le 1er paramete se trouve dans bp+2
    ;; Extraction de la taille du tableau dans CX pour controler une boucle
	;; l'adre'sse du tableau a été fourni comme parametre. elle se trouve dabs [bp+2]
	mov si, [bp+2]
	mov cx, [si]
	;; vérification que la taille du tableau n'est pas nulle tableau.
	;; Si la taille est nulle renvoyer la valeur -1 qui indique l'erreur
    cmp cx, 0
    jg tableauNonVide	
	;; Si l'exécution arrive à ce point ceci veut dire que le tableau ne contient aucn element
	;; retourer la valdur 0
	mov word [bp], 999
	jmp finREadIntArray
	
	;; Arrivé à ce niveau veut dire que le tableau possède une taille > 0. Affichage de la taille
    
tableauNonVide:	
    ;; Impression message "La taille du tableau est : "
    mov dx, tailleDuTableauEst
	push dx
    call printMess
	add sp, 2
	;; Impression de la taille du tableau 
	push cx
	call printInt
	add sp,2
	
	;; Initialisation du parcours du tableau pour le remplir. La boucle se base sur le contenude cx
	;; positionnement de l'indice de parcours sur le premier element du tableau
	;; nous supposons que le tableau contient au moins 1 element
	mov di, [bp+2]  ;; Récupération adresse dutanleau dans di
	add di, 2   ;; positionnement di sur premier entier du tableau
	mov dx, 0  ;; initialisation du compteur Nombre de nombre entiers lu
debutBoucleLireTableau:
	call mess_pour_lire_entier
	sub sp, 2   ;; Reservation de la zone de retour
	call readInteger
	pop ax   ; recuperation de la valeur de retour et remise en forme de la pile
	
	cmp ax, 999
	je   finLectureDuTableau
	mov [di], ax
	inc dx  ;; Incrémentation du compteur
	add di,2  ;; passer à l'element suivant du tableau
	loop  debutBoucleLireTableau

finLectureDuTableau:
;; retourner le nombre d'entiers lu
    mov[bp], dx

finREadIntArray:
	popa
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; fonction d'impression des nb premières case d'un tableau d'entiers
;;;;;                void printIntArray(int[] ia, int nb)	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printIntArray:
	pusha
	mov bp, sp
	add bp, 18 ;; positionnement de bp sur le 2ème paramètre c'est à dire nb
	           ;; le débt du tableau d'entier à la java se trouve dans bp+2
	
	call affichagePartielDuTableau
	mov cx, [bp]   ;; initialisation du compteur de boucle avecla valeur du parametre nb
	mov si, [bp+2] ;;  récupération adresse du tableau. Cette adresse contient la taille
	add si, 2      ;; positionnement indice si sur le premier element du tableau
    
bouclePrintPartialIntArray:
    
    mov  ax, [si]
	push ax
	call printInt
    add sp, 2
	add si,2
	mov ah,0x2
	mov dl,9
	int 21h
    loop bouclePrintPartialIntArray ;; 	
finPrintIntArray:
    popa
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fonction oid printCompleteIntArray(int[] ia)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printCompleteIntArray:	
	pusha
	mov bp, sp
	add bp, 18 ;; positionnement de bp sur le  paramètre c'est à dire le tableau ia

	call affichageDeToutLeTableau
	mov si, [bp]
	mov cx, [si]    ;; initialisation du compteur de boucle
    add si, 2   	;;  positionnement de l'indice de parcours
		
bouclePrintCompleteIntArray:
    
    mov  ax, [si]
	push ax
	call printInt
    add sp, 2
	add si,2
	mov ah,0x2
	mov dl,9
	int 21h
    loop bouclePrintCompleteIntArray ;; 
finPrintCompleteIntArray:
	popa
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;