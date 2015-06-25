function [struc, reader] = odml_load(file_name, struc_type, convert_tuple)
%ODML_LOAD   Load odML data from file into a structure array
%   The function ODML_LOAD reads data from an odML file using the Java
%   library provided by the odML project and returns the data into a MATLAB
%   structure array (i.e. an object of class struct).
%
%   The odML data can be mapped to the fields of the structure array in two
%   different ways depending on your needs thanks to the parameter 
%   struct_type described below.
%
%   The function odml_config must be run before running ODML_LOAD to insure
%   that the Java odML library is acessible to MATLAB.
%
%   For details about the odML format, see:
%   http://www.g-node.org/projects/odml
%
%Usage:
%   struc = ODML_LOAD(file_name)
%   where struc is the returned structure array containing the read odML
%   data and file_name is the name of the odML file.
%   The returned structure array struc is of type 'tree' as described
%   below, and the n-tuple values are stored as character strings in struc.
%
%   struc = ODML_LOAD(file_name, struc_type)
%   where struc and file_name are defined as above, and struc_type is
%   either 'tree' or 'odml' and specifies the way the odML data are mapped
%   to the fields of struc. The difference between the two types of
%   structure array is detailed below.
%   The n-tuple values in the odML file are stored as character strings in
%   struc.
%
%   struc = ODML_LOAD(file_name, struc_type, convert_tuple)
%   where struc, file_name, struc_type are defined as above, and
%   convert_tuple is a boolean specifying if the n-tuple values in the odML
%   file must be kept as character strings (if convert_tuple == false) or
%   converted to suitable MATLAB objects (if convert_tuple == true).
%   WARNING: The convert_tuple == true option uses the eval function which
%   makes it completely unsafe as it can be used to run arbitrary MATLAB
%   code. Use this option only with trusted odML files.
%
%   [struc, reader] = odml_load(...)
%   where struc is defined as below and reader is the odml.core.Reader Java
%   object used to access the odML data.
%
%   Description of the structure array types:
%
%   When struct_type == 'tree', the returned structure contains the tree of
%   sections and properties defined in the input odML file. The fields of 
%   this structure are named after the names of the sections and properties
%   in the odML file (with special characters replaced by '_' when needed 
%   and a prefix added if the first character of the name is a digit or 
%   '_').
%
%   The following examples illustrate how to access the data in struc 
%   when struct_type == 'tree':
%   To access the 'author' attribute of the root section use
%   struc.author
%   To access the 'type' attribute of the section named 'Subject' use
%   struc.Subject.type
%   To access the 'type' attribute of the section 'Amplifier' in the
%   section 'Hardware' use
%   struc.Hardware.Amplifier.type
%   To access the 'definition' attribute of the property 'Identity' in the
%   section 'Subject' use
%   struc.Subject.Identity.definition
%
%   When struct_type == 'tree', the values of the attributes are directly 
%   stored in the properties. The way they are stored is different if a 
%   property contains only one value or multiple values:
%   - when a property contains only one value, the value attributes can be
%   accessed according to the following example:
%   To access the 'value' attribute of the single value in the property
%   'Identity' in the section 'Subject' use
%   struc.Subject.Identity.value
%   All the value attributes can be directly accessed this way using the
%   attribute name as field name, except for the 'definition' attribute
%   which must be accessed with the field name 'valueDefinition' (to
%   differentiate with the property definition accessed with the
%   'definition' field),
%   - when a property contains multiple values, the value attributes can be
%   accessed according to the following example:
%   To access the 'value' attribute of the second value in the property
%   'Identity' in the section 'Subject' use
%   struc.Subject.Identity.Value2.value
%   All the value attributes can be accessed this way using the attribute
%   name as field name, except for the 'definition' attribute which
%   must be accessed with the field name 'valueDefinition' for consistency
%   with the previous case. 
%
%   When struct_type == 'odml', the returned structure conforms to the odML
%   model as illustrated by the following examples:
%   To access the 'author' attribute of the root section use
%   struc.author
%   To access the 'name' attribute of the 2nd section use
%   struc.section(2).name
%   To access the 'name' attribute of the 1st section in the 2nd section 
%   use
%   struc.section(2).section(1).name
%   To access the 'name' attribute of the 1st property in the 2nd section
%   use
%   struc.section(2).property(1).name
%   To access the 'value' attribute of the 3rd value of the 1st property in
%   the 2nd section use
%   struc.section(2).property(1).value(3).value
%
%   Comparison of the 'tree' and 'odml' types:
%
%   For structure arrays of type 'tree', only the fields corresponding to
%   non empty attributes defined in the odML file are created, making
%   exploration of the data in the returned structure easier, while in the
%   case 'odml', all the fields corresponding to the attributes defined in
%   the odML model are created in the returned structure, even when they
%   are not specified in the input odML file, in which case the
%   corresponding fields contain empty values.
%
%   For the 'tree' type, the direct use of the sections and properties
%   names as fields names of the returned structure generally makes the
%   code using the data easier to write and read, as the data are accessed
%   with explicit lines such as:
%   SubjectName = struc.Subject.FullName.value;
%   instead of:
%   SubjectName = struc.section(3).property(4).value(1).value;
%
%   In return, to be used as struct fields names, the sections and
%   properties names must be modified by replacing special characters by
%   '_' and adding a prefix if needed. In this case the exact original
%   values of the corresponding names in the odML file are lost.
%   
%   This limitation doesn't arise for the 'odml' type, where any section
%   and property name can be stored without modification.
%
%   The hierarchy of the structure array of type 'odml' is closer to the
%   odML model, which makes it more suitable for certain processing
%   (like looping over properties in one section for example).
%
%   For the 'tree' type, the hierarchy is more implictly coded as it is not
%   obvious to identify if a field in struc is representing a section, a
%   property, or an attribute of them. This can make some processing more
%   complicated to implement (for example counting the number of sections
%   in the odML file).
%
%   See also ODML_CONFIG, ODML_DISP, ODML_FIND.

