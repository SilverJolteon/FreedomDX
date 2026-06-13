import os
import io
import shutil
import pycdlib
import subprocess

#iso_dir = os.path.join("..", "build", "ULJM05066")
iso_dir = os.path.join("..", "iso")
mhff = os.path.join("..", "tools", "mhff", "psp", "data.py")
build_dir = "dumped_text"

newline = "<NEWLINE>"
new_section = "<NEW SECTION>"


data = {
    "ULJM05066": {
        "0003": ["general", 1],
        "4672": ["game0", 1],
        "4673": ["game1", 1],
        "4958": ["tavern", 3],
        "4959": ["kokoto", 3],
        "4960": ["farm", 3],
        "4961": ["kitchen", 3]
    },
    "ULUS10084": {
        "0003": ["general", 1],
        "4672": ["game0", 1],
        "4673": ["game1", 1],
        "4965": ["tavern", 3],
        "4966": ["kokoto", 3],
        "4967": ["farm", 3],
        "4968": ["kitchen", 3]
    },
    "ULES00318": {
        "0003": [os.path.join("EN", "general"), 1],
        "0004": [os.path.join("FR", "general"), 1],
        "0005": [os.path.join("DE", "general"), 1],
        "0006": [os.path.join("IT", "general"), 1],
        "0007": [os.path.join("ES", "general"), 1], 
        "4693": [os.path.join("EN", "game0"), 1],
        "4694": [os.path.join("FR", "game0"), 1],
        "4695": [os.path.join("DE", "game0"), 1],
        "4696": [os.path.join("IT", "game0"), 1],
        "4697": [os.path.join("ES", "game0"), 1],
        "4698": [os.path.join("EN", "game1"), 1],
        "4699": [os.path.join("FR", "game1"), 1],
        "4700": [os.path.join("DE", "game1"), 1],
        "4701": [os.path.join("IT", "game1"), 1],
        "4702": [os.path.join("ES", "game1"), 1],
        "4994": [os.path.join("EN", "tavern"), 3],
        "4995": [os.path.join("FR", "tavern"), 3],
        "4996": [os.path.join("DE", "tavern"), 3],
        "4997": [os.path.join("IT", "tavern"), 3],
        "4998": [os.path.join("ES", "tavern"), 3],
        "4999": [os.path.join("EN", "kokoto"), 3],
        "5000": [os.path.join("FR", "kokoto"), 3],
        "5001": [os.path.join("DE", "kokoto"), 3],
        "5002": [os.path.join("IT", "kokoto"), 3],
        "5003": [os.path.join("ES", "kokoto"), 3],
        "5004": [os.path.join("EN", "farm"), 3],
        "5005": [os.path.join("FR", "farm"), 3],
        "5006": [os.path.join("DE", "farm"), 3],
        "5007": [os.path.join("IT", "farm"), 3],
        "5008": [os.path.join("ES", "farm"), 3],
        "5009": [os.path.join("EN", "kitchen"), 3],
        "5010": [os.path.join("FR", "kitchen"), 3],
        "5011": [os.path.join("DE", "kitchen"), 3],
        "5012": [os.path.join("IT", "kitchen"), 3],
        "5013": [os.path.join("ES", "kitchen"), 3],
    }
}

# Quests
'''
for i in range(4674, 4914):
    data["ULJM05066"][f"{i}"] = ["quest", 2, 0x54]
    
for i in range(4674, 4921):
    data["ULUS10084"][f"{i}"] = ["quest", 2, 0x54]
    
for i in range(4703, 4950):
    data["ULES00318"][f"{i}"] = ["quest", 2, 0x54]
'''
        
def getString(data, addr, encoding):
    return data[addr:data.find(b"\x00", addr)].decode(encoding)
    
def getOffset(data, addr):
    return int.from_bytes(data[addr:addr+4], byteorder="little", signed=False)
    
def dumpQuestText(key, folder, path, start, encoding):
    lang = 0
    doLang = 1
    while(doLang and lang < 6):
        if(folder == "ULES00318"):
            if(lang == 0):
                lang += 1
            npath = os.path.join(build_dir, folder, ["", "EN", "DE", "FR", "ES", "IT"][lang], path)
        else:
            npath = os.path.join(build_dir, folder, path)
        
        output = os.path.join(npath, key)+".txt"
        input = os.path.join(build_dir, folder, key)
        
        os.makedirs(os.path.dirname(output), exist_ok=True)
        print(f"Dumping strings to \"{output}\"...");
        with open(input, "rb") as fp:
            data = fp.read()
            with open(output, "w", encoding="utf-8") as out:
                langOff = int.from_bytes(data[start:start+4], byteorder="little", signed=False)
                off = int.from_bytes(data[langOff+4*lang:langOff+4*lang+4], byteorder="little", signed=False)
                for i in range(4):
                    stringOff = int.from_bytes(data[off+4*i:off+4*i+4], byteorder="little", signed=False)
                    str = getString(data, stringOff, encoding)
                    out.write(str.replace("\n", newline)+"\n")

        if(folder == "ULES00318"):
            lang += 1
        else:
            doLang = 0
        shutil.copyfile(input, os.path.join(npath, key))
    os.remove(input)

