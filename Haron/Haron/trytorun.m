funcs = functionsForTUHData; 
a = scriptWorkWithExcelData;

% b = scriptWorkWithExcelData;
% funcs = functionsForTUHData; 
% 
% url = 'https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg/v1.1.0/edf/01_tcp_ar/085/00008530/s001_2012_01_04/00008530_s001.txt'
% 
% i = strsplit(url, '/'); 
% y = length(i); 
% fileName = i(y);
% ----------------------------------------------------------------
% htmlTree= '/Users/haron/Desktop/Work/Haron/tryyyy/s001_2012_01_04.html'
% test = a.getAllFolders(htmlTree)

% ----------------------------------------------------------------

% url = 'https://www.mathworks.com/matlabcentral/answers/757104-how-to-get-the-folder-of-an-url?s_tid=srchtitle'
% fileName = url(1: find(url =='/', 1,'last'))
% % ----------------------------------------------------------------

% str = "13-07-2018"
%  datetime(str,'InputFormat','dd-MM-yyyy')
% folder = "xls";
% ----------------------------------------------------------------

% cellArray ='founded_medicine.xls'
% % substring = 'https'
% a.getDataAndSubfoldersFromStringInCellArray(cellArray, substring)

% ----------------------------------------------------------------
% dataNormal = readcell('/Users/haron/Desktop/Work/Daniela/Data Daniela/1_normal_allChannelAllFreq_all.xls');
% dataMeds = readcell('/Users/haron/Desktop/Work/Haron_olanzapine/olanzapine_allchannels.xls')
% nameMeds ='Olanzapine'
% outlierPercentage=95
% outlierPercentageMeds=95
% timesSampling = 10
% % calcPValueAndMore(dataNormal, dataMeds, nameMeds, outlierPercentage,outlierPercentageMeds)
% outlierPercentageNormal =95
% ourlierPercentageMeds=95
% calcPValueAndMoreWithSampling(dataNormal, dataMeds, nameMeds, timesSampling, outlierPercentageNormal, ourlierPercentageMeds)
% 
% function calcPValueAndMoreWithSampling(dataNormal, dataMeds, nameMeds, timesSampling, outlierPercentageNormal, ourlierPercentageMeds)
%     
%     %lots of set ups
%     data = {};
%     pValueNormalMeds(1:95) = num2cell(0);
%     
%     %temporary data for one sampling step 
%     tempData = {}; 
%     %fill out first row 
%     tempData{1,1} = 'alpha/theta mean Normal';
%     tempData{1,2} = strcat('alpha/theta mean ', nameMeds);
%     tempData{1,3} = strcat('alpha/theta pvalue ', nameMeds);
%     tempData{1,4} = 'alpha/band mean Normal';
%     tempData{1,5} = strcat('alpha/band mean', nameMeds);
%     tempData{1,6} = 'alpha/band pValue';
%     tempData{1,7} = 'beta/band pValue';
%     tempData{1,8} = 'gamma/band pValue';
%     tempData{1,9} = 'delta/band pValue';
%     tempData{1,10} = 'theta/band pValue';
%     %fill out with zeros, otherwise we get data type errors during calculation
%     tempData(2:20, 1:10) = num2cell(0);
%     
%     sampleDataNormal = dataNormal;
%     %remove first line with string data, since it could get chosen by
%     %randsample and calc won't be possible with string data in it
%     sampleDataNormal(1,:) = [];     
%     
%    
%     for j = 1:timesSampling
%      
%         % pick random sample of the size of the medicine from normal set
%         y = randsample(size(sampleDataNormal,1),size(dataMeds,1));
%         data = sampleDataNormal(y,:); 
%        
%         counter = 1; 
%         len = size(dataNormal,2); 
%         % calc all values concerning p values
%         for i = 1:len
%             normal = {};
%             meds = {};
% 
%             normal = cell2mat(data(2:size(data,1), i));
%             meds = cell2mat(dataMeds(2:size(dataMeds,1),i));   
%             
%             %check if channel and frequency are the same 
%             %should always be the same 
%             if strcmp(dataNormal(1,i), dataMeds(1,i))
%                 %after every 5th set we have enough data to calcuate alpha/band
%                 %and alpha/theta
%                 x = mod(i,5);         
%                 switch x
%                     case 1
%                         alphaNormal = (normal);
%                         alphaMeds = (meds); 
%                     case 2
%                         betaNormal = (normal);
%                         betaMeds = (meds);
%                     case 3
%                         gammaNormal = (normal);
%                         gammaMeds = (meds);
%                     case 4
%                         deltaNormal = (normal);
%                         deltaMeds = (meds);
%                     case 0
%                         thetaNormal = (normal);
%                         thetaMeds = (meds);
%                         counter = counter +1; 
%                         
%                         
%                         %sum up all the sampling data, we calculate the
%                         %mean in the next loop, 
%                         %TODO find a more elegant version around
%                         normalAT = alphaNormal./thetaNormal;
%                         normalAT = rmoutliers(normalAT, 'percentiles', [0 outlierPercentageNormal]);
%                         tempData{counter,1} = tempData{counter,1} + mean(normalAT); 
%                         
%                         medsAT = alphaMeds./thetaMeds;
%                         medsAT = rmoutliers(medsAT, 'percentiles', [0 ourlierPercentageMeds]);
%                         tempData{counter,2} = tempData{counter,2} + mean(medsAT);
% 
%                         [h,p] = ttest2(normalAT, medsAT);
%                         tempData{counter,3} = tempData{counter,3}+p;
%                         
%                         normalAB = alphaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
%                         normalAB = rmoutliers(normalAB, 'percentiles', [0 outlierPercentageNormal]);
%                         tempData{counter,4} = tempData{counter,4} + mean(normalAB);
%                         
%                         medsAB = alphaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
%                         medsAB = rmoutliers(medsAB, 'percentiles', [0 ourlierPercentageMeds]);
%                         tempData{counter,5} = tempData{counter,5}+ mean(medsAB);
% 
%                         [h,p] = ttest2(normalAB, medsAB);
%                         
%                         tempData{counter,6} = tempData{counter,6} + p;
%                         
%                         normalBB = betaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
%                         normalBB = rmoutliers(normalBB, 'percentiles', [0 outlierPercentageNormal]);
%                         
%                         medsBB = betaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
%                         medsBB = rmoutliers(medsBB, 'percentiles', [0 ourlierPercentageMeds]);
%                         
%                         [h,p] = ttest2(normalBB, medsBB);
%                         
%                         tempData{counter,7} = tempData{counter,7} + p;
%                         
%                         normalGB = gammaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
%                         normalGB = rmoutliers(normalGB, 'percentiles', [0 outlierPercentageNormal]);
%                         
%                         medsGB = gammaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
%                         medsGB = rmoutliers(medsGB, 'percentiles', [0 ourlierPercentageMeds]);                   
%                         
%                         [h,p] = ttest2(normalGB, medsGB);
%                         
%                         tempData{counter,8} = tempData{counter,8} + p;
%  
%                         normalDB = deltaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
%                         normalDB = rmoutliers(normalDB, 'percentiles', [0 outlierPercentageNormal]);
%                         
%                         medsDB = deltaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
%                         medsDB = rmoutliers(medsDB, 'percentiles', [0 ourlierPercentageMeds]);                   
%                         
%                         [h,p] = ttest2(normalDB, medsDB);
%                         
%                         tempData{counter,9} = tempData{counter, 9} + p; 
%                         
%                         normalTB = thetaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
%                         normalTB = rmoutliers(normalTB, 'percentiles', [0 outlierPercentageNormal]);
%                         
%                         medsTB = thetaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
%                         medsTB = rmoutliers(medsTB, 'percentiles', [0 ourlierPercentageMeds]);                   
%                         
%                         [h,p] = ttest2(normalTB, medsTB);
%                         
%                         tempData{counter,10} = tempData{counter, 10} + p; 
%                         
%                         
%                         
%                     otherwise
%                         disp('not supposed to reach this');
%                 end %switch
%                 
% 
%             
%             normal = rmoutliers(normal, 'percentiles', [0 outlierPercentageNormal]);
%             meds = rmoutliers(meds, 'percentiles', [0 ourlierPercentageMeds]);
% 
%             [h,p] = ttest2(normal, meds);
%             pValueNormalMeds{i} = pValueNormalMeds{i} + p;
%             test{j, i} = p; 
%             
%             end %if            
%             
%         end %for i
% 
%     end %for j
%     
%     %reset data cell array and counter
%     data = {}; 
%     counter = 1; 
%     
%     % calc the rest of the statistics and fill in pvalue data from previous
%     % loop
%     for i = 1:size(dataNormal,2)
% 
%         normal = {};
%         meds = {};
% 
%         normal = cell2mat(dataNormal(2:size(dataNormal,1), i));
%         meds = cell2mat(dataMeds(2:size(dataMeds,1),i)); 
% 
%             if strcmp(dataNormal(1,i), dataMeds(1,i))
% 
%                 x = mod(i,5);
%                 if x == 0 
%                     counter = counter + 1;
%                     % enter sampling numbers divided by times of sampling
%                     % aka mean of the sampling data
%                     
%                     data{1,6} = 'alpha/theta mean Normal';
%                     data{i+1,6} = tempData{counter,1}/timesSampling; 
% 
%                     data{1,7} = strcat('alpha/theta mean_', nameMeds);
%                     data{i+1,7} = tempData{counter,2}/timesSampling; 
% 
%                     data{1,8} = strcat('alpha/theta pvalue_', nameMeds);
%                     data{i+1,8} = tempData{counter,3}/timesSampling;
% 
%                     data{1,9} = 'alpha/band mean Normal';
%                     data{i+1,9} = tempData{counter,4}/timesSampling;
% 
%                     data{1,10} = strcat('alpha/band mean', nameMeds);
%                     data{i+1,10} = tempData{counter,5}/timesSampling;
% 
%                     data{1,11} = 'alpha/band pValue';
%                     data{i+1,11} = tempData{counter,6}/timesSampling;
%                     
%                     data{1, 15} = 'beta/band pValue';
%                     data{i+1, 15} = tempData{counter, 7}/timesSampling; 
%                     
%                     data{1, 16} = 'gamma/band pValue';
%                     data{i+1, 16} = tempData{counter, 8}/timesSampling;
%                     
%                     data{1, 17} = 'delta/band pValue';
%                     data{i+1, 17} = tempData{counter, 9}/timesSampling;
%                     
%                     data{1, 18} = 'theta/band pValue';
%                     data{i+1, 18} = tempData{counter, 10}/timesSampling;
%                     
%                 end             
% 
%                 normal = rmoutliers(normal, 'percentiles', [0 outlierPercentageNormal]);
%                 meds = rmoutliers(meds, 'percentiles', [0 ourlierPercentageMeds]);
% 
%                 data{1,1} = 'Channel_Frequency';
%                 data{i+1,1} = dataNormal(1,i);
% 
%                 data{1,2} = strcat('pValue_', nameMeds, ' & normal');
%                 data{i+1,2} = pValueNormalMeds{1,i}/timesSampling;
% 
%                 data{1,3} = 'data points normal';
%                 data{i+1,3} = size(normal,1);
% 
%                 data{1,4} = 'mean normal';
%                 data{i+1,4} = mean(normal);         
% 
%                 data{1,5} = 'std normal'; 
%                 data{i+1,5} = std(normal);         
% 
%                 data{1,12} = strcat('data points_', nameMeds);
%                 data{i+1,12} = size(meds,1);       
% 
%                 data{1,13} = strcat('mean_', nameMeds);
%                 data{i+1,13} = mean(meds); 
% 
%                 data{1,14} = strcat('std_', nameMeds);
%                 data{i+1,14} = std(meds); 
% 
% 
%             end
% 
%     end
%     
%     %save calcualted data into an excel sheet   
%     fileName = strcat(nameMeds, '_normal_data_sampling_201002_2.xls'); 
%     data = cell2table(data);
%     writetable(data, fileName); 
% end
% ----------------------------------------------------------------

