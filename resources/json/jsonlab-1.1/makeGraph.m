clear; clc; close all; fclose all;
addpath(genpath('./jsonlab'));
disp('Making nodes...')
nodeGen('combined_result.txt', 'combined_nodes.js');
disp('Making edges...')
edgeGen('combined_result.txt', 'combined_edges.js');