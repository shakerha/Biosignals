%This script train and validate a feed forward network to detect slowing
%intervalls therfor the EEG Slowing Corpus and the annotation containing
%excel sheet are needed
funcs=functionsForTUHData;
slwoingPath='D:\EEGData\Slowing\v1.0.1';
excelSheet='D:\EEGData\Slowing\_SLOW_v02.xlsx';
windowzize=1;
overlap=0;
errorWeight=35;
%create list of edf files containing slowings (slowFileList) and extract 
%corresbonding annotations (slowings)
[slowFileList,slowings]=funcs.extractSlowingFiles(excelSheet,slwoingPath);
%create feed forward network
net=funcs.createNetwork();
%the alpha/thta power get extractet to change the feature extraction 
%the method funcs.createWavelets have to be used instead of funcs.createAlphaByThetas
[alphaByThetaSlowing,times]=funcs.createAlphaByThetas(slowFileList,windowzize,overlap);
inputs=cell2mat(alphaByThetaSlowing);
outputs=[];
%create the correct labels for the differndt windows/intervals
for i=1:size(slowings,1)
    output=funcs.createLableVec(times{i},slowings{i},windowzize);
    outputs=cat(2,outputs,output);
end
%configure error weights for the as slowing labeld windows
ew=ones(size(outputs));
ew(outputs==1)=errorWeight;
%train and validate network
[net,tr]=train(net,inputs,outputs,[],[],ew);
