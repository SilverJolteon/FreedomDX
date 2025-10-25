import os
import io
import re
import shutil
import pycdlib
import subprocess

VERSION = "v1.3.1"

iso_dir = "iso"
asm_src_dir = "source"
build_dir = "build"
assets = "assets"
armips = os.path.join("tools", "armips.exe")
umd_replace = os.path.join("tools", "UMD-replace.exe")
xdelta = os.path.join("tools", "xdelta.exe")
mhff = os.path.join("tools", "mhff", "psp", "data.py")
mhtools = os.path.join("tools", "mhtools.jar")
pspdecrypt = os.path.join("tools", "pspdecrypt.exe")

def patchDB(folder):
    patch = os.path.join(asm_src_dir, folder, "Enhanced.xdelta")
    unmodified = os.path.join(build_dir, folder,  "DATA.BIN")
    modified = os.path.join(build_dir, folder, "DATA.BIN_patched")
    subprocess.run(
        [xdelta, "-d", "-s", unmodified, patch, modified],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.STDOUT
    )
    os.remove(unmodified)
    os.rename(modified, unmodified)

def buildASM():
    for folder in os.listdir(build_dir):
        path = os.path.join(asm_src_dir, folder)
        subprocess.run(
            [armips, os.path.join(path, "main.asm"), "-temp", os.path.join(path, "log.txt")],
            check=True
        )

def creatPatches():
    for folder in os.listdir(build_dir):
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
    for folder in os.listdir(build_dir):
        iso = os.path.join(build_dir, folder, f"{folder}.iso")
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/USRDIR/DATA.BIN", os.path.join(build_dir, folder, "DATA.BIN")],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        #os.remove(os.path.join(build_dir, folder, "DATA.BIN"))
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/SYSDIR/EBOOT.BIN", os.path.join(build_dir, folder, "EBOOT.BIN")],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        #os.remove(os.path.join(build_dir, folder, "EBOOT.BIN"))
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/PARAM.SFO", os.path.join(build_dir, folder, "PARAM.SFO")],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        os.remove(os.path.join(build_dir, folder, "PARAM.SFO"))
        if folder == "ULJM05066":
            thumb = os.path.join(assets, "PortableDXThumb.png")
        else:
            thumb = os.path.join(assets, "FreedomDXThumb.png")
        subprocess.run(
            [umd_replace, iso, "/PSP_GAME/ICON0.PNG", thumb],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )



def addImage(folder, files, image):
    path = os.path.join(build_dir, folder, "DATA.BIN")
    patched = 0
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
        shutil.copy(os.path.join(assets, image), os.path.join(build_dir, folder, file, "001_palette_RGBA8888.png"))
        subprocess.run(
            ["java", "-jar", mhtools, "--rebuild", os.path.join(build_dir, folder, file), "5"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )
        shutil.rmtree(os.path.join(build_dir, folder, file))
        shutil.move(f"{file}.tmh", new_tmh)
        
        
        if not patched:
            patchDB(folder)
            patched = 1
        
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
    for folder in os.listdir(build_dir):
        if folder == "ULJM05066":
            addImage(folder, ["0013"], "PortableDXTitle.png")
        elif folder == "ULUS10084":
            addImage(folder, ["0013"], "FreedomDXTitle.png")
        elif folder == "ULES00318":
            addImage(folder, ["0017", "0022", "0023", "0024", "0025", "0026"], "FreedomDXTitle.png")
            

def setParamInfo():
    for folder in os.listdir(build_dir):
        path = os.path.join(build_dir, folder, "PARAM.SFO")
        if folder == "ULJM05066":
            with open(path, "r+b") as fp:
                fp.seek(0x158)
                fp.write(f"MONSTER HUNTER PORTABLE DX {VERSION}".encode("ascii").ljust(40, b"\x00")) 
        elif folder == "ULUS10084" or folder == "ULES00318":
            with open(path, "r+b") as fp:
                fp.seek(0x158)
                fp.write(f"MONSTER HUNTER FREEDOM DX {VERSION}".encode("ascii").ljust(40, b"\x00")) 
 
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
            if os.path.exists(dir):
                shutil.rmtree(dir)
            os.makedirs(dir, exist_ok=True)
            print(f"Extracting DATA.BIN from {file}...")
            with open(os.path.join(dir, "DATA.BIN"), "wb") as data_bin:
                iso.get_file_from_iso_fp(data_bin, iso_path="/PSP_GAME/USRDIR/DATA.BIN")
            print(f"Extracting EBOOT.BIN from {file}...")
            with open(os.path.join(dir, "EBOOT.BIN"), "wb") as eboot_bin:
                iso.get_file_from_iso_fp(eboot_bin, iso_path="/PSP_GAME/SYSDIR/EBOOT.BIN")
            print(f"Extracting PARAM.SFO from {file}...")
            with open(os.path.join(dir, "PARAM.SFO"), "wb") as param_sfo:
                iso.get_file_from_iso_fp(param_sfo, iso_path="/PSP_GAME/PARAM.SFO")
            iso.close()
            shutil.copyfile(os.path.join(iso_dir, file), os.path.join(build_dir, game_id, f"{game_id}.iso"))
            os.rename(os.path.join(iso_dir, file), os.path.join(iso_dir, f"{game_id}.iso"))
            print("Decrypting EBOOT.BIN...")
            subprocess.run(
                [pspdecrypt, os.path.join(dir, "EBOOT.BIN")],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.STDOUT
            )
            os.remove(os.path.join(dir, "EBOOT.BIN"))
            os.rename(os.path.join(dir, "EBOOT.BIN.dec"), os.path.join(dir, "EBOOT.BIN"))
 
if __name__ == "__main__":
    if os.path.exists(build_dir):
        shutil.rmtree(build_dir)
    os.makedirs(build_dir, exist_ok=True)
    
    extractData()
    setParamInfo()
    addImages()
    buildASM()
    patchISOs()
    creatPatches()