org 0x0100 ; Adresse de d�but .COM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Debut Programme  qui remplit un tableau (� la JAVA) d'entier                  ;;;
;;; et affiche ensuite le contenu du tableau                                      ;;;
;;; Ce programme utilise les fonction int readIntegerArray(int[] ia)              ;;;
;;; void printIntArray(int[] ia, int nb) et void printIntArray(int[] ia,int nb)   ;;;
;;; La fonction readIntegerArray rempli le tableau fourni en parametre et retourne ;;
;;; le nombre d'entiers lu. Dans le cas oule tableau donn� ne contien aucune case  ;;
;;; c'est � dire que sa taille est 0, cette fonction retourne la valeur 999        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data
;; Declaration d'un tableau de 8 entier � la java.. le premier entier repr�sente la taille du tableau
;; Les cases d'un tableau JAVA contiennent des 0 � la cr�ation du tableau 	
tabEntier: dw 10,0,0,0,0,0,0,0,0,0,0	

;;; Messages utilitaires 
nombreDeNombreLus:  db 10,10,13, "Nombre d'entiers lu est : ",'$'
section .text
main:
    mov ax , tabEntier   ;; R�cup�ration dans ax de l'adresse du tableau
	
	push ax ;; envoi du premier parametre
	sub sp, 2    ;; zone de retour
	call readIntArray
	pop ax  ;; r�cup�ration du nombre d'entier lu
    add sp,2  ;; mise en etat de la pile
	
	;; Affichage du nombre d'entiers lu
    mov bx, nombreDeNombreLus
	push bx
    call printMess
	add sp, 2
    
	
	push ax
    call printInt
	add sp,2
	
	;; V�rifier si  pas d'erreur.. en cas d'erreur (cas ou le tableaudonn� en param�tre est vide) 
	;; la fonction readIntArray renvoi 999
	cmp ax,999
	jne affichageTableau
	call messagetableauVide
	jmp finProg
	;; Affichage du tableau.. Juste les nombres lu
    ;; appel de void printIntArray(int[] ia, int nb)
affichageTableau:
	mov bx, tabEntier
	push bx  ;; trasmission du premier parametre:le tableau
	push ax  ;; trasmission du 2�me parametre:le nombre d'entiers lus
	call printIntArray
	add sp, 4
	
	;; Affichage complet du tableau.. 
	;; appel de void printCompleteIntArray (int[] ia)
	push bx
	call printCompleteIntArray
	add sp, 2
	
	
	call message_merci 
	;; Fin de main
finProg:	ret