% 
%cellArray = readcell('clozapin.xls');

% folder = {};
% cellArray = meds
% for i= 1:size(cellArray,1)
%     %get folder
%     if ismissing(cellArray{i}) %% für leere Zeilen
%     else
%         folder{i,1} = getFolderURLFromURLstring(cellArray{i});
%     end
% end

%################# FUnktion
% url = 'https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg/v1.1.0/edf/02_tcp_le/050/00005019/s001_2008_08_13/00005019_s001.txt'
% fileName = getFolderURLFromURLstring(url)
% 
% function fileName = getFolderURLFromURLstring(url)
% 
%         temp = strsplit(url, '/'); 
%         temp(end) = '';
%         fileName = strcat(strjoin(temp, '/'), '/'); 
% end


% ----------------------------------------------------------------
%% for i = 1:length(list)
%     file = list{i}; 
%     xlsData = readcell(file, 'DateTimeType', 'text'); 
%     xlsData(1,:) = [];
%     xlsTxtData =[]
%     xlsTxtData = xlsData(strcmp(xlsData(:,3), 'txt'), :)
% %     xlsData(:,2) = cell2mat( datetime(xlsData{:,2}, 'Locale', 'de') );
% 
% end

% --------------------------------
list = readcell('/Users/haron/Desktop/Work/Haron_olanzapine/createxls.xlsx')
meds = {}; 
tempmeds = {};
meds2 = {}; 
% function find_medicine(medicine)
    for i = 1:length(list)
    
        tempmeds = [];
        meds2 = []; 
    
        tempmeds = meds;   
        meds = []; 
        
        file = list{i}; 
        xlsData = readcell(file, 'DateTimeType', 'text'); 
