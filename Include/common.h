*-- Arquivo comum de inclus�o

#include "foxpro.h"
#include "registry.h"
#include "teclas.h"


*-- Caracteres
#DEFINE CRLF						CHR(13)+CHR(10)
#DEFINE CR							CHR(13)
#DEFINE TAB							CHR(9)

*-- Teclas
#DEFINE K_ENTER						13
#DEFINE K_ESC						27

*-- Direitos de acesso
#define AC_NAO						0
#define AC_CONSULTA					1
#define AC_ALTERA					2
#define AC_INCLUI					3
#define AC_EXCLUI					4

*-- Status do BaseForm
#define FORM_VISUALIZANDO			"V"
#define FORM_INCLUINDO				"I"
#define FORM_EDITANDO				"E"
#define FORM_ALTERANDO				"E"

*-- Nomes de barras de ferramentas
#DEFINE TB_FORMDESIGNER_LOC  		"Form Designer"
#DEFINE TB_STANDARD_LOC      		"Standard"
#DEFINE TB_LAYOUT_LOC        		"Layout"
#DEFINE TB_QUERY_LOC		 		"Query Designer"
#DEFINE TB_VIEWDESIGNER_LOC 		"View Designer"
#DEFINE TB_COLORPALETTE_LOC  		"Color Palette"
#DEFINE TB_FORMCONTROLS_LOC  		"Form Controls"
#DEFINE TB_DATADESIGNER_LOC  		"Database Designer"
#DEFINE TB_REPODESIGNER_LOC  		"Report Designer"
#DEFINE TB_REPOCONTROLS_LOC  		"Report Controls"
#DEFINE TB_PRINTPREVIEW_LOC  		"Print Preview"

*-- Dias da semana
#define DIAS_DA_SEMANA 				"Domingo        Segunda-feira  Ter�a-feira    Quarta-feira   Quinta-feira   Sexta-feira    S�bado                        "

*-- Meses do ano
#define MESES_DO_ANO				"Janeiro     Fevereiro   Mar�o       Abril       Maio        Junho       Julho       Agosto      Setembro    Outubro     Novembro    Dezembro                "

*-- Mensagens
#DEFINE MSG_AJUDANAODISPONIVEL 		"Ajuda n�o dispon�vel."
#DEFINE MSG_ERRORLOCK				"Erro bloqueando registro."
#DEFINE MSG_TENTARLOCK				"Este registro est� bloqueado por outra esta��o." + CRLF + "Voc� quer tentar novamente?"
#DEFINE MSG_TENTAFLOCK				"O arquivo de @ n�o pode ser bloqueado." + CRLF + "Voc� quer tentar novamente?"
#DEFINE MSG_ABANDONAMUDANCAS		"Dados foram alterados. Abandona altera��es sem salvar?"
#DEFINE MSG_NAOREGEXCLUIR			"N�o h� registro para ser excluido."
#DEFINE MSG_NAOREGALTERAR			"N�o h� registro para ser alterado."
#DEFINE MSG_CONFEXCLUSAO			"Voc� confirma exclus�o desse registro?"
#DEFINE MSG_SAIRSISTEMA				"Voc� tem certeza que quer sair do sistema?"
#DEFINE MSG_PROSSEGUIR				"Voc� quer prosseguir mesmo assim?"
#DEFINE MSG_ALTERADOPOROUTRO		"Este registro foi alterado por outro usu�rio."
#DEFINE MSG_METHOD          		"M�todo: "
#DEFINE MSG_LINENUM					"Linha: "
#DEFINE MSG_USUARIONAOCADASTRADO	"Usu�rio @ n�o cadastrado."
#DEFINE MSG_SENHAINCORRETA			"Senha incorreta."
#DEFINE MSG_ERROSINTATICOCONDICAO	"Erro sint�tico na condi��o."
#DEFINE MSG_ERROSINTATICOEXPRESSAO	"Erro sint�tico na express�o."
#DEFINE MSG_ERROLOCALIZACAO			"Erro na localiza��o."
#DEFINE MSG_ERROCRIANDOARQUIVO		"Erro na cria��o do arquivo @."
#DEFINE MSG_ASKATUALIZAVERSAO		"A vers�o @ do sistema j� est� dispon�vel para atualiza��o." + CRLF + "Voc� que atualizar agora?"
#DEFINE MSG_TELLATUALIZAVERSAO		"A vers�o @ do sistema j� est� dispon�vel para atualiza��o." + CRLF + "Por favor atualize agora."
#DEFINE MSG_ASKLOCALIZABASEDADOS	"N�o foi poss�vel encontrar a base de dados. Voc� quer localizar?"
#DEFINE MSG_VERSAOARQUIVOSINCOMP    "Vers�o dos arquivos incompat�vel. Voc� quer localizar outra base de dados?"

*-- EOF