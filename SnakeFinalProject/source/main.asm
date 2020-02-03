TITLE BattleSnek
;Authors: Aiden McIlraith and Chris Roberts
;Last Modified: 12/10/2018
;None of the functions in this code has any requirements for registers and most of them edit the registers

INCLUDE Irvine32.inc 

;Sets the default range of the board
dim equ 20d ;side length of board
sqrDim equ 400d ;square of dim

;Sets the colors for the game
aColor equ green + lightGreen * 16
bColor equ red + 16 * lightRed 
nullColor equ white


;stores a set of locations
loc STRUCT 
    X BYTE ?
    Y BYTE ?
loc ENDS


.data
   
    ;These are for visual effect
    aWins BYTE "Congradulations! Green Wins!", 0
    bWins BYTE "Congradulations! Red Wins!", 0
    tieMessage BYTE "it was a tie...", 0

	;The output for the board. These are each individual tiles.
    body  BYTE 177d,177d, 0d
    fruit BYTE 204d, 185d, 0
    walls BYTE 178d, 178d, 0
    colors BYTE 15, 13
    space byte "  ",0
    
    ;These are for data storage
    listA loc sqrDim DUP(<?,?>); This stores the snake part locations
    listB loc sqrDim DUP(<?,?>); This stores the snake part locations
    
    sSizeA BYTE 2d ;This stores the length of the first snake
    sSizeB BYTE 2d ;This stores the length of the second snake
    lastKeyA BYTE 31d
    lastKeyB BYTE 72d
    fruitLoc loc<?,?>


.code
main PROC
    ;--Obtained from http://kipirvine.com/asm/4th/instructor/4thEdition/moreprojects/bouncingball.asm --
	;----- hides the cursor ----------------------------------------
    .data
    cursorInfo CONSOLE_CURSOR_INFO <>
    outHandle  DWORD ?
    .code
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov  outHandle,eax
	INVOKE GetConsoleCursorInfo, outHandle, ADDR cursorInfo
	mov  cursorInfo.bVisible,0
	INVOKE SetConsoleCursorInfo, outHandle, ADDR cursorInfo
	;---------------------------------------------------------------
    call initBoard
    ;This is the bulk of the program
    MainSnekLoop:
        call addHead
        call editKey
        jmp MainSnekLoop
    exit
main ENDP

;This stores the last key or ignores a lack of key press
;snakeB
	;80d is down
	;72d is up
	;75d is left
	;6
	7d is right

;snakeA
	;17d is w
	;30d is a
	;31d is s
	;32d is d
editKey PROC
	mov  eax, 200; This determines refresh rate          
    call Delay      
    startEditKey:
    call ReadKey
    jz endEditKey

    ;Check A
    mov bh, lastKeyA
    push eax

    ;move if one of the four valid values
    cmp ah,17d
    cmove bx, ax
    cmp ah,30d
    cmove bx, ax
    cmp ah,31d
    cmove bx, ax
    cmp ah,32d
    cmove bx, ax
    
    ;Make sure that it doesn't kill itself by going straight backwards
    mov ah, lastKeyA
    mov al, 0
    mov bl, 0
    mov cl, ah
    sub cl, bh
    ;At this point, al and bl are 0, ah is the direction the snake was going, 
    ;and bh is the key that was pressed if it was valid, otherwise it will be the pevious thing pressed still
    ;cl holds their difference
    cmp cl, 2d
    cmove bx, ax
    cmp cl, 14d
    cmove bx, ax
    ;check for the other direction
    neg cl
    cmp cl, 2d
    cmove bx, ax
    cmp cl, 14d
    cmove bx, ax

    ;put the proper value into lastKey based on the two above criteria
    mov lastKeyA, bh

    ;Check B 
    pop eax
    mov bh, lastKeyB

    cmp ah,80d
    cmove bx, ax
    cmp ah,72d
    cmove bx, ax
    cmp ah,75d
    cmove bx, ax
    cmp ah,77d
    cmove bx, ax

    ;Make sure that it doesn't kill itself by going straight backwards
    mov ah, lastKeyB
    mov al, 0
    mov bl, 0
    mov cl, ah
    sub cl, bh
    ;At this point, al and bl are 0, ah is the direction the snake was going, 
    ;and bh is the key that was pressed if it was valid, otherwise it will be the pevious thing pressed still
    ;cl holds their difference
    cmp cl, 2d
    cmove bx, ax
    cmp cl, 8d
    cmove bx, ax
    ;check for the other direction
    neg cl
    cmp cl, 2d
    cmove bx, ax
    cmp cl, 8d
    cmove bx, ax

    mov lastKeyB, bh
    jmp startEditKey
    endEditKey:
    ret