%   2015/05: Created by Florent JAILLET
%   Institut de Neurosciences de la Timone
%   (INT - UMR 7289 CNRS / Aix-Marseille Univ.)

if nargin < 3
    convert_tuple = false;
end

if nargin < 2
    struc_type = 'tree';
end

% import the part of the Java odML library that we need
import odml.core.*;

% load the input odML in a Java reader
reader = Reader();
reader.load(file_name);

switch struc_type
    case 'tree'
        struc = load_tree_struct(reader, convert_tuple);
    case 'odml'
        struc = load_odml_struct(reader, convert_tuple);
end

end

function struc = load_odml_struct(reader, convert_tuple)
% load_odml_struct converts odML-metadata to odML model structure

% intitialize the output struct
struc = struct();

% retrieve the root section attributes
struc.author = char(reader.getRootSection.getDocumentAuthor());
struc.date = ...
    convert_datetime(reader.getRootSection.getDocumentDate(), 'date');
struc.version = char(reader.getRootSection.getDocumentVersion());
struc.repository = char(reader.getRootSection.getRepository());

% recursively convert the sections inside the root section
for(ind=0:reader.getRootSection.sectionCount()-1)
    struc.section(ind+1) = section_to_struct_odml( ...
        reader.getRootSection.getSection(ind), convert_tuple);
end

end

function sub = section_to_struct_odml(sect, convert_tuple)
% section_to_struct_odml converts an odML section to an odml substructure

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
    sub.property = struct([]);
else
    for ind=0:sect.propertyCount()-1
        sub.property(ind+1) = property_to_struct_odml( ...
            sect.getProperty(ind), convert_tuple);
    end
end

% recursively convert the sections inside the current section
if sect.sectionCount() == 0
    sub.section = struct([]);
else
    for ind=0:sect.sectionCount()-1
        sub.section(ind+1) = section_to_struct_odml( ...
            sect.getSection(ind), convert_tuple);
    end
end

end

function sub = property_to_struct_odml(prop, convert_tuple)
% property_to_struct_odml converts an odML property to an odml substructure

% retrieve the property attributes
sub.name = char(prop.getName());
sub.definition = char(prop.getDefinition());
sub.mapping = char(prop.getMapping());
sub.dependency = char(prop.getDependency());
sub.dependencyValue = char(prop.getDependencyValue());

% retrieve the values and their attributes for the current property
if prop.valueCount() == 0
    sub.value = struct([]);
