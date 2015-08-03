function odml_config()
%ODML_CONFIG   Import the odML Java library for use in MATLAB
%
%   The function ODML_CONFIG imports the odML Java library and other
%   required libraries into the matlab workspace.
%   This allows handling odML metadata directly with matlab.
% 
%   The required Java libraries must be stored in the directory containing
%   the .m file of this function.
%
%Usage:
%   ODML_CONFIG
%
%   See also ODML_LOAD, ODML_DISP, ODML_FIND.

%   2009-2010: Created by Jan GREWE  (no warranty)
%   For more information visit: www.g-node.org/odml

%   2015/05: Modified by Florent JAILLET
%   Institut de Neurosciences de la Timone
%   (INT - UMR 7289 CNRS / Aix-Marseille Univ.)

mfile_path = mfilename('fullpath');
indices = strfind(mfile_path, filesep);
work_dir = mfile_path(1:indices(end));

java_version = version('-java');
java_version = java_version(6:8);
odml_jar = ['odml-java', java_version, '.jar'];

warning('off', 'all');
javarmpath([work_dir, odml_jar]);
javarmpath([work_dir, 'jdom-2.0.5.jar']);

warning('on', 'all');
javaaddpath([work_dir, odml_jar]);
javaaddpath([work_dir, 'jdom-2.0.5.jar']);

end