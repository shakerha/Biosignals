for i = 1:size(dataNormal,2)

        normal = {};

dataNormal = readcell('1_normal_allChannelAllFreq_all.xls')

normal = cell2mat(dataNormal(2:size(dataNormal,1), i));

end