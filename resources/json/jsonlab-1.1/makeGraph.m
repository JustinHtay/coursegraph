clear; clc; close all; fclose all;
addpath(genpath('./jsonlab'));
disp('Making nodes...')
nodeGen('result.json', 'all_nodes.js');
disp('Making edges...')
edgeGen('result.json', 'all_edges.js');