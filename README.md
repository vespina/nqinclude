# nqinclude.prg
Library to include various public libraries


### TO DOWNLOAD THE LIBRARY

Add this code to your main program:


    checkForNQInclude()

    ...
    
    PROCEDURE checkForNQInclude
       IF NOT FILE("nqinclude.prg")
          STRTOFILE(httpGetFile("https://raw.githubusercontent.com/vespina/nqinclude/main/nqinclude.prg"),"nqinclude.prg")
          IF NOT FILE("nqinclude.prg")
             MESSAGEBOX("This library requires NQINCLUDE.PRG wich could not be downloaded at this time",48,"JSON.PRG")
             CANCEL
          ENDIF
       ENDIF
       RETURN
	
    PROCEDURE httpGetFile(pcUrl)
       pnTimeout = IIF(VARTYPE(pnTimeOut)<>"N",15,pnTimeout) 	
       LOCAL oHTTP
       oHTTP = CREATEOBJECT("MSXML2.XMLHTTP")
       oHTTP.open("GET", pcUrl, .F.)
       oHTTP.Send()
       LOCAL nTimeOut
       nTimeout = SECONDS()
       DO WHILE oHTTP.readyState<>4 OR (SECONDS() - nTimeout) > 15
          DOEVENTS
       ENDDO
       IF oHTTP.readyState <> 4 OR !BETWEEN(oHTTP.status,200,299)
          RETURN ""
       ENDIF 
       RETURN oHTTP.responseText()

    
### TO INCLUDE A LIBRARY

    IF NOT NQInclude("json")
      CANCEL
    ENDIF
    
    
Check the source code of NQInclude for a list of available libraries
