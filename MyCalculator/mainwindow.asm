.386
.model flat, stdcall
option casemap :none

include		user32.inc
include		windows.inc
include		kernel32.inc
include		gdi32.inc
includelib	kernel32.lib
includelib	user32.lib
includelib	msvcrt.lib
includelib	gdi32.lib

WinMain	PROTO	:dword, :dword, :dword, :dword
strcat	PROTO C :ptr sbyte, :ptr sbyte
strlen	PROTO C :ptr sbyte
sprintf	PROTO C :ptr sbyte, :vararg
sscanf	PROTO C :ptr sbyte, :vararg

public	buffer
extern	flag:dword ;结果类型
extern	answer:real8 ;最终结果

Expression		PROTO	stdcall
SinFloat		PROTO	stdcall:real8
CosFloat		PROTO	stdcall:real8
TanFloat		PROTO	stdcall:real8
Arctan			PROTO	stdcall:real8
Sqrt			PROTO	stdcall:real8
Log				PROTO	stdcall:real8
Fact			PROTO	stdcall:dword

.data
	ClassName			db	"MyCalculator", 0
	AppName				db	"MyCalculator", 0

	ButtonClassName		db	"button", 0
;button define #region
	Button1				db	"1", 0
	Button2				db	"2", 0
	Button3				db	"3", 0
	Button4				db	"4", 0
	Button5				db	"5", 0
	Button6				db	"6", 0
	Button7				db	"7", 0
	Button8				db	"8", 0
	Button9				db	"9", 0
	Button0				db	"0", 0
	Buttonadd			db	"+", 0
	Buttonsub			db	"-", 0
	Buttonequ			db	"=", 0
	Buttonmul			db	"*", 0
	Buttondiv			db	"/", 0
	Buttondot			db	".", 0
	Buttonright			db	")", 0
	Buttonleft			db	"(", 0
	Buttonce			db	"CE", 0
	Buttondel			db	"DELETE", 0
	Buttonmod			db	"%", 0
	Buttonsin			db	"sin", 0
	Buttoncos			db	"cos", 0
	Buttontan			db	"tan", 0
	Buttonarc			db	"arctan", 0
	Buttonpi			db	"π", 0
	Buttonfac			db	"n!", 0
	Button2x			db	"x^y", 0
	Buttonsqrt			db	"sqrt(x)", 0
	Buttonlog			db	"log(x)", 0
	Buttonneg			db	"±", 0
	Buttone				db	"e", 0
	Buttonmadd			db	"M+", 0
	Buttonmsub			db	"M-", 0
	Buttonms			db	"MS", 0
;#endregion
	errMsg				db	"error", 0
	div0Msg				db	"Divide 0 error", 0
	outFmt				db	"%g", 0
	numFmt				db	"%d", 0
	outfFmt				db	"%lf", 0
	negFmt				db	"%s%s", 0
	EditClassName		db	"edit", 0
	piMsg				db	"3.1415926", 0
	eMsg				db	"2.7182818", 0
	miMsg				db	"^", 0
	negMsg				db	"-", 0
	negbuf				db	512 dup(?)
	FontName			db	"Consolas", 0

	hInstance	HINSTANCE	?					;句柄
	CommandLine	LPSTR		?
	hwndButton	HWND		?
	hwndEdit	HWND		?
	OldWndProc	dd			?
	buffer		db			512 dup(?)			;表达式
	num			dword		?					;阶乘数

	EditID		equ			36
	IDM_GETTEXT equ			37

