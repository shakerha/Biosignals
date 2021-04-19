classdef NeuralNetwork < AbstractClassifier
    %NEURALNETWORK Manages a patternet classifier
    %   patternnet: A two-layer feed-forward network, with sigmoid hidden 
    %   and softmax output neurons. Stores the classifier and includes a
    %   classification function
    % 
    
    properties (Access = private)
        net;
        hiddenlayer;
    end
    
     methods (Access = public)
        function obj = NeuralNetwork(runName, hiddenlayer)
            obj = obj@AbstractClassifier(runName);
            if nargin == 2
               obj.hiddenlayer = hiddenlayer; 
            else
               obj.hiddenlayer = 10;
            end
        end
        
        function results = classify(obj, fvTest, fvTestClasses, fvTrain, fvTrainClasses, store)
            %CLASSIFY Classifies the given test data with a patternnet.
            % (two-layer feed-forward network, with sigmoid hidden and 
            % softmax output neurons). If there is no network with the 
            % object's name, the methods trains a new net with the given
            % training data, names it with the object's name and stores it.
            %
            % results = CLASSIFY(obj, fvTest, fvTestClasses, fvTrain, fvTrainClasses)
            %
            % fvTrain and fvTest are organized as:
            % fvTrain/fvTest = [featureVector 1;
            %                   featureVector 2;
            %                        ...
            %                   featureVector n]
            %
            % fvTrainClasses and fvTestClasses are organized as:
            % fvTrainClasses/fvTestClasses = [class 1;
            %                                 class 2;
            %                                   ...
            %                                 class n]
            %
            % results is organized as:
            % results = [class 1; 
            %            class 2; 
            %              ...
            %            class n]
            
            runName = obj.getName();
            fpath = strcat(pwd(), '/storage/', runName, '.mat');
            if exist(fpath, 'file') == 2
                fprintf('Loading network: %s\n', runName);
                load(fpath, 'net');
                obj.net = net;
            else
                %fprintf('Training networks and save: %s\n', runName);
                obj.trainNet(fvTrain, fvTrainClasses);
                if store
                    net = obj.net;
                    save(fpath, 'net');
                end
            end
            %fprintf('Testing network\n');
            results = obj.testNet(fvTest, fvTestClasses);
        end
     end
     
     
     methods (Access = private)
        function trainNet(obj, fvTrain, fvTrainClasses)
            
            trainFcn = 'trainlm';
            %obj.net = patternnet(obj.hiddenlayer, trainFcn);
            obj.net = patternnet(obj.hiddenlayer);
            
            % obj.net.layers{1}.transferFcn = 'poslin';
            %obj.net.performFcn = 'sse';
            obj.net.performFcn = 'crossentropy';
            
            obj.net.divideFcn = 'dividerand';  % Divide data randomly
            obj.net.divideParam.trainRatio = 85/100;
            obj.net.divideParam.valRatio = 15/100;
            obj.net.divideParam.testRatio = 0/100;
            
            obj.net = train(obj.net, fvTrain', fvTrainClasses');
        end
        
        function results = testNet(obj, fvTest, fvTestClasses)
            y = obj.net(fvTest');
            tind = vec2ind(fvTestClasses');
            yind = vec2ind(y);
            obj.score = sum(tind ~= yind)/numel(tind);
            results = y';
        end
    end
    
end