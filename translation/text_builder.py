import os
import shutil
import struct

build_dir = "built_files"

newline = "<NEWLINE>"
new_section = "<NEW SECTION>"

def buildType0(input_path, output_path, filesize):
    data = []
    with open(input_path, "rb") as fp:
        lines = fp.read()
        lines = lines.split(f"\r\n{new_section}\r\n".encode("shift_jis_2004"))
        for i, line in enumerate(lines):
            strings = line.split(b"\x0D\x0A")
            section = []
            for str in strings:
                str = str.replace(newline.encode("shift_jis_2004"), b"\x0A")
                section.append(str + b"\x00")
            if section:
                data.append(section)

    with open(output_path, "wb") as fp:
        size = len(data)
        if "4672" in output_path:
            size += 1
        fp.write(size.to_bytes(4, byteorder="little"))
        fp.write((8).to_bytes(4, byteorder="little"))
        
        # Section TOC Offset
        section_offset = (len(data) + 2) * 4
        
        for section in data:
            fp.write(section_offset.to_bytes(4, byteorder="little"))
            section_size = (len(section)+1) * 4
            for str in section:
                section_size += len(str)
            section_offset += section_size + 1
            if "4672" in output_path:
                section_offset -= 1 
        
        
        for section in data:
            str_offset = len(section) * 4 + 4
            for str in section:
                fp.write(str_offset.to_bytes(4, byteorder="little"))
                str_offset += len(str)
            fp.write(b"\xFF\xFF\xFF\xFF")
            str_offset += 4
            for str in section:
                fp.write(str)
            if not "4672" in output_path:
                fp.write(b"\x00")
                
        for i in range(section_offset, filesize):
            fp.write(b"\x00")