"""Verify the two standalone release ROMs and their checksums."""
import re

from firmware import ROOT, VERSION, ROM_SIZE, ROM32, ROM64, digest, read_reference


def check():
    manifest = {}
    for line in (ROOT / 'roms/SHA256SUMS.txt').read_text(encoding='ascii').splitlines():
        match = re.fullmatch(r'([0-9a-f]{64})  ([A-Za-z0-9_.-]+)', line)
        if not match or match[2] in manifest:
            raise ValueError('Invalid or duplicate SHA256SUMS entry.')
        manifest[match[2]] = match[1]
    image = read_reference()
    mirror = (ROOT / 'roms' / ROM64).read_bytes()
    if len(image) != ROM_SIZE or mirror != image * 2:
        raise ValueError('Invalid 32 KiB size or 64 KiB mirror.')
    expected = {ROM32, ROM64}
    paths = list((ROOT / 'roms').rglob('*.bin'))
    if set(manifest) != expected or len(paths) != 2 or {p.parent for p in paths} != {ROOT / 'roms'}:
        raise ValueError('Expected exactly the two release ROMs, without old variants.')
    for filename, data in ((ROM32, image), (ROM64, mirror)):
        if manifest.get(filename) != digest(data):
            raise ValueError(f'Checksum mismatch: {filename}')
        print(f'PASS {filename}: size and SHA-256')
    print('PASS 64 KiB image contains two identical 32 KiB copies')
    print(f'PASS Typestar TTY v{VERSION}: release bundle integrity')


if __name__ == '__main__':
    try:
        check()
    except (OSError, ValueError, KeyError, TypeError) as error:
        raise SystemExit(f'Release check failed: {error}')