editKey ENDP

;adds the heads in the direction that the keys that were last pressed
;This also checks to see if the snakes hit something and reacts appropriatly
addHead PROC
	;1. Add heads to the snakes
	;2. remove the tails of the snakes
	;3. check to see if the snakes hit eachother, the walls, or themselves.
    ;add head to array and screen

    ;Snake A
        movzx edi, sSizeA
        dec edi
        add edi, edi
        
        mov ah, lastKeyA
        cmp ah,17d
        je subVerticalHeadA
        cmp ah,30d
        je subHorizontalHeadA
        cmp ah,31d
        je addVerticalHeadA
        cmp ah,32d
        je addHorizontalHeadA

		;There is a case for each possible move direction for each snake
        addVerticalheadA:
            mov al, (loc ptr listA[edi]).Y
            mov ah, (loc ptr listA[edi]).X
            inc al

            inc edi
            inc edi
            mov (loc ptr listA[edi]).Y, al
            mov (loc ptr listA[edi]).X, ah
            inc sSizeA
            jmp addHeadSnakeB

        subVerticalheadA:
            mov al, (loc ptr listA[edi]).Y
            mov ah, (loc ptr listA[edi]).X
            dec al
            inc edi
            inc edi
            mov (loc ptr listA[edi]).Y, al
            mov (loc ptr listA[edi]).X, ah
            inc sSizeA
            jmp addHeadSnakeB

        addHorizontalHeadA:
            mov al, (loc ptr listA[edi]).Y
            mov ah, (loc ptr listA[edi]).X
            inc ah
            inc edi
            inc edi
            mov (loc ptr listA[edi]).Y, al
            mov (loc ptr listA[edi]).X, ah
            inc sSizeA
            jmp addHeadSnakeB

        subHorizontalHeadA:
            mov al, (loc ptr listA[edi]).Y
            mov ah, (loc ptr listA[edi]).X
            dec ah
            inc edi
            inc edi
            mov (loc ptr listA[edi]).Y, al
            mov (loc ptr listA[edi]).X, ah
            inc sSizeA
            jmp addHeadSnakeB

    addHeadSnakeB:
    ;Snake B
        movzx edi, sSizeB
        dec edi
        add edi, edi
        
        mov ah, lastKeyB
        cmp ah,72d
        je subVerticalHeadB
        cmp ah,80d
        je addVerticalheadB
        cmp ah,77d
        je addHorizontalHeadB
        cmp ah,75d
        je subHorizontalHeadB

        addVerticalheadB:
            mov al, (loc ptr listB[edi]).Y
            mov ah, (loc ptr listB[edi]).X
            inc al

            inc edi
            inc edi
            mov (loc ptr listB[edi]).Y, al
            mov (loc ptr listB[edi]).X, ah
            inc sSizeB
            jmp checkRemoveTailA

        subVerticalheadB:
            mov al, (loc ptr listB[edi]).Y
            mov ah, (loc ptr listB[edi]).X
            dec al
            inc edi
            inc edi
            mov (loc ptr listB[edi]).Y, al
            mov (loc ptr listB[edi]).X, ah
            inc sSizeB
            jmp checkRemoveTailA

        addHorizontalHeadB:
            mov al, (loc ptr listB[edi]).Y
            mov ah, (loc ptr listB[edi]).X
            inc ah
            inc edi
            inc edi
            mov (loc ptr listB[edi]).Y, al
            mov (loc ptr listB[edi]).X, ah
            inc sSizeB
            jmp checkRemoveTailA

        subHorizontalHeadB:
            mov al, (loc ptr listB[edi]).Y
            mov ah, (loc ptr listB[edi]).X
            dec ah
            inc edi
            inc edi
            mov (loc ptr listB[edi]).Y, al
            mov (loc ptr listB[edi]).X, ah
            inc sSizeB
            jmp checkRemoveTailA
        
        
        checkRemoveTailA:
        ;Remove the tail unless fruit
            movzx ecx, sSizeA
            add ecx, ecx

            mov al, (loc ptr listA[ecx-2]).X
            mov ah, (loc ptr listA[ecx-2]).Y
            mov bl, fruitLoc.X 
            mov bh, fruitLoc.Y
            cmp ax, bx
            je addNewFruitA
            call removeTailA
            jmp checkRemoveTailB
        addNewFruitA:
            call addFruit

        checkRemoveTailB:
        ;Remove the tail unless fruit
            movzx ecx, sSizeB
            add ecx, ecx

            mov al, (loc ptr listB[ecx-2]).X
            mov ah, (loc ptr listB[ecx-2]).Y
            mov bl, fruitLoc.X 
            mov bh, fruitLoc.Y
            cmp ax, bx
            je addNewFruitB
            call removeTailB
            jmp showHeads
        addNewFruitB:
            call addFruit

    showHeads:
        mov eax, aColor
        call SetTextColor
        movzx edi, sSizeA
        dec edi
        add edi, edi
        mov dl, (loc ptr listA[edi]).X
        add dl, 1
        add dl, dl
        mov dh, (loc ptr listA[edi]).Y
        add dh, 1
        call Gotoxy

        mov edx, offset body
        call WriteString


        mov eax, bColor
        call SetTextColor
		movzx edi, sSizeB
        dec edi
        add edi, edi
        mov dl, (loc ptr listB[edi]).X
        add dl, 1
        add dl, dl
        mov dh, (loc ptr listB[edi]).Y
        add dh, 1
        call Gotoxy

        mov edx, offset body
        call WriteString

    
    ;check loss A
		mov ax, loc ptr listA[edi]
        movzx edi, sSizeB
        dec edi
        add edi, edi
        cmp loc ptr listB[edi], ax
        je tie

        movzx edi, sSizeA
		dec edi
        add edi, edi

        movzx ecx, sSizeA
		dec ecx
		dec ecx
        add ecx, ecx
        cmp (loc ptr listA[edi]).X,0
        jl aLoss

        cmp (loc ptr listA[edi]).X,dim
        jge aLoss

        cmp (loc ptr listA[edi]).Y,0
        jl aLoss

        cmp (loc ptr listA[edi]).Y,dim
        jge aLoss

        checkSnakeASelfCollision:
            mov ax, loc ptr listA[ecx]
            cmp loc ptr listA[edi], ax
            je aLoss
            dec ecx
            dec ecx
			cmp ecx, 0
			jge checkSnakeASelfCollision

        movzx ecx, sSizeB
		dec ecx
        add ecx, ecx
        checkSnakeAOtherCollision:
            mov ax, loc ptr listA[edi]
            cmp loc ptr listB[ecx], ax
            je aLoss
            dec ecx
            dec ecx
			cmp ecx, 0
			jge checkSnakeAOtherCollision

        ;Snake B Check
        movzx edi, sSizeB
		dec edi
        add edi, edi


        
        movzx ecx, sSizeB
		dec ecx
		dec ecx
        add ecx, ecx
        cmp (loc ptr listB[edi]).X,0
        jl bLoss

        cmp (loc ptr listB[edi]).X,dim
        jge bLoss

        cmp (loc ptr listB[edi]).Y,0
        jl bLoss

        cmp (loc ptr listB[edi]).Y,dim
        jge bLoss

        checkSnakeBSelfCollision:
            mov ax, loc ptr listB[ecx]
            cmp loc ptr listB[edi], ax
            je bLoss
            dec ecx
            dec ecx
			cmp ecx, 0
			jge checkSnakeBSelfCollision

        movzx ecx, sSizeA
		dec ecx
        add ecx, ecx
        checkSnakeBOtherCollision:
            mov ax, loc ptr listB[edi]
            cmp loc ptr listA[ecx], ax
            je bLoss
            dec ecx
            dec ecx
			cmp ecx, 0
			jge checkSnakeBOtherCollision
        

	jmp endAddHead
    aLoss:
        mov dl, dim-10
        mov dh, dim/2
        call gotoxy

        mov eax, bColor
        call SetTextColor

        mov edx, offset bWins
        call WriteString
        mov eax, 1000
        call Delay
        exit
    bLoss:
        mov dl, dim-10
        mov dh, dim/2
        call gotoxy

        mov eax, aColor
        call SetTextColor

        mov edx, offset aWins
        call WriteString
        mov eax, 1000
        call Delay
        exit
    tie:
        mov dl, dim-10
        mov dh, dim/2
        call gotoxy

        mov eax, white
        call SetTextColor

        mov edx, offset tieMessage
        call WriteString
        mov eax, 1000
        call Delay
        exit
    endAddHead:
    ret
