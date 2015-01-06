function [struct, reader] = odml2Struct(file)
% odml2Struct converts odML-metadata to matlab struct.
% function calls:
%   odml2Struct(filename): converts the odml file
%
% by Jan Grewe 2009
% (this software is open source.
% it comes 'at it is' with absolutely no warrenty!)
import odml.core.*

if(~file(end-3:end) == '.xml')
    error('can not handle this file');
end

try
    reader = Reader();
    s = reader.load(file);
catch
    error(['an error occurred reading file: ' file]);
end

struct = []
for i = 0 : s.sectionCount()-1
    sub = [];
    sub = section2struct(s.getSection(i));
    sectionName = s.getSection(i).getName().toCharArray';
%     sectionName(find(sectionName==' '))=[];
    sectionName = strrep(sectionName, ' ', '_');
    try
        cmd= ['struct.' sectionName '= sub;'];
        eval(cmd);
    catch
        warning(strcat('Could not append section: ', sectionName, '! A naming issue?'))
    end 
end
 
if nargout==1
    clear reader;
end


function sub = section2struct(sect)
% section2struct converts an odML section to a substructure
    
    % retrieve the section attributes
    sub.name = char(sect.getName());
    sub.type = char(sect.getType());
    sub.reference = char(sect.getReference());
    sub.definition = char(sect.getDefinition());
    sub.repository = char(sect.getRepository());
    sub.mapping = char(sect.getMapping());
    sub.link = char(sect.getLink());
    sub.include = char(sect.getInclude());
    
    % convert the properties inside the current section
    if sect.propertyCount() == 0
        sub.property = struct();
    else
        for ind=0:sect.propertyCount()-1
            sub.property(ind+1) = property2struct(sect.getProperty(ind));
        end
    end
    
    % recursively convert the sections inside the current section
    if sect.sectionCount() == 0
        sub.section = struct();
    else
        for ind=0:sect.sectionCount()-1
                sub.section(ind+1) = section2struct(sect.getSection(ind));
        end
    end
end

function sub = property2struct(prop)
% property2struct converts an odML property to a substructure

    % retrieve the property attributes
    sub.name = char(prop.getName());
    sub.definition = char(prop.getDefinition());
    sub.mapping = char(prop.getMapping());
    sub.dependency = char(prop.getDependency());
    sub.dependencyValue = char(prop.getDependencyValue());
    
    % retrieve the values and their attributes for the current property 
    if prop.valueCount() == 0
        sub.value = struct();
    else
        for ind = 0:prop.valueCount()-1
            % !!! Note: the name of the functions to access the value
            % attributes are not consistent, as sometime the "Value" is 
            % omitted in the function name (like getUnit)
            
            sub.value(ind+1).value = prop.getValue(ind);
            sub.value(ind+1).uncertainty = prop.getValueUncertainty(ind);
            sub.value(ind+1).unit = char(prop.getUnit(ind)); 
            % !!! Note: the prop.getType(ind) function depending of the 
            % index seems unavailable in the java library but would be
            % needed in fact
            sub.value(ind+1).type = char(prop.getType());
            sub.value(ind+1).definition = ...
                char(prop.getValueDefinition(ind));
            sub.value(ind+1).reference = char(prop.getValueReference(ind));
            sub.value(ind+1).filename = char(prop.getFilename(ind));
            
            % !!! the functions to handle binary data in odML files don't
            % seem available in the java library, we would want something
            % like:
            % sub.value(ind+1).encoder = char(prop.getValueEncoder(ind));
            % sub.value(ind+1).checksum = char(prop.getValueChecksum(ind);
        end
    end
end

end