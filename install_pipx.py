#!/usr/bin/env python3
import subprocess as sp
import tempfile as tmp
import venv


def main():
    with tmp.TemporaryDirectory() as tmpdir:
        venv.create(tmpdir, with_pip=True)
        sp.run([f"{tmpdir}/bin/pip", "install", "pipx"],
               stdout=sp.DEVNULL, stderr=sp.DEVNULL)
        sp.run([f"{tmpdir}/bin/pipx", "install", "pipx"])


if __name__ == "__main__":
    main()
