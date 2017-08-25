%% makeGraph: create nodes and edges for CourseGraph

%Written by Justin Htay
%v1.0: 8/15/17

function makeGraph(varargin)
global nodes
    nodeName = varargin{1};
    edgeName = varargin{2};
    dataName = varargin{3};
    addpath(genpath('./jsonlab'));
    addpath(genpath('./distinguishable_colors'));
    
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
    rad = 14500; % radius
    cx = 15000; %center of circle
    cy = 15000;
    %other variables
    ind = [];
    xs = [];
    ys = [];
    nodes = {};
    reqs = {};
    %iterate through the data
    for x = 1:length(data)
        %separate school and number, i.e strtok('ECE 2026')
        [test, num] = strtok(data{x}.identifier);
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
            || ~(any(data{x}.grade_basis == 'A') || any(data{x}.grade_basis == 'L')) ...    
            || ~isfield(data{x}, 'sections') ...
            || any(num == 'X') ...
            || str2num(num(2:5)) > 5000 ...
            || str2num(num(2:5)) < 1000 ...
            || (isfield(data{x}, 'restrictions') && isfield(data{x}.restrictions, 'Campuses') && isempty(strfind(data{x}.restrictions.Campuses.requirements, 'Atlanta'))) ...
            || sum(strcmpi(data{x}.identifier, nodes) ~= 0)
            ind = [ind, x];
        else
             nodes = [nodes, data{x}.identifier];
%             listreq = {data{x}.fullname};
%             if any(strcmp(fieldnames(data{x}),'prerequisites'))
%                 [~, listreq] = allprereq(data{x}.prerequisites);
%                 listreq = [data{x}.fullname, '\\n', listreq];
%             end
%             reqs = [reqs, listreq];
        end
    end
    colors = round(255 * distinguishable_colors(length(nodes)));
    vec = 1:length(data);
    %delete the unused data
    data(ismember(vec, ind)) = [];
    % time to make the edges
    disp('Making edges...')
        edges = [];
    for x = 1:length(data)
        %if the data is a node and has prereqs
        st = data{x};
        listreq = {data{x}.fullname};
        if any(strcmp(fieldnames(st),'prerequisites')) && ismember(st.identifier, nodes)
            %get all prereqs, and delete the prereqs that aren't nodes
            [prereqs, listreq] = allprereq(st.prerequisites);
            prereqs(~ismember(prereqs, nodes)) = [];
            listreq = strrep(listreq, ')\\n)', '))');
            listreq = strrep(listreq, '()\\n', '');
            listreq = [data{x}.fullname, '\\n', listreq];
            %iterate to save each edge as a 1x2 cell array
            for y = 1:length(prereqs)
                edges = [edges; {st.identifier, prereqs{y}}];
            end
        end
        reqs = [reqs, listreq];
    end
    disp('Printing edges...')
    %create a structure of all the arrows
    json = struct('from', edges(:,2), 'to', edges(:,1), 'arrows', 'to');
    %stringify the structure and print it to file
    strjson = savejson('', json);
    strjson = ['var edges = ', strjson(2:end-3), ';'];
    fh = fopen(edgeName, 'w');
    fprintf(fh, strjson);
    fclose(fh);
    
    %Try to calculate the positions of all the nodes.
    groups = cellfun(@strtok, nodes, 'UniformOutput', false);
    nums = cell2mat(cellfun(@(x) str2num(x(x >= '0' & x <= '9')), nodes, 'UniformOutput', false));
    uniqueGroups = unique(groups);
    loc = cellfun(@(x) strcmp(x, groups), uniqueGroups, 'UniformOutput', false);
    count = [];
    for z = 1:4
        count = [count; cellfun(@(x) sum((floor(nums/1000) == z) & x), loc, 'UniformOutput', false)];
    end
    count = cell2mat(count);
    %count = cellfun(@sum, count); %number of classes for each school
    countdown = count;
    angle = 2 * pi * sum(count) / sum(sum(count));
    disp('Printing nodes...')
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
                myColor = sprintf('rgba(%d,%d,%d,1)', colors(pos,1), colors(pos,2), colors(pos,3));
                level =floor(nums(1) / 1000);
                myAngle = sum(angle(1:pos-1)) + angle(pos) * countdown(level,pos)/count(level,pos);
                countdown(level,pos) = countdown(level,pos) - 1;
                myX = cx + cos(myAngle) * rad * level / 4;
                myY = cy + sin(myAngle) * rad * level / 4;
                xs(end+1) = myX;
                ys(end+1) = myY;
                %print
                try
                line = [line(1:end-4),', "color": "', myColor, '" , "title": "', reqs{1},'", "x": ', '"', num2str(myX), '"', ', "y": ', '"', num2str(myY), '"',...
                    ', "group": ', '"', groups{1}, '"',  ', "level": ', '"', num2str(level(1)), '"',line(end-3:end)];
                catch
                    a = 1;
                end
                
                groups(1) = [];
                nums(1) = [];
                reqs(1) = [];
            end
            fprintf(fhout, line);
        end
        linenum = linenum + 1;
        line = fgets(fhin);
    end
    fprintf(fhout, ';');
    fclose(fhin);
    fclose(fhout);
    
    plot(xs,ys, '*')
end

%allprereq returns a cell array containing the prerequisites of the input
%structure
function [out, str] = allprereq(ca)
global nodes
    out = {};
    str = '(';
    join = ca.type;
    ca = ca.courses;
    for x = 1:length(ca)
        substr = [];
        if isstruct(ca{x})
            [down, substr] = allprereq(ca{x});
            out = [out, down];
        elseif ismember(ca{x}, nodes)
            out = [out, ca{x}];
            substr = ca{x};
        end
        if ~isempty(substr)
            str = [str, ' ', join, ' '];
        end
        str = [str, substr];
        if x == 1 && length(str) > 6
            str(2:3+length(join)) = [];
        end
    end
    parts = strsplit(str);
    if length(str) > 1 && any(strcmp(parts{2}, {'and', 'or'}))
        parts(2) = [];
        str = strjoin(parts);
        str(2) = [];
    else
        str = strjoin(parts);
    end
    
    str = [str, ')\\n'];
end
% overwrite contains() for MATLAB versions below 2017
function out = myContains(word, ca)
    out = [];
    for x = 1:length(ca)
       newword = strrep(word, ca{x}, char(0));
       out = [out, ~isequal(newword, word)]; 
    end
end

function str = stripNewLine(str)
    if length(str) > 5
        count = 1;
        vec = [];
        for x = 2:length(str)-2
            if isequal(str(x:x+2), '\\n') && count > 1
                vec = [vec,x];
            elseif str(x) == '('
                count = count+1;
            elseif str(x) == ')'
                count = count - 1;
            end
        end
        for x = 1:3
            str(vec) = [];
        end
    end
end