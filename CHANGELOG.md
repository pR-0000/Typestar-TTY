# Notes de version / Release notes

[Français](#français) · [English](#english)

## Français

### 1.0.0

Première version publique de **Typestar TTY**, firmware de terminal papier bidirectionnel pour Canon Typestar.

- Testé sur **Typestar 7 / S-70** et **Typestar 6-II / S-61 modifiée avec les composants de l'interface série**.
- Impression ASCII sur 72 colonnes et transmission des frappes clavier.
- Réception tamponnée pendant l'impression, contrôle RTS/CTS ou XON/XOFF.
- Cinq débits : 1200, 2400, 7812, 15625 et 31250 ; trames 8N1 et 7E1.
- Menu LCD pour la liaison, RETURN en CR/CRLF, écho papier et aperçu reçu.
- Commandes locales d'avance papier et d'impression du fragment en attente.
- Caractères de contrôle avec CODE, gestion CR/LF, tabulations et retour arrière sur le fragment en attente.
- Deux images IC8 autonomes : 32 Ko et 64 Ko miroir.
- Documentation français/anglais, sources HD6301 et génération reproductible des ROMs.

Les réglages sont temporaires et reviennent à 1200 bauds, 8N1 et RTS/CTS au redémarrage. L'impression utilise une police ASCII ; l'UTF-8 et les accents ne sont pas décodés. Les sessions sont ligne par ligne, avec `TERM=dumb` pour Linux.

## English

### 1.0.0

First public release of **Typestar TTY**, bidirectional hardcopy-terminal firmware for Canon Typestar typewriters.

- Tested on **Typestar 7 / S-70** and **Typestar 6-II / S-61 modified with the serial-interface components**.
- 72-column ASCII printing and keyboard transmission.
- Buffered reception during printing, with RTS/CTS or XON/XOFF flow control.
- Five rates: 1200, 2400, 7812, 15625 and 31250; 8N1 and 7E1 framing.
- LCD setup for the link, CR/CRLF, paper echo and received-text preview.
- Local paper advance and pending-fragment printing shortcuts.
- CODE control characters, CR/LF, tabs and backspace within pending text.
- Two standalone IC8 images: 32 KB and mirrored 64 KB.
- French/English documentation, HD6301 source and reproducible ROM generation.

Settings reset to 1200 baud, 8N1 and RTS/CTS after restart. Printing uses an ASCII font; UTF-8 and accents are not decoded. Sessions are line-oriented; use `TERM=dumb` on Linux.
