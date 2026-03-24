# Emacs Configuration
This is a repository of my Emacs configuration settings. It includes static analysis for C, C++, CUDA, Python, (System)Verilog, VHDL.

### Usage
to create a new python project, run the command `M-x my-python-project-init`. This will create and initialise a virtual environment and open a new terminal window within emacs in which you can install dependencies or run scripts

### Setup
The following dependeices are required to be installed and added to `PATH`:

- [clangd](https://github.com/llvm/llvm-project) (for C, C++ & CUDA support)
- [verible-verilog-ls](https://github.com/chipsalliance/verible) (for (System)Verilog)
- [VHDL_LS](https://github.com/VHDL-LS/rust_hdl) (for VHDL support)

Note: color themes may need to be installed through the package manager
