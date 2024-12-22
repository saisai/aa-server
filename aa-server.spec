# -*- mode: python -*-
# vi: set ft=python :

import os

import aa_core
import flask_restx

aa_core_path = os.path.dirname(aa_core.__file__)
restx_path = os.path.dirname(flask_restx.__file__)

name = "aa-server"
block_cipher = None


a = Analysis(
    ["__main__.py"],
    pathex=[],
    binaries=None,
    datas=[
        (os.path.join(restx_path, "templates"), "flask_restx/templates"),
        (os.path.join(restx_path, "static"), "flask_restx/static"),
        (os.path.join(aa_core_path, "schemas"), "aa_core/schemas"),
    ],
    hiddenimports=[],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)
exe = EXE(
    pyz,
    a.scripts,
    exclude_binaries=True,
    name=name,
    contents_directory=".",
    debug=False,
    strip=False,
    upx=True,
    console=True,
)
coll = COLLECT(
    exe, a.binaries, a.zipfiles, a.datas, strip=False, upx=True, name="aa-server"
)
