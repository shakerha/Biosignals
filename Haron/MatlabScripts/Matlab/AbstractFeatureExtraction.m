classdef AbstractFeatureExtraction < handle
    %ABSTRACTFEATUREEXTRACTION Interface for feature extractin classes
    %   Includes a name and a feature extraction function
    
    properties (Access = private)
        name;
    end
    
    methods (Abstract)
        % To implement feature extraction function
        features = extractFeatures(data);
    end
    
    methods (Access = public)
        function obj = AbstractFeatureExtraction(name)
            obj.name = name;
        end
        
        function name = getName(obj)
            name = obj.name;
        end
    end
    
end

