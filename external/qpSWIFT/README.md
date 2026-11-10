# qpSWIFT (bundled)

qpSWIFT is a lightweight interior-point QP solver by Abhishek Pandala,
Yanran Ding and Hae Won Park, licensed under **GPL-3.0** (see `LICENSE.txt`).
Upstream: https://github.com/qpSWIFT/qpSWIFT

This folder contains the unmodified MATLAB interface and prebuilt MEX binaries
used to produce the paper's results (files dated March 2023; the exact upstream
release was not recorded):

- `qpSWIFT.mexa64`    - Linux x86-64
- `qpSWIFT.mexw64`    - Windows x86-64
- `qpSWIFT.mexmaci64` - macOS Intel (not native on Apple Silicon)

If none of these binaries work on your system, build the MATLAB interface
from the upstream repository and put it on the MATLAB path instead.

The rest of this repository is MIT-licensed; qpSWIFT keeps its own GPL-3.0
license.
