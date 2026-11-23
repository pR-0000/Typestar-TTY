# Réglages et clavier / Settings and keyboard

[Français](#français) · [English](#english) · [Accueil / Home](../README.md)

## Français

### Le clavier au quotidien

| Touche Canon | Action |
| --- | --- |
| RETURN | Envoie CR au PC, ou CRLF si cette option est activée. |
| BACKSPACE | Envoie BS au PC. |
| MARGIN RELEASE / BREAK | Envoie Ctrl+C. |
| CODE + A…Z | Envoie Ctrl+A…Ctrl+Z, selon la disposition régionale du clavier. CODE+I donne Tab, CODE+D donne EOF sous Unix, CODE+Z donne Ctrl+Z. |
| CODE + MARGIN RELEASE / BREAK | Envoie ESC. |
| **CODE + RETURN** | **Imprime le fragment en attente et avance le papier d'une ligne**, sans envoyer de caractère au PC. |
| CODE + BACKSPACE | Imprime immédiatement le fragment reçu, sans ajouter de fin de ligne ni envoyer de caractère au PC. |
| **CODE + ESPACE** | **Ouvre les réglages locaux.** |

L'écho papier est **désactivé au démarrage** : l'hôte renvoie normalement les caractères à imprimer. Ainsi, une session Linux peut masquer un mot de passe. Si le PC n'effectue aucun écho, une frappe reste invisible sur le papier, y compris RETURN. CODE+RETURN permet toujours une avance locale. Activez `PAPER ECHO` seulement pour un hôte sans écho ou pour un usage autonome.

### Changer les réglages

1. Ouvrez le menu avec **CODE + ESPACE**. Le terminal demande au PC de suspendre l'envoi ; le texte déjà en attente reste tamponné.
2. Choisissez un réglage avec **haut / bas**, puis sa valeur avec **gauche / droite**.
3. Appuyez sur **RETURN** pour appliquer les six réglages. **MARGIN RELEASE**, **CODE + MARGIN RELEASE** ou **CODE + ESPACE** annulent les modifications.

| Réglage LCD | Valeurs | Au démarrage |
| --- | --- | --- |
| `BAUD` | 1200 / 2400 / 7812 / 15625 / 31250 | 1200 |
| `FORMAT` | 8N1 / 7E1 | 8N1 |
| `FLOW` | RTS / XON / BOTH | RTS |
| `RETURN` | CR / CRLF | CR |
| `PAPER ECHO` | OFF / ON | OFF |
| `RX PREVIEW` | OFF / ON | OFF |

`RTS` correspond au contrôle matériel RTS/CTS. `XON` active le contrôle logiciel XON/XOFF ; `BOTH` permet les deux. Le signal matériel de pause Canon reste piloté dans tous les modes. Avec XON, l'hôte peut utiliser seulement le contrôle logiciel.

Les paramètres sont appliqués ensemble après impression du texte déjà reçu avec l'ancienne configuration. **Réglez également le PC sur le même débit, la même trame et un contrôle de flux compatible.** Attendez la fin des transferts avant de changer ces trois paramètres. Si `TX BUSY` apparaît, une frappe attend encore son départ, par exemple après un XOFF du PC : annulez, faites reprendre la liaison puis réessayez.

7812, 15625 et 31250 sont les mêmes valeurs que dans le BASIC et Studio. Le logiciel et l'adaptateur PC doivent accepter ces débits. Le mécanisme thermique garde sa cadence ; RTS/CTS ou XON/XOFF règle toujours le rythme des transmissions. [Guide des débits](SETUP.md#débits-et-changement-de-configuration)

Les réglages sont conservés **jusqu'au redémarrage**. Celui-ci rétablit **1200 bauds, 8N1 et RTS/CTS**, avec RETURN en CR, écho papier OFF et aperçu OFF. Les images 32 et 64 Ko offrent exactement les mêmes fonctions ; choisissez leur taille uniquement selon la puce.

### Lire l'écran

Le début de la ligne indique le débit, la trame et le contrôle de flux. `R+` / `T+` signalent une activité récente en réception / émission ; `R-` / `T-` indiquent l'absence d'activité pendant l'intervalle précédent. `Q000` donne le nombre d'octets reçus encore en file. `HOST` signifie que l'hôte gère l'écho ; `LOCAL` indique que l'écho papier local est activé.

Avec `RX PREVIEW ON`, la seconde moitié du LCD montre les **16 derniers caractères ASCII reçus** à la place des détails TX/file/écho. Les frappes locales ne sont jamais recopiées dans cet aperçu. Un mot de passe peut toutefois s'y voir si l'hôte le renvoie : son masquage dépend de l'hôte et de la désactivation de l'écho papier local.

Les mises à jour d'état sont regroupées environ deux fois par seconde après une activité. Avant chaque réécriture du LCD, le firmware demande une courte pause à l'hôte pour éviter de perdre des octets pendant l'accès écran. L'impression reste prioritaire ; cet affichage n'est pas un moniteur instantané du port.

| Message LCD | Signification / action |
| --- | --- |
| `RX PARITY ERROR` | Parité reçue incorrecte : vérifier 8N1 / 7E1 côté Canon et PC. |
| `RX FRAME/OVERRUN` | Trame incorrecte ou débordement matériel : vérifier débit, câblage et contrôle de flux. |
| `RX BUFFER FULL` | L'hôte a envoyé alors que la Canon demandait une pause ; du texte a été perdu. |
| `TX BUFFER FULL` | La file clavier est pleine ; une frappe n'a pas été transmise. |
| `ECHO BUFFER FULL` | Une frappe transmise n'a pas pu être ajoutée à la file d'écho papier. |
| `TX BUSY` / `TX PAUSED` | Des frappes attendent avant un changement de paramètres. |
| `TTY PAPER ERROR - RESTART` | Le pilote a signalé une erreur d'impression. Vérifier papier et chariot puis redémarrer. |

Les erreurs série restent affichées pour permettre le diagnostic. Réappliquer les paramètres depuis le menu les efface ; les octets perdus ne sont pas retransmis automatiquement.

## English

### Everyday keys

| Canon key | Action |
| --- | --- |
| RETURN | Sends CR to the host, or CRLF when enabled. |
| BACKSPACE | Sends BS to the host. |
| MARGIN RELEASE / BREAK | Sends Ctrl+C. |
| CODE + A…Z | Sends Ctrl+A…Ctrl+Z using the regional keyboard layout. CODE+I sends Tab, CODE+D Unix EOF, CODE+Z Ctrl+Z. |
| CODE + MARGIN RELEASE / BREAK | Sends ESC. |
| **CODE + RETURN** | **Prints the pending fragment and advances the paper one line**, without sending a byte to the host. |
| CODE + BACKSPACE | Prints the pending received fragment immediately, without a line ending or host transmission. |
| **CODE + SPACE** | **Opens local setup.** |

Paper echo is **off at boot**. The host normally echoes characters to paper and can turn echo off for a password. With an un-echoing host, typing stays off the paper, including RETURN. CODE+RETURN always advances the paper locally. Enable `PAPER ECHO` only for a host that does not echo or for a standalone test.

### Local setup

1. Press **CODE + SPACE**. The terminal asks the host to pause; queued received text is retained.
2. Select a field with **up / down**, and its value with **left / right**.
3. Press **RETURN** to apply all six values. **MARGIN RELEASE**, **CODE + MARGIN RELEASE** or **CODE + SPACE** cancel the changes.

| LCD setting | Values | At startup |
| --- | --- | --- |
| `BAUD` | 1200 / 2400 / 7812 / 15625 / 31250 | 1200 |
| `FORMAT` | 8N1 / 7E1 | 8N1 |
| `FLOW` | RTS / XON / BOTH | RTS |
| `RETURN` | CR / CRLF | CR |
| `PAPER ECHO` | OFF / ON | OFF |
| `RX PREVIEW` | OFF / ON | OFF |

`RTS` means RTS/CTS hardware flow control. `XON` enables software XON/XOFF; `BOTH` supports both. The Canon hardware pause output remains driven in every mode. With XON enabled the host may use software flow control alone.

All values are committed together after printing queued text with the old configuration. **Match the host's baud, framing and flow control.** Finish transfers before changing these parameters. `TX BUSY` means a keystroke is still queued, possibly because the host sent XOFF: cancel, resume the link and try again.

7812, 15625 and 31250 match BASIC/Studio rates. The PC application and adapter must support them. Thermal printing speed is unchanged; hardware or software flow control still paces transfers. [Baud-rate guide](SETUP.md#baud-rates-and-flow-control)

Settings last **until restart**. Restart restores **1200 baud, 8N1 and RTS/CTS**, CR for RETURN, paper echo OFF and preview OFF. The 32 and 64 KB images provide the same functions; select their size only according to your chip.

### LCD status

The first fields show baud, framing and flow control. `R+` / `T+` mean recent RX / TX activity; a minus means no activity during the previous interval. `Q000` is the receive queue length. `HOST` means host echo; `LOCAL` means local paper echo is enabled.

With `RX PREVIEW ON`, the second half shows the **last 16 received ASCII characters** instead of TX/queue/echo details. Local keystrokes are never copied into the preview. A host that echoes a password can still reveal it; password hiding depends on host behavior and keeping local paper echo disabled.

Status updates are coalesced to about twice a second after activity. The host is paused briefly before LCD access to protect reception. Printing has priority, so this is not an instantaneous serial monitor.

Parity, framing/overrun, RX-full, TX-full and echo-full messages identify link or queue errors. They remain visible until settings are reapplied. Lost data is not retransmitted automatically. `TTY PAPER ERROR - RESTART` stops printing and keeps the host paused: check the paper and carriage, then restart.
