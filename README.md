# focused_slam
This is the simulation code for "Two-Stage Focused Inference for Resource-Constrained Collision-Free Navigation". See bib reference below:

 @Inproceedings{Mu_RSS_15, 
  	Author    = {B. Mu AND A. Agha-mohammadi AND L. Paull AND M. Graham AND J. How AND J. Leonard}, 
	Title     = {Two-Stage Focused Inference for Resource-Constrained Collision-Free Navigation}, 
	Booktitle = {Robotics Science and Systems}, 
	Year      = {2015}, 
	Address   = {Rome, Italy}, 
	Month     = {July} 
}

## iSAM library
Folder isam contains the modified isam library to optimize pose graphs. There are pre-compiled executable file isam and sparse_graph_glc under the bin folder
To compile from source, following the commands on ubuntu:
cd isam
mkdir build && cd build && cmake ..
make
Fore more details about the library, refer to readme file under isam folder.

## two-stage selection script
Folder focused_mapping contains matlab scripts of our two-stage selection algorithms as well as compared algorithms. The main script is main_simulate.m.


Data is contained in focused_mapping/data subfoler
