cd /d %~dp0 

dotNetFx40_Full_x86_x64_SC.exe /q

cd "C:\Windows\Microsoft.NET\Framework\v4.0.30319"

InstallUtil.exe "%~dp0\EmailSheduleService.exe%"

net start SimpleEmailService



pause