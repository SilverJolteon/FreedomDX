import struct
import array
import os

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
        
    with open(EBOOT_BIN, "r+b") as fp:
        fp.seek(0x10F388)
        fp.write(bytes([0x78, 0x00, 0x70, 0x00, 0x78]))   

    injector = Injector(DATA_BIN)

    injector.memcpy(0x1A6A3FE8, [0x02, 0x00, 0x06, 0x3C]) # 4959 memsize
    injector.memcpy(0x1A6A40E4, [0x00, 0xD8, 0x46, 0x34]) # 4673 memsize
    injector.memcpy(0x1A6396D0, [0x1A, 0x00, 0x05, 0x34]) # Press Start Position
    injector.memcpy(0x1A639D04, [0x28, 0x00, 0x05, 0x34, 0x38, 0xC5, 0x21, 0x0E, 0x14, 0x00, 0x06, 0x34]) # Title Menu Position
        
    path = os.path.join("translation", "data")
    if os.path.exists(path):
        files = sorted(os.listdir(path))
        for f in files:
            if f.isdigit():
                print(f"Injecting file {f} into ULJM05066 DATA.BIN...")
                injector.replace(int(f), os.path.join(path, f))

    injector.write()