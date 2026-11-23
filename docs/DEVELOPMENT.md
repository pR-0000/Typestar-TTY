# Sources / Development

[Français](#français) · [English](#english) · [Accueil / Home](../README.md)

## Français

**Pour utiliser le firmware, programmez simplement l'une des deux images de `roms/`.** Cette page concerne la modification des sources.

Les modules assembleur HD6301 sont dans `src/` : texte et impression, série, clavier, menu et LCD. Les outils sont dans `tools/`.

### Reconstruire

Il faut Python 3.10+ et un assembleur **A09 compatible HD6301** :

```sh
python tools/build.py --a09 A09_PATH
```

Remplacez `A09_PATH` par le chemin de l'assembleur, entre guillemets si nécessaire. Les deux images sont écrites dans `build/`, avec les symboles et le listing dans `build/assembly/`.

La reconstruction utilise **la ROM TTY de 32 Ko déjà fournie dans le dépôt** comme image de référence pour les routines communes et les données de police. Les modules TTY sont réassemblés et réinsérés dans leurs zones réservées. **Aucun fichier du firmware BASIC n'est à télécharger ou à fournir.** Avec les sources de cette version, les images reconstruites sont identiques à celles de `roms/`.

Le script contrôle l'empreinte de la référence, les bornes du code et 84 plages de données protégées. La ROM externe reste à `$4000–$BFFF`, la maskROM à `$C000–$FFFF`. L'image 64 Ko duplique les 32 Ko.

### Vérifier la distribution

```sh
python tools/check_release.py
```

Cette commande contrôle les deux fichiers, leurs empreintes et le miroir. Pour un audit du code reconstruit, les développeurs disposant d'une copie de la maskROM NH7-0815 peuvent aussi lancer :

```sh
python tools/audit_rom.py --mask NH7_0815_PATH
```

Cet audit suit les branches et appels directs ; il ne constitue pas une preuve exhaustive de tous les chemins matériels. Les résultats de construction restent dans `build/`, exclu de Git.

## English

**To use the firmware, simply program one of the two images in `roms/`.** This page is for source development.

`src/` contains the HD6301 modules for text/printing, serial, keyboard, setup and LCD. With Python 3.10+ and an HD6301-capable **A09** assembler, run:

```sh
python tools/build.py --a09 A09_PATH
```

The two output images go to `build/`; symbols and listings go to `build/assembly/`.

Rebuilding uses **the included 32 KB TTY ROM** as the reference for shared routines and font data. It reassembles and reinserts the TTY modules into their allocated regions. **No BASIC firmware download or input file is needed.** Unmodified release sources reproduce the supplied images byte for byte.

The builder checks the reference hash, code bounds and 84 protected data ranges. External ROM remains at `$4000–$BFFF`, mask ROM at `$C000–$FFFF`. The 64 KB image duplicates the 32 KB image.

`python tools/check_release.py` checks both distributed files, hashes and mirroring. Developers with an NH7-0815 mask-ROM copy can additionally run the audit command above. It checks direct control flow, not every possible hardware path. Build outputs are excluded from Git.