addHead ENDP


;This should remove the tail A during output. This also shortens the array by one
;Takes no arguements
removeTailA PROC
    mov dl, (loc ptr listA[0]).X
    add dl, 1
    add dl, dl
    mov dh, (loc ptr listA[0]).Y
    add dh, 1
    call Gotoxy

    mov eax, nullColor
    call SetTextColor

    mov edx, offset space
    call WriteString

    movzx ecx, sSizeA
	inc ecx
    add ecx, ecx 
    mov ebx, 0
    mov al, (loc ptr listA[0]).X
    removeTailALoop1:
        inc ebx
        xchg al, (loc ptr listA[ecx-1]).X
        loop removeTailALoop1

    movzx ecx, sSizeA
	inc ecx
    add ecx, ecx 
    mov ebx, 0
    mov al, (loc ptr listA[0]).X
    removeTailALoop2:
        inc ebx
        xchg al, (loc ptr listA[ecx-1]).X
        loop removeTailALoop2

    dec sSizeA

    ret
removeTailA ENDP

;This should remove the tail B during output. This also shortens the array by one.
removeTailB PROC
    mov dl, (loc ptr listB[0]).X
    add dl, 1
    add dl, dl
    mov dh, (loc ptr listB[0]).Y
    add dh, 1
    call Gotoxy

    mov eax, nullColor
    call SetTextColor
    mov edx, offset space
    call WriteString

    movzx ecx, sSizeB
	inc ecx
    add ecx, ecx 
    mov ebx, 0
    mov al, (loc ptr listB[0]).X
    removeTailBLoop1:
        inc ebx
        xchg al, (loc ptr listB[ecx-1]).X
        loop removeTailBLoop1

    movzx ecx, sSizeB
	inc ecx
    add ecx, ecx 
    mov ebx, 0
    mov al, (loc ptr listB[0]).X
    removeTailBLoop2:
        inc ebx
        xchg al, (loc ptr listB[ecx-1]).X
        loop removeTailBLoop2

    dec sSizeB

    ret
