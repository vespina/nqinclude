# nqinclude
Library to include various public libraries


### TO DOWNLOAD THE LIBRARY
Add this code to your main program:

    IF NOT FILE("nqinclude.prg")
    	STRTOFILE(GETURL("https://raw.githubusercontent.com/vespina/nqinclude/main/nqinclude.prg"),"nqinclude.prg")
    	IF NOT FILE("nqinclude.prg")
    		MESSAGEBOX("This library requires NQINCLUDE.PRG wich could not be downloaded at this time",48,"JSON.PRG")
    		CANCEL
	    ENDIF
    ENDIF
    
    
### TO INCLUDE A LIBRARY

    IF NOT NQInclude("json")
      CANCEL
    ENDIF
    
    
Check the source code of NQInclude for a list of available libraries
