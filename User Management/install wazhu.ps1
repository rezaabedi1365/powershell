Invoke-WebRequest -Uri http://192.168.1.10:3333/wazuh-agent-4.3.10-1.msi -OutFile ${env:tmp}\wazuh-agent-4.3.10.msi;
msiexec.exe /i ${env:tmp}\wazuh-agent-4.3.10.msi /q WAZUH_MANAGER='192.168.1.10' WAZUH_REGISTRATION_SERVER='192.168.1.10' WAZUH_AGENT_GROUP='default'

NET START wazuh
