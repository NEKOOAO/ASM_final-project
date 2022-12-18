INCLUDE Irvine32.inc
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
	sub dl,30h
	add eax,edx
	inc esi
	loop LOOPINT
	ret
convertINT ENDP
main PROC
	INVOKE CreateFile, OFFSET filename, GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0
	mov filehandle , eax
	cmp eax , INVALID_HANDLE_VALUE
	JNE L1
	mov eax, 0
L1:
	INVOKE ReadFile,filehandle, offset input, 3, offset debug,0
	INVOKE convertINT, addr input, 3
	exit
main ENDP
END main
