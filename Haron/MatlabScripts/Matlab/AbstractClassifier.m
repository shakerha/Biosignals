classdef AbstractClassifier < handle
    %ABSTRACTCLASSIFIER Interface for classifier classes
    %   Includes a name, a score and a classification function
    
    properties
        name;
        score;
    end
    
    methods (Abstract)
        % To implement classification function
        results = classify(obj, fvTest, fvTestClasses, fvTrain, fvTrainClasses, runName)
    end
    
    methods (Access = public)
        function obj = AbstractClassifier(name)
            obj.name = name;
        end
                
        function name = getName(obj)
            name = obj.name;
        end
        
        function score = getScore(obj)
            score = obj.score;
        end
    end
    
end

