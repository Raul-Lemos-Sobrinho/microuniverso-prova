#include "c:\prova\include\common.h"

***
*
* NetUse
*

FUNCTION NetUse( tcArquivo, tcAlias )

LOCAL lcOldError, lnError, lnTentativas

*-- Gerencia o erro
lcOldError = ON("ERROR")
ON ERROR lnError = ERROR()

*-- La�o de abertura
lnTentativas = 0
DO WHILE lnTentativas < 6

	SELECT SELECT(tcAlias)

	lnError = 0
	USE (tcArquivo) ALIAS (tcAlias) SHARED AGAIN

	*-- N�o havendo erro
	IF lnError == 0
		EXIT

	*-- Se n�o for CP0 tenta zerar
	ELSE
	 	IF CPDBF() <> 0
			USE IN (lcAlias)
			CpZero(lcArquivo + ".dbf", 0)
			lnError = 1914
		ENDIF
	ENDIF

	lnTentativas = lnTentativas + 1

ENDDO

*-- Restaura error
ON ERROR &lcOldError
RETURN lnError

ENDFUNC


***
*
* NetUseExclusive
*

FUNCTION NetUseExclusive( tcArquivo, tcAlias )

LOCAL lcOldError, lnError, lnTentativas

*-- Gerencia o erro
lcOldError = ON("ERROR")
ON ERROR lnError = ERROR()

*-- La�o de abertura
lnTentativas = 0
DO WHILE lnTentativas < 6

	SELECT SELECT(tcAlias)

	lnError = 0
	USE (tcArquivo) ALIAS (tcAlias) AGAIN EXCLUSIVE

	*-- N�o havendo erro
	IF lnError == 0
		EXIT

	*-- Se n�o for CP0 tenta zerar
	ELSE
	 	IF CPDBF() <> 0
			USE IN (lcAlias)
			CpZero(lcArquivo + ".dbf", 0)
			lnError = 1914
		ENDIF
	ENDIF

	lnTentativas = lnTentativas + 1

ENDDO

*-- Restaura error
ON ERROR &lcOldError
RETURN lnError

ENDFUNC


***
*
* Marca o CP no header do dbf
* Baseada no programa CPZERO
*

FUNCTION CpZero( tcArquivo, tnCP )

*-- Defaults
tnCP = IIF(VARTYPE(tnCP) = 'L', 0, tnCP)

*-- Set up table of code pages and DBF bytes numbers
LOCAL ARRAY laCP[29, 2]
laCP[ 1, 1] = 437		&& MS-DOS, U.S.A.
laCP[ 1, 2] = 1
laCP[ 2, 1] = 850		&& MS-DOS, International
laCP[ 2, 2] = 2
laCP[ 3, 1] = 1252		&& Windows, U.S.A & West European
laCP[ 3, 2] = 3
laCP[ 4, 1] = 10000		&& Macintosh, U.S.A.
laCP[ 4, 2] = 4
laCP[ 5, 1] = 852		&& MS-DOS, East European
laCP[ 5, 2] = 100
laCP[ 6, 1] = 866		&& MS-DOS, Russian
laCP[ 6, 2] = 101
laCP[ 7, 1] = 865		&& MS-DOS, Nordic
laCP[ 7, 2] = 102
laCP[ 8, 1] = 861		&& MS-DOS, Iceland
laCP[ 8, 2] = 103
laCP[ 9, 1] = 895		&& MS-DOS, Kamenicky (Czech)
laCP[ 9, 2] = 104
laCP[10, 1] = 620		&& MS-DOS, Mazovia (Polish)
laCP[10, 2] = 105
laCP[11, 1] = 737		&& MS-DOS, Greek
laCP[11, 2] = 106
laCP[12, 1] = 857		&& MS-DOS, Turkey
laCP[12, 2] = 107
laCP[13, 1] = 863		&& MS-DOS, Canada
laCP[13, 2] = 108
laCP[14, 1] = 950		&& Windows, Traditional Chinese
laCP[14, 2] = 120
laCP[15, 1] = 949		&& Windows, Korean (Hangul)
laCP[15, 2] = 121
laCP[16, 1] = 936		&& Windows, Simplified Chinese
laCP[16, 2] = 122
laCP[17, 1] = 932		&& Windows, Japanese (Shift-jis)
laCP[17, 2] = 123
laCP[18, 1] = 874		&& Windows, Thai
laCP[18, 2] = 124
laCP[19, 1] = 10007		&& Macintosh, Russian
laCP[19, 2] = 150
laCP[20, 1] = 10029		&& Macintosh, East European
laCP[20, 2] = 151
laCP[21, 1] = 10006		&& Macintosh, Greek
laCP[21, 2] = 152
laCP[22, 1] = 1250		&& Windows, East European
laCP[22, 2] = 200
laCP[23, 1] = 1251		&& Windows, Russian
laCP[23, 2] = 201
laCP[24, 1] = 1253		&& Windows, Greek
laCP[24, 2] = 203
laCP[25, 1] = 1254		&& Windows, Turkish
laCP[25, 2] = 202
laCP[26, 1] = 1255		&& Windows, Hebrew (Only supported on Hebrew OS)
laCP[26, 2] = 125
laCP[27, 1] = 1256		&& Windows, Arabic (Only supported on Arabic OS)
laCP[27, 2] = 126
laCP[28, 1] = 1257		&& Windows, Baltic
laCP[28, 2] = 204
laCP[29, 1] = 0			&& No codepage mark.
laCP[29, 2] = 0

