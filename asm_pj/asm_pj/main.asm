INCLUDE Irvine32.inc
INTLEN = 6
PIXELNUM = 20000
BOXWIDTH = 200
BOXHEIGHT = 100
convertINT PROTO,
	arr : PTR byte,
	len : word
convertCOLOR PROTO,
	arr : PTR byte,
	tar : PTR WORD,
	len : dword
.data
fileinput byte  "input file name : ",0
startplay byte "push any key to play video " , 0
filehandle dword ?
nowtime dword ?
nexttime dword ?
starttime dword ?
input byte 20009 DUP(?)
outputcolor WORD 20009 DUP(?)
debug DWORD ?
outputhandle DWORD ?
xyPosition COORD <0,0>
bytesWritten DWORD 0
outputchar BYTE BOXWIDTH DUP(' ')
count DWORD 0
endexe  byte 0
.code

main PROC
	mov edx , offset fileinput
	call WriteString
	mov edx , offset input
	mov ecx , (SIZEOF input)-1
	call ReadString
	mov edx , offset startplay
	call WriteString
	call crlf
	call waitmsg
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
	mov outputhandle , eax
	call Clrscr
	INVOKE CreateFile, OFFSET input, GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0
	mov filehandle , eax
	cmp eax , INVALID_HANDLE_VALUE
	JE BREAK
	INVOKE ReadFile,filehandle, addr input, INTLEN, offset debug,0
	call GetTickCount
	mov starttime , eax
	mov eax, 0
L1:
	INVOKE convertINT, addr input, INTLEN
	INVOKE ReadFile,filehandle, offset input, PIXELNUM, offset debug,0
	call draw_func
	call wait_next_scene
	movzx eax , endexe
	cmp eax , 1
	JE BREAK
	JMP L1
BREAK:
	exit
main ENDP

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

convertINT PROC USES ecx ebx edx, arr: PTR byte , len : word ;cac the input time (ret in eax)
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
	mov dl,[esi]
	sub dl,30h ; 30 -> 0's ascii
	add eax,edx
	inc esi
	loop LOOPINT
INTRET:
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