%         xlsData = readcell(file); 
        %xlsData(1,:) = [];
%     xlsData(:,2) = cell2mat( datetime(xlsData{:,2}, 'Locale', 'de') );

        xlsTxtData = xlsData(strcmp(xlsData(:,3), 'txt'), :)
    
        pattern=["haloperidol", "Haloperidolum", "PhEur", "Haloperidoli", "Haloperidoldecanoat"]
           
        meds2 = a.findClozapineInCellArray(xlsTxtData, meds, pattern); 
        meds = [tempmeds; meds2]; 
     
    end
    writecell(meds,'founded_medicine_test.xls') 
    
%  end 
%     pattern = ["quetiapine","seroquel", "quetiapina", "quetiapinum", "quetiapin"];
  % pattern = ["clozapin","clozaril","clopine","fazaclo","denzapine"]; 
   % pattern= ["dilantin", "epilan", "phenytoin"];
   %pattern = ["olanzapine","zypadhera","zyprexa"];

%         pattern =["risperidone", "risperdal", "belivon", "rispen", "risperidal", "rispolept", "risperin", "rispolin", "sequinan", "apexidone", "risperidonum", "risperidona", "psychodal", "spiron"];
%   pattern = ["olanzapine","zypadhera","zyprexa"];
pattern = ["aripiprazole", "Aripiprazolum", "monohydricum", "Monohydrat","Aripiprazol"];
% --------------------------------