LOCAL lnPonteiro, lnHandle, lcBuffer
lnPonteiro = ASCAN(laCP, tnCP, -1, -1, 1, 8)

IF lnPonteiro > 0 AND FILE(tcArquivo)

	*-- Abre o arquivo
	lnHandle = FOPEN(tcArquivo, 2)
	IF lnHandle > 0

		*-- First check that we have a FoxPro table...
		lcBuffer = FREAD(lnHandle, 32)
		IF (SUBSTR(lcBuffer, 1, 1) = CHR(139) OR;
			SUBSTR(lcBuffer, 1, 1) = CHR(203) OR;
			SUBSTR(lcBuffer, 31, 1) <> CHR(0) OR;
			SUBSTR(lcBuffer, 32, 1) <> CHR(0))
			FCLOSE(lnHandle)
			RETURN .F.
		ENDIF
		
		*-- Now poke the codepage id into byte 29
		FSEEK(lnHandle, 29)
		FWRITE(lnHandle, CHR(laCP[lnPonteiro, 2])) 
        FCLOSE(lnHandle)

        RETURN .T.

	ENDIF
ENDIF      

RETURN .F.


***
*
* Pergunta usando a fun��o MESSAGEBOX()
* Par�metro obrigat�rio preseleciona bot�o (Sim/N�o).
*

FUNCTION Ask(tcPrompt, tnDefaultBut, tcCaption)

*-- Defaults
IF VARTYPE(tcCaption) <> 'C'
	IF TYPE('_SCREEN.ActiveForm.Caption') = 'C'
		tcCaption = _SCREEN.ActiveForm.Caption
	ELSE
		tcCaption = _SCREEN.Caption
	ENDIF
ENDIF

IF VARTYPE(tnDefaultBut) <> 'N'
	tnDefaultBut = 1
ENDIF

RETURN ;
	MESSAGEBOX(tcPrompt, MB_ICONQUESTION + MB_YESNO +;
	IIF(tnDefaultBut = 1, MB_DEFBUTTON1, MB_DEFBUTTON2),;
	tcCaption) = IDYES

ENDFUNC


***
*
* Pergunta se quer parar o processamento
*
*

FUNCTION ParaProc(tcPrompt, tcCaption)

*-- Ve se tem tecla no buffer de teclado
IF CHRSAW()
	IF INKEY('H') <> K_ESC
		RETURN .F.
	ENDIF
ELSE
	RETURN .F.
ENDIF

*-- Defaults
IF VARTYPE(tcCaption) <> 'C'
	IF TYPE('_SCREEN.ActiveForm.Caption') = 'C'
		tcCaption = _SCREEN.ActiveForm.Caption
	ELSE
		tcCaption = _SCREEN.Caption
	ENDIF
ENDIF
IF VARTYPE(tcPrompt) <> "C"
	tcPrompt = "Voc� quer abandonar o processamento?"
ENDIF

CLEAR TYPEAHEAD

