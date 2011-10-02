function [s, reader] = odml2Struct(file)
% odml2Struct converts odML-metadata to matlab struct.
% function calls:
%   odml2Struct(filename): converts the odml file
%
% by Jan Grewe 2009
% (this software is open source.
% it comes 'at it is' with absolutely no warrenty!)
if(~file(end-3:end)=='.xml')
    error('can not handle this file');
end
import odml.core.*
import odml.xtra.*
try
    reader = Reader(file);
catch
    error(['an error occurred reading file: ' file]);
end
s=[];

for(i=0:reader.getRootSection.getSectionCount()-1)
    sub = [];
    sub = section2struct(reader.getRootSection.getSection(i));
    sectionName = reader.getRootSection.getSection(i).getName().toCharArray';
%     sectionName(find(sectionName==' '))=[];
    cmd= ['s.' sectionName '= sub;'];
    eval(cmd);
end
 
if nargout==1
    clear reader;
end
end