"""Check direct control flow, protected data and reclaimed ROM boundaries.

This bounded HD6301 walker follows both conditional arms, direct calls and
branches. Mask-ROM services are opaque after startup. Indirect transfers need
the keyboard/printing runtime tests; this is not a proof of all hardware paths.
"""
import argparse
import hashlib
import json
from pathlib import Path

from firmware import ROOT, MASK_SHA, read_reference, swap_halves


def instruction_size(op):
    # HD6301 addressing modes. HD6301 bit operations add an immediate mask.
    if op < 0x20 or 0x30 <= op < 0x60:
        return 1
    if op < 0x30:
        return 2
    if op < 0x70:
        return 3 if op in (0x61, 0x62, 0x65, 0x6B) else 2
    if op < 0x80 or op in (0x83, 0x8C, 0x8E, 0xC3, 0xCC, 0xCE):
        return 3
    return 3 if op & 0xF0 in (0xB0, 0xF0) else 2


def walk(memory, roots, regions, startup=False):
    pending = [(pc, None) for pc in roots]
    seen, indirect, findings = set(), [], []
    while pending:
        pc, source = pending.pop()
        if pc in seen or startup and pc == 0x6829:
            continue
        if not startup and pc >= 0xC000:
            continue
        if not 0x4000 <= pc < 0x10000:
            findings.append([source, pc, 'outside ROM'])
            continue
        seen.add(pc)
        if any(r['end'] <= pc < r['limit'] for r in regions):
            findings.append([source, pc, 'reclaimed free space'])
            continue
        op = memory[pc]
        targets = []
        if op in (0x7E, 0xBD):
            targets.append(int.from_bytes(memory[pc+1:pc+3], 'big'))
        elif op == 0x9D:
            targets.append(memory[pc+1])
        elif 0x20 <= op <= 0x2F or op == 0x8D:
            offset = memory[pc+1]
            if op != 0x21:  # BRN never takes its branch
                targets.append(pc + 2 + (offset if offset < 128 else offset - 256))
        elif op in (0x6E, 0xAD):
            indirect.append(pc)
        if op not in (0x39, 0x3B, 0x3F, 0x3E, 0x1A, 0x7E, 0x6E, 0x20):
            targets.append(pc + instruction_size(op))
        pending.extend((target, pc) for target in targets)
    return dict(instructions=len(seen), findings=findings,
                indirect=[f'{pc:04X}' for pc in sorted(indirect)])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mask', type=Path, required=True)
    parser.add_argument('--build', type=Path, default=ROOT / 'build')
    args = parser.parse_args()
    folder = args.build / 'assembly'
    cpu = (folder / 'cpu.bin').read_bytes()
    base = swap_halves(read_reference())
    mask = args.mask.read_bytes()
    assert hashlib.sha256(mask).hexdigest() == MASK_SHA
    protected = json.loads((ROOT / 'src' / 'protected-data.json').read_text())
    for lo, hi in protected:
        assert cpu[lo-0x4000:hi-0x4000] == base[lo-0x4000:hi-0x4000], hex(lo)
    memory = bytes(0x4000) + cpu + mask
    symbols = json.loads((folder / 'symbols.json').read_text())
    layout = json.loads((folder / 'layout.json').read_text())
    report = dict(
        sha256=hashlib.sha256(cpu).hexdigest(), protected_ranges=len(protected),
        startup=walk(memory, [0xFFE0, 0x6800], layout['regions'], startup=True),
        terminal=walk(memory, [symbols['TTYSTART'], 0x7154, 0x716F, 0x728B],
                      layout['regions']),
        reclaimed_bytes=layout['reclaimed_bytes'], free_bytes=layout['free_bytes'])
    (folder / 'audit.json').write_text(json.dumps(report, indent=2)+'\n', encoding='ascii')
    print(json.dumps(report, indent=2))
    assert not report['startup']['findings'] and not report['terminal']['findings']


if __name__ == '__main__':
    main()
