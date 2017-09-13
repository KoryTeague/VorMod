# VorMod
Voronoi Model

Voronoi CPlex and Matlab model for virtualized wireless networks.

CPlex model solves an optimization problem for allocating resources within a set of physical networks to a virtual network and slices those resources to the end users of the newly created virtual network.  This solution is considered optimal for the entire question.  This is currently a 2-stage optimization problem.
Matlab model is an approximation of the CPlex optimization problem.  Instead of a two-stage optimization problem, the MATLAB model only solves the first stage of allocating resources within the VNB to the VWN being created.
After resources are allocated (the first stage), the created network is then passed through a simplified version of the CPlex model which only solves the second stage.
