# ROMs — v1.0.0

[Français](#français) · [English](#english) · [Accueil / Home](../README.md)

## Français

**Deux fichiers, un seul firmware. Choisissez uniquement selon la puce à programmer.**

| Puce | Fichier |
| --- | --- |
| **OneROM configurée en 27C256**, ou 27C256 / W27C256 compatible | [typestar-tty-1.0.0-32k.bin](typestar-tty-1.0.0-32k.bin?raw=true) — **32 Ko** |
| **W27C512 / 27C512 compatible** | [typestar-tty-1.0.0-64k-mirror.bin](typestar-tty-1.0.0-64k-mirror.bin?raw=true) — **64 Ko miroir** |

L'image 64 Ko contient deux copies identiques de l'image 32 Ko. Les fonctions et réglages sont les mêmes. Les fichiers sont complets et directement programmables : **aucun fichier du firmware BASIC n'est nécessaire**.

Pour une OneROM, depuis la racine du dépôt :

```powershell
onerom program --slot "file=roms/typestar-tty-1.0.0-32k.bin,type=27C256" --plugin usb --verify
```

Les images sont déjà dans l'ordre IC8. Installez la puce selon le [guide matériel](../docs/HARDWARE.md). Au démarrage : **1200 bauds, 8N1, RTS/CTS**. Les autres réglages se font par CODE+ESPACE sur la Canon.

[Connexion au PC](../docs/SETUP.md) · [Empreintes SHA-256](SHA256SUMS.txt)

## English

**Two files, one firmware. Choose only according to the chip you are programming.**

| Chip | File |
| --- | --- |
| **OneROM configured as 27C256**, or a compatible 27C256 / W27C256 | [typestar-tty-1.0.0-32k.bin](typestar-tty-1.0.0-32k.bin?raw=true) — **32 KB** |
| **Compatible W27C512 / 27C512** | [typestar-tty-1.0.0-64k-mirror.bin](typestar-tty-1.0.0-64k-mirror.bin?raw=true) — **64 KB mirror** |

The 64 KB image contains two identical copies of the 32 KB image. Both provide the same functions and settings. They are complete and ready to program: **no BASIC firmware file is required**.

The OneROM command above runs from the repository root. Images already use IC8 byte order. Follow the [hardware guide](../docs/HARDWARE.md#english) for installation. Boot settings are **1200 baud, 8N1, RTS/CTS**; change settings using CODE+SPACE on the Canon.

[PC connection](../docs/SETUP.md#english) · [SHA-256 checksums](SHA256SUMS.txt)
