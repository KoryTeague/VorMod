Consider these instructions:
http://www.leandro-coelho.com/how-to-configure-ms-visual-studio-to-use-ibm-cplex-concert/

This will include installing the base C++ library for visual studio to use for compilation.
All .exes made from visual studio will require the primary cplex*.dll (currently cplex1271.dll) to run; this .dll is provided alongside the .exes where they might be executed.
This requirement may be unneccessary if the cplex C++ library is installed on the computer running the CPLEX based .exe.

Further, the project settings for the two projects (CP_Vormod, the two-stage optimization problem; and CP_Vormod_St2, the second-stage only optimization problem for evaluating the MATLAB approximation and CPLEX optimization results with new datasets) are also provided within this folder.
This might aid in preparing new installs of the visual studio or future projects using the library.