% xlsTxtData= readtable('/Users/haron/Desktop/Work/Daniela/xls/tuh_eeg_03_tcp_ar_a.xls')
% medsCell = {}
% pattern = 'lacosamide'
% test12 = a.findClozapineInCellArray(xlsTxtData, medsCell, pattern)

% medication= readtable('/Users/haron/Desktop/Work/Daniela/xls/tuh_eeg_03_tcp_ar_a.xls')
% pattern = 'lacosamide'
% neu= a.searchForMedication(medication, pattern)


% list1= readcell('xlstxt.xlsx')
% list= cellfun(@(x) x(1:end-1), list1, 'UniformOutput', false);
% 
% % folder = "xls";
% % list = funcs.createFileList('xls',folder);
% % 
% meds = {}; 
% tempmeds = {};
% meds2 = {}; 
% 
% for i = 1:length(list)
%     
%     tempmeds = [];
%     meds2 = []; 
%     
%     tempmeds = meds;   
%     meds = []; 
%     
%     file = list{i}; 
%     xlsData = readcell(file); 
% 
%     xlsTxtData = xlsData(strcmp(xlsData(:,3), 'txt'), :);
%     
%     
% %     pattern = ["quetiapine","seroquel", "quetiapina", "quetiapinum", "quetiapin"];
%     pattern = ["clozapin","clozaril","clopine","fazaclo","denzapine"]; 
%     meds2 = b.findClozapineInCellArray(xlsTxtData, meds, pattern); 
%     meds = [tempmeds; meds2]; 
% end 
% 



