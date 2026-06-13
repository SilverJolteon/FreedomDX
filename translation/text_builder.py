import os
import re
import shutil
import struct

build_dir = "built_files"

newline = "<NEWLINE>"
            
def buildType1(input_path, output_path, filesize):
    data = []
    
    files = [os.path.join(input_path, name) for name in os.listdir(input_path) if os.path.isfile(os.path.join(input_path, name))]
    files = sorted(files, key=lambda x: int(re.search(r"\d+", x).group()))
       
    for file in files:
        with open(file, "rb") as fp:
            lines = fp.read()
            strings = lines.split(b"\x0D\x0A")
            section = []
            for str in strings:
                str = str.replace(newline.encode("shift_jis_2004"), b"\x0A")
                section.append(str + b"\x00")
            if section:
                data.append(section)

    with open(output_path, "wb") as fp:
        size = len(data)
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
            
def buildType3(input_path, output_path, filesize):
    data = []
    
    files = [os.path.join(input_path, name) for name in os.listdir(input_path) if os.path.isfile(os.path.join(input_path, name))]
    files = sorted(files, key=lambda x: int(re.findall(r"\d+", x)[0]))
       
    for file in files:
        id = int(re.findall(r"\d+", file)[1])
        with open(file, "rb") as fp:
            lines = fp.read()
            strings = lines.split(b"\x0D\x0A")
            section = []
            for str in strings:
                str = str.replace(newline.encode("shift_jis_2004"), b"\x0A")
                type, str = str.split(b',', 1)
                section.append([type, str + b"\x00"])
            if section:
                data.append([id, section])

    with open(output_path, "wb") as fp:   
        # Section TOC Offset
        section_offset = (len(data) + 1) * 8
        
        for section in data:
            fp.write(section[0].to_bytes(4, byteorder="little"))
            fp.write(section_offset.to_bytes(4, byteorder="little"))
            section_size = len(section[1]) * 8
            for str in section[1]:
                section_size += len(str[1])
            section_offset += section_size + 1
        fp.write(b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF")
        
        for section in data:
            str_offset = len(section[1]) * 8
            for str in section[1]:
                fp.write(int(str[0]).to_bytes(4, byteorder="little"))
                fp.write(str_offset.to_bytes(4, byteorder="little"))
                str_offset += len(str[1])
            str_offset += 8
            for str in section[1]:
                fp.write(str[1])
            fp.write(b"\x00")
      
        for i in range(section_offset, filesize):
            fp.write(b"\x00")