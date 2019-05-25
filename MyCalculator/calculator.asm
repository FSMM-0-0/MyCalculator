.386
.model flat, stdcall
option casemap :none

includelib	msvcrt.lib

strlen	PROTO C :ptr sbyte
printf	PROTO C :dword, :vararg
sprintf	PROTO C :ptr sbyte, :vararg
sscanf	PROTO C :ptr sbyte, :vararg
fmod	PROTO C :real8, :real8
pow		PROTO C :real8, :real8

AddFloat		PROTO	stdcall:real8, :real8
SubFloat		PROTO	stdcall:real8, :real8
MulFloat		PROTO	stdcall:real8, :real8
DivFloat		PROTO	stdcall:real8, :real8
Bracket			PROTO	stdcall
Cal				PROTO	stdcall:real8, :byte, :real8
Operator		PROTO	stdcall:byte
Chpriority	    PROTO	stdcall:byte
Calfun			PROTO	stdcall
Finish			PROTO	stdcall


public  Expression
public	flag
public	answer
public	fresult
public	result
extern	buffer:byte

.data
	op			byte	512 dup(?) ;运算符栈
	optop		dword	0
	num			real8	512 dup(?) ;数字栈
	numtop		dword	0
	dig			dword	0 ;是否数字
	sign		dword	0 ;是否为负s
	tmpx		byte	512 dup(0) ;当前数字
	x			real8	? ;当前数字
	ans			real8	? ;中间结果
	flag		dword	0 ;结果类型
	sec			real8	? ;操作数
	fir			real8	? ;操作数
	ls			dword	? ;字符串长度
	priority	dword	? ;优先级1
	answer		real8	? ;最终结果
	errFmt		byte	'error', 0ah, 0
	div0Fmt		byte	'Divide 0', 0ah, 0
	outFmt		byte	'%d', 0ah, 0
	finFmt		byte    '%lf', 0
	catFmt		byte	'%s%c', 0
	float0		real8	0.0
	fresult		real8	? ;计算值
	result		dword	? ;计算值
.code

;表达式计算
Expression	proc	stdcall 
			push	eax
			push	esi
			push	edi

			;step1: 初始化
			finit
			xor		eax, eax
			mov		numtop, eax
			mov		optop, eax
			mov		dig, eax
			mov		flag, eax
			mov		sign, eax

			;step2: 遍历
			invoke	strlen, offset buffer
			mov	ls, eax
			xor		esi, esi
			.while	esi < ls
				;负数
				.if	buffer[esi] == '-' && (esi == 0 || \
					buffer[esi - 1] == '+' || buffer[esi - 1] == '-' || \
					buffer[esi - 1] == '*' || buffer[esi - 1] == '/' || \
					buffer[esi - 1] == '^' || buffer[esi - 1] == '%' || \
					buffer[esi - 1] == '(')
					mov		sign, 1
				;当前数
				.elseif	(buffer[esi] >= '0' && buffer[esi] <= '9') || buffer[esi] == '.'
					invoke	sprintf, offset tmpx, offset catFmt, offset tmpx, buffer[esi]
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
						invoke	sscanf, offset tmpx, offset finFmt, offset x
						mov tmpx[0], 0

						inc	numtop
						mov	edi, numtop
						fld	x
						.if sign != 0 
							fchs ;负数
							mov sign, 0
						.endif
						fst num[edi * 8]
						xor eax, eax
						mov dig, eax
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
				invoke	sscanf, offset tmpx, offset finFmt, offset x
				mov tmpx[0], 0

				inc	numtop
				mov	edi, numtop
				fld	x
				.if sign != 0 
					fchs ;负数
					mov sign, 0
				.endif
				fst num[edi * 8]
				xor eax, eax
				mov dig, eax
			.endif
			.if flag == 0
				invoke	Finish
			.endif

			.if flag != 1 && flag != 2
				mov eax, numtop
				fld	num[eax * 8]
				fst answer
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

Cal			proc	stdcall xx:real8, cc:byte, yy:real8
	push	eax
	push	edi

	.if	cc == '+'
		invoke	AddFloat, xx, yy
		fld	fresult
		fst ans
	.elseif	cc == '-'
		invoke	SubFloat, xx, yy
		fld	fresult
		fst ans
	.elseif	cc == '*'
		invoke	MulFloat, xx, yy
		fld	fresult
		fst ans
	.elseif	cc == '/'
		fld	yy
		fcom float0
		fnstsw ax
		sahf
		je div0_1

		invoke	DivFloat, xx, yy
		fld	fresult
		fst ans

		pop edi
		pop eax
		ret
div0_1: ;div 0
		mov flag, 2
		ret
	.elseif	cc == '%'
		fld	yy
		fcom float0
		fnstsw ax
		sahf
		je div0_2

		invoke	fmod, xx, yy ;浮点数取模
		fst ans

		pop edi
		pop eax
		ret
div0_2: ;div 0
		mov flag, 2
		ret
	.elseif cc == '^'
		invoke	pow, xx, yy ;浮点数求幂
		fst ans
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
	fld	num[ecx * 8]
	fst sec
	fld num[ecx * 8 - 8]
	fst fir
	dec numtop
	dec numtop
	mov	ebx, optop
	invoke	Cal, fir, op[ebx], sec
	.if	flag == 2
		pop		ebx
		pop		edi
		pop		ecx
		ret
	.endif		
	inc numtop
	mov ecx, numtop
	fld	ans
	fst	num[ecx * 8]
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

