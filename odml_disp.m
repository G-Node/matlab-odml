function [] = odml_disp(struc, struc_type, remove_empty_fields)
%ODML_DISP   Display the content of an odML structure array
%   The function ODML_DISP displays the content of an odML structure array
%   which must be of one of the two types returned by the odml_load
%   function ('tree' or 'odml').
%
%Usage:
%   ODML_DISP(struc)
%
%   where struc is the odML structure array as returned by odml_load or a
%   sub-structure array of it.
%   The empty fields in struc are not displayed.
%   By default, ODML_DISP guesses the type of the odML structure array in 
%   struc between the two possible types returned by odml_load. If this 
%   guess fails, the type of struc can be forced using the call below.
%
%   ODML_DISP(struc, struc_type)
%
%   where struc is defined as above, and struc_type is either 'tree' or
%   'odml' and specifies the type of odML structure array given in struc.
%   The empty fields in struc are not displayed.
%
%   ODML_DISP(struc, struc_type, remove_empty_fields)
%
%   where struc and struc_type are defined as above, and 
%   remove_empty_fields is a boolean flag specifying if the empty fields in
%   struc must be displayed. If remove_empty_fields == true, the empty
%   fields are not displayed, if remove_empty_fields == false, the empty
%   fields are displayed.
%
%   See also ODML_CONFIG, ODML_LOAD, ODML_FIND.

%   2015/05: Created by Florent JAILLET
%   Institut de Neurosciences de la Timone
%   (INT - UMR 7289 CNRS / Aix-Marseille Univ.)

if nargin < 3
    remove_empty_fields = true;
end

if nargin < 2
    struc_type = guess_struc_type(struc);
end

if strcmp(struc_type, 'odml')
    disp_odml_struc(struc, remove_empty_fields, inputname(1));
else
    disp_tree_struc(struc, remove_empty_fields, inputname(1));
end


end

function struc_type = guess_struc_type(struc)

if isfield(struc, 'section')
    struc_type = 'odml';
else
    struc_type = 'tree';
end

end

function [] = disp_tree_struc(struc, remove_empty_fields, curr_name)

disp(curr_name)
filtered_disp(struc, remove_empty_fields)

fields_list = fieldnames(struc);
for field_ind = 1:length(fields_list)
    if isstruct(struc.(fields_list{field_ind}))
        disp_tree_struc(struc.(fields_list{field_ind}), ...
            remove_empty_fields, [curr_name, '.', fields_list{field_ind}]);
    end
end

end

function [] = disp_odml_struc(struc, remove_empty_fields, curr_section)

disp(curr_section)
filtered_disp(struc, remove_empty_fields)

if isfield(struc, 'property')
    if ~isempty(struc.property)
        for ind=1:size(struc.property, 2)
            disp([curr_section, '.property(', num2str(ind), ')']);
            filtered_disp(struc.property(ind), remove_empty_fields)
            if isfield(struc.property(ind), 'value')
                for ind_val=1:size(struc.property(ind).value, 2)
                    disp([curr_section, '.property(', num2str(ind), ...
                        ').value(', num2str(ind_val), ')']) 
                    filtered_disp(struc.property(ind).value(ind_val), ...
                        remove_empty_fields)
                end
            end
        end
    end
end

if isfield(struc, 'section')
    if ~isempty(struc.section)
        for ind=1:size(struc.section, 2)
            tmp_curr_section = [curr_section, '.section(', ...
                num2str(ind), ')'];
            disp_odml_struc(struc.section(ind), remove_empty_fields, ...
                tmp_curr_section)
        end
    end
end

end

function filtered_disp(struc, remove_empty_fields)

if remove_empty_fields
    field_names = fieldnames(struc);
    for ind = 1:length(field_names)
        if isempty(struc.(field_names{ind}))
            struc = rmfield(struc, field_names{ind});
        end
    end
end
disp(struc)

end