;BUTTONID 1-35#region
ButtonID1		equ		1
ButtonID2		equ		2
ButtonID3		equ		3
ButtonID4		equ		4
ButtonID5		equ		5
ButtonID6		equ		6
ButtonID7		equ		7
ButtonID8		equ		8
ButtonID9		equ		9
ButtonID0		equ		10
ButtonIDadd		equ		11
ButtonIDsub		equ		12
ButtonIDequ		equ		13
ButtonIDmul		equ		14
ButtonIDdiv		equ		15
ButtonIDdot		equ		16
ButtonIDright	equ		17
ButtonIDleft	equ		18
ButtonIDce		equ		19
ButtonIDdel		equ		20
ButtonIDmod		equ		21
ButtonIDsin		equ		22
ButtonIDcos		equ		23
ButtonIDtan		equ		24
ButtonIDarc		equ		25
ButtonIDpi		equ		26
ButtonIDfac		equ		27
ButtonID2x		equ		28
ButtonIDsqrt	equ		29
ButtonIDlog		equ		30
ButtonIDneg		equ		31
ButtonIDe		equ		32
ButtonIDmadd	equ		33
ButtonIDmsub	equ		34
ButtonIDms		equ		35
;#endregion

.code
main	proc	C 
		invoke	GetModuleHandle, NULL
		mov		hInstance, eax
		invoke	GetCommandLine
		mov		CommandLine, eax
		invoke	WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT ;调用窗口主函数
		invoke	ExitProcess, eax
main	endp

