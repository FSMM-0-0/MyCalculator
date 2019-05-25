.386
.model flat, stdcall
option casemap :none

includelib	msvcrt.lib

strlen	PROTO C :ptr sbyte
printf	PROTO C :dword, :vararg

AddInteger		PROTO	stdcall:dword, :dword
SubInteger		PROTO	stdcall:dword, :dword
MulInteger		PROTO	stdcall:dword, :dword
DivInteger		PROTO	stdcall:dword, :dword
ModInteger		PROTO	stdcall:dword, :dword
Bracket			PROTO	stdcall
Cal				PROTO	stdcall:dword, :byte, :dword
Operator		PROTO	stdcall:byte
Chpriority	    PROTO	stdcall:byte
Calfun			PROTO	stdcall
Finish			PROTO	stdcall


public  Expression
public	flag
public	answer
extern	result:dword
extern	buffer:byte

.data
	op		byte	512 dup(?) ;运算符栈
	optop	dword	0
	num		dword	512 dup(0) ;数字栈
	numtop	dword	0
	dig		dword	0 ;是否数字
	x		dword	0 ;当前数字
	ans		dword	0 ;中间结果
	flag	dword	0 ;结果类型
	sec		dword	0 ;操作数
	fir		dword	0 ;操作数
	ls		dword	? ;字符串长度
	priority	dword	? ;优先级1
	answer	dword	? ;最终结果
	errFmt	byte	'error', 0ah, 0
	div0Fmt byte	'Divide 0', 0ah, 0
	outFmt  byte	'%d', 0ah, 0
.code

;表达式计算
Expression	proc	stdcall 
			push	eax
			push	esi
			push	edi

			;step1: 初始化
			xor		eax, eax
			mov		x, eax
			mov		numtop, eax
			mov		optop, eax
			mov		dig, eax
			mov		flag, eax

			;step2: 遍历
			invoke	strlen, offset buffer
			mov	ls, eax
			xor		esi, esi
			.while	esi < ls
				;当前数
				.if	buffer[esi] >= '0' && buffer[esi] <= '9'
					invoke	MulInteger, x, 10
					invoke	AddInteger, result, buffer[esi]
					invoke	SubInteger, result, '0'
					mov		eax, result
					mov		x, eax
					mov		eax, 1
					mov		dig, eax
				;操作符
				.else
					.if buffer[esi - 1] == '(' && buffer[esi] != '(' ;error
						mov	eax, 1
						mov	flag, eax
						.break
					.endif
					.if	dig != 0 ;数字进栈
						inc	numtop
						mov	edi, numtop
						mov	eax, x
						mov num[edi * 4], eax
						xor eax, eax
						mov dig, eax
						mov x, eax
					.endif
					.if	buffer[esi] == '(' || optop == 0 || buffer[esi] == '^'
						inc optop
						mov edi, optop
						mov al, buffer[esi]
						mov	op[edi], al
					.elseif buffer[esi] == ')'
						invoke	Bracket
						.if	flag == 1 || flag == 2
							.break
						.endif
					.elseif buffer[esi] == '+' || buffer[esi] == '-' || buffer[esi] == '*' || buffer[esi] == '/' || buffer[esi] == '^' || buffer[esi] == '%'
						invoke Operator, buffer[esi]
						.if	flag == 1 || flag == 2
							.break
						.endif
					.else
						mov flag, 1
						.break
					.endif
				.endif
				inc esi
			.endw

			.if dig != 0
				inc	numtop
				mov	edi, numtop
				mov	eax, x
				mov num[edi * 4], eax
				xor eax, eax
				mov dig, eax
			.endif
			.if flag == 0
				invoke	Finish
			.endif

			.if flag != 1 && flag != 2
				mov eax, numtop
				mov	edi, num[eax * 4]
				mov answer, edi
				;invoke	printf, offset outFmt, num[eax * 4]
			.endif

			pop		edi
			pop		esi
			pop		eax
			ret
Expression	endp

