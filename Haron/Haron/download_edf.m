
cellArrayData= readcell('founded_medicine_folder_ohne_.xls')
folderName= 'apri_edfs'
import matlab.net.http.*

for i = 1:size(cellArrayData,1)
        if endsWith(folderName, '/')
            filename = strcat(folderName, getFileNameFromURLstring(cellArrayData{i,1}));
        else 
            filename = strcat(folderName, '/', getFileNameFromURLstring(cellArrayData{i,1})); 
        end
        
        %finally save the data
        options = weboptions('Username', 'nedc', 'Password', 'nedc_resources', 'Timeout', 60); 
        url = cellArrayData{i,1}; 
        
        try
            websave(filename, url, options); 
        catch
            pause(10);
            websave(filename, url, options); 
            disp('saving failed: ' + filename); 
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