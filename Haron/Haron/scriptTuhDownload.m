import matlab.net.http.*
import mlreportgen.dom.*;


funcs = functionsForTUHData;
% %---------------------------------------------------------------------------------------------------------------------------


% %This is the step 4. in how_to_download_edf.txt
% 
% folderCellArray = {}
% data = readcell('founded_medicine_folder_test.xls')
% saveFileName = 'freeharon.xls'
% %string concat the saveFileName
% nameArray = {};
% dd = cell(1, 4);
% ff={}
% for i = 1:7
%     url   = data{i, 1};
%     dd{i} = listAllDirectories(url, folderCellArray, saveFileName)
%     ff= vertcat(ff,dd{i})
%     
% end
% 
% writecell(ff,'haloperidol_haron.xls')
%---------------------------------------------------------------------------------------------------------------------------

% % This is the step 6. in how_to_download_edf.txt
% 
% cellArrayData=readcell('haloperidol_edf.xls')
% folderName='haloperidol_edf'
% downloadFolderContentToHardDrive(cellArrayData, folderName)

%---------------------------------------------------------------------------------------------------------------------------
%SKETCHES

% T(all(cellfun('isempty',T),2),:) = [];
% ff=readcell('founded_medicine.xls')
%fullVal = ff(all(~cellfun('isempty', ff),1),:)

% m(all(isnan(m), 2), :) = []
% ff =readcell('founded_medicine_folder_ohne.xls')
% % ff='/Users/haron/Desktop/Work/Haron/tryyyy'
%  downloadFolderContentToCellArray(ff)

% url = 'https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg/v1.1.0/edf/02_tcp_le/050/00005019/s001_2008_08_13/00005019_s001.txt'
% fileName = getFileNameFromURLstring(url)

% % txtUrl='https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg/v1.1.0/edf/01_tcp_ar/000/00000000/s001_2015_12_30/00000000_s001.txt'
% txtUrl='https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg/v1.1.0/edf/02_tcp_le/'
% % % txtUrl='https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg_abnormal/v2.0.0/edf/eval/normal/01_tcp_ar/006/00000647/s002_2009_09_21/00000647_s002.txt'
% gg = checkForMedicine(txtUrl)


% meds = checkForMedicine(txtUrl)

%returns the file name from an url string
% url='https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg_abnormal/v2.0.0/edf/eval/normal/01_tcp_ar/006/'
% fileName = getFileNameFromURLstring(url)




% folder = "/Users/haron/Desktop/Work/Daniela/Data Daniela"; %add folder which contains xls file with cached server data %/Users/haron/Desktop/Work/MatlabScripts/cachedTUHEEGCorpusData
% list = funcs.createFileList('xls',folder)
% 
%meds = checkForMedicine(txtUrl)

% folderCellArray={}
% dd= listAllDirectories('https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg/v1.1.0/edf/01_tcp_ar/085/00008530/s001_2012_01_04/',folderCellArray, 'aaa.xls')
% folderCellArrayData={'https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg_seizure/v1.5.0/edf/train/01_tcp_ar/074/00007475/s003_2013_03_22/00007475_s003.txt'}

% folderCellArrayData = readcell('apri_ed.xls')
% 
% for i= 1:length(folderCellArrayData)
%     downloadFolderContentToCellArray(folderCellArrayData)
% end

%-------------------------------------------------------------------------------------------------------
%FUNCTIONS

%IMPORTANT fill in password and username everywhere to work 
%or rewrite functions so that it takes it as an input parameter
%didn't want it to stay hardcoded 

%TODO try websave or some other method to make this faster
% can take a week easily to cache all the server data 
% RECURSIVE 
function folderCellArray =  listAllDirectories(url, folderCellArray, saveFileName)
    import matlab.net.http.*
    
    creds = Credentials('Username', 'nedc', 'Password', 'nedc_resources'); 
    options = HTTPOptions('Credentials', creds, 'ConnectTimeout', 60); 
    
    %add timestring to console output to see how long this all takes
    timestr = datestr(now,'HH:MM:SS.FFF'); 
    disp(timestr);
    disp(url);    
    
    try
        resp = RequestMessage().send(url, options);
    catch
        pause(10);
        resp = RequestMessage().send(url, options);
        disp('catch listAllDirectories function'); 
    end 
    
    tree = htmlTree(resp.Body.Data); 
    textHTML = extractHTMLText(resp.Body.Data); 

    
    folder = getAllFolders(tree); 
    
    %%%%%%% oberen teil ersetzen, Mac speifisch
    %
    if length(folder) > 1
        if (length(folder) == 1)
            disp('folder lenght 1, not supposed to happen');
        end
    else
        disp('return'); 
        return; 
    end
    
    dates = getLastModifiedDate(textHTML);
    
    for i = 1:length(dates)
        %first iteration a 4 is added -> additional lines in xls file
        le = length(folderCellArray);
        folderCellArray{le + 1, 1} = strcat(url, folder(i+1)); 
        folderCellArray{le + 1, 2} = dates(i);
        
        
        %check if file is a folder or not 
        %get last symbol of string
        x = folder(i+1);
        temp = char(x); 
        y = temp(end); 
        
        if y(end) == '/'
            folderCellArray{le + 1, 3} = 'folder';
            urlsubfolders = strcat(url, folder(i+1));
            
            writecell(folderCellArray, saveFileName);           
            
            folderCellArray = listAllDirectories(urlsubfolders , folderCellArray, saveFileName); 
        else
            x = strsplit(folder(i+1), '.'); 
            y = length(x); 
            folderCellArray{le +1 , 3} = x(y); 
            
            %look if medicine is available for a txt file
            if strcmp( x(y), 'txt') 
                urlsubfolders = strcat(url, folder(i+1));   
                folderCellArray{le +1 , 4} = (checkForMedicine(urlsubfolders)); 
            end 
        end 
        
    end 
    
