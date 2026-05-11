import os
import array
import struct
import subprocess
from sys import platform
from .text_builder import *

armips = os.path.join("tools", "armips.exe")
if platform == "linux" or platform == "linux2":
    armips = os.path.join("tools", "armips", "build", "armips")

class Injector:
    def __init__(self, path):
        self.path = path
        with open(path, "rb") as fp:
            self.data = bytearray(fp.read())
        
        toc_size_sectors = struct.unpack_from("<I", self.data, 0)[0]
        self.toc_size_bytes = toc_size_sectors * 2048
        self.toc = array.array('I', self.data[:self.toc_size_bytes])
        total_sectors = len(self.data) // 2048
        self.file_count = self.toc.index(total_sectors)

    def memset(self, addr, value, size):
        self.data[addr : addr + size] = bytes([value]) * size

    def memcpy(self, addr, payload):
        self.data[addr : addr + len(payload)] = bytes(payload)
        
    def buildASM(self, build_dir, index, asm):
        print(f"Building {asm}.asm for ULJM05066...")
        filename = asm + ".bin"
        asm = os.path.join("translation", "asm", asm + ".asm")
        start_offset = self.toc[index] * 2048
        end_offset = self.toc[index + 1] * 2048
        output = os.path.join(build_dir, "ULJM05066", filename)
        open(output, "wb").write(self.data[start_offset:end_offset])
        subprocess.run(
            [armips, asm],
            check=True
        )
        self.replace(index, output)
        os.remove(output)
        
    def replace(self, index, repl_path):
        if not os.path.exists(repl_path):
            return

        with open(repl_path, "rb") as fp:
            repl_data = fp.read()

        start_offset = self.toc[index] * 2048
        end_offset = self.toc[index + 1] * 2048
        old_size = end_offset - start_offset

        if len(repl_data) < old_size:
            repl_data = repl_data.ljust(old_size, b"\x00")
        
        new_size = len(repl_data)

        if new_size > old_size:
            diff_bytes = new_size - old_size
            diff_sectors = diff_bytes // 2048
            
            for i in range(index + 1, self.file_count + 1):
                self.toc[i] += diff_sectors
                struct.pack_into("<I", self.data, i * 4, self.toc[i])

            self.data[end_offset:end_offset] = b"\x00" * diff_bytes

        self.data[start_offset : start_offset + new_size] = repl_data
        
    def expand(self, index, new_size):
        start_offset = self.toc[index] * 2048
        end_offset = self.toc[index + 1] * 2048
        old_size = end_offset - start_offset

        diff_bytes = new_size - old_size
        diff_sectors = diff_bytes // 2048
        
        for i in range(index + 1, self.file_count + 1):
            self.toc[i] += diff_sectors
            struct.pack_into("<I", self.data, i * 4, self.toc[i])

        self.data[end_offset:end_offset] = b"\x00" * diff_bytes

    def write(self):
        with open(self.path, "wb") as f:
            f.write(self.data)

def translate(build_dir):
    DATA_BIN = os.path.join(build_dir, "ULJM05066", "DATA.BIN")
    if not os.path.exists(DATA_BIN):
        return
        
    EBOOT_BIN = os.path.join(build_dir, "ULJM05066", "EBOOT.BIN")
    if not os.path.exists(EBOOT_BIN):
        return
        
    subprocess.run(
        [armips, os.path.join("translation", "asm", "eboot_bin.asm")],
        check=True
    )       

    injector = Injector(DATA_BIN)

    injector.buildASM(build_dir, 44, "demo_task")
    injector.buildASM(build_dir, 49, "gallery_task")
    injector.buildASM(build_dir, 51, "lobby_task")
    injector.buildASM(build_dir, 54, "arcade_task")
        
    path = os.path.join("translation", "data")
    
    build_0003(os.path.join("translation", "text", "0003.txt"), os.path.join(path, "0003"))
    
    if os.path.exists(path):
        files = sorted(os.listdir(path))
        for f in files:
            if f.isdigit():
                print(f"Injecting file {f} into ULJM05066 DATA.BIN...")
                injector.replace(int(f), os.path.join(path, f))

    injector.write()