else
    for ind = 0:prop.valueCount()-1
        % Note: in the Java library, the name of the functions to access
        % the value attributes are not consistent, as sometime the "Value"
        % is omitted in the function name (like getUnit)
        type = char(prop.getType());
        val = convert_value(prop.getValue(ind), type, convert_tuple);
        sub.value(ind+1).value = val;
        sub.value(ind+1).uncertainty = prop.getValueUncertainty(ind);
        if any(strcmpi(type, {'float', 'int'})) ...
                && ~isempty(sub.value(ind+1).uncertainty)
            sub.value(ind+1).uncertainty = ...
                str2double(sub.value(ind+1).uncertainty);
        end
        
        sub.value(ind+1).unit = char(prop.getUnit(ind));
        % Note: the prop.getType(ind) function depending of the
        % index seems unavailable in the Java library, so we put the same
        % type for all values
        sub.value(ind+1).type = type;
        sub.value(ind+1).definition = char(prop.getValueDefinition(ind));
        sub.value(ind+1).reference = char(prop.getValueReference(ind));
        sub.value(ind+1).file_name = char(prop.getFilename(ind));
        sub.value(ind+1).encoder = char(prop.getValueEncoder(ind));
        sub.value(ind+1).checksum = char(prop.getValueChecksum(ind));
        
    end
end

end

function struc = load_tree_struct(reader, convert_tuple)
% load_tree_struct converts odML-metadata to tree structure

% intitialize the output struct
struc = struct();

% retrieve the root section attributes
struc = setfield_if_not_empty(struc, 'author', ...
    char(reader.getRootSection.getDocumentAuthor()));
struc = setfield_if_not_empty(struc, 'date', ...
    convert_datetime(reader.getRootSection.getDocumentDate(), 'date'));
struc = setfield_if_not_empty(struc, 'version', ...
    char(reader.getRootSection.getDocumentVersion()));
struc = setfield_if_not_empty(struc, 'repository', ...
    char(reader.getRootSection.getRepository()));

% recursively convert the sections inside the root section
for ind = 0:reader.getRootSection.sectionCount()-1
    struc = section_to_struct_tree(...
        reader.getRootSection.getSection(ind), struc, convert_tuple);
end

end

function new_struc = section_to_struct_tree(sect, struc, convert_tuple)
% section_to_struct_tree converts an odML section to a substructure and 
% insert it in the the structure struc

new_struc = struc;

% retrieve the section attributes
sub = struct();
sub = setfield_if_not_empty( ...
    sub, 'type', char(sect.getType()));
sub = setfield_if_not_empty( ...
    sub, 'reference', char(sect.getReference()));
sub = setfield_if_not_empty( ...
    sub, 'definition', char(sect.getDefinition()));
sub = setfield_if_not_empty( ...
    sub, 'repository', char(sect.getRepository()));
sub = setfield_if_not_empty( ...
    sub, 'mapping', char(sect.getMapping()));
sub = setfield_if_not_empty( ...
    sub, 'link', char(sect.getLink()));
sub = setfield_if_not_empty( ...
    sub, 'include', char(sect.getInclude()));

% convert the properties inside the current section
for ind=0:sect.propertyCount()-1
    sub = property_to_struct_tree(sect.getProperty(ind), sub, ...
        convert_tuple);
end

% recursively convert the sections inside the current section
for ind=0:sect.sectionCount()-1
    sub = section_to_struct_tree(sect.getSection(ind), sub, convert_tuple);
end

% insert the created substructure in the main structure
name = adapt_field_name(char(sect.getName()), 'Section_');
new_struc.(name) = sub;

end

function new_struc = property_to_struct_tree(prop, struc, convert_tuple)
% section_to_struct_tree converts an odML property to a tree substructure
% and insert it in the the structure struc

new_struc = struc;

% retrieve the property attributes
sub = struct();
sub = setfield_if_not_empty(...
    sub, 'definition', char(prop.getDefinition()));
sub = setfield_if_not_empty(...
    sub, 'mapping', char(prop.getMapping()));
sub = setfield_if_not_empty(...
    sub, 'dependency', char(prop.getDependency()));
sub = setfield_if_not_empty(...
    sub, 'dependencyValue', char(prop.getDependencyValue()));

