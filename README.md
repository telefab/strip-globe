FPGA-powered POV globe
===

Source structure
---

* `board`: power board Eagle model
* `fpga_sources`: VHDL files for the FPGA
* `Solidworks`: model for the physical design
* `zybo_project`: integration on the Zybo board. The Vivado project references the `fpga_sources` files