% 
% medication = readcell('xlstxt.xlsx')
% % for i=1:size(medication,1)
% % medication= cellfun(@(x) x(1:end-1), medication, 'UniformOutput', false)
% % end
% % medication= cellfun(@(x) x(1:end-1), medication, 'UniformOutput', false);
% medication
% drugs=findDiffernetMedicines(medication)

%%%search for medicine in folder of .txt-files

% function meds = checkForMedicine(folder)


%     folder = '/Users/haron/Desktop/Work/abnormal_v2.0.0_normal';
%     typ = 'edf';
%     T = sprintf('*.%s',typ);
%     G = genpath(folder);
%     F = regexp(G,'[^:]+','match');
%     C = cell(size(F));
%     for k = 1:numel(F)
%         C{k} = dir(fullfile(F{k},T));
%     end
%     S = vertcat(C{:});
%     L = fullfile({S.folder},{S.name})
%     A= transpose(L)
% %     fprintf('X.xlsx',A)
    
%     %creates list of files of the defined typ that are included in the folder
% function fileList= createFileList(typ,folder)
%     fileCount=0;
%     listofFiles={};
%     T = sprintf('*.%s',typ);
%     G = genpath(folder);
%     F = regexp(G,'[^:]+','match');
%     C = cell(size(F));
%     for k = 1:numel(F)
%         C{k} = dir(fullfile(F{k},T));
%     end
%     S = vertcat(C{:});
%     L = fullfile({S.folder},{S.name})
%     A= transpose(L)
%     fileList=listofFiles;
% end

% strcmp(dataNormal(1,i), dataMeds(1,i))

% xlsTxtData= 'xlstxt.xlsx'
% medscell =  [meds; meds2]
% ff=getMedicalDataFromExcelSheet(xlsTxtData, medsCell, breaktime)


% 
% list = readcell('channeldata.xlsx')
% cc=createData(list)
% 
% function returnData = createData(list)
% 
%     list= cellfun(@(x) x(1:end-1), list, 'UniformOutput', false);
%     
%     logical = not( ~contains( list, 'channelData') );
%      
%     listChannel = list(logical,:);
%     
%     cellArrayData{1,1} = [];
% %     for i= 1:length(listFrequency)
%     
% end


% list = readcell('calcpowerforbands.xlsx')
% channel = 'F4'
% frequency = 'powerBeta'
% createdata = createData(list, channel, frequency)%function returnData = createData(list, channel, frequency)


