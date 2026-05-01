#------------------------------------------------------------
VERSION = "v1.8.1d"
ENGLISH_PATCH = 1
QUESTS_LANG = "EN"
VANILLA_MODE = 0
#------------------------------------------------------------
import os
import io
import re
import shutil
import pycdlib
import subprocess
from sys import platform
from tools.setup_linux import *
from PIL import Image, ImageDraw, ImageFont
from translation.translate import translate, Injector
#------------------------------------------------------------
iso_dir = "iso"
asm_src_dir = "source"
build_dir = "build"
assets = "assets"
quests_dir = "quests"
#------------------------------------------------------------
armips = os.path.join("tools", "armips.exe")
umd_replace = os.path.join("tools", "UMD-replace.exe")
xdelta = os.path.join("tools", "xdelta.exe")
mhff = os.path.join("tools", "mhff", "psp", "data.py")
mhtools = os.path.join("tools", "mhtools.jar")
#------------------------------------------------------------
if not os.path.exists(mhff):
    installMHFF()
if not os.path.exists(mhtools):
    installMHTools()

if platform == "linux" or platform == "linux2":
    armips = os.path.join("tools", "armips", "build", "armips")
    umd_replace = os.path.join("tools", "UMD-replace")
    xdelta = "xdelta3"
    if not os.path.exists(armips):
        installArmips()
    if not os.path.exists(umd_replace):
        installUMDReplace()
        
games = []

def createFolder(folder):
    if os.path.exists(folder):
        shutil.rmtree(folder)
    os.makedirs(folder, exist_ok=True)

def combineQuests():
    print("Building EVENT.BIN...")
    quests = os.path.join(quests_dir, QUESTS_LANG)
    mib_files = sorted([f for f in os.listdir(quests) if f.lower().endswith(".mib")])
    quest_size = 0x6800
    
    id = 60001;
    output = os.path.join(build_dir, "FDXDAT", "EVENT.BIN")
    with open(output, 'wb') as fp:
        for f in mib_files:
            quest = os.path.join(quests, f)
            with open(quest, "rb") as q:
                data = bytearray(q.read())
                size = len(data)
                
                if(size < quest_size):
                    data += b"\x00" * (quest_size - size)
                elif(size > quest_size):
                    data = data[:quest_size]
                data[0x5A:0x5C] = id.to_bytes(2, byteorder="little")
                fp.write(data)
            id += 1
def fixF1Quests():     
    if VANILLA_MODE: return
    if "ULJM05066" in games:
        if(ENGLISH_PATCH):
            quests = os.path.join(quests_dir, "FreedomExclusive", "EN")
        else:
            quests = os.path.join(quests_dir, "FreedomExclusive", "JP")
        mib_files = sorted([f for f in os.listdir(quests) if f.lower().endswith(".mib")])
        quest_size = 0x3000
        
        id = 1021;
        output = os.path.join(build_dir, "ULJM05066", "4912")
        with open(output, 'wb') as fp:
            for f in mib_files:
                quest = os.path.join(quests, f)
                with open(quest, "rb") as q:
                    data = bytearray(q.read())
                    size = len(data)
                    
                    if(size < quest_size):
                        data += b"\x00" * (quest_size - size)
                    elif(size > quest_size):
                        data = data[:quest_size]
                    data[0x5A:0x5C] = id.to_bytes(2, byteorder="little")
                    fp.write(data)
                
        injector = Injector(os.path.join(build_dir, "ULJM05066", "DATA.BIN"))
        injector.replace(4912, os.path.join(output))
        injector.write()
        os.remove(output)

def setASMOffset(path, asm, n, value):
    asm_path = os.path.join(path, asm)
    with open(asm_path, "r", encoding="utf-8") as fp:
        lines = fp.readlines()
        
    for i, line in enumerate(lines):
        if(i == n):
            lines[i] = value
            break
    
    with open(asm_path, "w", encoding="utf-8") as fp:
        fp.writelines(lines)

