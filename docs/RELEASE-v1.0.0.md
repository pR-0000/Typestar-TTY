## Français

**Première version publique de Typestar TTY**, un firmware qui transforme les Canon Typestar en terminaux papier série bidirectionnels : le texte reçu s'imprime et les frappes clavier sont transmises à l'ordinateur.

Testé sur **Typestar 7 / S-70** et **Typestar 6-II / S-61 modifiée avec ajout des composants de l'interface série**.

### Choisir votre ROM

| Puce | Fichier |
| --- | --- |
| OneROM en mode 27C256, ou 27C256 / W27C256 compatible | `typestar-tty-1.0.0-32k.bin` |
| W27C512 / 27C512 compatible | `typestar-tty-1.0.0-64k-mirror.bin` |

Les deux images contiennent le même firmware complet. Aucun fichier BASIC n'est nécessaire. L'image 64 Ko contient deux copies identiques de l'image 32 Ko.

- Démarrage : **1200 bauds, 8N1, RTS/CTS**.
- **CODE+ESPACE** : menu LCD, jusqu'à **31250 bauds**, trames 8N1/7E1, RTS/CTS ou XON/XOFF.
- Impression ASCII sur 72 colonnes, écho papier facultatif et aperçu reçu.
- Documentation et instructions d'installation en français/anglais dans le README.

Les réglages reviennent aux valeurs de démarrage après extinction. L'UTF-8 et les accents ne sont pas décodés. Les empreintes sont jointes dans `SHA256SUMS.txt`.

## English

**First public release of Typestar TTY**, bidirectional serial hardcopy-terminal firmware: received text prints on paper, and keyboard input is sent back to the computer.

Tested on **Typestar 7 / S-70** and **Typestar 6-II / S-61 modified with the serial-interface components**.

### Choose your ROM

| Chip | File |
| --- | --- |
| OneROM in 27C256 mode, or compatible 27C256 / W27C256 | `typestar-tty-1.0.0-32k.bin` |
| Compatible W27C512 / 27C512 | `typestar-tty-1.0.0-64k-mirror.bin` |

Both images contain the same complete firmware. No BASIC file is required. The 64 KB image duplicates the 32 KB image.

- Boot defaults: **1200 baud, 8N1, RTS/CTS**.
- **CODE+SPACE** opens LCD setup: up to **31250 baud**, 8N1/7E1 and RTS/CTS or XON/XOFF.
- 72-column ASCII printing, optional paper echo and received-text preview.
- French/English documentation and installation instructions in the README.

Settings reset after power-off. UTF-8 and accented characters are not decoded. Checksums are attached in `SHA256SUMS.txt`.