Bracket		proc	stdcall 
	push	ecx

	mov		ecx, optop
	.while optop != 0 
		mov ecx, optop
		.if op[ecx] == '('
			.break
		.endif
		invoke	Calfun
		.if flag == 1 || flag == 2
			pop ecx
			ret
		.endif
	.endw
	.if optop == 0
		mov flag, 1
	.else
		dec optop
		mov flag, 0
	.endif

	pop		ecx
	ret
Bracket		endp

Cal			proc	stdcall xx:dword, cc:byte, yy:dword
	push	eax
	push	edi

	.if	cc == '+'
		invoke	AddInteger, xx, yy
		mov	eax, result
		mov	ans, eax
	.elseif	cc == '-'
		invoke	SubInteger, xx, yy
		mov	eax, result
		mov ans, eax
	.elseif	cc == '*'
		invoke	MulInteger, xx, yy
		mov	eax, result
		mov ans, eax
	.elseif	cc == '/'
		.if yy == 0
			mov flag, 2
			pop edi
			pop eax
			ret
		.endif
		invoke	DivInteger, xx, yy
		mov eax, result
		mov ans, eax
	.elseif	cc == '%'
		.if yy == 0
			mov flag, 2
			pop edi
			pop eax
			ret			
		.endif
		invoke	ModInteger, xx, yy
		mov eax, result
		mov ans, eax
	.elseif cc == '^'
		mov ans, 1
		xor edi, edi
		.while edi < yy
			invoke	MulInteger, ans, xx
			mov eax, result
			mov ans, eax
			inc edi
		.endw
	.endif

	pop		edi
	pop		eax
	ret
Cal			endp

Chpriority	proc	stdcall cc:byte
	.if	cc == '+'
		mov priority, 1
		ret
	.elseif	cc == '-'
		mov priority, 1
		ret
	.elseif cc == '*'
		mov priority, 2
		ret
	.elseif	cc == '/'
		mov priority, 2
		ret
	.elseif cc == '^'
		mov priority, 3
		ret
	.elseif cc == '('
		mov priority, 0
		ret
	.endif
Chpriority	endp

Operator	proc	stdcall cc:byte
	local	c1:dword
	push	ebx
	push	edi
	push	edx

	.while optop != 0 
		mov	ebx, optop
		invoke Chpriority, op[ebx]
		mov edi, priority
		mov c1, edi
		invoke Chpriority, cc
		mov edi, priority
		cmp c1, edi
		jnl	continue
		.break
continue:
		invoke Calfun
		.if flag == 1 || flag == 2
			ret
		.endif
	.endw
	inc optop
	mov ebx, optop
	mov dl, cc
	mov op[ebx], dl

	pop		edx
	pop		edi
	pop		ebx
	ret
Operator	endp

Calfun		proc	stdcall
	push	ecx
	push	edi
	push	ebx

	.if	numtop < 2
		mov flag, 1
		pop		ebx
		pop		edi
		pop		ecx
		ret
	.endif
	mov ecx, numtop
	mov edi, num[ecx * 4]
	mov sec, edi
	mov edi, num[ecx * 4 - 4]
	mov fir, edi
	dec numtop
	dec numtop
	mov	ebx, optop
	.if	op[ebx] == '^' && sec < 0
		mov flag, 1
		pop		ebx
		pop		edi
		pop		ecx
		ret
	.endif
	invoke	Cal, fir, op[ebx], sec
	.if	flag == 2
		pop		ebx
		pop		edi
		pop		ecx
		ret
	.endif		
	inc numtop
	mov ecx, numtop
	mov edi, ans
	mov num[ecx * 4], edi
	dec optop

	pop		ebx
	pop		edi
	pop		ecx
	ret
Calfun		endp

Finish		proc	stdcall
	.while optop != 0
		invoke	Calfun
		.if	flag == 1 || flag == 2
			ret
		.endif
	.endw
	.if numtop != 1
		mov flag, 1
	.else
		mov flag, 0
	.endif
	ret
Finish		endp
			end