def dumpNPCText(key, folder, path, encoding):
    input = os.path.join(build_dir, folder, key)
    
    os.makedirs(path, exist_ok=True)
    
    print(f"Dumping strings to \"{path}\"...");
    with open(input, "rb") as fp:
        header_data = []
        data = fp.read()
        h_off = 0
        while(1):
            sec_id = getOffset(data, h_off)
            sec_off = getOffset(data, h_off+4)
            if(sec_id == 0xFFFFFFFF and sec_off == 0xFFFFFFFF):
                break;
            header_data.append([sec_id, sec_off])
            h_off += 8
            
        for i, section in enumerate(header_data):
            with open(os.path.join(path, f"string_table_{i}_{section[0]}.txt"), "w", encoding=encoding) as out:
                sec_start = section[1]
                
                s_off = getOffset(data, sec_start+4)
                
                sec_off = sec_start
                while(sec_off < sec_start + s_off):
                    str_id = getOffset(data, sec_off)
                    str_off = getOffset(data, sec_off+4)
                    str = f"{str_id}," + getString(data, sec_start+str_off, encoding).replace("\n", newline)
                    sec_off += 8
                    if(sec_off+4 < sec_start + s_off):
                        str += "\n"
                    out.write(str)
                    
    shutil.copyfile(input, os.path.join(path, key))
    os.remove(input)
    
def dumpGameText(key, folder, path, encoding):
    input = os.path.join(build_dir, folder, key)
    
    os.makedirs(path, exist_ok=True)
    
    print(f"Dumping strings to \"{path}\"...");
    with open(input, "rb") as fp:
        header_data = []
        data = fp.read()
        sec_size = getOffset(data, 0)
       
        for i in range(8, sec_size * 4 + 8, 4):
            sec_off = getOffset(data, i)
            header_data.append(sec_off)
            
        for i, section in enumerate(header_data):
            with open(os.path.join(path, f"string_table_{i}.txt"), "w", encoding=encoding) as out:
                sec_start = section
                
                s_off = getOffset(data, sec_start)
                
                sec_off = sec_start
                while(sec_off < sec_start + s_off):
                    str_off = getOffset(data, sec_off)
                    str = getString(data, sec_start+str_off, encoding).replace("\n", newline)
                    sec_off += 4
                    if(sec_off+4 < sec_start + s_off):
                        str += "\n"
                    out.write(str)
                    
    shutil.copyfile(input, os.path.join(path, key))
    os.remove(input)
        

def extractFiles(folder):
    path = os.path.join(build_dir, folder, "DATA.BIN")
    encoding = ""
    if(folder == "ULJM05066" or folder == "ULUS10084"): encoding = "shift_jis_2004"
    else: encoding = "utf-8"
    for key, value in data[folder].items():
        print(f"Extracting file \"{key}\" from {folder}.iso...");
        file = os.path.join(build_dir, folder, key)
        subprocess.run(
            ["python", mhff, "x", path, key, file],
            check=True
        )
        if(value[1] == 1):
            dumpGameText(key, folder, os.path.join(build_dir, folder, value[0]), encoding);
        if(value[1] == 3):
            dumpNPCText(key, folder, os.path.join(build_dir, folder, value[0]), encoding);
        if(value[1] == 2):
            dumpQuestText(key, folder, value[0], value[2], encoding);

    os.remove(path)

def extractDataBin():
    for _, _, files in os.walk(iso_dir):
        for file in files:
            if not file.endswith(".iso"):
               continue
            iso = pycdlib.PyCdlib()
            iso.open(os.path.join(iso_dir, file))
            param = io.BytesIO()
            iso.get_file_from_iso_fp(param, iso_path="/PSP_GAME/PARAM.SFO")
            param.seek(0x128)
            game_id = param.read(0x0A)
            game_id = game_id.split(b"\x00", 1)[0].decode("utf-8")
            if not (game_id == "ULUS10084" or game_id == "ULES00318" or game_id == "ULJM05066"):
                continue
            dir = os.path.join(build_dir, game_id)
            if os.path.exists(dir):
                shutil.rmtree(dir)
            os.makedirs(dir, exist_ok=True)
            print(f"Extracting DATA.BIN from {file}...")
            with open(os.path.join(dir, "DATA.BIN"), "wb") as data_bin:
                iso.get_file_from_iso_fp(data_bin, iso_path="/PSP_GAME/USRDIR/DATA.BIN")
            iso.close()

if __name__ == "__main__":
    if os.path.exists(build_dir):
        shutil.rmtree(build_dir)
    os.makedirs(build_dir, exist_ok=True)
    
    extractDataBin()
    for folder in os.listdir(build_dir):
        extractFiles(folder)
    
    print("\nDone!")