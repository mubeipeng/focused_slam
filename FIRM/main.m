% Add FIRM toolbox and external toolboxes as needed to the Matlab path
addpath(genpath(pwd))
add_external_toolboxes()

%%
load('../focused_mapping/simulation_results.mat','project_focus'); 
lm_file = project_focus.lm; lm_file.pos = project_focus.lm_transformed(1:2,:);
y_focus = run_simulator(lm_file);

%%
load('../focused_mapping/simulation_results.mat','project_full'); 
lm_file = project_full.lm; lm_file.pos = project_full.lm_transformed(1:2,:);
y_full = run_simulator(lm_file);

%%
load('../focused_mapping/simulation_results.mat','project_down'); 
lm_file = project_down.lm; lm_file.pos = project_down.lm_transformed(1:2,:);
y_down = run_simulator(lm_file);

%%
load('../focused_mapping/simulation_results.mat','project_glc_direct'); 
lm_file = project_glc_direct.lm; lm_file.pos = project_glc_direct.lm_transformed(1:2,:);
y_glc_direct = run_simulator(lm_file);

%%
load('../focused_mapping/simulation_results.mat','project_glc_optimize'); 
lm_file = project_glc_optimize.lm; lm_file.pos = project_glc_optimize.lm_transformed(1:2,:);
y_glc_optimize = run_simulator(lm_file);

%%
p=0:1/17:1;
figure; hold on;
plot(sort([0 y_focus]),p);
plot(sort([0 y_full]),p);
plot(sort([0 y_down]),p);
plot(sort([0 y_glc_direct]),p);
plot(sort([0 y_glc_optimize]),p);
axis([0 700 0 1]);
legend('focus', 'full', 'down', 'glc optimize', 'glc direct');

%%
save output/navigation_results.mat