# Development Notes

Quick reference for building VSBHDA.

* 32-bit build with Open Watcom:
  ```bash
  ./build.sh ow
  ```
* 16-bit build with Open Watcom:
  ```bash
  ./build.sh ow16
  ```
* Build with the DJGPP makefile using a cross compiler (downloads tools if needed):
  ```bash
  ./build.sh cross
  ```

The script detects missing dependencies such as Open Watcom or the DJGPP toolchain and fetches them automatically. See `README.md` for full details.
