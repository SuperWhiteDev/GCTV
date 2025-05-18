@echo off
:loop
setlocal enabledelayedexpansion
for /L %%n in (1,1,10) do (
    set /a "color=%%n %% 16"
    call color !color!
    echo Boom! %%n
    timeout /t 1 > NUL
)
endlocal
goto loop
