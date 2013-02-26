% Tutorial: using odml in Matlab
% This tutorial introduces how to use the odml metadata library in Matlab
%
% Requirements:
% to run the code you must download the odml files for Matlab from github:
% https://github.com/G-Node/matlab-odml
% There are a number of files in the repository. Download them all and put
% them into a folder of your choice. You may want to add the folder to the
% Matlab search path (file->Set Path).
% Before you can use the odml library you have to add the library to
% Matlabs javaclasspath. This can be done manually or with the odmlConfig.m
% script. Once this is done, we are ready to begin.
%
% All odml software is open source published under the LGPL. It comes as it
% is without any kind of warranty.
%
% For more information see www.g-node.org/odml
% Javadoc API documentation can be found here: http://portal.g-node.org/odml/doc/java
%
%Useful commands for handling java objects in Matlab:
% 
% javaclasspath.m - lists all java jars Matlab is aware of. The just added ones can be found in the 'dynamic java path'
% 
% methodsview odml.core.Section - opens a window displaying all public
% methods of the Section class.
%
% methods odml.core.Section  - gives an overview on the command line
%
% import 'package' - imports the classes of the specified package into the search path. 



%% Configuration
odmlConfig;

import odml.core.* % for convenience: add all classes of the odml package to the import list


%% First steps: Creating simple objects

%Create a Section
disp('odml javalib Tutorial: section01');

input('Press any key to start...')

disp('');
disp('Create a simple tree...');

disp('Create a section: s = Section(''myFirstSection'',''recording'');...');
s = Section('myFirstSection','recording');

disp('Append a second Section to s: Section(s,''myNextSection'',''dataset'');...');
Section(s,'myNextSection','dataset');

disp('Append another one with a different type but the same name as before \n(Note the warning! Section names must be unique): Section(s, ''myNextSection'', ''stimulus'');...');
Section(s, 'myNextSection', 'stimulus');

disp('Append a section that has a derived type: Section(s, ''stimulus'', ''stimulus/white_noise''); ...');
Section(s, 'stimulus', 'stimulus/white_noise');

disp('Add a few more sections: ');
disp('    Section(s, ''thirdSection'', ''dataset'');');
disp('    Section s2 = Section(s, ''Subject01'', ''subject'');');
disp('    Section(s2, ''cell01'', ''cell'');');
disp('    Section(s2, ''cell02'', ''cell'');');
Section(s, 'thirdSection', 'dataset');
s2 = Section(s,'Subject01', 'subject');
Section(s2,'Cell01', 'cell');
Section(s2,'Cell02', 'cell');
s2.removeSection('/subject01/cell02');
s2.addProperty('cell01#cellType', 'CA-1');

disp('Display the tree in tree view dialog, just for illustration! Not suited to really work with it! Also works in Matlab...');
disp('\ts.displayTree();');
s.displayTree();

input('Press any key to continue...')
disp('');
disp('List all child sections of the root node: s.getSections()...');
disp(s.getSections());
% retrieve a section by name
disp('');
disp(s.getSection('myNextSection'));
% retrieve all sections by type
disp('');
disp(s.getSectionByType('dataset'));
% retrieve all sections of the same type
disp('');
disp(s.getSectionsByType('dataset'));
% retrieving subsections by type includes derived types!
disp('');
disp(s.getSectionsByType('stimulus'));

disp('');
disp('Retrieving ''cell01'' from the root section using path notation. getSection(''Subject01/cell01'')...');
disp(s.getSection('Subject01/cell01/'));

disp('');
disp('Retrieving ''cell01'' from section ''Subject01'' using absolute path notation: s2.getSection(''/Subject01/cell01/'')...');
disp(s2.getSection('/Subject01/cell01/'));



%%