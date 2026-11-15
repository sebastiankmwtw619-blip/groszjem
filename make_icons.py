"""Generuje ikony PNG aplikacji (bez zewnętrznych bibliotek): żółty talerz na ciemnym tle."""
import struct
import zlib
from pathlib import Path

BG = (0x12, 0x12, 0x12)
YELLOW = (0xFF, 0xD4, 0x3B)
OUT = Path(__file__).parent / "icons"


def png(path, size, safe):
    """safe = jaka część ikony może być zajęta przez rysunek (maskable potrzebuje marginesu)."""
    c = size / 2
    r_plate = size * 0.36 * safe
    r_ring = size * 0.26 * safe
    r_inner = size * 0.20 * safe
    rows = []
    for y in range(size):
        row = bytearray([0])
        for x in range(size):
            # 4 próbki na piksel = gładkie krawędzie
            acc = [0, 0, 0]
            for sy in (0.25, 0.75):
                for sx in (0.25, 0.75):
                    d = ((x + sx - c) ** 2 + (y + sy - c) ** 2) ** 0.5
                    if d <= r_inner:
                        col = YELLOW
                    elif d <= r_ring:
                        col = BG
                    elif d <= r_plate:
                        col = YELLOW
                    else:
                        col = BG
                    for i in range(3):
                        acc[i] += col[i]
            row += bytes(v // 4 for v in acc)
        rows.append(bytes(row))
    raw = zlib.compress(b"".join(rows), 9)

    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0)) + chunk(b"IDAT", raw) + chunk(b"IEND", b"")
    path.write_bytes(data)


OUT.mkdir(exist_ok=True)
png(OUT / "icon-192.png", 192, 1.0)
png(OUT / "icon-512.png", 512, 1.0)
png(OUT / "icon-maskable-512.png", 512, 0.78)
png(OUT / "apple-touch-icon.png", 180, 1.0)
print("ok")
