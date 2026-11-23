# Connexion et utilisation / Connection and use

[Français](#français) · [English](#english) · [Accueil / Home](../README.md) · [Réglages / Settings](CONTROLS.md)

## Français

### Choisir les paramètres

Le firmware démarre à **1200 bauds, 8 bits, sans parité, 1 bit d'arrêt, RTS/CTS**. Les images 32 et 64 Ko offrent les mêmes fonctions. Réglez ensuite la liaison par **CODE+ESPACE** sur la Canon et faites correspondre les paramètres du PC. Un redémarrage restaure les valeurs de départ.

### PC : envoyer et recevoir du texte

Installez Python 3.10+ et pySerial. Ces outils servent sur le PC ; la Canon fonctionne de façon autonome avec sa ROM.

```sh
python -m pip install pyserial
python -m serial.tools.list_ports
python -m serial.tools.miniterm COM5 1200 --rtscts --eol CRLF --exit-char 24
```

Remplacez `COM5` par le port identifié. Sous Linux, utilisez par exemple `/dev/ttyUSB0` ; sous macOS, `/dev/cu.usbserial-XXXX`. `python3` peut remplacer `python`.

Le texte saisi sur le PC est envoyé à la Canon. Les caractères tapés sur la Canon arrivent au PC. **Ctrl+X** ferme miniterm. Son écho local peut être activé avec l'option `-e` pour voir les caractères que vous tapez sur le PC ; cela ne crée pas l'écho des frappes Canon sur le papier. Une session Linux/DOS ou une application hôte peut gérer cet écho.

**RETURN sur la Canon envoie CR par défaut.** Si le PC ne renvoie pas de fin de ligne, le papier ne bouge pas. Utilisez **CODE+RETURN** pour une avance locale, ou activez `PAPER ECHO` uniquement quand l'hôte ne fait pas déjà l'écho.

Pour une liaison 7E1, réglez le logiciel sur **7 bits, parité paire, 1 bit d'arrêt**. Dans miniterm, `--parity E` sélectionne la parité ; après ouverture et avant de transmettre, **Ctrl+T puis 7** sélectionne les 7 bits. Consultez la [documentation pySerial](https://pyserial.readthedocs.io/en/latest/tools.html#module-serial.tools.miniterm) pour ses menus.

### Débits et changement de configuration

| Valeur à choisir sur la Canon et le PC | Débit Canon calculé |
| --- | --- |
| 1200 | 1201,923 bauds |
| 2400 | 2403,846 bauds |
| 7812 | 7812,5 bauds |
| 15625 | 15625 bauds |
| 31250 | 31250 bauds |

7812, 15625 et 31250 sont les mêmes débits natifs que dans Typestar BASIC. Votre logiciel et votre adaptateur série doivent accepter la valeur choisie. Les débits usuels proposés dans une liste de logiciel ne sont pas des valeurs de remplacement.

Pour passer à 31250 : terminez la transmission, ouvrez CODE+ESPACE sur la Canon, choisissez BAUD=31250 puis RETURN. Fermez la connexion du PC et rouvrez-la au même débit :

```sh
python -m serial.tools.miniterm COM5 31250 --rtscts --eol CRLF --exit-char 24
```

Pour le contrôle logiciel, choisissez FLOW=XON ou BOTH sur la Canon et remplacez `--rtscts` par `--xonxoff` côté PC. Le signal matériel Canon reste piloté ; le logiciel hôte décide du mécanisme qu'il utilise.

L'impression reste limitée par le mécanisme thermique. Le débit élevé accélère les échanges et remplit plus vite le tampon ; **le contrôle de flux règle toujours le rythme de l'ordinateur**. Un redémarrage restaure 1200 bauds, 8N1 et RTS/CTS.

### Linux / Unix

Une session de connexion série transforme la Canon en console papier. Gardez `PAPER ECHO OFF`, utilisez la trame 8N1 et fermez tout autre logiciel qui occupe le port. Exemple avec `agetty`, lancé depuis une autre console Linux :

```sh
sudo agetty --8bits --local-line=always --flow-control --noclear ttyUSB0 1200 dumb
```

Remplacez `ttyUSB0` par le nom du port, sans `/dev/`. `dumb` définit le type de terminal. Connectez-vous puis utilisez des commandes ligne par ligne, telles que `echo HELLO` et `exit`. L'hôte gère l'écho et peut le supprimer pour la saisie d'un mot de passe. Sous Bash, `set +o emacs` puis `set +o vi` désactivent l'édition de ligne Readline si celle-ci redessine les commandes.

Références : [agetty](https://man7.org/linux/man-pages/man8/agetty.8.html) · [service de connexion systemd](https://man7.org/linux/man-pages/man8/systemd-getty-generator.8.html).

### MS-DOS

Un PC DOS avec port RS-232 exige le [convertisseur de niveaux approprié](HARDWARE.md#port-rs-232-et-dos). Commencez à 1200 bauds en 8N1 avec contrôle matériel :

```bat
MODE COM1:12,N,8,1
CTTY COM1
```

Adaptez `COM1` au port utilisé. Si vous sélectionnez 7E1 sur la Canon, la première commande devient `MODE COM1:12,E,7,1`. Depuis la Canon, `VER` affiche la version DOS et `CTTY CON` rend la console au PC.

`CTTY` concerne les entrées/sorties standard DOS. Les applications qui accèdent directement à la vidéo ou au clavier ne suivent pas cette redirection. Selon la version de DOS, une sortie longue peut nécessiter une option de relance de `MODE`, par exemple `,P` ou `RETRY=B`. Les débits disponibles dépendent également du logiciel DOS et de son pilote.

Références : [manuel MS-DOS 3.3](https://bitsavers.org/pdf/hp/9000_hpux/softpc/98870-90050_MSDOS_3.3_Reference_Sep89.pdf) · [référence MS-DOS 6.22](https://freedos.link/OS/Using_MS-DOS_622.pdf).

### Impression de fichiers et limites

Envoyez du **texte ASCII** depuis une application série qui respecte le contrôle de flux. Le port USB apparaît comme un port série, et non comme une imprimante USB standard : l'envoi se fait par ce port, sans pilote d'impression Typestar TTY.

Le firmware imprime sur 72 colonnes. Les séquences ANSI courantes sont filtrées ; l'effacement de caractères déjà imprimés est impossible. Backspace corrige seulement le fragment encore en mémoire. Les applications plein écran et les documents PDF/images nécessitent un autre traitement côté hôte ; le firmware reçoit du texte.

Les accents et l'UTF-8 ne sont pas décodés. Une trame 8N1 ne change pas le jeu de caractères de la police ASCII. Convertissez le texte vers ce jeu avant l'envoi.

### Dépannage

| Symptôme | Vérification |
| --- | --- |
| Caractères illisibles / erreur de parité ou de trame | Faire correspondre débit et trame, puis contrôler masse, TX/RX et câble. |
| Des caractères manquent dans une sortie longue | Activer et câbler RTS/CTS, ou activer XON/XOFF des deux côtés. |
| Le PC reçoit le clavier, mais rien ne s'imprime | Vérifier TX du PC vers RX Canon, CTS de l'adaptateur et la face sensible du papier thermique. |
| RETURN ne fait pas avancer le papier | L'hôte doit renvoyer une fin de ligne ; CODE+RETURN avance localement. |
| Les caractères s'impriment deux fois | Mettre PAPER ECHO sur OFF si l'hôte fait déjà l'écho. |
| Plus de liaison après modification des réglages | Accorder le PC aux réglages Canon, ou redémarrer pour retrouver 1200 bauds, 8N1 et RTS/CTS. |
| RX/TX BUFFER FULL | Du texte ou une frappe n'a pas pu être mémorisé ; vérifier le contrôle de flux et renvoyer le contenu nécessaire. |
| TTY PAPER ERROR - RESTART | Vérifier papier et chariot, puis redémarrer. |

Le [guide du LCD](CONTROLS.md#lire-lécran) détaille les messages. Réappliquer les paramètres depuis le menu efface les erreurs série mémorisées.

## English

### Choose matching settings

The firmware always starts at **1200 baud, 8 data bits, no parity, 1 stop bit, RTS/CTS**. The 32 and 64 KB images provide the same functions. Change settings through **CODE+SPACE** and match the PC settings. Restart restores the defaults.

### PC connection

Install Python 3.10+ and pySerial, then identify and open the port:

```sh
python -m pip install pyserial
python -m serial.tools.list_ports
python -m serial.tools.miniterm COM5 1200 --rtscts --eol CRLF --exit-char 24
```

Replace `COM5` with your port, such as `/dev/ttyUSB0` on Linux or `/dev/cu.usbserial-XXXX` on macOS. Use `python3` if needed. Text typed on the PC prints on the Canon, and Canon keys arrive on the PC. **Ctrl+X** exits miniterm.

Miniterm's `-e` option displays characters typed on the PC; it does not echo Canon input back onto paper. A host session/application handles that echo. **RETURN sends CR by default**; the paper advances when the host returns a line ending. **CODE+RETURN** always advances locally. Enable `PAPER ECHO` only if the host does not echo.

For 7E1, select **7 data bits, even parity, 1 stop bit**. In miniterm, use `--parity E`, then **Ctrl+T followed by 7** after opening and before transmitting. [pySerial guide](https://pyserial.readthedocs.io/en/latest/tools.html#module-serial.tools.miniterm)

### Baud rates and flow control

Use **1200, 2400, 7812, 15625 or 31250** on both ends. The table in the French section lists the calculated Canon rates. The higher values are native BASIC/Canon clock rates and require host/adapter support.

Finish the current transfer, choose BAUD in CODE+SPACE setup and press RETURN. Reopen the PC port at the selected rate; for example:

```sh
python -m serial.tools.miniterm COM5 31250 --rtscts --eol CRLF --exit-char 24
```

For software flow control, choose XON or BOTH on the Canon and replace `--rtscts` with `--xonxoff`. The Canon hardware pause signal remains driven in every mode. Higher baud rates speed up the link; **thermal printing speed is unchanged** and flow control still paces the host. Restart restores 1200 baud, 8N1 and RTS/CTS.

### Linux / Unix

Use 8N1 with `PAPER ECHO OFF` and close other programs using the port. From another Linux console:

```sh
sudo agetty --8bits --local-line=always --flow-control --noclear ttyUSB0 1200 dumb
```

Replace `ttyUSB0`, omitting `/dev/`. `dumb` sets the terminal type. Log in and use line-oriented commands such as `echo HELLO` and `exit`. The host controls echo, including password suppression. In Bash, `set +o emacs` and `set +o vi` disable Readline editing if it redraws commands.

References: [agetty](https://man7.org/linux/man-pages/man8/agetty.8.html) · [systemd getty](https://man7.org/linux/man-pages/man8/systemd-getty-generator.8.html).

### MS-DOS

Use an [RS-232 level converter](HARDWARE.md#rs-232-and-dos). At 1200/8N1 with hardware flow control:

```bat
MODE COM1:12,N,8,1
CTTY COM1
```

For 7E1, use `MODE COM1:12,E,7,1`. Change the COM port as needed. From the Canon, `VER` prints the DOS version and `CTTY CON` returns the console to the PC.

`CTTY` redirects standard DOS input/output; direct keyboard/video applications are outside that mechanism. Long output may need a `MODE` retry option such as `,P` or `RETRY=B`, depending on DOS version. Available rates also depend on the host software/driver.

References: [MS-DOS 3.3 manual](https://bitsavers.org/pdf/hp/9000_hpux/softpc/98870-90050_MSDOS_3.3_Reference_Sep89.pdf) · [MS-DOS 6.22 reference](https://freedos.link/OS/Using_MS-DOS_622.pdf).

### Text files and troubleshooting

Send **ASCII text** through a serial application that honors flow control. The USB adapter appears as a serial port; this firmware is not a USB printer driver. Printing is 72 columns wide. Common ANSI sequences are filtered, and backspace only edits pending text. Convert accented/UTF-8 text on the host. PDFs, images and full-screen applications require different host-side handling.

| Symptom | Check |
| --- | --- |
| Garbled characters / parity or framing error | Match baud/framing, then check ground, TX/RX and the cable. |
| Missing characters during long output | Wire and enable RTS/CTS, or enable XON/XOFF at both ends. |
| Keyboard reaches PC but nothing prints | Check PC TX to Canon RX, adapter CTS and the thermal paper orientation. |
| RETURN does not advance paper | The host must echo a line ending; CODE+RETURN advances locally. |
| Double printing | Turn PAPER ECHO OFF if the host echoes. |
| Link stops after changing settings | Match the host settings, or restart to restore ROM defaults. |
| RX/TX BUFFER FULL | Text or a key was lost; check flow control and resend what is needed. |
| TTY PAPER ERROR - RESTART | Check the paper and carriage, then restart. |

See [LCD controls](CONTROLS.md#lcd-status) for messages. Reapplying setup clears stored serial errors.
