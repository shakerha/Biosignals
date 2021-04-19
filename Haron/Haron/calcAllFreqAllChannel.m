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