RETURN MESSAGEBOX(tcPrompt, MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2, tcCaption) = IDYES

ENDFUNC


***
*
* Aviso simples usando a fun��o MESSAGEBOX()
*
*

FUNCTION Tell(tcPrompt, tcCaption)

*-- Defaults
IF VARTYPE(tcCaption) <> 'C'
	IF TYPE('_SCREEN.ActiveForm.Caption') = 'C'
		tcCaption = _SCREEN.ActiveForm.Caption
	ELSE
		tcCaption = _SCREEN.Caption
	ENDIF
ENDIF

=MESSAGEBOX(tcPrompt, MB_ICONINFORMATION + MB_OK + MB_APPLMODAL, tcCaption)

RETURN .F.

ENDFUNC


***
*
* Aviso alerta usando a fun��o MESSAGEBOX()
*
*

FUNCTION Alert(tcPrompt, tcCaption)

*-- Defaults
IF VARTYPE(tcCaption) <> 'C'
	IF TYPE('_SCREEN.ActiveForm.Caption') = 'C'
		tcCaption = _SCREEN.ActiveForm.Caption
	ELSE
		tcCaption = _SCREEN.Caption
	ENDIF
ENDIF

=MESSAGEBOX(tcPrompt, MB_ICONEXCLAMATION + MB_OK + MB_APPLMODAL, tcCaption)

RETURN .F.

ENDFUNC


***
*
* Aviso simples de parada usando a fun��o MESSAGEBOX()
*
*

FUNCTION Stop(tcPrompt, tcCaption)

*-- Defaults
IF VARTYPE(tcCaption) <> 'C'
	IF TYPE('_SCREEN.ActiveForm.Caption') = 'C'
		tcCaption = _SCREEN.ActiveForm.Caption
	ELSE
		tcCaption = _SCREEN.Caption
	ENDIF
ENDIF

=MESSAGEBOX(tcPrompt, MB_ICONSTOP + MB_OK + MB_APPLMODAL, tcCaption)

RETURN .F.

ENDFUNC


***
*
* Retorna um string Criptogradado
*
*

FUNCTION Cripto( tcString, tcChave )

LOCAL lnT, lnLenString, lcCriptografado

lnLenString     = LEN(tcString)
lcCriptografado = ""

*-- Deixa a chave do mesmo tamanho
tcChave = LEFT(REPLICATE(tcChave, lnLenString / LEN(tcChave) + 1), lnLenString)

*-- Criptografa com XOR
FOR lnT = 1 TO lnLenString
	lcCriptografado = lcCriptografado +;
		CHR(BITXOR(ASC(SUBSTR(tcString, lnT, 1)), ASC(SUBSTR(tcChave, lnT, 1))))
NEXT

RETURN lcCriptografado


***
*
* Funcao CriptoOneWay
*
*

FUNCTION CriptoOneWay( tcString, tcChave )

*-- Criptografa com a chave
tcString = Cripto(tcString, tcChave)

*-- Criptografa 2 vezes com o produto dos caracteres
LOCAL lnU, lnT, lnChave, lcChave
tcChave = ""
FOR lnU = 1 TO 2
	lnChave = 0
	FOR lnT = 1 TO LEN(tcString)
		lnChave = lnChave + ASC(SUBSTR(tcString, lnT, 1))
	NEXT
	lcChave = REPLICATE(ALLTRIM(STR(lnChave, 15, 0)), 30)
	FOR lnT = 1 TO 10
		tcChave = CHR(VAL(SUBSTR(lcChave, lnT * 3 - 2, 3)) % 256) + tcChave
	NEXT
	tcString = Cripto(tcString, tcChave)
NEXT

RETURN tcString

ENDFUNC


***
*
* Funcao RunForm
*
*

FUNCTION RunForm( tcForm, tlNovaInstancia, tnModal, tnInvisivel, tnRetornaValor, txParametro1, txParametro2 )

LOCAL llNovaInstancia, llModal, llInvisivel, llRetornaValor, lxRetorno

STORE .T. TO llModal, llInvisivel, llRetornarValor

IF TYPE('tnModal') = "L" OR tnModal = 2
	llModal = .F.
ENDIF

IF TYPE('tnModal') = "L" OR tnModal = 2
	llModal = .F.
