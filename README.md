# Information

Detta projekt är utfört med **Visual Studio Code** och kräver ett aktivt **Azure-konto** samt att **.NET SDK** är installerat för att kunna skapa och köra en enkel webapplikation.

Projektet syftar till att bygga en säker infrastruktur för en **.NET-webbapplikation**, där webbservern skyddas bakom två andra servrar. Infrastrukturen provisioneras med en **ARM-template** som skapar tre virtuella maskiner och de nödvändiga nätverksresurserna. Vid provisioneringen konfigureras de virtuella maskinerna med nödvändiga installationer och inställningar genom **custom data**, där **cloud-init-skript** används för att automatisera installationen och konfigurationen.

---

# Steg för att Skapa och Konfigurera Projekt

1. **Skapa Projektmapp och Öppna i Visual Studio Code**
   - Skapa en ny mapp med namnet `GithubActionDemo` och öppna den i Visual Studio Code.

2. **Skapa Enkel .NET-applikation (alt använd den färdiga)**
   - Skapa en ny .NET webbapplikation:
     ```bash
     dotnet new webapp
     ```
     *Detta kommando skapar en enkel .NET-webbapplikation i mappen.*

3. **Skapa .gitignore (optional)**
   - Generera en `.gitignore` för att utesluta onödiga filer från Git:
     ```bash
     dotnet new gitignore
     ```
     *En `.gitignore`-fil hjälper till att undvika att onödiga filer läggs till i Git-repot.*

4. **Ladda Ner Skript och Mallar**
   - Ladda ner skript och mallar från katalogen `Provision_scripts`. Placera katalogen i huvudmappen för projektet, till exempel `Uppgift_2/Provision_scripts`.

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
   - Lägg till en GitHub Actions workflow för .NET genom att skapa en fil `workflow.yaml` i `.github/workflows/`-mappen och använda koden från `workflow.yaml`:
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
     cd /path/to/Provision_scripts
     ```
     *Se till att katalogen `Provision_scripts` ligger i rätt sökväg innan du kör detta kommando.*

2. **Kör Provisioneringsskript**
   - Kör skriptet för att provisionera virtuella maskiner:
     ```bash
     ./VM_provision.sh
     ```
     *Detta skript skapar de virtuella maskiner och nätverksresurser som behövs för infrastrukturen.*

3. **Starta SSH-agent**
   - Starta SSH-agent för att hantera SSH-nycklar:
     ```bash
     eval $(ssh-agent)
     ```
     *SSH-agenten lagrar din privata nyckel för att möjliggöra säker anslutning utan att behöva skriva lösenord varje gång.*

4. **Lägg till SSH-nyckel**
   - Lägg till din SSH-nyckel:
     ```bash
     ssh-add /path/to/key
     ```
     *Lägger till din privata SSH-nyckel till agenten för att kunna logga in på servrarna.*

5. **Anslut till Bastion Host**
   - SSH in till bastion-servern:
     ```bash
     ssh -A username@bastion-ip-address
     ```
     *Ansluter till bastion-servern som är skyddad bakom en brandvägg. Flaggan `-A` (agent forwarding) vidarebefordrar dina lokala SSH-nycklar från SSH-agenten till bastion-servern. Detta gör att du kan använda dina nycklar för att autentisera mot andra servrar från bastion-servern utan att behöva kopiera nycklarna dit.*

6. **Anslut till Web Server**
   - SSH in till webbservern:
     ```bash
     ssh username@10.0.0.100
     ```
     *Ansluter till webbservern via bastion-servern.*

---

# Skapa GitHub Actions Runner för Linux

7. **Hämta och Installera Runner**

   1. **Skapa en mapp för runner**
      ```bash
      mkdir actions-runner && cd actions-runner
      ```

   2. **Ladda ner den senaste runner-paketet**
      ```bash
      curl -o actions-runner-linux-x64-2.319.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
      ```

   3. **Valfritt: Verifiera hash (byt ut hash-värdet vid behov)**
      ```bash
      echo "3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464  actions-runner-linux-x64-2.319.1.tar.gz" | shasum -a 256 -c
      ```

   4. **Extrahera installeringspaketet**
      ```bash
      tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz
      ```

---

8. **Konfigurera och Starta Runner**

   5. **Skapa och konfigurera runner**
      ```bash
      ./config.sh --url https://github.com/yourusername/yourrepository --token xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      ```
      *Byt ut `https://github.com/yourusername/yourrepository` mot URL:en till din GitHub-repository och ersätt `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` med din personliga runner-token (Observera att token är tidsbegränsad, så använd den direkt efter generering).*

---

9. **Installera och Starta Runner som Tjänst**
   - Installera och starta runnern som en tjänst för att säkerställa att den körs automatiskt:
     ```bash
     sudo ./svc.sh install username
     sudo ./svc.sh start
     ```
     *Detta installerar och startar runnern som en systemtjänst på webbservern, så att den automatiskt startar om vid systemåterstart och alltid finns tillgänglig för GitHub Actions.*