def buildASM():
    if VANILLA_MODE: return
    for folder in games:
        print(f"Building ASM for {folder}.iso...")
        path = os.path.join(asm_src_dir, folder)
        if(folder == "ULJM05066" and ENGLISH_PATCH):
            setASMOffset(path, "EventLoader.asm", 0, "SLOT_1\t\t\tequ 0x095079E0 ; EN\n")
        elif(folder == "ULJM05066" and not ENGLISH_PATCH):
            setASMOffset(path, "EventLoader.asm", 0, "SLOT_1\t\t\tequ 0x094F31E0 ; JP\n")

        subprocess.run(
            [armips, os.path.join(path, "main.asm")],
            check=True
        )

def createPatches():
    for folder in games:
        print(f"Creating xdelta patch for {folder}.iso...")
        unmodified = os.path.join(iso_dir, f"{folder}.iso")
        modified = os.path.join(build_dir, folder, f"{folder}.iso")
        patch = os.path.join(build_dir, folder, f"{folder}.xdelta")
        subprocess.run(
            [xdelta, "-e", "-s", unmodified, modified, patch],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )

def patchISOs():
    for folder in games:
        iso = os.path.join(build_dir, folder, f"{folder}.iso")
        print(f"Patching DATA.BIN for {folder}.iso...")
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/USRDIR/DATA.BIN", os.path.join(build_dir, folder, "DATA.BIN")],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        print(f"Patching EBOOT.BIN for {folder}.iso...")
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/SYSDIR/EBOOT.BIN", os.path.join(build_dir, folder, "EBOOT.BIN")],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        print(f"Patching PARAM.SFO for {folder}.iso...")
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/PARAM.SFO", os.path.join(build_dir, folder, "PARAM.SFO")],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        os.remove(os.path.join(build_dir, folder, "PARAM.SFO"))
        if not VANILLA_MODE:
            thumb = os.path.join(assets, "ICON0.PNG")
        else:
            thumb = os.path.join(assets, "VANILLA.PNG")
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/ICON0.PNG", thumb],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        PIC0 = os.path.join(assets, "PIC0.PNG")
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/PIC0.PNG", PIC0],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )

def addImage(folder, files, old_img, new_img, text=""):
    print(f"Replacing {new_img} image for {folder}.iso...")
    path = os.path.join(build_dir, folder, "DATA.BIN")
    for file in files:
        old_tmh = os.path.join(build_dir, folder, f"{file}.tmh")
        new_tmh = os.path.join(build_dir, folder, f"{file}_modified.tmh")
        subprocess.run(
            ["python", mhff, "x", path, file, old_tmh],
            check=True
        )
        subprocess.run(
            ["java", "-jar", mhtools, "--extract", old_tmh, "5"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )

        RBGA8888 = os.path.join(build_dir, folder, file, old_img)
        shutil.copy(os.path.join(assets, new_img), RBGA8888)
        
        if text:
            img = Image.open(RBGA8888).convert("RGBA")
            overlay = Image.new("RGBA", img.size, (255, 255, 255, 0))
            draw = ImageDraw.Draw(overlay)
            
            font = ImageFont.truetype(os.path.join(assets, "MyriadPro-Bold.otf"), 20)
            
            draw.text((350,215), f"{VERSION}", (255, 255, 255), font=font)
            img = Image.alpha_composite(img, overlay)
            img = img.convert("P", palette=Image.ADAPTIVE, colors=256)
            img.save(RBGA8888)
        
        subprocess.run(
            ["java", "-jar", mhtools, "--rebuild", os.path.join(build_dir, folder, file), "5"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        shutil.rmtree(os.path.join(build_dir, folder, file))
        shutil.move(f"{file}.tmh", new_tmh)
        
        with open(path, "rb") as fp:
            data = fp.read()
        with open(old_tmh, "rb") as fp:
            og_tmh_data = fp.read()
        with open(new_tmh, "rb") as fp:
            new_tmh_data = fp.read()
        matches = [m.start() for m in re.finditer(re.escape(og_tmh_data), data)]
        with open(path, "r+b") as fp:
            for offset in matches:
                fp.seek(offset)
                fp.write(b"\x00" * len(og_tmh_data))
                fp.seek(offset)
                fp.write(new_tmh_data)
        os.remove(old_tmh)
        os.remove(new_tmh)

def addImages():
    if VANILLA_MODE:
        return
    for folder in os.listdir(build_dir):
        if folder == "ULJM05066":
            addImage(folder, ["0013"], "001_palette_RGBA8888.png", "Title.png", VERSION)
            addImage(folder, ["0014"], "001_palette_RGBA8888.png", os.path.join("sharpness_fix", "EN.png"))
            addImage(folder, ["4923"], "000_pixels_RGBA8888.png", os.path.join("ui_fix", "000_pixels_RGBA8888.png"))
        elif folder == "ULUS10084":
            addImage(folder, ["0013"], "001_palette_RGBA8888.png", "Title.png", VERSION)
            addImage(folder, ["0014"], "001_palette_RGBA8888.png", os.path.join("sharpness_fix", "EN.png"))
            addImage(folder, ["4930"], "000_pixels_RGBA8888.png", os.path.join("ui_fix", "000_pixels_RGBA8888.png"))
        elif folder == "ULES00318":
            addImage(folder, ["0017", "0022", "0023", "0024", "0025", "0026"], "001_palette_RGBA8888.png", "Title.png", VERSION)
            addImage(folder, ["0018"], "001_palette_RGBA8888.png", os.path.join("sharpness_fix", "EN.png"))
            addImage(folder, ["0027"], "001_palette_RGBA8888.png", os.path.join("sharpness_fix", "FR.png"))
            addImage(folder, ["0028"], "001_palette_RGBA8888.png", os.path.join("sharpness_fix", "DE.png"))
            addImage(folder, ["0029"], "001_palette_RGBA8888.png", os.path.join("sharpness_fix", "IT.png"))
            addImage(folder, ["0030"], "001_palette_RGBA8888.png", os.path.join("sharpness_fix", "ES.png"))
            addImage(folder, ["4959"], "000_pixels_RGBA8888.png", os.path.join("ui_fix", "000_pixels_RGBA8888.png"))

def setParamInfo():
    for folder in os.listdir(build_dir):
        path = os.path.join(build_dir, folder, "PARAM.SFO")
        if folder == "ULJM05066" or folder == "ULUS10084" or folder == "ULES00318":
            with open(path, "r+b") as fp:
                print(f"Setting PARAM.SFO info for {folder}.iso...")
                fp.seek(0x158)
                if not VANILLA_MODE:
                    fp.write(f"MONSTER HUNTER FREEDOM DX {VERSION}".encode("ascii").ljust(40, b"\x00"))
                else:
                    fp.write(f"MONSTER HUNTER FREEDOM".encode("ascii").ljust(40, b"\x00")) 
 
def extractData():
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
            createFolder(dir)
            print(f"Extracting DATA.BIN from {file}...")
            with open(os.path.join(dir, "DATA.BIN"), "wb") as data_bin:
                iso.get_file_from_iso_fp(data_bin, iso_path="/PSP_GAME/USRDIR/DATA.BIN")
            print(f"Extracting BOOT.BIN from {file}...")
            with open(os.path.join(dir, "BOOT.BIN"), "wb") as boot_bin:
                iso.get_file_from_iso_fp(boot_bin, iso_path="/PSP_GAME/SYSDIR/BOOT.BIN")
            print(f"Extracting PARAM.SFO from {file}...")
            with open(os.path.join(dir, "PARAM.SFO"), "wb") as param_sfo:
                iso.get_file_from_iso_fp(param_sfo, iso_path="/PSP_GAME/PARAM.SFO")
            iso.close()
            shutil.copyfile(os.path.join(iso_dir, file), os.path.join(build_dir, game_id, f"{game_id}.iso"))
            os.rename(os.path.join(iso_dir, file), os.path.join(iso_dir, f"{game_id}.iso"))
            os.rename(os.path.join(dir, "BOOT.BIN"), os.path.join(dir, "EBOOT.BIN"))
            
            games.append(game_id)
 
if __name__ == "__main__":
    createFolder(build_dir)
    
    shutil.copytree(os.path.join(assets, "FDXDAT"), os.path.join(build_dir, "FDXDAT"))
    extractData()
    setParamInfo()
    buildASM()
    if "ULJM05066" in games and ENGLISH_PATCH:
        translate(build_dir)
    addImages()
    fixF1Quests()
    patchISOs()
    createPatches()
    combineQuests()
        
    print("Done!")