ENDIF

IF TYPE('tnInvisivel') = "L" OR tnInvisivel = 2
	llInvisivel = .F.
ENDIF

IF TYPE('tnRetornaValor') = "L" OR tnRetornaValor = 2
	llRetornarValor = .F.
ENDIF

DO CASE

CASE (! tlNovaInstancia) AND WEXIST(tcForm)
	ACTIVATE WINDOW &tcForm.

CASE ( ! llModal AND ! llInvisivel AND ! llRetornarValor AND TYPE('txParametro1') = "L" )
	DO FORM &tcForm.

CASE TYPE('txParametro1') != "L" AND TYPE('txParametro2') != "L"
	IF llModal
		DO FORM &tcForm. WITH llModal, llInvisivel, llRetornarValor, txParametro1, txParametro2 TO lxRetorno
	ELSE
		DO FORM &tcForm. WITH llModal, llInvisivel, llRetornarValor, txParametro1, txParametro2
	ENDIF

CASE TYPE('txParametro1') != "L"
	IF llModal
		DO FORM &tcForm. WITH llModal, llInvisivel, llRetornarValor, txParametro1 TO lxRetorno
	ELSE
		DO FORM &tcForm. WITH llModal, llInvisivel, llRetornarValor, txParametro1
	ENDIF

ENDCASE

IF llRetornarValor
	RETURN lxRetorno
ENDIF

ENDFUNC


***
*
* Funcao EncerrarAplicacao
*
*

PROCEDURE EncerrarAplicacao()

ON SHUTDOWN
CLEAR EVENTS

IF VERSION(2) = 0
	QUIT
ENDIF

SET SYSMENU ON
POP MENU _MSYSMENU

ENDPROC


***
*
* Abre tabelas
*
*

FUNCTION AbrirTabelas( tcAlias, tcScript )

LOCAL lcArquivo, llRetorno, lnStatus

IF VARTYPE(tcAlias) = "C" AND ! EMPTY(tcAlias)

	lnStatus = -1

	DO CASE
	CASE tcAlias = "Telas"
		lnStatus = NetUse(gcPathLocal + 'Telas', 'Telas')

	CASE tcAlias = "Codigos"
		lcArquivo = ( gcPathDados + "Codigos" )

		IF GerarIndices(tcAlias, lcArquivo)
			lnStatus = NetUse(lcArquivo, 'Codigos')
		ENDIF

		IF lnStatus = 0
			SET INDEX TO (lcArquivo)
			SET ORDER TO 0
		ENDIF

	CASE tcAlias = "Configuracao"
		lnStatus = NetUse(gcPathDados + 'Configuracao', 'Configuracao')

	CASE tcAlias = "Usuarios"
		lcArquivo = ( gcPathDados + "Usuarios" )

		IF GerarIndices(tcAlias, lcArquivo)
			lnStatus = NetUse(lcArquivo, 'Usuarios')
		ENDIF

		IF lnStatus = 0
			SET INDEX TO (lcArquivo)
			SET ORDER TO 0

			TEXT TO tcScript NOSHOW PRETEXT 2
				SELECT *, RECNO() AS R_e_c_n_o;
					FROM Usuarios;
					INTO CURSOR crsUsuarios;
					READWRITE

				SELECT crsUsuarios
				INDEX ON Id			TAG ID
				INDEX ON Nome		TAG NOM ADDITIVE COLLATE "GENERAL"
				INDEX ON Login		TAG LOG ADDITIVE COLLATE "GENERAL"
				INDEX ON Papel		TAG PAP ADDITIVE
				INDEX ON VlrMinimo	TAG MIN ADDITIVE
				INDEX ON VlrMaximo	TAG MAX ADDITIVE
				INDEX ON DELETED()	TAG DEL ADDITIVE
				SET ORDER TO NOM
				GO TOP
			ENDTEXT
		ENDIF

	CASE tcAlias = "Notas"
		lcArquivo = ( gcPathDados + "Notas" )

		IF GerarIndices(tcAlias, lcArquivo)
			lnStatus = NetUse(lcArquivo, 'Notas')
		ENDIF

		IF lnStatus = 0
			SET INDEX TO (lcArquivo)
			SET ORDER TO 0

			TEXT TO tcScript NOSHOW PRETEXT 2
				SELECT *, RECNO() AS R_e_c_n_o;
					FROM Notas;
					INTO CURSOR crsNotas;
					READWRITE

				SELECT crsNotas
				INDEX ON Id			TAG ID
				INDEX ON DtEmissao	TAG EMI	ADDITIVE
				INDEX ON VlProdutos TAG PRO	ADDITIVE
				INDEX ON VlDesconto	TAG DES	ADDITIVE
				INDEX ON VlFrete	TAG FRE	ADDITIVE
				INDEX ON VlrTotal	TAG TOT ADDITIVE
				INDEX ON Status		TAG STA ADDITIVE
				INDEX ON DELETED()	TAG DEL	ADDITIVE
				SET ORDER TO NOM
				GO TOP
			ENDTEXT
		ENDIF

	CASE tcAlias = "Aprovacoes"
		lcArquivo = ( gcPathDados + "Aprovacoes" )

		IF GerarIndices(tcAlias, lcArquivo)
			lnStatus = NetUse(lcArquivo, 'Aprovacoes')
		ENDIF

		IF lnStatus = 0
			SET INDEX TO (lcArquivo)
			SET ORDER TO 0

			TEXT TO tcScript NOSHOW PRETEXT 2
				SELECT *, RECNO() AS R_e_c_n_o;
					FROM Notas;
					INTO CURSOR crsNotas;
					READWRITE

				SELECT crsAprovacoes
				INDEX ON Id			TAG ID
				INDEX ON Data		TAG DAT	ADDITIVE
				INDEX ON IdUsuario	TAG USU	ADDITIVE
				INDEX ON IdNota		TAG NOT	ADDITIVE
				INDEX ON Operacao	TAG OPE	ADDITIVE
				INDEX ON DELETED()	TAG DEL	ADDITIVE
				SET ORDER TO DAT
				GO TOP
			ENDTEXT
		ENDIF
	OTHERWISE
		lnStatus = -1

	ENDCASE

	llRetorno = ( lnStatus = 0 )

