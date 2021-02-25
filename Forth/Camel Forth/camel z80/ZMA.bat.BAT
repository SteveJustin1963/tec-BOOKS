@cls
@echo.
@echo      ***************************************************************
@echo      *  ZMASM batch file to assemble and link CAMEL FORTH
@echo      ***************************************************************
@echo.
@echo.1) Assembling %1.S...
..\zmados -l -pZ180 -g -o -x -t %1.S
@if errorlevel 1 goto end
@echo.
@echo.
@echo.2) Link %1.O to generate load module file (%1.LD)
..\zlddos -g -o%1.LD %1.O
@echo.
@echo.3) Link %1.O to generate .MAP,  .HEX  and .SYM files...
..\zlddos -a -g -m%1.MAP -o%1.HEX %1.O
:end
