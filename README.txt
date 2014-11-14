Running guidelines:

This program is a c++ compiled program. To run correctly this program, you need the following dll:
1. hdf5.dll
2. szip.dll
3. zlib.dll
and the most important
4. libmatio.dll
This libmatio.dll is used to read and write .Mat file format.
Normally, this dll should work for different platforms (WIN7 64, X84), but in case of 
errors, you will have to build it yourself.
To build this libmatio.dll correctly, you will have to refer to the matio-1.5.2 visual studio project
and you will have HDF_1.8.12 installed.

First, set up a system variable "HDF5_DIR" pointed to your HDF5_1.8.12 directory.
Then open the matio-1.5.2 visual studio project and click build, you will have your own-built 
libmatio.dll in visual_studio/x64 directory.

Then you can cope this libmatio.dll to the same directory than you put your IRSIMIT.exe.
and at this point, you should be able to run this program correctly.


Setup files for IRSIMIT.exe:
The setup files for IRSIMIT.exe should follow a few regulations to run it correctly.
The name for the variables should be as follows:

....
....
....
....


