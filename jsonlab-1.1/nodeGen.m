%% nodeGen: generates the nodes based on a Grouch json file

function nodeGen(fname, outname)
    data = loadjson(fname);
    ind = [];
    groups = [];
    for x = 1:length(data)
        st = data{x};
        [~, num] = strtok(data{x}.identifier);
        if any(contains(data{x}.fullname,{'Special Topics', 'Special Problems', 'Undergrad'})) ...
            || ~isfield(data{x}, 'sections') ...
            || any(num == 'X') ...
            || (isfield(data{x}, 'restrictions') && isfield(data{x}.restrictions, 'Campuses') && ~contains(data{x}.restrictions.Campuses.requirements, 'Atlanta'))
            ind = [ind, x];
        end
        groups = [groups, num(2)];
    end
    fhin = fopen(fname);
    fhout = fopen(outname, 'w');
    fprintf(fhout, 'var nodes = ');
    line = fgets(fhin);
    linenum = 0;
    while ischar(line)
        if all(ind-linenum ~= 0)
            if length(line) > 20
                line = [line(1:end-4), ', "group": ', groups(linenum), line(end-3:end)];
            end
            fprintf(fhout, line);
        end
        linenum = linenum + 1;
        line = fgets(fhin);
    end
    fprintf(fhout, ';');
    fclose(fhin);
    fclose(fhout);
end