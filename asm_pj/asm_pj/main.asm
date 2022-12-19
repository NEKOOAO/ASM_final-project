INCLUDE Irvine32.inc
INTLEN = 6
PIXELNUM = 10
BOXWIDTH = 2
BOXHEIGHT = 5
convertINT PROTO,
	arr : PTR byte,
	len : word
convertCOLOR PROTO,
	arr : PTR byte,
	tar : PTR WORD,
	len : dword
.data
filename byte  "a.txt"
filehandle dword ?
nowtime dword ?
nexttime dword ?
input byte 100 DUP(?)
outputcolor WORD 100 DUP(?)
debug DWORD ?
outputhandle DWORD ?
xyPosition COORD <0,0>
bytesWritten DWORD 0
outputchar BYTE BOXWIDTH DUP(' ')
count DWORD 0
.code

main PROC
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
	mov outputhandle , eax
	call Clrscr
	INVOKE CreateFile, OFFSET filename, GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0
	mov filehandle , eax
	cmp eax , INVALID_HANDLE_VALUE
	JNE L1
	mov eax, 0
L1:
	INVOKE ReadFile,filehandle, addr input, INTLEN, offset debug,0
	INVOKE convertINT, addr input, INTLEN
	INVOKE ReadFile,filehandle, offset input, PIXELNUM, offset debug,0
	call draw_func
	exit
main ENDP

draw_func PROC USES ebx ecx ;use input draw screen
	mov xyPosition.y , 0
	mov ecx , BOXHEIGHT
	INVOKE convertCOLOR , offset input , offset outputcolor , PIXELNUM
	mov ebx , offset outputcolor
DrawLoop:
	push ecx
	INVOKE WriteConsoleOutputAttribute, outputHandle,ebx,BOXWIDTH,xyPosition,ADDR bytesWritten 
	INVOKE WriteConsoleOutputCharacter,outputhandle,ADDR outputchar,BOXWIDTH,xyPosition,ADDR count	
	add ebx , BOXWIDTH*2
	inc xyPosition.y
	pop ecx
	LOOP DrawLoop
	ret

draw_func ENDP

convertINT PROC USES ecx ebx edx, arr: PTR byte , len : word ;cac the input time
	movzx ecx, len
	mov eax, 0
	mov edx, 0
	mov ebx , 10
	mov esi , arr
LOOPINT:
	mul ebx
	mov dl,[esi]
	sub dl,30h ; 30 -> 0's ascii
	add eax,edx
	inc esi
	loop LOOPINT
	ret
convertINT ENDP

convertCOLOR PROC USES eax ecx ebx edx, arr:PTR byte , tar : PTR WORD, len : dword ; cac the input color 
	cld    
	mov esi , arr
	mov ecx , len
	mov edi , tar
LOOP_COLOR:
	mov eax , 0
	mov al , [esi]
	cmp al , 39h;9's ascii +1
	JB ISINT
	JMP COLOR
ISINT:
	sub al, 30h ; 30h -> 0's ascii
	JMP COLOR_RET
COLOR:
	sub al, 41h ; 41h -> A's ascii
	add al, 10;
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
