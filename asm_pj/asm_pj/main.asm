INCLUDE Irvine32.inc
INTLEN = 3
.data
filename byte  "a.txt"
filehandle dword ?
input byte 100 DUP(?)
debug DWORD ?
.code
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

convertCOLOR PROC USES ecx ebx edx, char:byte
	movzx eax , char
	cmp eax , 39h;9's ascii +1
	JB ISINT
	JMP COLOR
ISINT:
	sub eax, 30h ; 30h -> 0's ascii
	JMP COLOR_RET
COLOR:
	sub eax, 41h ; 41h -> A's ascii
	add eax, 10;
	JMP COLOR_RET
COLOR_RET:
	ret
convertCOLOR ENDP

main PROC
	INVOKE CreateFile, OFFSET filename, GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0
	mov filehandle , eax
	cmp eax , INVALID_HANDLE_VALUE
	JNE L1
	mov eax, 0
L1:
	INVOKE ReadFile,filehandle, offset input, INTLEN, offset debug,0
	INVOKE convertINT, addr input, INTLEN
	INVOKE ReadFile,filehandle, offset input, 1, offset debug,0
	INVOKE convertCOLOR, input[0]
	exit
main ENDP
END main
