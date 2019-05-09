function [] = odml_example()
%ODML_EXAMPLE   Example illustrating the use of the odML functions
%   The function ODML_EXAMPLE creates an odML example file and loads these
%   data in a structure array using the odm_load function, then displays
%   the loaded data using the odml_disp function, and finally illustrates
%   how to access the data and use the odml_find function on the data.
%
%Usage:
%   ODML_EXAMPLE
%
%   See also ODML_CONFIG, ODML_LOAD, ODML_DISP, ODML_FIND.

%   2015/05: Created by Florent JAILLET
%   Institut de Neurosciences de la Timone
%   (INT - UMR 7289 CNRS / Aix-Marseille Univ.)

odml_file_name = 'odml_example.odml';

disp(['* creating the odML example file ', odml_file_name]);

odml = {
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<odML version="1">'
    '  <date>2042-02-24</date>'
    '  <author>Bob Author</author>'
    '  <section>'
    '    <name>Subject</name>'
    '    <type>person</type>'
    '    <property>'
    '      <name>FullName</name>'
    '      <value>John Doe<type>string</type></value>'
    '    </property>'
    '    <property>'
    '      <name>Height</name>'
    '      <value>177.5<type>float</type><unit>cm</unit></value>'
    '    </property>'
    '  </section>'
    '</odML>'
    };
disp(pwd)
file_id = fopen(odml_file_name, 'w');
fprintf(file_id, join(odml));
fclose(file_id);
disp('___');

odml_config;
disp(['* loading the data from ', odml_file_name, ...
    ' as a ''tree'' structure array']);
example_tree = odml_load(odml_file_name, 'tree');
disp('___');

disp('* displaying the loaded data:');
odml_disp(example_tree);
disp('___');

disp(['* loading the data from ', odml_file_name, ...
    ' as an ''odml'' structure array']);
example_odml = odml_load(odml_file_name, 'odml');
disp('___');

disp('* displaying the loaded data:');
odml_disp(example_odml);
disp('');

disp('* Accessing the date attribute in the root section:');
disp('tree: ');
disp(example_tree.date);
disp('odml: ');
disp(example_odml.date);
disp('___');

disp(['* Accessing the value of the Height property in the section '...
    'Subject:']);
disp('tree: ');
disp(example_tree.Subject.Height.value);
disp('odml: ');
disp(example_odml.section(1).property(2).value(1).value);
disp('___');

disp('* Finding and locating the property named Height')
[prop_tree, loc_tree] = odml_find(example_tree, 'Height');
disp('tree: ');
disp(prop_tree);
disp(loc_tree);
[prop_odml, loc_odml] = odml_find(example_odml, 'Height');
disp('odml: ');
disp(prop_odml);
disp(prop_odml.value);
disp(loc_odml);
disp('___');

disp('* Finding the property named FullName')
prop_tree = odml_find(example_tree, 'FullName');
disp('tree: ');
disp(prop_tree);
prop_odml = odml_find(example_odml, 'FullName');
disp('odml: ');
disp(prop_odml);
disp(prop_odml.value);
disp('___');

disp('* Locating the section named Subject')
[~, loc_tree] = odml_find(example_tree, 'Subject');
disp('tree: ');
disp(loc_tree);
[~, loc_odml] = odml_find(example_odml, 'Subject');
disp('odml: ');
disp(loc_odml);

end

function res = join(strings)
    tmp = cell(length(strings)*2-1, 1);
    tmp(1:2:end) = strings;
    tmp(2:2:end) = {'\n'};
    res = [tmp{:}];
end


