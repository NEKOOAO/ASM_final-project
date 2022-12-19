INCLUDE Irvine32.inc
INTLEN = 6
PIXELNUM = 1
BOXWIDTH = 2
HEIGHT = 100
convertINT PROTO,
	arr : PTR byte,
	len : word
convertCOLOR PROTO,
	arr : PTR byte,
	len : dword
.data
filename byte  "a.txt"
filehandle dword ?
nowtime dword ?
nexttime dword ?
input byte 100 DUP(?)
debug DWORD ?
outputhandle DWORD ?
xyPosition COORD <0,0>
bytesWritten DWORD 0
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
	INVOKE ReadFile,filehandle, offset input, INTLEN, offset debug,0
	INVOKE convertINT, addr input, INTLEN
	INVOKE ReadFile,filehandle, offset input, PIXELNUM, offset debug,0
	INVOKE convertCOLOR , addr input , PIXELNUM
	INVOKE WriteConsoleOutputAttribute, outputHandle,ADDR input,BOXWIDTH,xyPosition,ADDR bytesWritten 
 
	exit
main ENDP

convertINT PROC USES ecx ebx edx, arr: PTR byte , len : word
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

convertCOLOR PROC USES ecx ebx edx, arr:PTR byte ,len : dword
	mov esi , arr
	mov ecx , len
	
LOOP_COLOR:
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
	mov [esi] , al
	inc esi
	LOOP LOOP_COLOR
	ret
convertCOLOR ENDP
END main
