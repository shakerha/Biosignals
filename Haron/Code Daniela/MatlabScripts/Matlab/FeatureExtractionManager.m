classdef FeatureExtractionManager < handle
    %FEATUREEXTRACTIONMANAGER Manages feature extraction classes
    %   Includes a list  of feature extraction classes and a feature 
    %   extraction function
    
    properties (Access = private)
        featureExtractionList;
    end
    
    methods (Access = public)
        function obj = FeatureExtractionManager()
            obj = obj@handle();
            obj.featureExtractionList = {};
        end
        
        function addFeatureExtraction(obj, featureExtractionClass)
            %ADDFEATUREEXTRACTION Adds a feature extraction object to the
            % Feature Extraction Manager's feature extraction list.
            %
            % ADDFEATUREEXTRACTION(obj, featureExtractionClass)
            %
            % featureExtractionClass is of type AbstractFeatureExtraction
            
            obj.featureExtractionList{length(obj.featureExtractionList)+1} =  featureExtractionClass;  
        end
        
        function clearFeatureExtractionList(obj)
            obj.featureExtractionList = {};
        end
        
        function EEG = extractFeatures(obj, eegs)
            %EXTRACTFEATURES Performs feature extraction on the given
            % records with the feature extraction classes in the feature 
            % extraction list and replaces the records raw data by the
            % extracted features.
            %
            % EXTRACTFEATURES(obj, eegs)
            %
            % eegs is a row vector containing Record objects:
            % eegs = [Record 1, Record 2, ..., Record n]
            
            EEG = {};
            for n = 1:size(eegs,2)
                curEEG = eegs(1:2,n);
                EEG{n}= obj.extractFeaturesRawData(curEEG); 
            end
            fprintf('Performed feature extraction and updated epochs\n');
        end
        
    end
    
    
    methods (Access = private)
        function features = extractFeaturesRawData(obj, data)
            %EXTRACTFEATURESRAWDATA Performs feature extraction on the 
            % given data with the feature extraction classes in the feature
            % extraction list.
            %
            % features = EXTRACTFEATURESRAWDATA(obj, data)
            %
            % data is organized as:
            % data = [raw data 1;
            %         raw data 2;
            %             ...
            %         raw data n]
            %
            % features is organized as:
            % features = [feature vector 1;
            %             feature vector 2;
            %                  ...
            %             feature vector n]
            % Where every feature vector is composed of the features
            % extcrated from the feature extraction classes:
            % feature vector 1 = [features 1, features 2, ..., features m]
            
            tmpfeatures = cell(1, length(obj.featureExtractionList));
            sumcols = 0;
            allrows = 0;
            for i = 1:length(obj.featureExtractionList)
                fec = obj.featureExtractionList{i};
                tmpfeatures{i} = fec.extractFeatures(data);
                [rows, cols] = size(tmpfeatures{i});
                if i == 1
                    allrows = rows;
                end
                if rows ~= allrows
                    error('number of rows should be identical');
                end
                sumcols = sumcols + cols;
            end
            features = zeros(allrows, sumcols);
            offset = 1;
            for i = 1:length(obj.featureExtractionList)
                [rows, cols] = size(tmpfeatures{i});
                features(1:rows, offset:offset+cols-1) = tmpfeatures{i};
                offset = offset + cols;
            end
        end
        
    end
    
end

