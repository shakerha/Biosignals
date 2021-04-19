cellArrayData=readcell('apri_edf.xls')
folderName='apri_edfs'

downloadFolderContentToHardDriv(cellArrayData, folderName)


% cellArrayData     CellArray with expected data
%                   1) file/folder
%                   2) last modified time/date
%                   3) file type
% folderName        Name of the folder in which the data will be saved
% hint: run listAllDirectories first if excel file is not yet available
% recursion
function downloadFolderContentToHardDriv(cellArrayData, folderName)
import matlab.net.http.*
    
    %check if folder already exists, otherwise create one
    folderName = string(folderName); 
    
    if ~exist(folderName, 'dir')
        mkdir(folderName); 
    end 
   for i = 1:size(cellArrayData,1)
        %get filename
        if endsWith(folderName, '/')
            filename = strcat(folderName, getFileNameFromURLstring(cellArrayData{i,1}));
        else 
            filename = strcat(folderName, '/', getFileNameFromURLstring(cellArrayData{i,1})); 
        end
   end
 
        
        %finally save the data
        options = weboptions('Username', 'nedc', 'Password', 'nedc_resources', 'Timeout', 60); 
        url = cellArrayData{i,1}; 
        
        try
            websave(filename, url, options); 
        catch
            pause(10);
            websave(filename, url, options); 
            disp('saving failed: ' + filename) 
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