<<<<<<< HEAD
# CICD pipeline i ett paket
### När ändringar på appen pushas till `master-branch` triggas workflow och uppdaterar live till APP-servern

---

# Information
Detta projekt är utfört med **Visual Studio Code** och kräver ett aktivt **Azure-konto** samt att **.NET SDK** är installerat för att kunna skapa och köra en enkel webapplikation.

Projektet syftar till att bygga en säker infrastruktur för en **.NET-webbapplikation**, där webbservern skyddas bakom två andra servrar. Infrastrukturen provisioneras med en **ARM-template** som skapar tre virtuella maskiner och de nödvändiga nätverksresurserna. Vid provisioneringen konfigureras de virtuella maskinerna med nödvändiga installationer och inställningar genom **custom data**, där **cloud-init-skript** används för att automatisera installationen och konfigurationen.

---
# Detta projekt innefattar följande steg:
1. Skapande av DotNet webapp
2. Deployment av Azure resurser via `Azure_deployment/1click.sh`. Denna fil startar ARM-templates med respektive config fil.
   - Bastion-host 
   - Reverseproxy 
   - Webapp server (`config_appserver.yaml` installerar dotnet support och docker samt `zekath/mydotnetapp` och `Watchtower`som håller dockercontainers uppdaterade)
   - Blub storage (för att se cat.jpg)
   - NSG och ASG
3. `.github/workflow/cicd.yaml` Denna fil packeterar appen
   - Gör en dockerimage 
   - Publiserar den till Dockerhub. (OBS!! se fil för ändring av användare och secrets)-
4. SSH-nycklar
   - Sökväg: `C:\Users\<usr>\.ssh\id_rsa`
---
# Steg för att Skapa och Konfigurera Projekt

1. **Skapa Projektmapp och Öppna i Visual Studio Code**
   - Skapa en ny mapp med namnet `GithubActionDemo` och öppna den i Visual Studio Code.

2. **Skapa Enkel .NET-applikation (frivilligt. alt använd den färdiga)**
   - Skapa en ny .NET webbapplikation:
     ```bash
     dotnet new webapp
     ```
     *Detta kommando skapar en enkel .NET-webbapplikation i mappen.*

3. **Skapa .gitignore (frivilligt)**
   - Generera en `.gitignore` för att utesluta onödiga filer från Git:
     ```bash
     dotnet new gitignore
     ```
     *En `.gitignore`-fil hjälper till att undvika att onödiga filer läggs till i Git-repot.*

4. **Ladda Ner Skript och Mallar**
   - Ladda ner skript och mallar från katalogen `Azure_deployment`. Placera katalogen i huvudmappen för projektet.

5. **Initiera Git**
   - Initiera ett nytt Git-repo:
     ```bash
     git init
     ```
     *Detta kommando startar ett nytt Git-repository i projektmappen.*

6. **Koppla Git till GitHub**
   - Lägg till filer och koppla det lokala repot till GitHub:
     ```bash
     git add .
     git commit -m "Initial commit"
     git remote add origin <GitHub-repository-URL>
     git push -u origin main
     ```
     *Detta initierar Git, skapar en första commit och länkar till din GitHub-repository.*

7. **Skapa en GitHub Actions Workflow för .NET**
   - Lägg till en GitHub Actions workflow för .NET genom att skapa en fil `cicd.yaml` i `.github/workflows/`-mappen och använda koden från `cicd.yaml`:
     *Detta sätter upp en automatisk pipeline för att bygga och testa din applikation på GitHub.*

8. **Synkronisera Lokala Filer med GitHub**
   - Hämta eventuella uppdateringar från GitHub:
     ```bash
     git pull
     ```
     *Synkroniserar lokala filer med den senaste versionen från GitHub.*

---

# Steg för att Provisionera och Konfigurera VM

1. **Navigera till Katalog med Skript**
   - Gå till katalogen där provisioneringsskripten finns:
     ```bash
     cd /GithubActionsDemo/Azure_deployment
     ```
     *Se till att katalogen `Azure_deployment` ligger i rätt sökväg innan du kör detta kommando.*

2. **Kör Provisioneringsskript**
   - Kör skriptet för att provisionera virtuella maskiner:
     ```bash
     ./1click.sh
     ```
     *Detta skript skapar de virtuella maskiner och nätverksresurser som behövs för infrastrukturen.*
     *När scriptet är klart visar IP adresser till samtliga VM's*

---
# Starta SSH-agent

1. - Starta SSH-agent för att hantera SSH-nycklar:
     ```bash
     eval $(ssh-agent)
     ```
     *SSH-agenten lagrar din privata nyckel för att möjliggöra säker anslutning utan att behöva skriva lösenord varje gång.*

2. **Lägg till SSH-nyckel**
   - Lägg till din SSH-nyckel:
     ```bash
     ssh-add /path/to/key
     ```

     *Lägger till din privata SSH-nyckel till agenten för att kunna logga in på servrarna.*

3. **Anslut till Bastion Host**
   - SSH in till bastion-servern:
     ```bash
     ssh -A azureuser@bastion-ip-address
     ```
     *Ansluter till bastion-servern som är skyddad bakom en brandvägg. Flaggan `-A` (agent forwarding) vidarebefordrar dina lokala SSH-nycklar från SSH-agenten till bastion-servern. Detta gör att du kan använda dina nycklar för att autentisera mot andra servrar från bastion-servern utan att behöva kopiera nycklarna dit.*

4. **Anslut till Web Server**
   - SSH in till webbservern:
     ```bash
     ssh azureuser@10.0.0.10
     ```
     *Ansluter till webbservern via bastion-servern.*

---