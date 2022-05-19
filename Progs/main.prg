CLEAR
CLEAR MACROS
CLOSE ALL

SET BELL OFF
SET CENTURY ON
SET COLLATE TO "GENERAL"
SET CURSOR ON
SET DATE BRITISH
SET DECIMALS TO 2
SET DELETED ON
SET CPDIALOG OFF
SET ESCAPE OFF
SET HOURS TO 24
SET NOTIFY OFF
SET POINT TO ","
SET SAFETY OFF
SET SEPARATOR TO "."
SET TALK OFF

PUSH MENU _MSYSMENU
SET SYSMENU OFF

*-- Para adaptar as pastas na vers�o de desenvolvimento
IF VERSION(2) = 0
	SET STATUS BAR OFF
	SET PROCEDURE TO lib ADDITIVE

ELSE
	SET DEFAULT TO ALLTRIM(JUSTPATH(SYS(16, 0)))
	CD ..

	LOCAL lcPath, lcPathMenus, lcPathProgs, lcPathForms
	lcPath = SYS(5) + CURDIR()

	CD &lcPath.

	lcPathMenus = lcPath + "Menus;"
	lcPathProgs = lcPath + "Progs;"
	lcPathForms = lcPath + "Forms;"

	lcPath = lcPathForms + lcPathMenus + lcPathProgs + HOME()

	SET PATH TO &lcPath. Additive
	SET PROCEDURE TO (STRTRAN(lcPathProgs, ';', '\') + 'lib')        ADDITIVE

ENDIF

_SCREEN.Visible     = .F.
_SCREEN.AutoCenter  = .T.
_SCREEN.BackColor   = RGB(226,226,226)
_SCREEN.Caption     = "Aprova��es de Notas de Compra"
_SCREEN.Icon        = "logo_somelsd.ico"
_SCREEN.WindowState = 2
_SCREEN.Visible     = .T.

*-- As informa��es do usu�rio logado ficar�o vis�veis em todo o sistema
ADDPROPERTY(_SCREEN, 'IdUsuario', 0)
ADDPROPERTY(_SCREEN, 'Nome', '')
ADDPROPERTY(_SCREEN, 'Login', '')
ADDPROPERTY(_SCREEN, 'Papel', '')
ADDPROPERTY(_SCREEN, 'VlrMinimo', 0)
ADDPROPERTY(_SCREEN, 'VlrMaximo', 0)

PUBLIC gcPathDados, goFormAtual
gcPathDados = SYS(5) + CURDIR() + "DBFs\"
goFormAtual = _SCREEN

SET SYSMENU ON

*-- Carrega o menu principal e ap�s o login permite o acesso aos m�dulos
DO mnuprincipal.mpr
IF Login()
	ON SHUTDOWN EncerrarAplicacao()
	READ EVENTS
ENDIF

*-- Deixa o ambiente "aberto" na vers�o de desenvolvimento
IF VERSION(2) = 0
	CLOSE DATABASES
	SET PROCEDURE TO
	SET LIBRARY TO
	RELEASE ALL EXTENDED
	ON SHUTDOWN
	QUIT
ENDIF

ON SHUTDOWN

SET SYSMENU ON
POP MENU _MSYSMENU

*-- Fim