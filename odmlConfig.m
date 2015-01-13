function odmlConfig()
% odmlConfig: import odML Java library for use in Matlab.
%
% Imports the odml.jar and other used libraries into the matlab workspace.
% This allows handling odML metadata directly with matlab.
% 
% odmlConfig tries to import the required libraries into the
% workspace while using the current working directory.
%
%
% by Jan Grewe 2009, 2010 (no warranty)
% for more information visit: www.g-node.org/odml

path = mfilename('fullpath');
indices = strfind(path,filesep);
workDir = path(1:indices(end));

warning('off', 'all');
javarmpath([workDir 'odml.jar']);
javarmpath([workDir 'commons-codec-1.5.jar']);
javarmpath([workDir 'jdom-2.0.5.jar']);

warning('on', 'all');
javaaddpath([workDir 'odml.jar']);
javaaddpath([workDir 'commons-codec-1.5.jar']);
javaaddpath([workDir 'jdom-2.0.5.jar']);
