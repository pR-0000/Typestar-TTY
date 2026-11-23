# Typestar TTY

**Transformez une Canon Typestar en terminal papier bidirectionnel.**

**Turn a Canon Typestar into a bidirectional hardcopy terminal.**

**v1.0.0** · HD6301 · 1200–31250 bauds / baud · Documentation FR / EN

[**Télécharger / Download v1.0.0**](https://github.com/pR-0000/Typestar-TTY/releases/tag/v1.0.0)

[Français](#français) · [English](#english) · [ROMs](roms/README.md) · [Connexion / Connection](docs/SETUP.md) · [Clavier / Keyboard](docs/CONTROLS.md)

## Français

Typestar TTY est un firmware dédié qui transforme une **Canon Typestar 7 (S-70)** ou une **Typestar 6-II (S-61) modifiée pour le port série** en terminal papier. Le texte envoyé par l'ordinateur s'imprime sur le papier thermique ; les frappes sur le clavier de la Canon repartent vers l'ordinateur. Le firmware démarre directement dans ce mode.

### Une imprimante TTY, qu'est-ce que c'est ?

**TTY** est l'abréviation de *teletypewriter*, en français **téléimprimeur**. Ces appareils permettaient d'échanger du texte à distance, puis ont servi de terminaux pour les ordinateurs avant la généralisation des écrans. Le clavier envoyait les caractères ; l'imprimante rendait visibles les réponses. Le papier faisait donc office d'écran, tout en conservant une trace de la conversation.

Le terme est resté dans Unix et Linux : les terminaux et les ports série portent encore des noms comme `tty` ou `ttyUSB0`, même lorsqu'ils n'utilisent plus de papier. Dans ce projet, il désigne un **terminal papier série bidirectionnel**.

Typestar TTY reprend ce fonctionnement avec une liaison série et du texte ASCII. La Canon est à la fois **un périphérique de sortie**, qui imprime les réponses, et **un périphérique d'entrée**, qui transmet les touches. Une imprimante série uniquement réceptrice ne fournit que la première de ces fonctions.

Par exemple, Linux peut envoyer `login:` : la Canon l'imprime, vous tapez votre identifiant puis RETURN, et l'ordinateur poursuit la connexion. Les commandes sont exécutées sur l'ordinateur relié ; la Canon fournit le clavier et la sortie papier. Son LCD sert aux réglages et à l'état de la liaison.

| Utilisation | Ce que fait la Canon |
| --- | --- |
| **Console Linux / Unix** | Imprime l'invite de connexion et les réponses du shell ; permet de saisir les commandes au clavier. |
| **Console MS-DOS** | Sert de console texte série avec `CTTY`, pour les programmes utilisant les entrées/sorties standard DOS. |
| **Impression de texte** | Reçoit des notes, listes, résultats ou journaux envoyés par un logiciel série. |
| **Rétro-informatique et démonstration** | Recrée le dialogue avec un ordinateur sur un terminal papier, avec une trace imprimée de la session. |

Le fonctionnement est **ligne par ligne**. Sous Linux, utilisez `TERM=dumb`. Les interfaces plein écran, les mouvements de curseur et l'effacement de texte déjà imprimé ne correspondent pas aux possibilités du papier. La liaison du firmware utilise des octets série ASCII ; elle ne fournit pas d'interface de téléimprimeur Baudot ou de boucle de courant.

### Matériel compatible

**Le firmware a été testé sur les deux configurations suivantes :**

| Machine | Configuration |
| --- | --- |
| **Canon Typestar 7 / S-70** | Interface série d'origine et ROM IC8 remplacée par le firmware TTY. |
| **Canon Typestar 6-II / S-61 modifiée** | **Ajout des composants de l'interface et de la prise série**, puis remplacement de la ROM IC8 par le firmware TTY. |

La modification de la S-61 comprend le peuplement du circuit série ; l'ajout du connecteur seul ne suffit pas. Le [guide matériel](docs/HARDWARE.md) présente les prérequis et renvoie à la procédure de modification.

Prévoyez du **papier thermique**, une **ROM IC8 compatible** et un **câble série adapté aux niveaux TTL 5 V de la Canon**. Avec un adaptateur USB, le câble doit relier la sortie RTS# de la Canon à l'entrée CTS# de l'adaptateur pour le contrôle de flux matériel.

### Fonctions

- Impression ASCII sur **72 colonnes**, avec retour automatique à la ligne.
- Transmission des frappes sans attendre une ligne complète.
- Réception pendant l'impression, avec tampon et pauses RTS/CTS ou XON/XOFF.
- Débits **1200, 2400, 7812, 15625 et 31250 bauds** ; trames **8N1 et 7E1**.
- Menu local sur le **LCD 32 caractères** : liaison, fin de ligne, écho papier et aperçu reçu.
- Gestion CR, LF et CRLF, tabulations et retour arrière sur le texte encore tamponné.
- Impression des invites sans fin de ligne, telles que `login:` et `C:\>`.
- Écho papier désactivé par défaut, pour laisser l'hôte gérer l'écho et masquer les mots de passe.

Les caractères accentués et l'UTF-8 ne sont pas décodés. Pour du texte français, convertissez les accents côté ordinateur avant l'envoi. Les séquences ANSI courantes sont filtrées ; le firmware ne réalise pas une émulation VT100.

### Démarrage rapide

Les deux fichiers contiennent **le même firmware autonome**. Choisissez leur taille selon la puce ; **aucun fichier du firmware BASIC n'est nécessaire**.

| Puce à programmer | Image à utiliser |
| --- | --- |
| OneROM en mode 27C256, ou 27C256 / W27C256 compatible | [**32 Ko**](roms/typestar-tty-1.0.0-32k.bin?raw=true) |
| W27C512 / 27C512 compatible | [**64 Ko miroir**](roms/typestar-tty-1.0.0-64k-mirror.bin?raw=true) |

L'image 64 Ko contient deux copies identiques des 32 Ko. Tous les réglages série restent accessibles depuis le menu de la Canon.

1. **Programmez le fichier correspondant à votre puce**, selon le tableau ci-dessus.
2. Installez la ROM en IC8, placez le papier et branchez le câble. [Installation et matériel](docs/HARDWARE.md)
3. Allumez la Canon. Le LCD commence par **`1200 8N1 RTS`** avec l'image recommandée.
4. Sur le PC, ouvrez le port en **1200 bauds, 8N1, RTS/CTS**. Exemple avec Python et pySerial :

```sh
python -m pip install pyserial
python -m serial.tools.list_ports
python -m serial.tools.miniterm COM5 1200 --rtscts --eol CRLF --exit-char 24
```

Remplacez `COM5` par le port de votre adaptateur, par exemple `/dev/ttyUSB0` sous Linux ou `/dev/cu.usbserial-XXXX` sous macOS. Utilisez `python3` si nécessaire.

Tapez du texte sur le PC : il s'imprime après une courte pause ou à la fin de la ligne. Tapez sur la Canon : les caractères arrivent au PC. **Ctrl+X** ferme miniterm. Pour une session interactive avec écho et invite de commande, suivez le [guide Linux / DOS](docs/SETUP.md).

| Raccourci Canon | Action |
| --- | --- |
| **CODE + ESPACE** | Ouvrir les réglages sur le LCD. |
| **CODE + RETURN** | Imprimer le fragment en attente et avancer le papier localement. |
| CODE + BACKSPACE | Imprimer le fragment en attente sans fin de ligne. |
| CODE + A…Z | Envoyer Ctrl+A…Ctrl+Z selon la disposition régionale du clavier. |
| MARGIN RELEASE / BREAK | Envoyer Ctrl+C à l'ordinateur. |
| CODE + MARGIN RELEASE / BREAK | Envoyer ESC. |

**RETURN seul envoie Entrée à l'ordinateur.** Le papier avance quand celui-ci renvoie une fin de ligne, ou avec CODE+RETURN. Dans le menu, utilisez haut/bas pour le réglage, gauche/droite pour la valeur et RETURN pour appliquer. Les réglages reviennent aux valeurs de la ROM au redémarrage.

### Documentation et licence

- [ROMs prêtes à programmer](roms/README.md) : choix selon la puce et SHA-256.
- [Matériel et installation](docs/HARDWARE.md) : S-70, S-61 modifiée, câble et ROM IC8.
- [Connexion et dépannage](docs/SETUP.md) : PC, débits, Linux et DOS.
- [Clavier, menu et LCD](docs/CONTROLS.md) : toutes les commandes et les messages.
- [Construction du firmware](docs/DEVELOPMENT.md) : reconstruction et vérifications.
- [Notes de version](CHANGELOG.md) · [Préparation d'une publication](docs/PUBLISHING.md).

Typestar TTY réutilise le démarrage, le clavier et le pilote thermique de [Typestar BASIC](https://github.com/pR-0000/Typestar-BASIC). Les contributions originales sont sous licence MIT ; les éléments Canon conservent leurs droits et attributions. [Licence](LICENSE) · [Attributions](THIRD_PARTY_NOTICES.md)

---

## English

Typestar TTY is dedicated firmware that turns a **Canon Typestar 7 (S-70)** or a **serial-upgraded Typestar 6-II (S-61)** into a hardcopy terminal. Text from the computer prints on thermal paper, and Canon keystrokes travel back to the computer. The firmware starts directly in terminal mode.

### What is a TTY printer?

**TTY** stands for **teletypewriter**. These machines first exchanged text over communication lines and later became computer terminals before screens were common. Their keyboard sent characters and their printer displayed the responses. Paper served as the screen and kept a record of the conversation.

The name survives in Unix and Linux: terminals and serial ports still have names such as `tty` and `ttyUSB0`, even when no paper is involved. Here it means a **bidirectional serial hardcopy terminal**.

Typestar TTY recreates that experience using serial ASCII text. The Canon provides both **output**, by printing responses, and **input**, by sending keystrokes. A receive-only serial printer provides only the output part.

For example, Linux sends `login:`, the Canon prints it, you type a username and press RETURN, and the computer continues the login. Commands run on the connected computer; the Canon supplies the keyboard and paper output. Its LCD handles settings and link status.

| Use | What the Canon does |
| --- | --- |
| **Linux / Unix console** | Prints the login prompt and shell responses, and lets you type commands. |
| **MS-DOS console** | Works as a serial text console through `CTTY` for programs using standard DOS input/output. |
| **Text printing** | Receives notes, lists, results or logs from a serial application. |
| **Vintage computing and demonstrations** | Recreates a hardcopy computer session and keeps a printed record. |

Operation is **line-oriented**. Use `TERM=dumb` on Linux. Full-screen interfaces, cursor positioning and erasing already printed text are beyond what paper can do. The firmware exchanges serial ASCII bytes; it does not provide a Baudot teleprinter or current-loop interface.

### Supported hardware

**The firmware has been tested on both configurations below:**

| Machine | Configuration |
| --- | --- |
| **Canon Typestar 7 / S-70** | Factory serial interface and a replacement IC8 ROM running TTY firmware. |
| **Modified Canon Typestar 6-II / S-61** | **Serial-port and interface components added**, plus a replacement IC8 ROM running TTY firmware. |

The S-61 upgrade requires populating the serial interface circuit, not just fitting the connector. The [hardware guide](docs/HARDWARE.md#english) lists requirements and links to the modification procedure.

You need **thermal paper**, a **compatible IC8 ROM**, and a **serial cable designed for the Canon's 5 V TTL signals**. With a USB adapter, connect Canon RTS# to adapter CTS# for hardware flow control.

### Features

- **72-column ASCII printing** with automatic line wrapping.
- Keystroke transmission without waiting for a complete line.
- Buffered reception during printing, paced by RTS/CTS or XON/XOFF.
- **1200, 2400, 7812, 15625 and 31250 baud**; **8N1 and 7E1** framing.
- Local setup on the **32-character LCD**, including link settings, line endings, paper echo and RX preview.
- CR, LF and CRLF handling, tabs, and backspace within pending text.
- Printing of prompts without a line ending, such as `login:` and `C:\>`.
- Paper echo off by default so the host can control echo and hide passwords.

Accented characters and UTF-8 are not decoded. Convert such characters to ASCII on the host before sending. Common ANSI sequences are filtered; this is not VT100 emulation.

### Quick start

Both files contain **the same standalone firmware**. Choose by chip size; **no BASIC firmware file is required**.

| Chip | Image |
| --- | --- |
| OneROM in 27C256 mode, or a compatible 27C256 / W27C256 | [**32 KB**](roms/typestar-tty-1.0.0-32k.bin?raw=true) |
| Compatible W27C512 / 27C512 | [**64 KB mirror**](roms/typestar-tty-1.0.0-64k-mirror.bin?raw=true) |

The 64 KB file contains two identical 32 KB copies. All serial settings are available in the Canon menu.

1. **Program the file matching your chip**, using the table above.
2. Install it in IC8, load the paper and connect the cable. [Hardware and installation](docs/HARDWARE.md#english)
3. Turn on the Canon. The recommended image starts with **`1200 8N1 RTS`** on the LCD.
4. Open the host port at **1200 baud, 8N1, RTS/CTS**. With Python and pySerial:

```sh
python -m pip install pyserial
python -m serial.tools.list_ports
python -m serial.tools.miniterm COM5 1200 --rtscts --eol CRLF --exit-char 24
```

Replace `COM5` with your adapter's port, for example `/dev/ttyUSB0` on Linux or `/dev/cu.usbserial-XXXX` on macOS. Use `python3` if needed.

Type on the PC to print text after a short pause or a line ending. Type on the Canon to send characters to the PC. **Ctrl+X** exits miniterm. For an interactive session with echo and a command prompt, follow the [Linux / DOS guide](docs/SETUP.md#english).

| Canon shortcut | Action |
| --- | --- |
| **CODE + SPACE** | Open LCD setup. |
| **CODE + RETURN** | Print pending text and advance the paper locally. |
| CODE + BACKSPACE | Print pending text without a line ending. |
| CODE + A…Z | Send Ctrl+A…Ctrl+Z using the regional keyboard layout. |
| MARGIN RELEASE / BREAK | Send Ctrl+C to the host. |
| CODE + MARGIN RELEASE / BREAK | Send ESC. |

**RETURN alone sends Enter to the host.** Paper advances when the host sends a line ending, or with CODE+RETURN. In setup, use up/down for fields, left/right for values and RETURN to apply. Settings return to the ROM defaults after a restart.

### Documentation and license

- [Ready-to-program ROMs](roms/README.md#english): chip selection and SHA-256.
- [Hardware and installation](docs/HARDWARE.md#english): S-70, modified S-61, cable and IC8 ROM.
- [Connection and troubleshooting](docs/SETUP.md#english): host setup, baud rates, Linux and DOS.
- [Keyboard, setup and LCD](docs/CONTROLS.md#english): controls and messages.
- [Firmware development](docs/DEVELOPMENT.md#english): rebuilding and verification.
- [Release notes](CHANGELOG.md#english) · [Publishing](docs/PUBLISHING.md#english).

Typestar TTY reuses startup, keyboard and thermal routines from [Typestar BASIC](https://github.com/pR-0000/Typestar-BASIC). Original contributions are MIT-licensed; Canon components retain their rights and attribution. [License](LICENSE) · [Third-party notices](THIRD_PARTY_NOTICES.md)
