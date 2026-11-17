"""Build the redistributable ZIP using only Python's standard library.

No game files, credentials, local paths or private test data are packaged.
"""
from pathlib import Path
import hashlib
import zipfile

ROOT = Path(__file__).resolve().parent
VERSION = 'v0.1-beta'
FILES = (
    'README.md', 'TECHNICAL.md', 'TESTING.md',
    'IncreasedTransferInterest.patch', 'RemoveIncreasedTransferInterest.patch',
    'CheckCompatibility.ps1', 'CheckCompatibility.cmd', 'CheckBeforeRemoval.cmd',
    'build_release.py',
)

def build(destination=None):
    destination = Path(destination) if destination else ROOT / 'dist'
    destination.mkdir(parents=True, exist_ok=True)
    archive = destination / f'CM0102-Increased-Interest-{VERSION}.zip'
    with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as out:
        for name in sorted(FILES):
            data = (ROOT / name).read_bytes()
            # Normalize text for reproducible archives across Windows and Linux.
            data = data.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')
            info = zipfile.ZipInfo(name, date_time=(2026, 11, 17, 12, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            out.writestr(info, data, compresslevel=9)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    checksum = destination / f'{archive.name}.sha256'
    checksum.write_text(f'{digest}  {archive.name}\n', encoding='ascii')
    print(f'{archive.name}: {digest}')
    return archive

if __name__ == '__main__':
    build()
