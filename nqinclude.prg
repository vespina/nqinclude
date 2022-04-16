* NQINCLUDE.PRG
*
* LIBRARY TO INCLUDE VARIOUS PUBLIC LIBRARIES
*
* AUTHOR: VICTOR ESPINA
*
*
* USAGE:
* SET PROC TO NQInclude
*
* bool = NQInclude("resourceId")
*


PROCEDURE NQInclude(pcResourceID)
	LOCAL cUrls,cCRLF
	cUrls = ""
	cCRLF = CHR(13)+CHR(10)
	DO CASE
	   CASE pcResourceId = "vfplegacy"
	        cURLs = "https://raw.githubusercontent.com/vespina/vfplegacy/main/vfplegacy.prg" + cCRLF + ;
	                "https://raw.githubusercontent.com/vespina/vfplegacy/main/vfplegacy.h"
	        
	   CASE pcResourceId = "base64Helper"
	        cURLs = "https://raw.githubusercontent.com/vespina/base64helper/main/base64helper.PRG"

	   CASE pcResourceId = "json"
	        cURLs = "https://raw.githubusercontent.com/vespina/json/main/json.PRG"
    
       OTHERWISE
			MESSAGEBOX("Invalid resource id '" + pcResourceID + "'", 0 + 48, "NQInclude")
			RETURN .F.
	ENDCASE
	LOCAL ARRAY aSources[1]
	LOCAL nCount,i,cFileName,cUrl,cSource,lResult
	nCount = ALINES(aSources, cURLs)
	lResult = .T.
	FOR i = 1 TO nCount
		cUrl = aSources[i]
		cFileName = JUSTFNAME(cUrl)
		IF FILE(cFileName)
			RETURN
		ENDIF
		cSource = GetURL(cUrl)
		IF EMPTY(cSource)
			MESSAGEBOX("Resource '" + cUrl + "' is not available at this time", 0 + 48, "NQInclude")
			lResult = .F.
			EXIT
		ENDIF
		STRTOFILE(cSource, cFileName)
		IF LOWER(JUSTEXT(cFileName)) == "prg"
			COMPILE (cFileName)
		ENDIF
	ENDFOR
	RETURN lResult



***********************************************
** GETURL.PRG
** Devuelve el contenido de un URL dado.
**
** Versión: 1.0
**
** Autor: Victor Espina (vespinas@cantv.net)
**        Walter Valle (wvalle@develcomp.com)
**        (basado en código original de Pablo Almunia)
*
** Fecha: 20-Agosto-2003
**
**
** Sintáxis:
** cData = GetURL(pcURL[,plVerbose])
**
** Donde:
** cData	 Contenido (texto o binario) del recurso 
**			 indicado en cURL. Si ocurre algún error
**           se devolverá la cadena vacia.
** pcURL	 Dirección URL del recurso o archivo a obtener
** plVerbose Opcional. Si se establece en True, se mostrará
**		     información visual sobre el avance del proceso.
**
** Ejemplo:
** cHTML=GetURL("http://www.portalfox.com")
**
*************************************************
**
** GETURL.PRG
** Returns the contains of any given URL
**
** Version: 1.0
**
** Author: Victor Espina (vespinas@cantv.net)
**         Walter Valle (wvalle@develcomp.com)
**         (based on original source code from Pablo Almunia)
*
** Date: August 20, 2003
**
**
** Syntax:
** cData = GetURL(pcURL[,plVerbose])
**
** Where:
** cData	 Contents (text or binary) of requested URL.
** pcURL	 URL of the requested resource or file. If an
**           error occurs, a empty string will be returned.
** plVerbose Optional. If setted to True, progress info
**			 will be shown.
**
** Example:
** cHTML=GetURL("http://www.portalfox.com")
**
**************************************************
PROCEDURE GetURL
LPARAMETER pcURL,plVerbose
 *
 *-- Se definen las funciones API necesarias
 *
 #DEFINE INTERNET_OPEN_TYPE_PRECONFIG     0
 DECLARE LONG GetLastError IN WIN32API
 DECLARE INTEGER InternetCloseHandle IN "wininet.dll" ;
	LONG hInet
 DECLARE LONG InternetOpen IN "wininet.dll" ;
  STRING   lpszAgent, ;
  LONG     dwAccessType, ;
  STRING   lpszProxyName, ;
  STRING   lpszProxyBypass, ;
  LONG     dwFlags
 DECLARE LONG InternetOpenUrl IN "wininet.dll" ;
    LONG    hInet, ;
 	STRING  lpszUrl, ;
	STRING  lpszHeaders, ;
    LONG    dwHeadersLength, ;
    LONG    dwFlags, ;
    LONG    dwContext
 DECLARE LONG InternetReadFile IN "wininet.dll" ;
	LONG     hFtpSession, ;
	STRING  @lpBuffer, ;
	LONG     dwNumberOfBytesToRead, ;
	LONG    @lpNumberOfBytesRead
	
	
 *-- Se establece la conexión con internet
 *
 IF plVerbose
  WAIT "Opening Internet connection..." WINDOW NOWAIT
 ENDIF
 
 LOCAL nInetHnd
 nInetHnd = InternetOpen("GETURL",INTERNET_OPEN_TYPE_PRECONFIG,"","",0)
 IF nInetHnd = 0
  WAIT "ERROR: Connection could not be opened" WINDOW NOWAIT
  RETURN ""
 ENDIF
 
 
 *-- Se establece la conexión con el recurso
 *
 IF plVerbose
  WAIT "Opening connection to URL..." WINDOW NOWAIT
 ENDIF
 
 LOCAL nURLHnd
 nURLHnd = InternetOpenUrl(nInetHnd,pcURL,NULL,0,0,0)
 IF nURLHnd = 0
  InternetCloseHandle( nInetHnd )
  WAIT "ERROR: URL could not be opened" WINDOW NOWAIT
  RETURN ""
 ENDIF


 *-- Se lee el contenido del recurso
 *
 LOCAL cURLData,cBuffer,nBytesReceived,nBufferSize
 cURLData=""
 cBuffer=""
 nBytesReceived=0
 nBufferSize=0

 DO WHILE .T.
  *
  *-- Se inicializa el buffer de lectura (bloques de 2 Kb)
  cBuffer=REPLICATE(CHR(0),2048)
  
  *-- Se lee el siguiente bloque
  InternetReadFile(nURLHnd,@cBuffer,LEN(cBuffer),@nBufferSize)
  IF nBufferSize = 0
   EXIT
  ENDIF
  
  *-- Se acumula el bloque en el buffer de datos
  cURLData=cURLData + SUBSTR(cBuffer,1,nBufferSize)
  nBytesReceived=nBytesReceived + nBufferSize
  
  IF plVerbose
   WAIT WINDOW ALLTRIM(TRANSFORM(INT(nBytesReceived / 1024),"999,999")) + " Kb received..." NOWAIT
  ENDIF
  *
 ENDDO
 IF plVerbose
  WAIT CLEAR
 ENDIF

 
 *-- Se cierra la conexión a Internet
 *
 InternetCloseHandle( nInetHnd )

 *-- Se devuelve el contenido del URL
 *
 RETURN cURLData
 *
ENDPROC	