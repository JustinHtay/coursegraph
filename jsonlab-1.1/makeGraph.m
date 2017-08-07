addpath(genpath('./jsonlab'));
disp('Making nodes...')
nodeGen('test_result.json', 'nodes.js');
disp('Making edges...')
edgeGen('test_result.json', 'edges.js');