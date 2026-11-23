# Matériel et installation / Hardware and installation

[Français](#français) · [English](#english) · [Accueil / Home](../README.md)

## Français

### Machines prises en charge

Typestar TTY v1.0.0 a été **testé sur une Canon Typestar 7 (S-70)** et sur une **Canon Typestar 6-II (S-61) modifiée par ajout des composants de l'interface série**.

| Modèle | Préparation |
| --- | --- |
| **Typestar 7 / S-70** | Utiliser l'interface série d'origine et installer la ROM TTY en IC8. |
| **Typestar 6-II / S-61** | Ajouter les composants de la prise et du circuit série, puis installer la ROM TTY en IC8. |

Pour identifier et modifier la S-61, consultez le [guide de l'extension série](https://github.com/pR-0000/Typestar-BASIC/blob/main/docs/hardware/typestar-6-serial-upgrade.md). Il décrit notamment la carte **NG3-0672 / NH1-0159-065**, le microcontrôleur **NH7-0815** et les composants à ajouter. Le suffixe « -II » peut manquer sur la façade : identifiez la carte et la machine avant modification.

### ROM IC8

Le firmware s'installe à la place de la ROM externe **IC8**. La maskROM du microcontrôleur reste en place. Les formats disponibles sont :

- **32 Ko** pour OneROM en mode **27C256** ou ROM compatible.
- **64 Ko miroir** pour une W27C512 compatible, avec deux copies identiques des 32 Ko.

Choisissez votre fichier dans le [dossier ROMs](../roms/README.md). Les images sont déjà dans l'ordre attendu par le support IC8.

Pour la programmation, le démontage et l'orientation de la puce, suivez le [guide illustré d'installation](https://github.com/pR-0000/Typestar-BASIC/blob/main/docs/user-manual/02-installation-firmware.md). La procédure matérielle est commune ; utilisez le fichier **Typestar TTY** de cette version. Effectuez le remplacement hors tension, alimentation et piles déconnectées. Conservez la ROM d'origine pour pouvoir rétablir le fonctionnement précédent.

### Câble USB-série

Le connecteur **CN7 / DE-9 de la Canon utilise des signaux TTL 5 V**. Sa forme ne signifie pas qu'il accepte directement les tensions d'un port RS-232 de PC.

Avec un adaptateur USB-TTL compatible 5 V, le câblage est le suivant. Les noms RXD et TXD sont ceux de l'interface TTL de l'adaptateur.

| Contact Canon | Signal | Côté câble USB-TTL |
| --- | --- | --- |
| 1 | GND | Masse de l'adaptateur |
| 2 | TXD Canon | RXD de l'adaptateur |
| 3 | RXD Canon | TXD de l'adaptateur |
| 4 | RTS# Canon | CTS# de l'adaptateur |
| 5 | Détection de l'interface | Résistance de **2,2 kΩ vers la masse** |
| 6 | Détection de présence | **Autre résistance de 2,2 kΩ vers la masse** |
| 7 | DTR# Canon | Isolé dans le câble USB décrit ici |
| 8 | Non connecté | Isolé |
| 9 | +5 V Canon | Isolé |

Les deux résistances des contacts 5 et 6 sont distinctes. L'alimentation VCC et la sortie RTS# de l'adaptateur USB restent isolées. Consultez le [schéma de câblage](https://github.com/pR-0000/Typestar-BASIC/blob/main/docs/user-manual/02-presentation-firmware.md#serial-cable) pour les repères et l'orientation du connecteur.

La Canon utilise RTS# pour demander une pause au PC pendant l'impression ou les accès LCD. Le câble transmet cette demande à l'entrée CTS# de l'adaptateur ; le logiciel doit activer RTS/CTS. Le menu permet aussi d'utiliser XON/XOFF si l'hôte est configuré pour ce mode.

### Port RS-232 et DOS

Pour un port COM RS-232, utilisez un **convertisseur de niveaux et de polarité RS-232 ↔ TTL 5 V**. Après conversion, TX et RX se croisent ; RTS# Canon commande CTS côté PC. DTR# Canon peut fournir l'état de disponibilité à DSR côté PC selon le câblage du convertisseur. Les résistances de détection restent nécessaires et la sortie +5 V Canon reste isolée.

La mise en service de la console DOS est décrite dans le [guide de connexion](SETUP.md#ms-dos).

## English

### Supported machines

Typestar TTY v1.0.0 has been **tested on the Canon Typestar 7 (S-70)** and on a **Canon Typestar 6-II (S-61) modified by adding the serial-interface components**.

| Model | Preparation |
| --- | --- |
| **Typestar 7 / S-70** | Use the factory serial interface and replace IC8 with the TTY ROM. |
| **Typestar 6-II / S-61** | Populate the serial-port/interface components, then replace IC8 with the TTY ROM. |

The [S-61 serial-upgrade guide](https://github.com/pR-0000/Typestar-BASIC/blob/main/docs/hardware/typestar-6-serial-upgrade.md#english) describes identification, the **NG3-0672 / NH1-0159-065** PCB, **NH7-0815** MCU and added components. Some front panels omit the “-II” suffix; identify the machine and PCB before modifying it.

### IC8 ROM

Replace the external **IC8** ROM. The microcontroller's mask ROM stays in place. Use a **32 KB** image for a OneROM configured as **27C256** or a compatible ROM, or a **64 KB mirrored** image for a compatible W27C512. The [ROM directory](../roms/README.md#english) lists the files, already in physical IC8 order.

Follow the [illustrated installation guide](https://github.com/pR-0000/Typestar-BASIC/blob/main/docs/user-manual/en/02-installation-firmware.md) for programming, disassembly and chip orientation. The hardware procedure is shared; use this release's **Typestar TTY** image. Disconnect power and batteries before replacing IC8. Keep the original ROM to restore the previous firmware later.

### USB serial cable

The Canon's **CN7 / DE-9 connector carries 5 V TTL signals**. It must not be connected directly to a PC's RS-232 voltage levels.

| Canon contact | Signal | USB-TTL adapter connection |
| --- | --- | --- |
| 1 | GND | Adapter ground |
| 2 | Canon TXD | Adapter RXD |
| 3 | Canon RXD | Adapter TXD |
| 4 | Canon RTS# | Adapter CTS# |
| 5 | Interface detection | **2.2 kΩ resistor to ground** |
| 6 | Presence detection | **Separate 2.2 kΩ resistor to ground** |
| 7 | Canon DTR# | Isolated in this USB cable |
| 8 | Not connected | Isolated |
| 9 | Canon +5 V | Isolated |

Keep the two detection resistors separate. Leave adapter VCC and RTS# isolated. Refer to the [wiring guide](https://github.com/pR-0000/Typestar-BASIC/blob/main/docs/user-manual/en/02-presentation-firmware.md#serial-cable) for connector orientation and numbering.

Canon RTS# requests a host pause during printing and LCD access. The cable routes it to adapter CTS#; enable RTS/CTS in the host software. XON/XOFF is also available when configured on both ends.

### RS-232 and DOS

Use an **RS-232 ↔ 5 V TTL level/polarity converter** for a PC COM port. Cross TX/RX through it and route Canon RTS# to PC CTS. Depending on converter wiring, Canon DTR# can provide readiness to PC DSR. Keep the detection resistors and isolate Canon +5 V.

See [DOS setup](SETUP.md#ms-dos-1) for console configuration.
