% file to test some functions or let them run with the rest of it 

% % a = scriptWorkWithExcelData;
% % b = scriptTuhDownload;
% c = visualizeEEGData; 
% d = functionsForTUHData;
% 
% % 1) download wanted edf files
% % already done for normal, clozapine, risperidone
% % 2) create frequency xlsx files for every channel in edf data
% 
% % need eeglab to read edf data 
% addpath('eeglab2019_1\'); 
% eeglab; 
% 
% % create xlsx files
% 
% folder = 'NormalSubset/';
% listNormal = d.createFileList('edf',folder);
% c.calculatePowerForBands(listNormal);
% 
% folder = 'ClozapineAgain/';
% listCloz = d.createFileList('edf',folder);
% c.calculatePowerForBands(listCloz);



% clozapinData = readcell('1_clozapin_allChannelAllFreq.xls');
% normalData = readcell('1_normal_allChannelAllFreq_all.xls');
% risperidoneData = readcell('1_risperidone_allChannelAllFreq_all.xls');

calcPValueAndMore(normalData, risperidoneData, 'risperidone', 95, 95); 





% funcs = functionsForTUHData; 
% 
% folder = "ClozapineAgain";
% list = funcs.createFileList('xlsx',folder);
% 
% logical = not( cellfun( @isempty, strfind( list, 'channelData') ) ); 
% list = list(logical, :); 
% 
% channelData = {};
% temps = {};
% x  = {};
% 
% for i = 1:length(list)
%    
%     temps = [];
%     temps = channelData; 
%     
%     channelData = []; 
%     x = [];
%     x = readcell(list{i});
%    
%     channelData(i,1:length(x)) = x;
%     
% end
% 
% 

%-----------------------------------------------------------------
% % 
% cellArray = readcell('clozapin.xls');
% 
% folder = {};
% 
% for i= 1:size(cellArray,1)
%     %get folder
%     if ismissing(cellArray{i})
%     else
%         folder{i,1} = getFolderURLFromURLstring(cellArray{i});
%     end
% end
% 
% 
% function fileName = getFolderURLFromURLstring(url)
% 
%         temp = strsplit(url, '/'); 
%         temp(end) = '';
%         fileName = strcat(strjoin(temp, '/'), '/'); 
% end


%-------------------------------------------------
%search for medicine in xls files

% b = scriptWorkWithExcelData;
% funcs = functionsForTUHData; 
% 
% folder = "xls";
% list = funcs.createFileList('xls',folder);
% 
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

%did not find anything
%pattern = ["Haloperidol", "haloperidol", "aloperidin", "serenace", "haloperidolum PhEur", "haloperidoli decanoas", "haloperidoldecanoat"];

%found stuff
%pattern = ["risperidone", "risperdal", "belivon", "rispen", "risperidal", "rispolept", "risperin", "rispolin", "sequinan", "apexidone", "risperidonum", "risperidona", "psychodal", "spiron"];
    