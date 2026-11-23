"""Assemble the Typestar TTY overlay and package NH7 socket images."""
import argparse
import json
from pathlib import Path
import re
import subprocess


from firmware import ROOT, read_reference, swap_halves, write_images


ABI = {
    'CONSOLEATTACH': 0x5A7D, 'UIINIT': 0x50B3, 'BOOTFLAG': 0x19E7,
    'PUTS': 0x509E, 'UICLEAR': 0x510C, 'KBDFAST': 0x5B8F,
    'PEND': 0x19CE, 'DFLOOR': 0x1EC0, 'DHEAP': 0x1EBE,
    'SPBOOT': 0x5AAE, 'LPBUILD': 0x861D, 'LPREAD': 0x1DAD,
    'LPREMAIN': 0x1DAF, 'LPSUPPRESS': 0x1DB0, 'LPMODE': 0x1DBA,
    'LPCOLUMN': 0x1B5D, 'GPTICK': 0x8DB1, 'GPTIMEOUT': 0x8DAD,
    'KBASE': 0x199B, 'KROW': 0x199C, 'KRAW': 0x199A,
    'KDENTRY': 0x4D31, 'KBDNONE': 0x5C3E, 'KBDRETURN': 0x5C3F,
    'LCDBUF': 0x19A0, 'LCDREDRAW': 0x5B32,
}

# Hook widths preserve the instruction boundaries in the bundled reference.
# Its full SHA-256 is checked before any source code is inserted.
HOOKS = (
    (0x5000, 4, 'TTYSTART', 0x7E),
    (0x8DA4, 9, 'TTYWAIT', 0x7E),
    (0x8677, 3, 'TTYFAIL', 0x7E),
    (0x5801, 3, 'TTYPAPERKEY', 0xBD),
    (0x665F, 3, 'TTYPAPERKEY', 0xBD),
    (0x872F, 3, 'TTYPAPERKEY', 0xBD),
    (0x5B91, 3, 'TTYSCAN', 0xBD),
    (0x5C17, 3, 'TTYTRANSLATE', 0x7E),
    (0x899E, 4, 'TTYFAIL', 0x7E),
    (0x58D3, 3, 'TTYFAIL', 0x7E),
    (0x4D57, 4, 'TTYMAPREAD', 0x7E),
)
FIXED_PATCHES = (
    (0x827D, '0101'),  # Always use the retained ASCII font.
    # Caps Lock still toggles the regional map. Its old BASIC LCD markers
    # would overwrite TTY status and block unpaused reception at high baud.
    (0x5BE9, '010101'),
)
REGIONS = (
    (0x9900, 'TTYDISPLAYEND', 0x9D00, 'display.asm', 'BASIC arrays'),
    (0x9D00, 'TTYKEYEND', 0xA000, 'keyboard.asm', 'BASIC arrays'),
    (0xA00F, 'TTYMAINEND', 0xA3C5, 'tty.asm', 'BASIC decimal expressions'),
    (0xA8DB, 'TTYHELPEND', 0xAB11, 'serial.asm', 'BASIC token storage'),
    (0xBA5D, 'TTYMENUEND', 0xBCF9, 'menu.asm', 'BASIC string statements'),
)


def assemble(assembler, work):
    equates = dict(ABI, DEFAULTFRAME=0, DEFAULTFLOW=0)
    header = '        OPT H01\n' + ''.join(
        f'{name} EQU ${value:04X}\n' for name, value in equates.items())
    body = (ROOT / 'src' / 'state.inc').read_text(encoding='ascii')
    for origin, _, _, filename, _ in REGIONS:
        body += f'\n        ORG ${origin:04X}\n'
        body += (ROOT / 'src' / filename).read_text(encoding='ascii')
    source = work / 'linked.asm'
    source.write_text(header + body, encoding='ascii')
    listing = work / 'linked.lst'
    binary = work / 'linked.bin'
    subprocess.run([str(assembler), '-B' + str(binary), '-L' + str(listing), str(source)],
                   cwd=work, check=True)
    table = listing.read_text(encoding='ascii').split('SYMBOL TABLE', 1)[1]
    labels = {name: int(value, 16) for name, value in
              re.findall(r'\b([A-Z][A-Z0-9_]*)\s+[0-9A-F]{2}\s+([0-9A-F]{4})\b', table)}
    data = binary.read_bytes()
    if len(data) != labels['TTYMENUEND'] - REGIONS[0][0]:
        raise ValueError('Unexpected assembler output span')
    return data, labels


def build(assembler, output):
    raw = read_reference()
    base = swap_halves(raw)
    cpu = bytearray(base)
    work = output / 'assembly'
    work.mkdir(parents=True, exist_ok=True)
    data, labels = assemble(assembler, work)
    patches = []
    regions = []
    for start, end, limit, filename, retired in REGIONS:
        stop = labels[end]
        if not start < stop <= limit:
            raise ValueError(f'Overlay at ${start:04X} extends to ${stop:04X} (limit ${limit:04X})')
        origin = REGIONS[0][0]
        replacement = data[start - origin:stop - origin] + bytes([0xFF]) * (limit - stop)
        patches.append((start, replacement))
        regions.append(dict(start=start, end=stop, limit=limit, source=filename,
                            retired=retired, free_bytes=limit-stop))
    for address, width, target, opcode in HOOKS:
        patches.append((address, bytes([opcode]) + labels[target].to_bytes(2, 'big') +
                        bytes([0x01]) * (width - 3)))
    for address, replacement in FIXED_PATCHES:
        patches.append((address, bytes.fromhex(replacement)))
    for address, replacement in patches:
        offset = address - 0x4000
        cpu[offset:offset + len(replacement)] = replacement
    protected = json.loads((ROOT / 'src' / 'protected-data.json').read_text(encoding='ascii'))
    for start, end in protected:
        if cpu[start-0x4000:end-0x4000] != base[start-0x4000:end-0x4000]:
            raise ValueError(f'Protected Canon or font data changed at ${start:04X}')
    socket = swap_halves(cpu)
    (work / 'cpu.bin').write_bytes(cpu)
    (work / 'symbols.json').write_text(json.dumps(labels, indent=2) + '\n', encoding='ascii')
    (work / 'layout.json').write_text(json.dumps(dict(regions=regions,
        reclaimed_bytes=sum(r['limit']-r['start'] for r in regions),
        free_bytes=sum(r['free_bytes'] for r in regions)), indent=2) + '\n', encoding='ascii')
    write_images(output, socket)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--a09', type=Path, required=True, help='A09 assembler executable')
    parser.add_argument('--output', type=Path, default=ROOT / 'build')
    args = parser.parse_args()
    build(args.a09.resolve(), args.output.resolve())


if __name__ == '__main__':
    main()