% list= '/Users/haron/Desktop/Work/Data/abnormal_v2.0.0_normal/104/00010400/s001_2013_06_04/00010400_s001_t000.edf'
% EEGData = pop_biosig(list,'importevent','off','importannot','off'); 
% 
% %Welche Bedeutung haben window- und OverlapSize
% %Was macht EEGData.data?
% srate = EEGData.srate;
% windowSize = 10
% overlapSize = 4
%  eegFunctions = scriptWorkWithExcelData;    
%         [powerAlpha, powerTheta, powerDelta, powerBeta, powerGamma, times] = eegFunctions.createBrainwaves(EEGData.data,srate,windowSize,overlapSize);

        
% [channels, length] = size(EEGData.data)
%  rowsTheta = cell(channels, 1)
%  
% for i = 1:channels
%         %fshort time fourier transform an the data.
%         %get data per channel 
%         channelData = EGGData.data(i,:); 
%         [~ , f, times, ps] = spectrogram(channelData, windowsize, overlap, [], srate);        
%         
%         rowsTheta{i} = f > theta(1) & f < theta(2);
% 
% end

% list='/Users/haron/Desktop/Work/Data/abnormal_v2.0.0_normal/104/00010400/s001_2013_06_04/00010400_s001_t000.edf_times.xlsx/'
% temp=strsplit(list, '/');
% %Was macht temp(end)
% filename=temp(end)

%list = readcell('calcpowerforbands.xlsx')
%list= cellfun(@(x) x(1:end-1), list, 'UniformOutput', false);

% list = readcell('calcpowerforbands.xlsx')
% logical = not( ~contains( list, 'channelData') );
% listChannel = list(logical,:);

%dataChannel = readcell(listChannel)

%Why can't call the function?
%b = visualizeEEGData;

%create xls list
%folder = "/Users/haron/Desktop/Work/Data/v2.0.0/edf/eval/normal/01_tcp_ar/006/00000647/s002_2009_09_21"; %add folder which contains xls file with cached server data 
%list = funcs.createFileList('edf',folder)
%%DOESNT WORK!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%list = '/Users/haron/Desktop/Work/abnormal_v200_normal.xlsx'
%windowsize = 10
%overlap = 4
%calc = b.calculatePowerForBands(list, windowSize, overlapSize)




 %read edf file (mehrere)
      % EEGData = pop_biosig('/Users/haron/Desktop/Work/data_abnormalevalnormal.xls','importevent','off','importannot','off'); 
    %    srate = EEGData.srate;
           
    
    % createBrainwaves(data,srate,windowsize,overlap)
      

     
    %Liste aus sämtlichen Subfoldern auspucken
     
    %funcs2 = calcAllFreqALLChannel;
     
     
    %folder = '002';
     
    %wie bekomme ich xlsx files? FUNKTIONIERT NICHT
   
    %a = scriptWorkWithExcelData;
    % folder = '/Users/haron/Desktop/Work/Data/abnormal_v2.0.0_normal';
    %list = funcs.createFileList('gz',folder)
      

     
 %data = 'abnormal_v200_norm';
 %c = visualizeEEGData;
 %c.calculatePowerForBands(data);
 
    %data = '/Users/haron/Desktop/Work/abnormal_v200_normal'
    % srate = 250
    % %windowsize = 10
    % overlap = 4

     
   %  a.createBrainwaves(data,srate,windowsize,overlap)
%function calculatePowerForBands(list, windowSize, overlapSize)

%data = importdata('/Users/haron/Desktop/Work/Data/Slowing/edf/01_tcp_ar/002/00000254/s005_2010_11_15/00000254_s005_t000.edf')
%data = edfRead("00000254_s005_t000.edf")
%srate = 250
%windowsize = 10
%overlap = 4


%list = funcs.createBrainwaves(data,srate,windowsize,overlap);

%function [powerAlpha, powerTheta, powerDelta, powerBeta, powerGamma, times] = createBrainwaves(data,srate,windowsize,overlap)
%type("Datap1.mat")

