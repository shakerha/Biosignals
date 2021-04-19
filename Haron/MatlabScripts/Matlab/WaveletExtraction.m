classdef WaveletExtraction < AbstractFeatureExtraction 
    %WAVELETEXTRACTION Performs a wavelet decomposition and extracts features
    %   Includes a level filter  and feature extraction function 
    
    properties (Access = public)
        name;
        level;
        filter;
    end
    
    methods (Access = public)
        function obj = WaveletExtraction(level, filter)
            obj = obj@AbstractFeatureExtraction('WaveletExtraction');
            obj.level = level;
            obj.filter = filter;
        end
        
        function features = extractFeatures(obj, data)
            %EXTRACTFEATURES Performs feature extraction on the given data
            % with the objects wavelet filter and level. The calculated
            % features are: Max, Min, Mean and Std of the wavelet
            % coefficients, wavelet entropy and relative wavelet energy.
            %
            % features = extractFeatures(obj, data)
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
            % Where every feature vector is composed of the extracted 
            % features
            
            features = zeros(size(data, 1), 6*(obj.level+1));
            for curData = 1:size(data, 1)
                features(curData, :) = obj.createFeatureVector(data(curData, :));
            end
        end
    end
    
    methods (Access = public)
        function featureVector = createFeatureVector(obj, data)
           % perform wavelet decomposition
           [c,l] = wavedec(data, obj.level, obj.filter);
           [ea, ed] = wenergy(c,l);
           energy = [ea, ed];
           
           offset = 6;
           featureVector = zeros(1, offset*(obj.level+1));
           coffset = 1;
           soffset = 1;
           for n = 3:obj.level+1
               coeff = c(1, coffset:coffset+l(n)-1);
               entropy = wentropy(coeff, 'log energy');
               rwe = energy(1, n);
               featureVector(1, soffset:soffset+offset-1) = [max(coeff), min(coeff), mean(coeff), std(coeff), entropy, rwe];
               soffset = soffset + offset;
               coffset = coffset + l(n);
           end 
        end
    end
    
end

