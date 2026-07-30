#!/usr/bin/env python3
"""
Generate minimal GOFF object files for testing z/OS archives/their respective
archive symbol attributes.

A GOFF object file is a sequence of 80-byte records. This script emits the
minimum records needed to exercise getZOSSymbolArchiveAttributes():

  HDR  - required first record
  ESD  - one ED (element definition) as the parent section
  ESD  - one LD (label definition) as the exported symbol
  END  - required last record

The three archive attribute bits come from fields in the ESD records:
  bit 2 (0x4): 64-bit   - AMODE field of the LD record (byte 60) == 4
  bit 1 (0x2): XPLink   - LinkageType bit of the LD record (byte 66, bit 2)
  bit 0 (0x1): WSA      - NameSpaceId of the parent ED record (byte 40) == 3

Usage:
  python generate_goff_object.py --output foo.o --name foo --amode64 --xplink
  python generate_goff_object.py --output wsa.o --name bar --wsa
"""

import argparse
import struct
import sys

RECORD_LEN = 80

# Note: The following record and ESD information can be found in GOFF.h.

# Record type, stored in the high 4 bits of byte 1.
# The record type is retrieved in GOFFObjectFile.cpp, and defined in GOFF.h.
RT_HDR = 0xF0  # 15 << 4
RT_ESD = 0x00  # 0  << 4
RT_END = 0x40  # 4  << 4

# ESD symbol types (byte 3 of an ESD record).
ESD_ST_ElementDefinition = 1
ESD_ST_LabelDefinition   = 2

# ESD NameSpaceId values (byte 40 of an ESD record).
ESD_NS_NormalName = 1
ESD_NS_Parts      = 3   # WSA

# AMODE values (byte 60 of an ESD record).
ESD_AMODE_31 = 2
ESD_AMODE_64 = 4

# LinkageType is bit 2 (0-indexed from MSB) of byte 66 of an ESD record.
# Bit 2 from MSB in an 8-bit byte = value 0x20.
ESD_LT_XPLINK_BIT = 0x20


def make_record(record_type_byte, payload):
    """Build one 80-byte GOFF record.
    Byte 0:  0x03 (PTV prefix — identifies GOFF format)
    Byte 1:  record type in high 4 bits, flags in low 4 bits
    Bytes 2-79: payload (padded with zeros to 78 bytes)
    """
    assert len(payload) <= 78, f"payload too long: {len(payload)}"
    payload = payload.ljust(78, b'\x00')
    return struct.pack('BB', 0x03, record_type_byte) + payload


def make_hdr():
    """Minimal HDR record (all payload fields zero except arch level = 1)."""
    payload = bytearray(78)
    struct.pack_into('>H', payload, 50, 1)  # ArchitectureLevel = 1
    return make_record(RT_HDR, bytes(payload))


def make_end():
    """Minimal END record."""
    return make_record(RT_END, b'')


def make_esd(esd_id, parent_esd_id, symbol_type, name_bytes,
             namespace=ESD_NS_NormalName, amode=ESD_AMODE_31,
             xplink=False, length=0):
    """Build an ESD record.

    Field layout (byte offsets, all big-endian):
      3:     symbol type
      4-7:   ESD ID
      8-11:  parent ESD ID
      24-27: length
      40:    NameSpaceId
      60:    AMODE
      66:    flags byte — bit 2 (0x20) = XPLink linkage type
      70-71: name length
      72-79: name (up to 8 bytes; longer names need continuation records,
             not needed for these short test names)
    """
    payload = bytearray(78)
    payload[1]  = symbol_type
    struct.pack_into('>I', payload, 2, esd_id)
    struct.pack_into('>I', payload, 6, parent_esd_id)
    struct.pack_into('>I', payload, 22, length)
    payload[38] = namespace
    payload[58] = amode
    if xplink:
        payload[64] |= ESD_LT_XPLINK_BIT
    name = name_bytes[:8]
    struct.pack_into('>H', payload, 68, len(name))
    payload[70:70 + len(name)] = name
    return make_record(RT_ESD, bytes(payload))


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--output', required=True, help='Output .o file path')
    p.add_argument('--name',   required=True, help='Exported symbol name (ASCII)')
    p.add_argument('--amode64', action='store_true', help='Set 64-bit AMODE flag')
    p.add_argument('--xplink',  action='store_true', help='Set XPLink linkage flag')
    p.add_argument('--wsa',     action='store_true', help='Set WSA (ESD_NS_Parts) flag')
    args = p.parse_args()

    name_bytes = args.name.encode('ascii')
    amode      = ESD_AMODE_64 if args.amode64 else ESD_AMODE_31
    namespace  = ESD_NS_Parts if args.wsa else ESD_NS_NormalName

    # ESD ID 1: parent ED (section). Give it zero length so the LD below
    # triggers the "zero-length ED with LD child" section case in the parser.
    ed  = make_esd(esd_id=1, parent_esd_id=0,
                   symbol_type=ESD_ST_ElementDefinition,
                   name_bytes=b'',
                   namespace=namespace,
                   length=0)

    # ESD ID 2: LD (label definition) — this is the exported symbol.
    # AMODE and XPLink are set on the LD record itself.
    ld  = make_esd(esd_id=2, parent_esd_id=1,
                   symbol_type=ESD_ST_LabelDefinition,
                   name_bytes=name_bytes,
                   amode=amode,
                   xplink=args.xplink)

    data = make_hdr() + ed + ld + make_end()
    with open(args.output, 'wb') as f:
        f.write(data)


if __name__ == '__main__':
    main()
