%to be able to call single functions from this script 
function excelDataFunctions = scriptWorkWithExcelData
   
    excelDataFunctions.createAlphaTheta = @createAlphaTheta; 
    excelDataFunctions.createBrainwaves = @createBrainwaves; 
    excelDataFunctions.getMedicalDataFromExcelSheet = @getMedicalDataFromExcelSheet; 
    excelDataFunctions.findClozapineInCellArray = @findClozapineInCellArray; 
    excelDataFunctions.getDataAndSubfoldersFromStringInCellArray = @getDataAndSubfoldersFromStringInCellArray; 
end 


% calcualtes power spectral density for data from an EDF file for all its
% frequencies and channels
% data              expects readin EEG data from eeglab
% srate             sampling rate
% windowsize        windows size to analyze the EEG data
% overlap           overlapt between the windows 
% returns rows for alpha, beta, gamma, delta, theta ways for all channels
%   in the EEG data
% returns times from spectrogram function 
%   "a vector of time instants, t, at which the spectrogram is computed."
function [powerAlpha, powerTheta, powerDelta, powerBeta, powerGamma, times] = createBrainwaves(data,srate,windowsize,overlap)
    %define various brain wave frequencies as told by Ekaterina
    theta=[3.5 7.5];
    alpha=[7.5 12.5];
    delta = [1 3.5]; 
    beta = [12.5 25];
    gamma = [25 60]; %gamma technically open ended
   

    [channels, length] = size(data);
    windowsize = windowsize*srate;
    if windowsize > length
        windowsize = length;
        overlap = 0;
    end
    
    overlap = overlap*srate;
    
    %define rows of data
    rowsTheta = cell(channels, 1); 
    rowsAlpha = cell(channels, 1); 
    rowsDelta = cell(channels, 1);  
    rowsBeta = cell(channels, 1); 
    rowsGamma = cell(channels, 1);     
    
    for i = 1:channels
        %fshort time fourier transform an the data.
        %get data per channel 
        channelData = data(i,:); 
        [~ , f, times, ps] = spectrogram(channelData, windowsize, overlap, [], srate);        
        
        rowsTheta{i} = f > theta(1) & f < theta(2);
        rowsAlpha{i} = f > alpha(1) & f < alpha(2);
        rowsDelta{i} = f > delta(1) & f < delta(2); 
        rowsBeta{i} = f > beta(1) & f < beta(2); 
        rowsGamma{i} = f > gamma(1) & f < gamma(2);      
        
        powerAlpha{1,i}= sum(ps(rowsAlpha{i},:)); 
        powerBeta{1,i} = sum(ps(rowsBeta{i},:)); 
        powerGamma{1,i} = sum(ps(rowsGamma{i},:)); 
        powerDelta{1,i} = sum(ps(rowsDelta{i},:)); 
        powerTheta{1,i} = sum(ps(rowsTheta{i},:)); 
        
    end


    
    
end 


%works, needs to be rewritten with try catch and without breaktime
%needs a better name since it's downloading the txt data and not read the
%medicin from xls data
%TODO
function getMedicalDataFromExcelSheet(xlsTxtData, medsCell, breaktime)
    import matlab.net.http.*
    xlsTxtData= cellfun(@(x) x(1:end-1), list, 'UniformOutput', false);
    for i = 1:length(xlsTxtData)

        % get all the txt file
        creds = Credentials('Username', 'nedc', 'Password', 'nedc_resources'); 
        options = HTTPOptions('Credentials', creds); 
        url = xlsTxtData{5 + i , 1};
        resp = RequestMessage().send(url, options);

        textHTML = extractHTMLText(resp.Body.Data); 
        %temp save file
        fileID = fopen('temp.txt', 'w'); 
        fprintf(fileID, '%s', resp.Body.Data); 
        fclose(fileID); 

        obj = InformationExtraxtor('temp.txt', 'txt'); 
        meds = extractMedication(obj); 
        medsCell{i+1, 1} = url; 
        medsCell{i+1,2} = meds; 

        pause(breaktime);

    end 

end

%filters out all txt data with soem pattern as a medicament
%from a cellarray (aka big xls file with server folder structure)
% xlsTxtData    extracted drugs data from the txt files for each edf file
% (zugesendete xls, mit vierte Spalte 'medicine'
% medsCell      cellArray
% pattern       pattern for a drug which should be looked for 
function medsCell = findClozapineInCellArray(xlsTxtData, medsCell, pattern)
    funcs=functionsForTUHData;
    j = 2; 
    for i = 1:size(xlsTxtData, 1)
        meds = xlsTxtData{i,4};  %4 greift auf spalte ein, die die medizin enthält.
        %bClozapineExists = funcs.searchClozapine(meds); 
        bClozapineExists = searchForMedication(meds, pattern);
       if bClozapineExists
            medsCell{j,1} = xlsTxtData{i,1}; 
            medsCell{j,2} = xlsTxtData{i,4}; 
            j = j+1; 
        end 
    end 

end 

%filters out all folder strings with the same starting substring
%use case: get all subfolders from a patient with a specific medicine 
% cellArray         cell array in which a prefix is to be found
% substring         folder/url prefix string 
%might be buggy, needs more tests
function cellArray = getDataAndSubfoldersFromStringInCellArray(cellArray, substring)

    len = length(substring); 
    cellArray = cellArray(strncmp(substring, cellArray(:,1), len), :);
end


%searches for drugs for a pattern
% medication    original string data in which drug is searched
% pattern       pattern for a drug to be searched for
function medsIntake=searchForMedication(medication, pattern)
    clozapinePatterns=pattern;
    medsIntake=false;
    
    %check what kind of input was given to the function
    if ischar(medication)
        medication = lower(medication); 
    elseif ismissing(medication) || isa(medication, 'double')
        return;  
    else 
        medication=lower(medication{:,:});
    end
    for patternNr=1:size(clozapinePatterns)
        if sum(contains(medication,clozapinePatterns(patternNr))>0)
            medsIntake=true;
            break;
        end
    end
end