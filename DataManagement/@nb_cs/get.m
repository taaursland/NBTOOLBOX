function propertyValue = get(obj,propertyName)
% Syntax:
%
% propertyValue = get(obj,propertyName)
%
% Description:
%
% Get the properties of the object
% 
% Input:
% 
% - obj          : An object of class nb_ts
% 
% - propertyName : Name of the property you want to get:
% 
%     - 'data'                 : The data of the object as a double
%     - 'dataNames'            : Name of the object datasets, as 
%                                cellstr array
%     - 'numberOfDatasets'     : Number of datasets (pages) of the 
%                                object. Size of the third 
%                                dimension
%     - 'numberOfTypes'        : Number of types of the object.
%                                Size of the first dimension
%     - 'numberOfVariables'    : Number of variables of the object.
%                                Size of the second dimension
%     - 'types'                : The types of the object as a  
%                                cellstr array
%     - 'variables'            : The variables of the object, given 
%                                as a cellstr array
%     - 'links'                : A structure of the data source
%                                links.
%     - 'sorted'               : true or false
%     - 'updateable'           : 1 if updateable, 0 otherwise.
% 
% Output:
% 
% propertyValue : The property value of the object for the wanted 
%                 property
%                       
% Examples:
% 
% dataAsDouble = get(obj,'data');
% variables    = get(obj,'variables')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(propertyName)

        case 'data'

            propertyValue = obj.data;
            
        case 'datanames'
            
            propertyValue = obj.dataNames;

        case 'numberofdatasets'

            propertyValue = obj.numberOfDatasets; 

        case 'numberoftypes'

            propertyValue = obj.numberOfTypes;

        case 'numberofvariables'

            propertyValue = obj.numberOfVariables;    

        case 'types'

            propertyValue = obj.types;

        case 'variables'
            
            propertyValue = obj.variables;
            
        case 'links'
            
            propertyValue = obj.links;
            
        case 'sorted'
            
            propertyValue = obj.sorted;
                
        case 'updateable'
            
            propertyValue = obj.updateable;
            
        otherwise

            error([mfilename ':: Bad property ' propertyName])

    end

end
