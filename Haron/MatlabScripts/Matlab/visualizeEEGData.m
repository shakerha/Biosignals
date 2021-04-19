%add eeglab to path and start its init file%
addpath('eeglab2019_1\'); 
eeglab; 

%read data into Matlab
dataNormal = readcell('1_normal_allChannelAllFreq_all.xls');
dataRisperidone = readcell('1_risperidone_allChannelAllFreq_all.xls');
dataClozapine = readcell('1_clozapin_allChannelAllFreq.xls');

%calculate statistics with sampling
calcPValueAndMoreWithSampling(dataNormal, dataClozapine, 'clozapine', 15, 95, 85);


% calculates accumulating power data for all frequencies and all channels 
% folder    name of the folder with xlsx files containing power density data
% filename  filename in which the function output data should be saved in 
function calcAllFreqAllChannel(folder, filename)
    
    funcs = functionsForTUHData; 
    list = funcs.createFileList('xlsx',folder);
    data = {}; 
    k = 1;
    
    %setup all channel and frequency names
    [channels, frequencies] = setUpChannelsFrequencies;
    %loop through all of them, takes a lot of time if the file list is long
    for i = 1:length(channels)
        for j= 1:length(frequencies)

            text = strcat(channels{i}, '_', frequencies{j});
            data{1,k} = text;
            
            %use createDataClozapine function if clozapine is calculated 
            x = table2cell(createData(list, channels{i}, frequencies{j}));
            data(2:length(x)+1,k) = x(1:length(x),1);
            
            str = strcat(channels{i},'_', frequencies{j}, '_____', int2str(k) , '/', int2str(19*5), '_done');
            k = k+1;
            disp(str);
        end

    end

    writecell(data, filename);
end

% calculates accumulating power data for one channel with one frequency 
% list      list of xlsx files
% channel   channel name e.g. F4, O1,...
% frequency freq name e.g. powerAlpha, powerBeta
function returnData = createData(list, channel, frequency)

    logical = not( cellfun( @isempty, strfind( list, frequency) ) ); 
    listFrequency = list(logical, :); 
    
    logical = not( cellfun( @isempty, strfind( list, 'channelData') ) );
    listChannel = list(logical,:);
    
    cellArrayData{1,1} = [];
    for i= 1:length(listFrequency)
        %channel
        dataChannel = readcell(listChannel{i});
        index = find(contains(dataChannel, channel));
        
        if length(index) > 1
            index = index(1,1);
        elseif length(index) == 0
            continue; 
        end
        
        %frequency
        data = readcell(listFrequency{i}); 
        mat = cell2mat(data);
        meanData = mean(mat,1); 

        data = mat2cell(meanData, 1, length(meanData));
        temp = num2cell(data{1,1});
        cellArrayData(i,1) = temp(index);  
    end
    
        returnData = cell2table(cellArrayData); 
        
end



% calculates accumulating power data for one channel with one frequency 
% special function to deal with some of the clozapine files
% it was faster to hardcode for Clozapine than to rewirte the function 

% list      list of xlsx files
% channel   channel name e.g. F4, O1,...
% frequency freq name e.g. powerAlpha, powerBeta

% TODO  rewrite function to check for files with several parts (e.g. xxxx_t000.edf xxxx_t001.edf)
function returnData = createDataClozapine(list, channel, frequency)

    logical = not( cellfun( @isempty, strfind( list, frequency) ) ); 
    listFrequency = list(logical, :); 
    
    logical = not( cellfun( @isempty, strfind( list, 'channelData') ) );
    listChannel = list(logical,:);
    
    
    cellArrayData{1,1} = [];
    for i= 1:length(listFrequency)
        %channel
        dataChannel = readcell(listChannel{i});
        index = find(contains(dataChannel, channel));
        
        if length(index) > 1
            index = index(1,1);
        elseif length(index) == 0
            continue; 
        end
        
        %frequency
        data = readcell(listFrequency{i}); 
        mat = cell2mat(data);
        meanData = mean(mat,1); 

        data = mat2cell(meanData, 1, length(meanData));
        temp = num2cell(data{1,1});
        cellArrayData(i,1) = temp(index);  
    end
    
    clozapineArray = {}; 
    clozapineArray(1,1) = cellArrayData(1); %3264
   
    clozapineArray(2,1) = num2cell(mean(cell2mat(cellArrayData(2:3,:)))); %5019
    
    %5021
    clozapineArray(3,:) = num2cell(mean(cell2mat(cellArrayData(4:5,:))));
    
    clozapineArray(4:9,:) = cellArrayData(6:11,:); %5894, 5931, 9063, 9270, 9509, 10943
    
    %11905
    clozapineArray(10,:) = num2cell(mean(cell2mat(cellArrayData(12:13,:))));
    
    %12438_s2
    clozapineArray(11,:) = num2cell(mean(cell2mat(cellArrayData(14:15,:))));
    
    %12438_s3
    clozapineArray(12,:) = num2cell(mean(cell2mat(cellArrayData(16:26,:))));
    
    %12438_s4
    clozapineArray(13,:) = num2cell(mean(cell2mat(cellArrayData(27:29,:))));
    
    %14388
    clozapineArray(14,:) = num2cell(mean(cell2mat(cellArrayData(30:31,:))));
    
    returnData = cell2table(clozapineArray);
        
end

%  calculates the power spectral density for a list of edf files
%  list         List of edf files with folder paths 
%  windowSize   window size for the time data in the edf files, e.g. 1s
%  overlapSize  overlap between the windows, e.g. 0,5sec
function calculatePowerForBands(list, windowSize, overlapSize)

    for i = 1:length(list)
        %get folder path for the file
        %folder path seperator in here \ not / 
        temp = strsplit(list{i}, '\'); 
        filename = temp(end); 
        temp(end) = '';
        folderpath = strcat(strjoin(temp, '\'), '\'); 

        %read edf file
        EEGData = pop_biosig(list{i},'importevent','off','importannot','off'); 
        srate = EEGData.srate;

        %calculate power spectral density 
        eegFunctions = scriptWorkWithExcelData;    
        [powerAlpha, powerTheta, powerDelta, powerBeta, powerGamma, times] = eegFunctions.createBrainwaves(EEGData.data,srate,windowSize,overlapSize);

        %saved in txt file for each edf file 
        %transpose cellArrays, otherwise too many columns
        t_powerAlpha = cellfun(@transpose, powerAlpha, 'UniformOutput', false); 
        t_powerBeta = cellfun(@transpose, powerBeta, 'UniformOutput', false);
        t_powerGamma = cellfun(@transpose, powerGamma, 'UniformOutput', false);
        t_powerDelta = cellfun(@transpose, powerDelta, 'UniformOutput', false);
        t_powerTheta = cellfun(@transpose, powerTheta, 'UniformOutput', false);

        %only has one row/column
        t_times = transpose(times);
        writematrix(t_times,strcat(folderpath, filename{1}, '_times.xlsx'));
        
        %save channel data
        channelData = struct2cell(EEGData.chanlocs);
        channelData = channelData(1,:); 
        writecell(channelData, strcat(folderpath, filename{1}, '_channelData.xlsx'));
        
        
        %all power channels have the same size
        %write powers into excel files, xlsx file type is a must since
        %available dimensions in xls are too small
        for j = 1: size(powerAlpha, 2)
            %TODO test if I can write all data into one xls file and not several
            column = strcat(xlscol(j), '1'); 
            writematrix(t_powerAlpha{j}, strcat(folderpath, filename{1}, '_powerAlpha.xlsx'), 'Range', column);
            writematrix(t_powerBeta{j}, strcat(folderpath, filename{1}, '_powerBeta.xlsx'), 'Range', column);
            writematrix(t_powerGamma{j}, strcat(folderpath, filename{1}, '_powerGamma.xlsx'),  'Range', column);
            writematrix(t_powerDelta{j}, strcat(folderpath, filename{1}, '_powerDelta.xlsx'),  'Range', column);
            writematrix(t_powerTheta{j}, strcat(folderpath, filename{1}, '_powerTheta.xlsx'),  'Range', column);

        end 
    end 
end 

% calculates statistics for normal and medical data
% dataNormal   accumulated power data for normal set           
% dataMeds     accumulated power data for drug set
% nameMeds     name of the medicine from the dataMeds set
% outlierPercentage      percentage to remove outliers for normal set e.g. 95
% outlierPercentageMeds  percentage to remove outliers for drug set e.g. 95
function calcPValueAndMore(dataNormal, dataMeds, nameMeds, outlierPercentage,outlierPercentageMeds)

    data = {};

    for i = 1:size(dataNormal,2)

        normal = {};
        meds = {};

        normal = cell2mat(dataNormal(2:size(dataNormal,1), i));
        meds = cell2mat(dataMeds(2:size(dataMeds,1),i)); 
        
        %check if channel and frequency are the same 
        %should always be the same 
        if strcmp(dataNormal(1,i), dataMeds(1,i))

            %after every 5th set we have enough data to calcuate alpha/band
            %and alpha/theta
            x = mod(i,5);
            switch x
                case 1
                    alphaNormal =  (normal);
                    alphaMeds = (meds); 
                case 2
                    betaNormal = (normal);
                    betaMeds = (meds);
                case 3
                    gammaNormal = (normal);
                    gammaMeds = (meds);
                case 4
                    deltaNormal = (normal);
                    deltaMeds = (meds);
                case 0
                    thetaNormal = (normal);
                    thetaMeds = (meds);
                    
                    data{1,6} = 'alpha/theta mean Normal';
                    normalAT = alphaNormal./thetaNormal;
                    normalAT = rmoutliers(normalAT, 'percentiles', [0 outlierPercentage]);
                    data{i+1,6} = mean(normalAT); 
                    
                    data{1,7} = strcat('alpha/theta mean', nameMeds);
                    medsAT = alphaMeds./thetaMeds;
                    medsAT = rmoutliers(medsAT, 'percentiles', [0 outlierPercentageMeds]);
                    data{i+1,7} = mean(medsAT);
                    
                    [h,p] = ttest2(normalAT, medsAT);
                    data{1,8} = strcat('alpha/theta pvalue', nameMeds);
                    data{i+1,8} = p;
                    
                    
                    data{1,9} = 'alpha/band mean Normal';
                    %calculate first otherwise dimenions might not work out
                    normalAB = alphaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
                    %then remove the outliers
                    normalAB = rmoutliers(normalAB, 'percentiles', [0 outlierPercentage]);
                    data{i+1,9} = mean(normalAB);
                   
                    data{1,10} = strcat('alpha/band mean', nameMeds);
                    %calculate first otherwise dimenions might not work out
                    medsAB = alphaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
                    %then remove the outliers
                    medsAB = rmoutliers(medsAB, 'percentiles', [0 outlierPercentageMeds]);
                    data{i+1,10} = mean(medsAB);
                    
                    [h,p] = ttest2(normalAB, medsAB);
                    data{1,11} = 'alpha/band pValue';
                    data{i+1,11} = p;
                    

                otherwise
                    disp('not supposed to reach this');
            end
            

            normal = rmoutliers(normal, 'percentiles', [0 outlierPercentage]);
            meds = rmoutliers(meds, 'percentiles', [0 ourlierPercentageMeds]);

            [h,p] = ttest2(normal, meds);

            data{1,1} = 'Channel_Frequency';
            data{i+1,1} = dataNormal(1,i);

            data{1,2} = strcat('pValue ', nameMeds, ' & normal');
            data{i+1,2} = p;

            data{1,3} = 'data points normal';
            data{i+1,3} = size(normal,1);

            data{1,4} = 'mean normal';
            data{i+1,4} = mean(normal);         

            data{1,5} = 'std normal'; 
            data{i+1,5} = std(normal);         
            
            data{1,12} = strcat('data points ', nameMeds);
            data{i+1,12} = size(meds,1);       

            data{1,13} = strcat('mean ', nameMeds);
            data{i+1,13} = mean(meds); 

            data{1,14} = strcat('std ', nameMeds);
            data{i+1,14} = std(meds); 
            
            
        end

    end
    
    fileName = strcat(nameMeds, '_normal_data_200622.xls'); 
    data = cell2table(data);
    writetable(data, fileName); 

end

% calculates statistics for normal and medical data with sampling
% dataNormal   accumulated power data for normal set           
% dataMeds     accumulated power data for drug set
% nameMeds     name of the medicine from the dataMeds set
% outlierPercentageNormal percentage to remove outliers for normal set e.g. 95
% outlierPercentageMeds   percentage to remove outliers for drug set e.g. 95
function calcPValueAndMoreWithSampling(dataNormal, dataMeds, nameMeds, timesSampling, outlierPercentageNormal, ourlierPercentageMeds)
    
    %lots of set ups
    data = {};
    pValueNormalMeds(1:95) = num2cell(0);
    
    %temporary data for one sampling step 
    tempData = {}; 
    %fill out first row 
    tempData{1,1} = 'alpha/theta mean Normal';
    tempData{1,2} = strcat('alpha/theta mean ', nameMeds);
    tempData{1,3} = strcat('alpha/theta pvalue ', nameMeds);
    tempData{1,4} = 'alpha/band mean Normal';
    tempData{1,5} = strcat('alpha/band mean', nameMeds);
    tempData{1,6} = 'alpha/band pValue';
    %fill out with zeros, otherwise we get data type errors during calculation
    tempData(2:20, 1:6) = num2cell(0);
    
    sampleDataNormal = dataNormal;
    %remove first line with string data, since it could get chosen by
    %randsample and calc won't be possible with string data in it
    sampleDataNormal(1,:) = [];     
    
    for j = 1:timesSampling
     
        % pick random sample of the size of the medicine from normal set
        y = randsample(size(sampleDataNormal,1),size(dataMeds,1));
        data = sampleDataNormal(y,:); 
       
        counter = 1; 
        len = size(dataNormal,2); 
        % calc all values concerning p values
        for i = 1:len
            normal = {};
            meds = {};

            normal = cell2mat(data(2:size(data,1), i));
            meds = cell2mat(dataMeds(2:size(dataMeds,1),i));   
            
            %check if channel and frequency are the same 
            %should always be the same 
            if strcmp(dataNormal(1,i), dataMeds(1,i))
                %after every 5th set we have enough data to calcuate alpha/band
                %and alpha/theta
                x = mod(i,5);         
                switch x
                    case 1
                        alphaNormal = (normal);
                        alphaMeds = (meds); 
                    case 2
                        betaNormal = (normal);
                        betaMeds = (meds);
                    case 3
                        gammaNormal = (normal);
                        gammaMeds = (meds);
                    case 4
                        deltaNormal = (normal);
                        deltaMeds = (meds);
                    case 0
                        thetaNormal = (normal);
                        thetaMeds = (meds);
                        counter = counter +1; 
                        
                        
                        %sum up all the sampling data, we calculate the
                        %mean in the next loop, 
                        %TODO find a more elegant version around
                        normalAT = alphaNormal./thetaNormal;
                        normalAT = rmoutliers(normalAT, 'percentiles', [0 outlierPercentageNormal]);
                        tempData{counter,1} = tempData{counter,1} + mean(normalAT); 
                        
                        medsAT = alphaMeds./thetaMeds;
                        medsAT = rmoutliers(medsAT, 'percentiles', [0 ourlierPercentageMeds]);
                        tempData{counter,2} = tempData{counter,2} + mean(medsAT);

                        [h,p] = ttest2(normalAT, medsAT);
                        tempData{counter,3} = tempData{counter,3}+p;
                        
                        normalAB = alphaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
                        normalAB = rmoutliers(normalAB, 'percentiles', [0 outlierPercentageNormal]);
                        tempData{counter,4} = tempData{counter,4} + mean(normalAB);
                        
                        medsAB = alphaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
                        medsAB = rmoutliers(medsAB, 'percentiles', [0 ourlierPercentageMeds]);
                        tempData{counter,5} = tempData{counter,5}+ mean(medsAB);

                        [h,p] = ttest2(normalAB, medsAB);
                        
                        tempData{counter,6} = tempData{counter,6} + p;

                    otherwise
                        disp('not supposed to reach this');
                end %switch
                

            
            normal = rmoutliers(normal, 'percentiles', [0 outlierPercentageNormal]);
            meds = rmoutliers(meds, 'percentiles', [0 ourlierPercentageMeds]);

            [h,p] = ttest2(normal, meds);
            pValueNormalMeds{i} = pValueNormalMeds{i} + p;
            
            end %if            
            
        end %for i

    end %for j
    
    %reset data cell array and counter
    data = {}; 
    counter = 1; 
    
    % calc the rest of the statistics and fill in pvalue data from previous
    % loop
    for i = 1:size(dataNormal,2)

        normal = {};
        meds = {};

        normal = cell2mat(dataNormal(2:size(dataNormal,1), i));
        meds = cell2mat(dataMeds(2:size(dataMeds,1),i)); 

            if strcmp(dataNormal(1,i), dataMeds(1,i))

                x = mod(i,5);
                if x == 0 
                    counter = counter + 1;
                    % enter sampling numbers divided by times of sampling
                    % aka mean of the sampling data
                    
                    data{1,6} = 'alpha/theta mean Normal';
                    data{i+1,6} = tempData{counter,1}/timesSampling; 

                    data{1,7} = strcat('alpha/theta mean_', nameMeds);
                    data{i+1,7} = tempData{counter,2}/timesSampling; 

                    data{1,8} = strcat('alpha/theta pvalue_', nameMeds);
                    data{i+1,8} = tempData{counter,3}/timesSampling;

                    data{1,9} = 'alpha/band mean Normal';
                    data{i+1,9} = tempData{counter,4}/timesSampling;

                    data{1,10} = strcat('alpha/band mean', nameMeds);
                    data{i+1,10} = tempData{counter,5}/timesSampling;

                    data{1,11} = 'alpha/band pValue';
                    data{i+1,11} = tempData{counter,6}/timesSampling;
                    
                end             

                normal = rmoutliers(normal, 'percentiles', [0 outlierPercentageNormal]);
                meds = rmoutliers(meds, 'percentiles', [0 ourlierPercentageMeds]);

                data{1,1} = 'Channel_Frequency';
                data{i+1,1} = dataNormal(1,i);

                data{1,2} = strcat('pValue_', nameMeds, ' & normal');
                data{i+1,2} = pValueNormalMeds{1,i}/timesSampling;

                data{1,3} = 'data points normal';
                data{i+1,3} = size(normal,1);

                data{1,4} = 'mean normal';
                data{i+1,4} = mean(normal);         

                data{1,5} = 'std normal'; 
                data{i+1,5} = std(normal);         

                data{1,12} = strcat('data points_', nameMeds);
                data{i+1,12} = size(meds,1);       

                data{1,13} = strcat('mean_', nameMeds);
                data{i+1,13} = mean(meds); 

                data{1,14} = strcat('std_', nameMeds);
                data{i+1,14} = std(meds); 


            end

    end
    
    %save calcualted data into an excel sheet   
    fileName = strcat(nameMeds, '_normal_data_sampling_200731.xls'); 
    data = cell2table(data);
    writetable(data, fileName); 
end

%setup function for used strings for channels and frequencies 
function [channels, frequencies] = setUpChannelsFrequencies()

    %constants 
    %channels of EDF files/EEG Data
    channels{1} = 'FP1';
    channels{2} = 'FP2';
    channels{3} = 'F3';
    channels{4} = 'F4';
    channels{5} = 'C3'; 
    channels{6} = 'C4';
    channels{7} = 'P3';
    channels{8} = 'P4';
    channels{9} = 'O1';
    channels{10} = 'O2';
    channels{11} = 'F7';
    channels{12} = 'F8';
    channels{13} = 'T3';
    channels{14} = 'T4';
    channels{15} = 'T5';
    channels{16} = 'T6';
    channels{17} = 'FZ';
    channels{18} = 'CZ';
    channels{19} = 'PZ';

    %frequencies extracted from EDF files/EEG Data
    frequencies{1} = 'powerAlpha';
    frequencies{2} = 'powerBeta';
    frequencies{3} = 'powerGamma';
    frequencies{4} = 'powerDelta';
    frequencies{5} = 'powerTheta';


end