removeTailB ENDP

;This outputs a random fruit to the board  where the snake isn't and stores is loc
addFruit PROC
		;Reset the text color so it displays nicely
        mov eax, white
        call SetTextColor
	;Makes sure the fruit is in a valid location
    addFruitTop:
        mov eax, dim
        call RandomRange
        mov bl, al
        mov eax, dim
        call RandomRange
        mov bh, al

        movzx ecx, sSizeA
		add ecx, ecx
        addFruitCheckA:
            mov al, (loc ptr ListA[ecx-2]).X
            mov ah, (loc ptr ListA[ecx-2]).Y
            cmp ax, bx
            je addFruitTop
            loop addFruitCheckA

        movzx ecx, sSizeB
		add ecx, ecx
        addFruitCheckB:
            mov al, (loc ptr ListB[ecx-2]).X
            mov ah, (loc ptr ListB[ecx-2]).Y
            cmp ax, bx
            je addFruitTop
            loop addFruitCheckB

        
        ;Once the fruit is in a valid location, save the location, then output it to the screen
        mov fruitLoc.X, bl
        mov fruitLoc.Y, bh

		mov dl, fruitLoc.X
		add dl, 1
		add dl, dl
		mov dh, fruitLoc.Y
		add dh, 1
		call Gotoxy

		mov edx, offset fruit
        call WriteString
    ret
