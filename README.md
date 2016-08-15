# focused_slam
This is the simulation code for "Two-Stage Focused Inference for Resource-Constrained Collision-Free Navigation". See bib reference below:

@INPROCEEDINGS{Mu_RSS_15, 
  AUTHOR    = {B. Mu AND A. Agha-mohammadi AND L. Paull AND M. Graham AND J. How AND J. Leonard}, 
	TITLE     = {Two-Stage Focused Inference for Resource-Constrained Collision-Free Navigation}, 
	BOOKTITLE = {Robotics Science and Systems}, 
	YEAR      = {2015}, 
	ADDRESS   = {Rome, Italy}, 
	MONTH     = {July} 
}

Folder isam contains the modified isam library to optimize pose graphs. Please refer to readme file in that folder for installation instructions.

Folder focused_mapping contains matlab scripts of our two-stage selection algorithms as well as compared algorithms. The main script is main_sim.m.
Please specifies parameters in the second section when using.