WinMain		proc	hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
		LOCAL	wc:WNDCLASSEX                                  
		LOCAL	msg:MSG 
		LOCAL	hwnd:HWND

		 mov	wc.cbSize,SIZEOF WNDCLASSEX
		 mov	wc.style, CS_HREDRAW or CS_VREDRAW 
		 mov	wc.lpfnWndProc, OFFSET WndProc 
		 mov	wc.cbClsExtra,NULL 
		 mov	wc.cbWndExtra,NULL 
		 push	hInst
		 pop	wc.hInstance
		 mov	wc.hbrBackground,COLOR_WINDOW+1 
		 mov	wc.lpszMenuName,NULL 
		 mov	wc.lpszClassName,OFFSET ClassName 
		 invoke LoadIcon,NULL,IDI_APPLICATION 
		 mov	wc.hIcon,eax 
		 mov	wc.hIconSm,eax
		 invoke LoadCursor,NULL,IDC_ARROW 
		 mov	wc.hCursor,eax 
		 invoke RegisterClassEx, addr wc
		 invoke CreateWindowEx,NULL,\ 
                ADDR ClassName,\ 
                ADDR AppName,\ 
                WS_OVERLAPPEDWINDOW,\ 
                CW_USEDEFAULT,\ ;x
                CW_USEDEFAULT,\ ;y
                460,\ ;宽
                550,\ ;高
                NULL,\ 
                NULL,\ 
                hInst,\ 
                NULL 
		 mov  	hwnd,eax 
		 invoke ShowWindow, hwnd,SW_SHOWNORMAL       ; display window
		 invoke UpdateWindow, hwnd             ; refresh the client area
		 .WHILE TRUE                                                         ; Enter message loop 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .if (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
		 .ENDW
		 mov     eax,msg.wParam
		 ret
WinMain	endp
;#endregion

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL hfont:HFONT

	.if uMsg==WM_DESTROY                    ; closes window 
		invoke PostQuitMessage,NULL         ; quit application 
	.elseif uMsg==WM_CREATE
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
						WS_CHILD or WS_VISIBLE or WS_BORDER or ES_RIGHT or ES_MULTILINE or\
						ES_AUTOVSCROLL,\
						25,35,400,100,hWnd,EditID,hInstance,NULL
		mov  hwndEdit,eax
		invoke SetFocus, hwndEdit
		invoke SetWindowLong,hwndEdit,GWL_WNDPROC,addr EditWndProc
		mov OldWndProc,eax

		;edit字体
		invoke CreateFont,45,0,0,0,FW_NORMAL,0,0,0,ANSI_CHARSET,\
                    OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
                    DEFAULT_QUALITY,DEFAULT_PITCH or FF_SCRIPT,\
                    ADDR FontName
		mov	hfont,eax
		invoke	SendMessage, hwndEdit, WM_SETFONT, hfont, 1
		;button字体
		invoke CreateFont,25,0,0,0,FW_EXTRABOLD,0,0,0,ANSI_CHARSET,\
                    OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
                    DEFAULT_QUALITY,DEFAULT_PITCH or FF_SCRIPT,\
                    ADDR FontName	
		mov	hfont,eax

		;createbutton #region
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonleft,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						1,460,88,50,hWnd,ButtonIDleft,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonright,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						89,460,88,50,hWnd,ButtonIDright,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button0,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						177,460,88,50,hWnd,ButtonID0,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttondot,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						265,460,88,50,hWnd,ButtonIDdot,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonequ,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						353,460,88,50,hWnd,ButtonIDequ,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonarc,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						1,410,88,50,hWnd,ButtonIDarc,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button1,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						89,410,88,50,hWnd,ButtonID1,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button2,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						177,410,88,50,hWnd,ButtonID2,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button3,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						265,410,88,50,hWnd,ButtonID3,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonadd,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						353,410,88,50,hWnd,ButtonIDadd,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttontan,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						1,360,88,50,hWnd,ButtonIDtan,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button4,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						89,360,88,50,hWnd,ButtonID4,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button5,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						177,360,88,50,hWnd,ButtonID5,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button6,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						265,360,88,50,hWnd,ButtonID6,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonsub,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						353,360,88,50,hWnd,ButtonIDsub,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttoncos,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						1,310,88,50,hWnd,ButtonIDcos,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button7,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						89,310,88,50,hWnd,ButtonID7,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button8,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						177,310,88,50,hWnd,ButtonID8,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button9,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						265,310,88,50,hWnd,ButtonID9,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonmul,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						353,310,88,50,hWnd,ButtonIDmul,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonsin,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						1,260,88,50,hWnd,ButtonIDsin,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonpi,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						89,260,88,50,hWnd,ButtonIDpi,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonfac,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						177,260,88,50,hWnd,ButtonIDfac,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonmod,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						265,260,88,50,hWnd,ButtonIDmod,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttondiv,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						353,260,88,50,hWnd,ButtonIDdiv,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Button2x,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						1,210,88,50,hWnd,ButtonID2x,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonsqrt,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						89,210,88,50,hWnd,ButtonIDsqrt,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonlog,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						177,210,88,50,hWnd,ButtonIDlog,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonce,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						265,210,88,50,hWnd,ButtonIDce,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttondel,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						353,210,88,50,hWnd,ButtonIDdel,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonneg,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						1,160,88,50,hWnd,ButtonIDneg,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttone,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						89,160,88,50,hWnd,ButtonIDe,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonmadd,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						177,160,88,50,hWnd,ButtonIDmadd,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonmsub,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						265,160,88,50,hWnd,ButtonIDmsub,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR Buttonms,\
						WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
						353,160,88,50,hWnd,ButtonIDms,hInstance,NULL
		mov  hwndButton,eax
		invoke	SendMessage, hwndButton, WM_SETFONT, hfont, 1
		;#endregion
	.elseif	uMsg==WM_COMMAND
		mov	eax,wParam
		.if	lParam==0
			.if ax==IDM_GETTEXT
				invoke	GetWindowText, hwndEdit, ADDR buffer, 512
				invoke	MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK
			.else
				invoke	DestroyWindow,hWnd
			.endif
		.else
			;button control #region
			;显示按钮 
			.if	ax==ButtonID0
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button0
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID1
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button1
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID2
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button2
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID3
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button3
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID4
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button4
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID5
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button5
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID6
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button6
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID7
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button7
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID8
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button8
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID9
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Button9
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDleft
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Buttonleft
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDright
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Buttonright
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDdot
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Buttondot
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDadd
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Buttonadd
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDsub
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Buttonsub
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDmul
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Buttonmul
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDdiv
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Buttondiv
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDmod
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset Buttonmod
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDpi
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset piMsg
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDe
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset eMsg
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonID2x
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strcat, offset buffer, offset miMsg
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDce
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	SetWindowText,hwndEdit, NULL
				.endif
			.elseif ax==ButtonIDdel
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	strlen, offset buffer
					mov	buffer[eax - 1], 0
					invoke	SetWindowText,hwndEdit, ADDR buffer
				.endif
			.elseif ax==ButtonIDneg
				shr	eax,16
				.if	ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	sprintf, offset negbuf, offset negFmt, offset negMsg, offset buffer
					invoke	SetWindowText,hwndEdit, ADDR negbuf
				.endif					
			;求解按钮
			.elseif ax==ButtonIDequ || ax==ButtonIDsin || ax==ButtonIDcos || \
					ax==ButtonIDtan || ax==ButtonIDarc || ax==ButtonIDsqrt || \
					ax==ButtonIDlog || ax==ButtonIDfac
				mov bx, ax
				shr eax,16
				.if ax==BN_CLICKED
					invoke	GetWindowText, hwndEdit, ADDR buffer, 512
					invoke	Expression ;求解函数	
						
					.if flag == 1 ;error
						invoke	SetWindowText, hwndEdit, ADDR errMsg
					.elseif flag == 2 ;div 0
						invoke	SetWindowText, hwndEdit, ADDR div0Msg
					.else ;answer
						.if	bx==ButtonIDsin ;sin
							invoke	SinFloat, answer
						.elseif bx==ButtonIDcos ;cos
							invoke	CosFloat, answer
						.elseif	bx==ButtonIDtan ;tan
							invoke	TanFloat, answer
						.elseif bx==ButtonIDarc ;arctan
							invoke	Arctan, answer
						.elseif	bx==ButtonIDsqrt ;sqrt
							invoke	Sqrt, answer
						.elseif	bx==ButtonIDlog ;log10
							invoke	Log, answer
						.elseif bx==ButtonIDfac ;fact
							invoke	sprintf, offset buffer, offset outFmt, answer
							invoke	sscanf, offset buffer, offset numFmt, offset num
							invoke	Fact, num
							mov	num, eax
							invoke	sprintf, offset buffer, offset numFmt, num
							invoke	sscanf, offset buffer, offset outfFmt, offset answer
						.endif
						invoke	sprintf, offset buffer, offset outFmt, answer
						invoke	SetWindowText, hwndEdit, ADDR buffer
					.endif
				.endif
			.endif
			;#endregion
		.endif
	.else 
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam     ; Default message processing 
		ret 
	.endif 
	xor eax,eax 
	ret 
WndProc endp

;输入框键盘响应
EditWndProc PROC hEdit:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.if uMsg==WM_CHAR
		mov eax,wParam
		.if (al>="0" && al<="9") || al=="+" || al=="-" || al=="*" || al=="/" || \
			al=="%" || al=="." || al=="(" || al==")" || al=="^" 
			invoke CallWindowProc,OldWndProc,hEdit,uMsg,eax,lParam
			ret
		.endif
	.elseif uMsg==WM_KEYDOWN
		mov eax,wParam
		.if al==VK_RETURN
			invoke	GetWindowText, hwndEdit, ADDR buffer, 512
			invoke	Expression
			.if flag == 1
				invoke	SetWindowText, hwndEdit, ADDR errMsg
			.elseif flag == 2 
				invoke	SetWindowText, hwndEdit, ADDR div0Msg
			.else
				invoke	sprintf, offset buffer, offset outFmt, answer
				invoke	SetWindowText, hwndEdit, ADDR buffer
			.endif
			invoke SetFocus,hEdit
		.elseif al==VK_BACK || al==VK_DELETE
			invoke	GetWindowText, hwndEdit, ADDR buffer, 512
			invoke	strlen, offset buffer
			mov	buffer[eax - 1], 0
			invoke	SetWindowText,hwndEdit, ADDR buffer			
		.else
			invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam
			ret
		.endif
	.else
		invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
EditWndProc endp
		end