% retrieve the values attributes for the current property
for ind=0:prop.valueCount()-1
    if prop.valueCount() == 1
        tmpsub = sub;
    else
        tmpsub = struct();
    end
    
    type = char(prop.getType());
    val = convert_value(prop.getValue(ind), type, convert_tuple);
    tmpsub = setfield_if_not_empty(tmpsub, 'value', val);
    tmpsub = setfield_if_not_empty(tmpsub, 'type', type);
    
    uncertainty = prop.getValueUncertainty(ind);
    if any(strcmpi(type, {'float', 'int'})) && ~isempty(uncertainty)
        uncertainty = str2double(uncertainty);
    end
    tmpsub = setfield_if_not_empty(...
        tmpsub, 'uncertainty', uncertainty);
    
    tmpsub = setfield_if_not_empty(...
        tmpsub, 'unit', char(prop.getUnit(ind)));
    tmpsub = setfield_if_not_empty(...
        tmpsub, 'valueDefinition', char(prop.getValueDefinition(ind)));
    tmpsub = setfield_if_not_empty(...
        tmpsub, 'reference', char(prop.getValueReference(ind)));
    tmpsub = setfield_if_not_empty(...
        tmpsub, 'file_name', char(prop.getFilename(ind)));
    tmpsub = setfield_if_not_empty(...
        tmpsub, 'encoder', char(prop.getValueEncoder(ind)));
    tmpsub = setfield_if_not_empty(...
        tmpsub, 'checksum', char(prop.getValueChecksum(ind)));
    
    if prop.valueCount() == 1
        sub = tmpsub;
    else
        sub.(['Value' num2str(ind+1)]) = tmpsub;
    end
    
end

% insert the created substructure in the main structure
name = adapt_field_name(char(prop.getName()), 'Property_');
new_struc.(name) = sub;

end

function new_struc = setfield_if_not_empty(struc, field, value)
% an equivalent of the setfield function but creating the new field only
% if the given value is not empty

if isempty(value)
    new_struc = struc;
else
    new_struc = setfield(struc, field, value);
end

end

function new_name = adapt_field_name(name, prefix)
% modifies name so that it can be used as a valid structure field name

% replace the special characters by '_'
new_name = regexprep(name, '[^a-zA-Z0-9]', '_');

if regexprep(new_name(1),'[^0-9_]','')
    % the first character of the name is a number or the character '_'
    % so the name must be modified to be usable as a structure field
    % by adding a prefix starting with a letter
    new_name = [prefix, new_name];
end

end

function converted_val = convert_value(val, type, convert_tuple)
% converts a value to the most adapted MATLAB type

converted_val = val;
if any(strcmpi(type, {'date', 'time', 'datetime'}))
    converted_val = convert_datetime(val, type);
elseif strcmpi(type, 'url')
    converted_val = char(val);
elseif convert_tuple && (~isempty(strfind(type, '-Tuple')) ...
        || ~isempty(strfind(type, '-tuple')))
    converted_val = convert_tuple_value(val);
end
    
end

function converted_val = convert_tuple_value(val)
% convert tuples string to a more useful MATLAB class

% The n-Tuple format is not precisely constrainted according to
% the odML article which says:
% n-Tuple are typically integer or float values but there is no
% hard restriction in the format.
% So we will try our best to store the value in the most
% convenient way in MATLAB

% try to convert the tuple to a row vector of doubles
% WARNING: str2num uses eval and is completely unsafe (it can
% be used to run arbitrary matlab code passed to the function,
% try str2num(plot(rand(100,1))) for example to get a feel of
% it...

% if the conversion doesn't work, we will just return the input
converted_val = val;

tmp = str2num(val(2:end-1)).';
if isempty(tmp)
    % converting the tuple to a vector of doubles didn't work
    try
        % try to convert the tuple to a row cell vector
        % WARNING: using eval here is completely unsafe, with
        % the same problem than with str2num
        eval(['tmp = {' val(2:end-1) '}.'';']);
        if ~isempty(tmp)
            converted_val = tmp;
        end
    end 
else
    converted_val = tmp;
end

end

function str = convert_datetime(java_datetime, type)
% converts a Java datetime to a string adapting the format to the type of
% value

if ~isempty(java_datetime)
    date_vector = [java_datetime.getYear()+1900, ...
        java_datetime.getMonth()+1, java_datetime.getDate(), ...
        java_datetime.getHours(), java_datetime.getMinutes(), ...
        java_datetime.getSeconds()];

    switch type
        case 'date'
            format = 'yyyy-mm-dd';
        case 'time'
            format = 'HH:MM:ss';
        case 'datetime'
            format = 'yyyy-mm-dd HH:MM:ss';
    end

    str = datestr(date_vector, format);
else
    str = java_datetime;
end

end

