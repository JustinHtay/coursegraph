%% makeGraph: create nodes and edges for CourseGraph

%Written by Justin Htay
%v1.0: 8/15/17

function makeGraph(varargin)
    nodeName = varargin{1};
    edgeName = varargin{2};
    dataName = varargin{3};
    addpath(genpath('./jsonlab'));
    %Load the data in, either as a .mat file or as a .json file
    disp('Loading Data...')
    try
        matName = varargin{4};
        load(matName);
    catch
        data = loadjson(dataName);
    end
    disp('Making nodes...')
    %position configuration
    rad = 1900; % radius
    cx = 2000; %center of circle
    cy = 2000;
    max_num = 5000; %maximum class number, can be changed
    %other variables
    ind = [];
    level = [];
    nodes = {};
    groups = {};
    %iterate through the data
    for x = 1:length(data)
        %separate school and number, i.e strtok('ECE 2026')
        [~, num] = strtok(data{x}.identifier);
        %If it's any of the things in line 25, hasn't been offered (so it
        %doesn't have a section field), has an X in the number (i.e a
        %transfer course), is a graduate class (number > 5k), or isn't
        %taught at Atlanta campus, delete it. Otherwise, add it to list of
        %nodes and groups
        %pre-2017 versions of MATLAB don't have contains(), so I wrote my
        %own. I assume that MATLAB's version is better, so I default to it
        try
            check = any(contains(data{x}.fullname,{'Spec Prob', 'Special Topics', 'Special Problems', 'Undergrad', 'Graduate', 'Research', 'Seminar'}));
        catch
            check = any(myContains(data{x}.fullname,{'Spec Prob', 'Special Topics', 'Special Problems', 'Undergrad', 'Graduate', 'Research', 'Seminar'}));
        end
        if  check ...
            || ~strcmp(data{x}.grade_basis, 'ALP') ...    
            || ~isfield(data{x}, 'sections') ...
            || any(num == 'X') ...
            || str2num(num(2:5)) > 5000 ...
            || (isfield(data{x}, 'restrictions') && isfield(data{x}.restrictions, 'Campuses') && isempty(strfind(data{x}.restrictions.Campuses.requirements, 'Atlanta'))) ...
            || sum(strcmpi(data{x}.identifier, nodes) ~= 0)
            ind = [ind, x];
        else
            nodes = [nodes, data{x}.identifier];
        end
    end
    %Try to calculate the positions of all the nodes.
    groups = cellfun(@strtok, nodes, 'UniformOutput', false);
    nums = cellfun(@(x) str2num(x(x >= '0' & x <= '9')), nodes, 'UniformOutput', false);
    uniqueGroups = unique(groups);
    count = cellfun(@(x) strcmp(x, groups), uniqueGroups, 'UniformOutput', false);
    count = cellfun(@sum, count); %number of classes for each school
    angle = 2 * pi * count / sum(count);
    
    %Write the node data to the nodeName file
    fhin = fopen(dataName);
    fhout = fopen(nodeName, 'w');
    %write the variable declaration
    fprintf(fhout, 'var nodes = ');
    line = fgets(fhin);
    linenum = 0;
    while ischar(line)
        %If the line wasn't in the list of bad lines and is not a couple of
        %characters, write it. Include the group and level fields.
        if all(ind-linenum ~= 0)
            if length(line) > 20
                %calculate position
                pos = find(strcmp(groups{1}, uniqueGroups));
                myAngle = sum(angle(1:pos-1)) + mod(nums{1}, 1000);
                myX = cx + cos(myAngle) * rad * floor(nums{1}/1000) / 4;
                myY = cy + sin(myAngle) * rad * floor(nums{1} / 1000) / 4;
                %print
                line = [line(1:end-4), ', "x": ', '"', num2str(myX), '"', ', "y": ', '"', num2str(myY), '"',...
                    ', "group": ', '"', groups{1}, '"',  ', "level": ', '"', num2str(floor(nums{1} / 1000)), '"',line(end-3:end)];
                groups(1) = [];
                nums(1) = [];
            end
            fprintf(fhout, line);
        end
        linenum = linenum + 1;
        line = fgets(fhin);
    end
    fprintf(fhout, ';');
    fclose(fhin);
    fclose(fhout);
    vec = 1:length(data);
    %delete the data that wasn't written
    data(ismember(vec, ind)) = [];
    % time to make the edges
    disp('Making edges...')
        edges = [];
    for x = 1:length(data)
        %if the data is a node and has prereqs
        st = data{x};
        if any(strcmp(fieldnames(st),'prerequisites')) && ismember(st.identifier, nodes)
            %get all prereqs, and delete the prereqs that aren't nodes
            prereqs = allprereq(st.prerequisites.courses);
            prereqs(~ismember(prereqs, nodes)) = [];
            %iterate to save each edge as a 1x2 cell array
            for y = 1:length(prereqs)
                edges = [edges; {st.identifier, prereqs{y}}];
            end
        end       
    end
    %create a structure of all the arrows
    json = struct('from', edges(:,2), 'to', edges(:,1), 'arrows', 'to');
    %stringify the structure and print it to file
    strjson = savejson('', json);
    strjson = ['var edges = ', strjson(2:end-3), ';'];
    fh = fopen(edgeName, 'w');
    fprintf(fh, strjson);
    fclose(fh);
end

%allprereq returns a cell array containing the prerequisites of the input
%structure
function out = allprereq(ca)
    out = {};
    for x = 1:length(ca)
        if isstruct(ca{x})
            out = [out, allprereq(ca{x}.courses)];
        else
            out = [out, ca{x}];
        end
    end
end
% overwrite contains() for MATLAB versions below 2017
function out = myContains(word, ca)
    out = [];
    for x = 1:length(ca)
       newword = strrep(word, ca{x}, char(0));
       out = [out, ~isequal(newword, word)]; 
    end
end