addFruit ENDP

;Output the starting board and set the initial conditions for the snake
initBoard PROC
    mov eax, nullColor
    call SetTextColor

    call Randomize
    ;Draw Top
    mov edx, 0
    call Gotoxy

    mov edx, OFFSET walls
    mov ecx, dim + 2
    initLoopTop:
        call WriteString     
        loop initLoopTop
    
    ;Draw left
    mov edx, 0
    mov ecx, dim+2
    initLoopLeft:
        call Gotoxy
        push edx

        mov edx, OFFSET walls
        call Writestring

        pop edx
        inc dh
        loop initLoopLeft

    ;Draw right
    mov edx, 0
    mov dl, dim + dim + 2
    mov ecx, dim+2
    initLoopRight:
        call Gotoxy
        push edx

        mov edx, OFFSET walls
        call Writestring

        pop edx
        inc dh
        loop initLoopRight

    ;Draw bottom
    mov edx, 0
    mov dh, dim + 1
    call Gotoxy

    mov edx, OFFSET walls
    mov ecx, dim + 2
    initLoopBottom:
        call WriteString     
        loop initLoopBottom

    ;set up the snakes
    mov (loc ptr listA[0]).X,0
    mov (loc ptr listA[0]).Y,0
    mov (loc ptr listA[2]).X,0
    mov (loc ptr listA[2]).Y,1
    
    mov dl, (loc ptr listA[0]).X
	add dl, 1
    add dl, dl
    mov dh, (loc ptr listA[0]).Y
	add dh, 1
    call Gotoxy
    
    mov eax, aColor
    call SetTextColor
    mov edx, offset body
    call WriteString

    mov dl, (loc ptr listA[2]).X
	add dl, 1
    add dl, dl
    mov dh, (loc ptr listA[2]).Y
	add dh, 1
    call Gotoxy

    mov edx, offset body
    call WriteString

	;setup B snake
    mov eax, bColor
    call SetTextColor
    mov (loc ptr listB[0]).X,dim-1
    mov (loc ptr listB[0]).Y,dim-1
    mov (loc ptr listB[2]).X,dim-1
    mov (loc ptr listB[2]).Y,dim-2

    mov dl, (loc ptr listB[0]).X
	add dl, 1
    add dl, dl
    mov dh, (loc ptr listB[0]).Y
	add dh, 1
    call Gotoxy

    mov edx, offset body
    call WriteString

    mov dl, (loc ptr listB[2]).X
    add dl, 1
    add dl, dl
    mov dh, (loc ptr listB[2]).Y
    add dh, 1
    call Gotoxy

    mov edx, offset body
    call WriteString

    call addFruit
    ret
initBoard ENDP

END