ENDIF

RETURN llRetorno

ENDFUNC

***
*
* Gerar �ndices
*
*

FUNCTION GerarIndices(tcAlias, tcArquivo)

LOCAL lcArquivo, llRetorno

lcArquivo = ( tcArquivo + ".cdx" )
llRetorno = FILE(lcArquivo)

IF ! llRetorno

	IF USED(tcAlias)
		USE IN (tcAlias)
	ENDIF
	
	IF ( ! USED(tcAlias) AND NetUseExclusive(tcArquivo, tcAlias) = 0 )
		SELECT (tcAlias)

		DO CASE
		CASE tcAlias = "Usuarios"
			TRY
				INDEX ON Id			TAG ID	OF (lcArquivo)
				INDEX ON Nome		TAG NOM	OF (lcArquivo) ADDITIVE COLLATE "GENERAL"
				INDEX ON Login		TAG LOG	OF (lcArquivo) ADDITIVE COLLATE "GENERAL"
				INDEX ON Papel		TAG PAP	OF (lcArquivo) ADDITIVE
				INDEX ON VlrMinimo	TAG MIN	OF (lcArquivo) ADDITIVE
				INDEX ON VlrMaximo	TAG MAX OF (lcArquivo) ADDITIVE
				INDEX ON DELETED()	TAG DEL	OF (lcArquivo) ADDITIVE
				SET ORDER TO 0
				llRetorno = .T.

			CATCH
				llRetorno = .F.

			ENDTRY

		CASE tcAlias = "Notas"
			TRY
				INDEX ON Id			TAG ID	OF (lcArquivo)
				INDEX ON DtEmissao	TAG EMI	OF (lcArquivo) ADDITIVE
				INDEX ON VlProdutos TAG PRO	OF (lcArquivo) ADDITIVE
				INDEX ON VlDesconto	TAG DES	OF (lcArquivo) ADDITIVE
				INDEX ON VlFrete	TAG FRE	OF (lcArquivo) ADDITIVE
				INDEX ON VlrTotal	TAG TOT OF (lcArquivo) ADDITIVE
				INDEX ON Status		TAG STA OF (lcArquivo) ADDITIVE
				INDEX ON DELETED()	TAG DEL	OF (lcArquivo) ADDITIVE
				SET ORDER TO 0
				llRetorno = .T.

			CATCH
				llRetorno = .F.

			ENDTRY

		CASE tcAlias = "Aprovacoes"
			TRY
				INDEX ON Id			TAG ID
				INDEX ON Data		TAG DAT	ADDITIVE
				INDEX ON IdUsuario	TAG USU	ADDITIVE
				INDEX ON IdNota		TAG NOT	ADDITIVE
				INDEX ON Operacao	TAG OPE	ADDITIVE
				INDEX ON DELETED()	TAG DEL	ADDITIVE
				SET ORDER TO 0
				llRetorno = .T.

			CATCH
				llRetorno = .F.

			ENDTRY

		CASE tcAlias = "Codigos"
			TRY
				INDEX ON Tabela    TAG TA OF (lcArquivo) COLLATE "GENERAL"
				INDEX ON DELETED() TAG DEL OF (lcArquivo) ADDITIVE
				SET ORDER TO 0
				llRetorno = .T.

			CATCH
				llRetorno = .F.

			ENDTRY

		ENDCASE

		USE IN (tcAlias)

	ENDIF

