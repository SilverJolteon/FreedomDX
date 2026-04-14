import os
import shutil
import requests
import subprocess

def createFolder(folder):
    if os.path.exists(folder):
        shutil.rmtree(folder)
    os.makedirs(folder, exist_ok=True)

def installArmips():
    armips_dir = os.path.join("tools", "armips")
    armips_build_dir = os.path.join(armips_dir, "build")
    armips = os.path.join(armips_build_dir, "armips")
        
    if not os.path.exists(armips_dir):
        subprocess.run(
            ["git", "clone", "--recursive", "https://github.com/Kingcom/armips.git", armips_dir],
            check=True
        )

    createFolder(armips_build_dir)
    subprocess.run(
        ["cmake", "-DCMAKE_BUILD_TYPE=Release", ".." ],
        cwd=armips_build_dir,
        check=True
    )
    subprocess.run(
        ["cmake", "--build", "."],
        cwd=armips_build_dir,
        check=True
    )   

def installMHFF():
    mhff_dir = os.path.join("tools", "mhff")
        
    if not os.path.exists(mhff_dir):
        subprocess.run(
            ["git", "clone", "https://github.com/svanheulen/mhff.git", mhff_dir],
            check=True
        )
    
def installMHTools():
    mhtools_dir = os.path.join("tools", "mhtools.jar")
    if not os.path.exists(mhtools_dir):
        with requests.get("https://github.com/codestation/mhtools/releases/download/v1.0/mhtools.jar") as r:
            if r.status_code == 200:
                with open(mhtools_dir, "wb") as f:
                    f.write(r.content)

def installUMDReplace():
    umd_replace_dir = os.path.join("tools", "src")
    umd_replace = os.path.join("tools", "UMD-replace")
    subprocess.run(
        ["gcc", os.path.join(umd_replace_dir, "UMD-replace.c"), "-Wno-implicit-function-declaration", "-o", umd_replace],
        check=True
    )
