# Publication GitHub / GitHub publishing

[Français](#français) · [English](#english) · [Accueil / Home](../README.md)

## Français

### Informations du dépôt

**Nom :** `Typestar-TTY`

**Description courte recommandée :**

> Bidirectional serial TTY firmware for Canon Typestar 7 and modified Typestar 6-II typewriters, with paper output, keyboard input and LCD setup.

**Description française :**

> Firmware TTY bidirectionnel pour Canon Typestar 7 et Typestar 6-II modifiée : terminal papier série avec clavier et réglages sur LCD.

**Topics :** `canon`, `typestar`, `tty`, `serial-terminal`, `firmware`, `hd6301`, `thermal-printer`, `retrocomputing`.

### Publier une version

Ce guide s'adresse aux personnes qui maintiennent le projet. Pour installer le firmware, téléchargez simplement l'une des deux ROMs depuis les [releases](https://github.com/pR-0000/Typestar-TTY/releases).

Le workflow [Publish release](../.github/workflows/release.yml) démarre quand le fichier `VERSION` est modifié sur `main`. Il peut aussi être lancé manuellement depuis l'onglet **Actions** de GitHub. Seule la branche `main` peut publier.

1. Préparez les deux ROMs dans `roms/`, leurs empreintes dans `SHA256SUMS.txt`, et mettez à jour les métadonnées, le README et le changelog.
2. Ajoutez les notes français/anglais dans `docs/RELEASE-vX.Y.Z.md`, sur le modèle des [notes v1.0.0](RELEASE-v1.0.0.md).
3. Mettez `VERSION` à jour avec `X.Y.Z`, puis lancez `python -B tools/check_release.py`.
4. Publiez les changements sur `main` et vérifiez le résultat du workflow dans **Actions**.

Le workflow vérifie les tailles, le miroir 64 Ko et les empreintes SHA-256 avant de créer le tag `vX.Y.Z` sur le commit vérifié. Il publie ensuite une release **Typestar TTY vX.Y.Z**, avec exactement **deux fichiers `.bin`** et **`SHA256SUMS.txt`**. GitHub fournit en complément ses archives source habituelles.

Une release existante n'est pas remplacée. Les ROMs sont autonomes ; aucun fichier BASIC séparé n'est nécessaire.

Les dossiers `build/`, `release/` et `dist/`, les fichiers de travail et les caches Python sont exclus du dépôt. La licence et les attributions accompagnent les sources et les images.

## English

### Repository details

**Name:** `Typestar-TTY`

**Short description:**

> Bidirectional serial TTY firmware for Canon Typestar 7 and modified Typestar 6-II typewriters, with paper output, keyboard input and LCD setup.

Suggested topics are listed above. This guide is for maintainers. To install the firmware, download one of the two ROMs from [Releases](https://github.com/pR-0000/Typestar-TTY/releases).

### Publish a version

The [Publish release](../.github/workflows/release.yml) workflow starts when `VERSION` changes on `main`. It can also be started manually from GitHub's **Actions** tab. Only `main` can publish.

1. Prepare both ROMs in `roms/`, their `SHA256SUMS.txt`, and updated metadata, README and changelog.
2. Add French/English notes in `docs/RELEASE-vX.Y.Z.md`, following the [v1.0.0 notes](RELEASE-v1.0.0.md).
3. Set `VERSION` to `X.Y.Z`, then run `python -B tools/check_release.py`.
4. Push the changes to `main` and check the workflow result in **Actions**.

The workflow verifies sizes, the 64 KB mirror and SHA-256 checksums before creating tag `vX.Y.Z` at the verified commit. It then publishes **Typestar TTY vX.Y.Z** with exactly **two `.bin` files** and **`SHA256SUMS.txt`**. GitHub also provides its standard source archives.

An existing release is not overwritten. Both ROMs are standalone; no separate BASIC firmware file is needed.

Build outputs, temporary files and Python caches are excluded. Keep the license and attribution with source and images.
