"""
Run this script once to create placeholder PNG files so the Flutter app
doesn't show errors while you extract the real logos from the PDF.

Usage:
  python3 create_placeholders.py

Then replace the generated files with your real logos.
"""

import struct, zlib, os

def make_png(width, height, r, g, b, path):
    """Create a minimal solid-color PNG file."""
    def chunk(name, data):
        c = zlib.crc32(name + data) & 0xFFFFFFFF
        return struct.pack('>I', len(data)) + name + data + struct.pack('>I', c)

    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    raw = b''
    for _ in range(height):
        raw += b'\x00'  # filter type none
        raw += bytes([r, g, b] * width)
    compressed = zlib.compress(raw)
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', ihdr)
    png += chunk(b'IDAT', compressed)
    png += chunk(b'IEND', b'')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(png)
    print(f"Created: {path}")

make_png(128, 128, 29, 78, 58,  'assets/images/logo_faculty.png')
make_png(128, 128, 29, 78, 58,  'assets/images/logo_university.png')
print("Done! Replace these files with your real logos extracted from logo.pdf")