end 

%TODO: check for time to figure out if files should be redownloaded
function dates = getLastModifiedDate(htmlText)

    %filter out correct date 
    x = textscan(htmlText,'%{yyyy-MM-dd}D');
    %filter out all NaT and return result
    dates = rmmissing(x{1:1}); 

end 

%does not return files, only folders 
function folders = getAllFolders(htmlTree)
    
    allLinks = findElement(htmlTree, "A");
    x = length(allLinks)-1; 
    folders = getAttribute(allLinks(5:x), "href"); 

end

%not recursive
function downloadFolderContentToCellArray(folderCellArrayData)
    import matlab.net.http.*
    
    %add password, didn't want it to stay in code 
    creds = Credentials('Username', 'nedc', 'Password', 'nedc_resources'); 
    options = HTTPOptions('Credentials', creds, 'ConnectTimeout', 60); 
    
    len = length(folderCellArrayData); 
    %TODO make it first line or someting and not a sudden magic number
    %currently first line descriptions of content
    %following two empty lines 
    for x = 1:len
        
       filetype =  folderCellArrayData{x,3};
       url = folderCellArrayData{x,1};
       
       if ~(strcmp(filetype, 'folder'))
           
        resp = RequestMessage().send(url , options); 
    
        %find file name
        i = strsplit(url, '/'); 
        y = length(i); 
        fileName = i(y); 
        
        
        %save file in temp folder
        fileID = fopen(fileName, 'w'); 
        fprintf(fileID, '%s', resp.Body.Data); 
        fclose(fileID);        
       end 

        
    end 
end

%lookup medicine in txt files 
% txtUrl   url of txt file
function meds = checkForMedicine(txtUrl)
import matlab.net.http.*

    % get all the txt file
    creds = Credentials('Username', 'nedc', 'Password', 'nedc_resources'); 
    options = HTTPOptions('Credentials', creds,  'ConnectTimeout', 60); 

    try
        resp = RequestMessage().send(txtUrl, options);
    catch
        pause(20);
        disp('catch in checkForMedicine'); 
        resp = RequestMessage().send(txtUrl, options);
    end

    %temp save file
    fileID = fopen('temp.txt', 'w'); 
    fprintf(fileID, '%s', resp.Body.Data); 
    fclose(fileID); 

    obj = InformationExtraxtor('temp.txt', 'txt'); 
    meds = extractMedication(obj); 
    meds = strjoin(meds, '-'); 
    
    %delete after we got what we need from it
    delete('temp.txt'); 
end


% downlaods files to the hard drive from a list of urls in cellArrayData
% cellArrayData     CellArray with expected data
%                   1) file/folder
%                   2) last modified time/date
%                   3) file type
% folderName        Name of the folder in which the data will be saved
% hint: run listAllDirectories first if excel file is not yet available
% recursion
function downloadFolderContentToHardDrive(cellArrayData, folderName)
import matlab.net.http.*
    
    %check if folder already exists, otherwise create one
    folderName = string(folderName); 
    
    if ~exist(folderName, 'dir')
        mkdir(folderName); 
    end 

    for i = 1:size(cellArrayData,1)

        %at first does the string represent a folder
        if strcmp(cellArrayData{i,3}, 'folder')

            dirName = getFileNameFromURLstring(cellArrayData{i,1});
            tempFolderName = folderName; 
            
            %ensure that all subfolders are build correctly
            if endsWith(dirName, '/')
                folderName = strcat(folderName, dirName); 
            else
                folderName = strcat(folderName, dirName, '/');
            end 
            
            %get all files in the folder
            len = length(cellArrayData{i,1}); %length of string in that cell array entry
            subArrayData = cellArrayData(strncmp(cellArrayData{i,1}, cellArrayData(:,1), len), :);
            
            %subtract from original data array to not download data twice
            len = size(subArrayData, 1) - 1; 
            cellArrayData(i+1 : i+len, :) = []; 
                       
            %delete first row, otherwise will have too many folders around
            subArrayData(1,:) = [];  
            
            %recursion for the win
            downloadFolderContentToHardDrive(subArrayData, folderName); 

            %reset folderName
            folderName = tempFolderName; 
            
            %check if I'm done with the the cell array
            %otherwise get an error with out of bound since I'm deleting
            %entries for recursion 
            if i == size(cellArrayData, 1)
                break; 
            else
                continue
            end
        %skip loop iterration when data is not empty or first line or missing  
        elseif  isempty(cellArrayData{i,1}) 
            continue 
        elseif ismissing(cellArrayData{i,1})
            continue
        elseif strcmp(cellArrayData{i,1}, 'file type')
            continue
        end
        
        %get filename
        if endsWith(folderName, '/')
            filename = strcat(folderName, getFileNameFromURLstring(cellArrayData{i,1}));
        else 
            filename = strcat(folderName, '/', getFileNameFromURLstring(cellArrayData{i,1})); 
        end
        
        %finally save the data
        options = weboptions('Username', 'nedc', 'Password', 'nedc_resources', 'Timeout', 60, 'ContentType','raw'); 
        url = cellArrayData{i,1}; 
        
        try
            websave(filename, url, options); 
        catch
            pause(10);
            websave(filename, url, options); 
            disp('saving failed: ' + filename) 
        end 
    
    end 
end

%returns the file name from an url string
function fileName = getFileNameFromURLstring(url)

    x = strsplit(url, '/'); 
    
    if strcmp(x(end), "")
        %folder
        fileName = x(end -1); 
    else
        %not a folder
        fileName = x(end); 
    end
end
