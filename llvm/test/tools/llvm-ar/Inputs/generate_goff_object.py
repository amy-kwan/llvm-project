#!/usr/bin/env python3
"""Generate a minimal GOFF object file for testing z/OS archive symbol attributes.

A GOFF file is a sequence of 80-byte records. This script emits:
  HDR + ED (parent section) + LD (exported symbol) + END

The three z/OS archive attribute bits come from ESD record fields:
  bit 2 (0x4): 64-bit  - LD AMODE (record byte 60) == 4
  bit 1 (0x2): XPLink  - LD LinkageType bit (byte 66 bit 2 from MSB, mask 0x20)
  bit 0 (0x1): WSA     - ED NameSpaceId (byte 40) == 3 (ESD_NS_Parts)

Usage:
  python generate_goff_object.py --output foo.o --name foo --amode64 --xplink
  python generate_goff_object.py --output bar.o --name bar --wsa
"""

import argparse
import struct

# EBCDIC / ASCII conversion table (IBM-1047). GOFF symbol names are EBCDIC.
ASCII_TO_EBCDIC = (
    0x00,0x01,0x02,0x03,0x37,0x2D,0x2E,0x2F,0x16,0x05,0x15,0x0B,0x0C,0x0D,0x0E,0x0F,
    0x10,0x11,0x12,0x13,0x3C,0x3D,0x32,0x26,0x18,0x19,0x3F,0x27,0x1C,0x1D,0x1E,0x1F,
    0x40,0x5A,0x7F,0x7B,0x5B,0x6C,0x50,0x7D,0x4D,0x5D,0x5C,0x4E,0x6B,0x60,0x4B,0x61,
    0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0x7A,0x5E,0x4C,0x7E,0x6E,0x6F,
    0x7C,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,
    0xD7,0xD8,0xD9,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xAD,0xE0,0xBD,0x5F,0x6D,
    0x79,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x91,0x92,0x93,0x94,0x95,0x96,
    0x97,0x98,0x99,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xC0,0x4F,0xD0,0xA1,0x07,
)


def record(rtype, payload=b''):
    """Wrap payload in an 80-byte GOFF record (0x03 prefix + type byte)."""
    return struct.pack('BB', 0x03, rtype) + bytes(payload).ljust(78, b'\x00')


def make_esd(esd_id, parent_id, sym_type, name_ebcdic,
             namespace=1, amode=2, xplink=False):
    """Build an ESD record. All byte offsets are record-absolute.
      byte  3: symbol type (1=ED, 2=LD)
      bytes 4-7: ESD ID
      bytes 8-11: parent ESD ID
      byte 40: NameSpaceId (1=Normal, 3=Parts/WSA)
      byte 60: AMODE (2=31-bit, 4=64-bit)
      byte 66: bit 2 from MSB (0x20) = XPLink
      bytes 70-71: name length; bytes 72+: name (EBCDIC)
    """
    p = bytearray(78)
    p[1] = sym_type
    struct.pack_into('>I', p, 2, esd_id)
    struct.pack_into('>I', p, 6, parent_id)
    p[38] = namespace
    p[58] = amode
    if xplink:
        p[64] |= 0x20  # record byte 66
    name = name_ebcdic[:8]
    struct.pack_into('>H', p, 68, len(name))
    p[70:70 + len(name)] = name
    return record(0x00, p)  # RT_ESD = 0


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--output',  required=True)
    ap.add_argument('--name',    required=True)
    ap.add_argument('--amode64', action='store_true')
    ap.add_argument('--xplink',  action='store_true')
    ap.add_argument('--wsa',     action='store_true')
    args = ap.parse_args()

    name_e = bytes(ASCII_TO_EBCDIC[b] for b in args.name.encode('ascii'))
    amode  = 4 if args.amode64 else 2   # ESD_AMODE_64 : ESD_AMODE_31
    ns     = 3 if args.wsa     else 1   # ESD_NS_Parts : ESD_NS_NormalName

    # HDR: required first record; architecture level = 1 at payload byte 50.
    hdr_p = bytearray(78)
    struct.pack_into('>H', hdr_p, 50, 1)
    hdr = record(0xF0, hdr_p)  # RT_HDR = 15 << 4

    # ED (ESD ID 1): zero-length parent section. The zero length + LD child
    # triggers the GOFFObjectFile "case 2b" that makes the LD symbol visible.
    ed = make_esd(1, 0, 1, b'', namespace=ns)  # sym_type 1 = ElementDefinition

    # LD (ESD ID 2): the exported symbol. BindingScope defaults to 0
    # (Unspecified), which is != ESD_BSC_Section and != ESD_BSC_Module so
    # GOFFObjectFile sets SF_Global and isArchiveSymbol() accepts it.
    ld = make_esd(2, 1, 2, name_e,             # sym_type 2 = LabelDefinition
                  amode=amode, xplink=args.xplink)

    end = record(0x40)  # RT_END = 4 << 4

    with open(args.output, 'wb') as f:
        f.write(hdr + ed + ld + end)


if __name__ == '__main__':
    main()
