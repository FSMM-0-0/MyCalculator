.386
.model flat, stdcall
option casemap :none

includelib	msvcrt.lib
log10	PROTO C :real8

public  AddInteger
public	SubInteger
public  MulInteger
public  DivInteger
public  ModInteger
public  AddFloat
public  SubFloat
public  MulFloat
public  DivFloat
public  SinFloat
public  CosFloat
public  TanFloat
public  Arctan
public	Sqrt
public	Log
public	Fact
extern	result:dword
extern	fresult:real8
extern	answer:real8 ;最终结果
.data
.code

;整数加法a+b
AddInteger	proc	stdcall a, b
			push	eax
			mov		eax, a
			add		eax, b
			mov		result, eax
			pop		eax
			ret		
AddInteger	endp

;整数减法a-b
SubInteger	proc	stdcall a, b
			push	eax
			mov		eax, a
			sub		eax, b
			mov		result, eax
			pop		eax
			ret
SubInteger	endp

;整数乘法a*b
MulInteger	proc	stdcall a, b
			push	eax
			mov		eax, a
			mul		b
			mov		result, eax
			pop		eax
			ret
MulInteger	endp

;整数除法a÷b
DivInteger	proc	stdcall a, b
			push	eax
			mov		eax, a
			div		b
			mov		result, eax
			pop		eax
			ret
DivInteger  endp

;整数取余a%b
ModInteger	proc	stdcall a, b
			push	eax
			push	edx
			mov		eax, a
			div		b
			mov		result, edx
			pop		edx
			pop		eax
			ret
ModInteger	endp
		
;浮点数加法a+b
AddFloat	proc	stdcall a:real8, b:real8
			finit
			fld		b
			fld		a
			fadd	st(0),st(1)
			fst		fresult
			ret
AddFloat	endp

;浮点数减法a-b
SubFloat	proc	stdcall a:real8, b:real8
			finit
			fld		b
			fld		a
			fsub	st(0),st(1)
			fst		fresult
			ret
SubFloat	endp

;浮点数乘法a*b
MulFloat	proc	stdcall a:real8, b:real8
			finit
			fld		b
			fld		a
			fmul	st(0),st(1)
			fst		fresult
			ret
MulFloat	endp

;浮点数除法a÷b
DivFloat	proc	stdcall a:real8, b:real8
			finit
			fld		b
			fld		a
			fdiv	st(0),st(1)
			fst		fresult
			ret
DivFloat	endp

;sin(a)
SinFloat	proc	stdcall a:real8
			finit
			fld		a
			fsin
			fst		answer
			ret
SinFloat	endp

;cos(a)
CosFloat	proc	stdcall a:real8
			finit
			fld		a
			fcos
			fst		answer
			ret
CosFloat	endp

;tan(a)
TanFloat	proc	stdcall a:real8
			finit
			fld		a
			fptan
			fst		answer
			ret
TanFloat	endp

;arctan(a)
Arctan		proc	stdcall a:real8
			finit
			fld		a
			fpatan
			fst		answer
			ret
Arctan	endp

;sqrt(a)
Sqrt		proc	stdcall a:real8
			finit
			fld		a
			fsqrt
			fst		answer
			ret
Sqrt	endp

;log10(a)
Log			proc	stdcall a:real8
			finit
			invoke	log10, a
			fst		answer
			ret
Log		endp

;fact(n)
Fact		proc	stdcall n:dword
			cmp		n,1
			jbe		exitrecurse
			mov		ebx, n
			dec		ebx
			invoke	Fact, ebx
			imul	n
			ret
exitrecurse:
			mov	eax,1
			ret
Fact		endp

			end

