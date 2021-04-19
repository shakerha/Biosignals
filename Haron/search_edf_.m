new_edflist = {}

data1 = readcell('haloperidol_haron.xls', 'DateTimeType', 'text')

for i = 1:size(data1,1)
    if strcmp(data1{i,3},'edf')
         
        new_edflist = vertcat(new_edflist, data1{i,1})
%         new_edflist1 = vertcat(new_edflist, new_edflistt)
    end
end

% new_edflistt = 'folder'
% 
% for i = 1:size(new_edflist,1)
%     new_edflist{i,3} = new_edflistt
% end


writecell(new_edflist,'haloperidol_edf.xls')


