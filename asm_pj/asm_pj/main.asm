INCLUDE Irvine32.inc
INTLEN = 6
PIXELNUM = 79325
BOXWIDTH = 475
BOXHEIGHT = 167		; video resolution

convertINT PROTO,
	arr : PTR byte,
	len : word
convertCOLOR PROTO,
	arr : PTR byte,
	tar : PTR WORD,
	len : dword

.data
; string
fileinput byte  "Input file name : ",0
startplay byte "Push any key to play video " , 0
errorMessage byte "Some error occured, please check your file ", 0

; handle
input byte PIXELNUM DUP(?)
filehandle dword ?
outputhandle DWORD ?

; time
nowtime dword ?
nexttime dword ?
starttime dword ?

; timeline bar
nextbartime dword ?
timeblock dword ?
barPosition COORD <0 , BOXHEIGHT+1>
barcolor WORD 0D0h
barchar BYTE ' '

; other
outputcolor WORD PIXELNUM DUP(?)
outputchar BYTE BOXWIDTH DUP(' ')
debug DWORD ?
xyPosition COORD <0,0>
bytesWritten DWORD 0
count DWORD 0
endexe  byte 0 

.code
main PROC
	mov edx, offset fileinput
	call WriteString
	mov edx, offset input
	mov ecx, (SIZEOF input)-1
	call ReadString		; reads in the file name from the user
	mov edx, offset startplay
	call WriteString
	call crlf
	call waitmsg

	; Get the console ouput handle
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE 
	mov outputhandle, eax
	call Clrscr
	INVOKE CreateFile, OFFSET input, GENERIC_READ, DO_NOT_SHARE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov filehandle, eax

	; if the file is broken, or file doesn't exist, end the program
	cmp eax, INVALID_HANDLE_VALUE
	JE ERROR

	; get computer time
	call GetTickCount
	mov starttime , eax
	mov eax, 0
	INVOKE ReadFile,filehandle, addr input, INTLEN, offset debug,0
	INVOKE convertINT, addr input, INTLEN
	mov edx , 0
	mov ebx , BOXWIDTH
	DIV ebx
	mov timeblock , eax
	add eax , starttime
	mov nextbartime , eax
	INVOKE ReadFile,filehandle, addr input, 2, offset debug,0
	INVOKE ReadFile,filehandle, addr input, INTLEN, offset debug,0
L1:
	INVOKE convertINT, addr input, INTLEN
	INVOKE ReadFile,filehandle, offset input, PIXELNUM, offset debug, 0
	call draw_func
	call wait_next_scene
	call draw_bar
	movzx eax, endexe
	cmp eax , 1		; exit code
	JE BREAK
	JMP L1
ERROR:
	mov edx, offset errorMessage
	call WriteString
BREAK:
	call Clrscr
	exit
main ENDP


; pause the program and wait for the appropriate amount of time, which is frame rate
wait_next_scene PROC USES eax ebx ecx		
NEXTINPUT:
	INVOKE ReadFile,filehandle, addr input, 2, offset debug,0
	INVOKE ReadFile,filehandle, addr input, INTLEN, offset debug,0
	INVOKE convertINT, addr input, INTLEN
	cmp eax , 0FFFFFFFFh
	JE BREAK
	add eax , starttime
	mov nexttime , eax
	call GetTickCount
	cmp eax , nexttime
	JB NEXTSCENE
	INVOKE ReadFile,filehandle, offset input, PIXELNUM, offset debug,0
	JMP NEXTINPUT
NEXTSCENE:
	mov ebx , nexttime
	sub ebx , eax
	INVOKE sleep, ebx
BREAK:
	ret
wait_next_scene ENDP

; draw the timeline bar
draw_bar PROC USES eax ebx ecx
bar_loop:
	call GetTickCount
	cmp eax , nextbartime
	JB not_draw
	INVOKE WriteConsoleOutputAttribute, outputHandle,ADDR barcolor,1,barPosition,ADDR bytesWritten 
	INVOKE WriteConsoleOutputCharacter,outputhandle,ADDR barchar,1,barPosition,ADDR count	
	inc barPosition.x
	mov eax , nextbartime
	add eax , timeblock
	mov nextbartime , eax
	JMP bar_loop
not_draw:
	ret
draw_bar ENDP

; converting the input from the file into the scene
draw_func PROC USES ebx ecx		
	mov xyPosition.y , 0
	mov ecx , BOXHEIGHT
	INVOKE convertCOLOR, offset input, offset outputcolor, PIXELNUM
	mov ebx , offset outputcolor
DrawLoop:
	push ecx
	INVOKE WriteConsoleOutputAttribute, outputHandle, ebx, BOXWIDTH, xyPosition, ADDR bytesWritten 
	INVOKE WriteConsoleOutputCharacter, outputhandle, ADDR outputchar, BOXWIDTH, xyPosition, ADDR count	
	add ebx , BOXWIDTH*2
	inc xyPosition.y
	pop ecx
	LOOP DrawLoop
	ret
draw_func ENDP


; cac the input time (ret in eax)
convertINT PROC USES ecx ebx edx, arr: PTR byte , len : word 
	movzx ecx, len
	mov eax, 0
	mov edx, 0
	mov ebx , 10
	mov esi , arr
	mov dl ,[esi]
	cmp dl , 53h
	JNE LOOPINT
	mov endexe , 1
	mov eax , 0FFFFFFFFh
	JMP INTRET
LOOPINT:
	mul ebx
	mov dl, [esi]
	sub dl, 30h ; 30 -> 0's ascii
	add eax, edx
	inc esi
	loop LOOPINT
INTRET:
	ret
convertINT ENDP


; cac the input color 
convertCOLOR PROC USES eax ecx ebx edx, arr:PTR byte , tar : PTR WORD, len : dword 
	cld    
	mov esi , arr
	mov ecx , len
	mov edi , tar
LOOP_COLOR:
	mov eax , 0
	mov al , [esi]
	cmp al , 39h		; 9's ascii +1
	JB ISINT
	JMP COLOR
ISINT:
	sub al, 30h			; 30h -> 0's ascii
	JMP COLOR_RET
COLOR:
	sub al, 41h			; 41h -> A's ascii
	add al, 10
	JMP COLOR_RET
COLOR_RET:
	shl al , 4
	mov [edi] , ax 
	add esi , 1
	add edi , 2
	LOOP LOOP_COLOR
	ret
convertCOLOR ENDP
END main
