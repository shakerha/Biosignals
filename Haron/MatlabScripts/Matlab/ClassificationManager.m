classdef ClassificationManager < handle
    %CLASSIFICATIONMANAGER Manages classifier classes
    %   Includes a classifier list, a classification function and 
    %   evaluation functions for error and performance measuring
    
    properties (Access = private)
        classifierList;
        store;
        score;
    end
    
    methods (Access = public)
        function obj = ClassificationManager(store)
            obj = obj@handle();
            obj.classifierList = {};
            if nargin == 2
                obj.store = store;
            else
                obj.store = false;
            end
        end
        
        function addClassifier(obj, classifier)
            %ADDCLASSIFIER Adds a classifier object to the Classification
            % Manager's classifier list.
            %
            % addClassifier(obj, classifier)
            %
            % classifier is of type AbstractClassifier
            
            obj.classifierList{length(obj.classifierList)+1} =  classifier;
        end
        
        function clearClassifierList(obj)
            obj.classifierList = {};
        end
        
        function store = getStore(obj)
            store = obj.store;
        end
        
        function setStore(obj, value)
            obj.store = value;
        end
        
        function names = getClassifierNames(obj)
            %GETCLASSIFIERNAMES Returns the names of all classifier objects
            % in the Classification Manager's classifier list.
            %
            % names = getClassifierNames(obj)
            %
            % names is organized in a cell array (1 x n):
            % names = {'1. classifier', '2. classifier', ..., 'n. classifier'}
            
            numClassifiers = numel(obj.classifierList);
            names = cell(1, numClassifiers);
            for n = 1:numClassifiers
                cls = obj.classifierList{n};
                names{1, n} = cls.getName();
            end
        end
        
        function [aresults, ascore] = classify(obj, test, testClasses, train, trainClasses)
            tmpResults = obj.classifyEpochs(test, testClasses, train, trainClasses);
            [aresults, ascore] = obj.vote(tmpResults, test, testClasses, 0.5);
        end
        
        function results = classifyEpochs(obj, test, testClasses, train, trainClasses)
            %CLASSIFYEPOCHS Classifies the epochs contained in the given test 
            % data with the classifiers in the classifier list of the 
            % ClassificationManager. Returns the results for every 
            % classifier in the cell array results.
            %
            % results = CLASSIFYEPOCHS(obj, test, testClasses, train, trainClasses)
            %
            % train and test are row vector containing Record objects:
            % train/test = [Record 1, Record 2, ..., Record n]
            %
            % trainClasses and testClasses are organized as:
            % trainClasses/testClasses = [class 1;
            %                             class 2;
            %                               ...
            %                             class n]
            %
            % results is organized as:
            % results = {results from 1. classifier, 
            %            results from 2. classifier, 
            %                     ..., 
            %            results from m. classifier}
            
            % Extract data epochs from all Record objects
            trainData = vertcat(train.data);
            testData = vertcat(test.data);
            
            % Extend classes according to the epochs
            tmpTrainClasses = zeros(size(trainData, 1), size(trainClasses, 2));
            tmpTestClasses = zeros(size(testData, 1), size(testClasses, 2));
            c = 1;
            for n = 1:length(train)
                % Number of epochs of the current Record
                numCls = size(train(n).data, 1);
                % Copy the record's class for all epochs
                cls = repmat(trainClasses(n,:), [numCls, 1]);
                tmpTrainClasses(c:c+numCls-1, :) = cls;
                c = c + numCls;
            end
            trainClasses = tmpTrainClasses;
            c = 1;
            for n = 1:length(test)
                % Number of epochs of the current Record
                numCls = size(test(n).data, 1);
                % Copy the record's class for all epochs
                cls = repmat(testClasses(n,:), [numCls, 1]);
                tmpTestClasses(c:c+numCls-1, :) = cls;
                c = c + numCls;
            end
            testClasses = tmpTestClasses;
            
            results = cell(1, length(obj.classifierList));
            for i = 1:length(obj.classifierList)
                cls = obj.classifierList{i};
                disp(['Applying ' cls.getName()]);
                results{i} = cls.classify(testData, testClasses, trainData, trainClasses, obj.store);
            end
            
            numClassifiers = numel(obj.classifierList);
            obj.score = zeros(1, numClassifiers);
            for i = 1:numClassifiers
                cls = obj.classifierList{i};
                obj.score(1, i) = cls.getScore();
            end
            
        end
        
        function [newResults, newScore] = vote(obj, results, eegs, classes, t)
            %VOTE Classifies the given EEG records via a voting over their
            % epochs. For multiple results the average is taken.
            %
            % VOTE(obj, results, eegs, testClasses)
            %
            % eegs is a row vector containing Record objects:
            % eegs = [Record 1, Record 2, ..., Record n]
            %
            % results is organized as:
            % results = {results from 1. classifier, 
            %            results from 2. classifier, 
            %                     ..., 
            %            results from m. classifier}
            %
            % classes is organized as:
            % classes = [class 1;
            %            class 2;
            %             ...
            %            class n]
            
            averageResults = zeros(size(results{1}));
            
            for n = 1:numel(results)
                averageResults = averageResults + results{n};
            end
            averageResults = averageResults / numel(results);
            
            newResults = obj.helpVote(averageResults, eegs, classes, t);
            
            tind = vec2ind(classes');
            yind = vec2ind(newResults');
            newScore = sum(tind ~= yind)/numel(tind);
            
        end
        
        function score = getScore(obj)
            %GETSCORE Returns the score (error rate) for every classifier
            % in the classifier list of the ClassificationManager. The
            % scores are put into a score vector.
            %
            % score = GETSCORE(obj)
            %
            % score is organized as:
            % score = [score of cls 1, score of cls 2, ..., score of cls n]
            
            score = obj.score;
        end
        
        function [threshold, AUC, Yind] = roc(obj, tmpResults, testData, testClasses)
            averageResults = zeros(size(tmpResults{1}));
            
            for n = 1:numel(tmpResults)
                averageResults = averageResults + tmpResults{n};
            end
            averageResults = averageResults / numel(tmpResults);
            
            results = obj.helpVoteROC(averageResults, testData, testClasses);
            
            ntestClasses = testClasses(:,1);
            nresults = results(:,1);
            
            [X,Y,T,AUC] = perfcurve(ntestClasses, nresults, 1);
            Yind = Y + (ones(size(X)) - X) - 1;
            [Yind, BestTr] = max(Yind);
            plot(X,Y);
            hold on;
            rline = linspace(0, 1, length(X));
            plot(rline, rline);
            xlabel('1- Specificity');
            ylabel('Sensitivity');
            hold off;
            threshold = T(BestTr);
        end
        
    end
    
    
    methods(Access = private)
       
       function newResults = helpVote(~, results, eegs, classes, t)
            %VOTING
            c = 1;
            newResults = zeros(size(classes));
            for n = 1:length(eegs)
                curEEG = eegs(n);
                tmpRes = zeros(1, size(classes, 2));
                for k = 1:size(curEEG.data, 1)
                    tmpRes = tmpRes + results(c, :);
                    c = c +1;
                end
                if ~isempty(curEEG.data)
                    tmpRes = tmpRes / size(curEEG.data, 1);
                end
                if tmpRes(1) >= t || tmpRes(2) == 0
                    tmpRes = [1 0]; 
                else
                    tmpRes = [0 1];
                end
                newResults(n,:) = tmpRes;
            end
       end
       
       function newResults = helpVoteROC(~, results, eegs, classes)
            %VOTING
            c = 1;
            newResults = zeros(size(classes));
            for n = 1:length(eegs)
                curEEG = eegs(n);
                tmpRes = zeros(1, size(classes, 2));
                for k = 1:size(curEEG.data, 1)
                    tmpRes = tmpRes + results(c, :);
                    c = c +1;
                end
                if ~isempty(curEEG.data)
                    tmpRes = tmpRes / size(curEEG.data, 1);
                end
                if tmpRes(2) == 0
                    tmpRes = [1 0];
                end
                newResults(n,:) = tmpRes;
            end
       end
       
    end
    
end