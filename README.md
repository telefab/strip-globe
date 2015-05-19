LED strip-based, FPGA-powered POV globe
===

Documentation
---

Documentation is [available on Instructables](http://www.instructables.com/id/Globe-of-persistence-of-vision/).

Source structure
---

* `app_sources`: sources of programs running on the globe
* `board`: power board Eagle model
* `fpga_sources`: VHDL files for the FPGA
* `Solidworks`: model for the physical design
* `zybo_project`: integration on the Zybo board. The Vivado project references the `fpga_sources` files
