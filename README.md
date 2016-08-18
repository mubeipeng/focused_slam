# focused_slam
This is the simulation code for "Two-Stage Focused Inference for Resource-Constrained Collision-Free Navigation". See bib reference below:

 @inproceedings{Mu_RSS_15, 
  	Author    = {B. Mu AND A. Agha-mohammadi AND L. Paull AND M. Graham AND J. How AND J. Leonard}, 
	Title     = {Two-Stage Focused Inference for Resource-Constrained Collision-Free Navigation}, 
	Booktitle = {Robotics Science and Systems}, 
	Year      = {2015}, 
	Address   = {Rome, Italy}, 
	Month     = {July} 
}

Folder isam contains the modified isam library to optimize pose graphs. Please refer to readme file in that folder for installation instructions.

Folder focused_mapping contains matlab scripts of our two-stage selection algorithms as well as compared algorithms. The main script is main_sim.m.
Please specifies parameters in the second section when using.

Data is contained in focused_mapping/data subfoler
