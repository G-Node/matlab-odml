function [res, loc] = odml_find(struc, searched_name, nb_res, struc_type)
%ODML_FIND   Find a section or property by name in an odML structure array
%   This function returns the sections or properties having a given name
%   in an odML structure array, as well as their location in the odML
%   structure array.
%
%   The structure array must be of one of the two types returned by the
%   odml_load function ('tree' or 'odml').
%
%Usage:
%
%   [res, loc] = ODML_FIND(struc, searched_name)
%
%   where res is the structure array containing the first found section or 
%   property, loc is the location of the first found section or 
%   property, struc is the odML structure array as returned by odml_load or
%   a sub-structure array of it and searched_name is the character array 
%   containing the searched section name or property name.
%   By default, if the structure array contains several sections 
%   or properties with the same name, only the first one found is returned,
%   and ODML_FIND guesses the type of the odML structure array in 
%   struc between the two possible types returned by odml_load. If this 
%   guess fails, the type of struc can be forced using the call below.
%
%   [res, loc] = ODML_FIND(struc, searched_name, nb_res)
%
%   where struc and searched_name are defined as above, and nb_res is the
%   maximal number of sections or properties having the name searched_name
%   that must be found. If only one section or property is found, res and
%   loc are defined as above. If more than one section or property are
%   found, then res and loc are cell arrays containing the multiple found
%   sections or properties and their locations.
%   Use nb_res = Inf if you want to find all sections or properties having
%   the name searched_name.
%
%   [res, loc] = ODML_FIND(struc, searched_name, nb_res, struc_type)
%
%   where res, loc, struc, searched_name, nb_res are defined as above, and
%   struc_type is either 'tree' or 'odml' and specifies the type of odML
%   structure array given in struc.
%
%   If you are not wanting to return both the found sections or properties
%   and their locations, you can use the standard MATLAB syntax to ignore
%   one ouput, that is:
%   res = ODML_FIND(...)
%   to ouput only the found sections or properties, and
%   [~, loc] = ODML_FIND(...)
%   to ouput only the locations of the found sections or properties.
%
%   See also ODML_CONFIG, ODML_LOAD, ODML_DISP.

%   2015/05: Created by Florent JAILLET
%   Institut de Neurosciences de la Timone
%   (INT - UMR 7289 CNRS / Aix-Marseille Univ.)

if nargin < 3
    nb_res = 1;
end

if nargin < 4
    struc_type = guess_struc_type(struc);
end

if strcmp(struc_type, 'odml')
    [res, loc] = find_in_odml_struc(struc, searched_name, ...
        inputname(1), {}, {}, nb_res);
else
    % the searched name might need to be modified to be a valid struct
    % field name:
    
    % replace the special characters by '_'
    searched_name = regexprep(searched_name, '[^a-zA-Z0-9]', '_');
    
    if regexprep(searched_name(1),'[^0-9_]','')
        % the first character of the name is a number or the character '_'
        % so the name should be modified to be usable as a structure field
        % by adding the prefix 'Section_' or 'Property_' depending of the
        % element type
        [res, loc] = find_in_tree_struc(struc, ...
            ['Section_', searched_name], inputname(1), {}, {}, nb_res);
        if isempty(res)
            [res, loc] = find_in_tree_struc(struc, ...
                ['Property_', searched_name], inputname(1), {}, {}, ...
                nb_res);
        end
    else
        [res, loc] = find_in_tree_struc(struc, searched_name, ...
            inputname(1), {}, {}, nb_res);
    end
end

if length(res) == 1
    res = res{:};
end
if length(loc) == 1
    loc = loc{:};
end

end

function struc_type = guess_struc_type(struc)

if isfield(struc, 'section')
    struc_type = 'odml';
else
    struc_type = 'tree';
end

end

function [res, loc] = find_in_tree_struc(struc, searched_name, ...
    curr_name, res_in, loc_in, nb_res)

res = res_in;
loc = loc_in;

field_names = fieldnames(struc);
for field_ind = 1:length(field_names)
    if strcmp(field_names{field_ind}, searched_name)
        res{end+1} = struc.(searched_name);
        loc{end+1} = [curr_name, '.', searched_name];
        if length(res) == nb_res
            return;
        end
    end
    if isstruct(struc.(field_names{field_ind}))
        [res, loc] = find_in_tree_struc(...
            struc.(field_names{field_ind}), searched_name, ...
            [curr_name, '.', field_names{field_ind}], res, loc, nb_res);
        if length(res) == nb_res
            return;
        end
    end
end

end

function [res, loc] = find_in_odml_struc(struc, searched_name, ...
    curr_section, res_in, loc_in, nb_res)

res = res_in;
loc = loc_in;

if isfield(struc, 'section')
    if ~isempty(struc.section)
        ind = find(strcmp(searched_name, {struc.section.name}));
        if ~isempty(ind)
            res{end+1} = struc.section(ind);
            loc{end+1} = [curr_section, '.section(', num2str(ind), ')'];
            if length(res) == nb_res
                return;
            end
        end
        for ind = 1:length(struc.section)
            if isfield(struc.section(ind), 'section')
                tmp_curr_section = [curr_section, '.section(', ...
                    num2str(ind), ')'];
                [res, loc] = find_in_odml_struc(struc.section(ind), ...
                    searched_name, tmp_curr_section, res, loc, nb_res);
                if length(res) == nb_res
                    return;
                end
            end
        end
    end
end
if isfield(struc, 'property')
    if ~isempty(struc.property)
        ind = find(strcmp(searched_name, {struc.property.name}));
        if ~isempty(ind)
            res{end+1} = struc.property(ind);
            loc{end+1} = [curr_section, '.property(', num2str(ind), ')'];
            if length(res) == nb_res
                return;
            end
        end
    end
end

end