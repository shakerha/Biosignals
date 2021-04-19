%This function gives you the corresponding folder of each file. 
%It the deletes the last part after the last ‘/’

cellArray = readcell('founded_medicine_folder_ohne.xls');

folder = {};

for i= 1:size(cellArray,1)
    %get folder
    if ismissing(cellArray{i})
    else
        folder{i,1} = getFolderURLFromURLstring(cellArray{i});
    end
    list= cellfun(@(x) x(1:end-1), list, 'UniformOutput', false);
end

 writecell(folder,'founded_medicine_folder_test.xls') 


function fileName = getFolderURLFromURLstring(url)

    fileName = url(1: find(url =='/', 1,'last'))
end