ENDIF

RETURN llRetorno

ENDFUNC


***
*
* Sleep
*
*

FUNCTION Sleep( tnMilliseconds )

TRY
	Sleep_Api(tnMilliseconds)
CATCH
	DECLARE Sleep IN kernel32 AS Sleep_Api INTEGER nMilliseconds
	Sleep_Api(tnMilliseconds)
ENDTRY

RETURN .T.

ENDFUNC


***
*
* Processando
*
*

PROCEDURE Processando(tcMensagem, tcCaption, tlFechar)

IF VARTYPE(glProcessando) != "U" OR tlFechar
	LOCAL loFormAtual
	loFormAtual = goFormAtual
	RELEASE glProcessando
	SET CURSOR ON
	goFormAtual = loFormAtual
ELSE
	PUBLIC glProcessando
	DO FORM Forms\frmProcessando NAME glProcessando LINKED WITH tcMensagem, tcCaption NOSHOW
	SET CURSOR OFF
	glProcessando.Show()
	Sleep(300)
ENDIF

RETURN

ENDPROC


***
*
* Gerar c�digos
*
*

FUNCTION GerarCodigo( tcTabela, tnValor, tnDigitos, tnFlag )

LOCAL lcRetorno, lnOldArea

lcRetorno = "-1"
lnOldArea = SELECT()

IF AbrirTabelas('Codigos')

	IF ! SEEK(tcTabela, 'Codigos', 'TA')
		APPEND BLANK
		REPLACE Tabela WITH tcTabela

		IF TYPE('tnDigitos') = "N" AND tnDigitos > 0
			REPLACE Digitos WITH tnDigitos
		ELSE
			REPLACE Digitos WITH LEN(&tcTabela..Id)
		ENDIF

	ENDIF

	IF ( TYPE('tnFlag') = "N" AND tnFlag > 0 AND Flag != tnFlag )
		REPLACE Ultimo	WITH 0,;
				Flag 	WITH tnFlag
	ENDIF

	IF tnValor > 0
		REPLACE Ultimo WITH ( Ultimo + tnValor )
	ENDIF

	IF Digitos = 0
		lcRetorno = Codigos.Ultimo
	ELSE
		lcRetorno = PADL(Codigos.Ultimo, Codigos.Digitos, '0')
	ENDIF

	USE IN Codigos

ELSE
	Stop('N�o foi poss�vel determinar o pr�ximo n�mero da tabela C�digos.')

ENDIF

SELECT (lnOldArea)
RETURN lcRetorno

ENDFUNC


***
*
* Login de acesso ao sistema
*
*

FUNCTION Login()

LOCAL llRetorno

DO FORM Forms\frmLogin.scx TO llRetorno
llRetorno = ( ! EMPTY(_SCREEN.IdUsuario) )
RETURN llRetorno

ENDFUNC


***
*
* Senha para a aprova��o/visto
*
*

FUNCTION Senha()

LOCAL llRetorno

DO FORM Forms\frmSenha.scx TO llRetorno
RETURN llRetorno

ENDFUNC