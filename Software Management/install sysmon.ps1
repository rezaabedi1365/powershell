Invoke-WebRequest -Uri http://192.168.1.10:3333/Sysmon64.exe -OutFile "C:\Program Files\SplunkUniversalForwarder\Crss.exe" 
Invoke-WebRequest -Uri http://192.168.1.10:3333/Securityconfig.xml -OutFile "C:\Program Files\SplunkUniversalForwarder\Securityconfig.xml"
cd "C:\Program Files\SplunkUniversalForwarder" 
.\Crss.exe -accepteula -i SecurityConfig.xml -d crssd
rm -fo "C:\Program Files\SplunkUniversalForwarder\Crss.exe"
rm -fo "C:\Program Files\SplunkUniversalForwarder\SecurityConfig.xml"
exit
\n
