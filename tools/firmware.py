"""Shared metadata and I/O for the two standalone Typestar TTY ROM images."""
from hashlib import sha256
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VERSION = (ROOT / 'VERSION').read_text(encoding='ascii').strip()
ROM_SIZE = 32768
STEM = f'typestar-tty-{VERSION}'
ROM32 = STEM + '-32k.bin'
ROM64 = STEM + '-64k-mirror.bin'
REFERENCE_SHA = '573f87925f46b1ab7662b2ef2c53ea6b9227118658cd09d3b40ea1411bfe1eeb'
MASK_SHA = '9679e78d87398c918818aa76f608cdd72132075fe7286cf1333cf6d1a8f1cf3d'


def digest(data):
    return sha256(data).hexdigest()


def read_reference():
    """Use the bundled TTY image for shared Canon routines and font data."""
    data = (ROOT / 'roms' / ROM32).read_bytes()
    if len(data) != ROM_SIZE or digest(data) != REFERENCE_SHA:
        raise ValueError('Restore the original bundled 32 KiB TTY image before rebuilding.')
    return data


def swap_halves(data):
    return data[16384:] + data[:16384]


def write_images(output, image):
    output.mkdir(parents=True, exist_ok=True)
    if len(image) != ROM_SIZE:
        raise ValueError('Expected a 32 KiB IC8 image.')
    checksums = []
    for name, data in ((ROM32, image), (ROM64, image * 2)):
        (output / name).write_bytes(data)
        checksums.append(f'{digest(data)}  {name}')
    (output / 'SHA256SUMS.txt').write_bytes(('\n'.join(checksums)+'\n').encode('ascii'))
    print('\n'.join(checksums))
