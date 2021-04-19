%%Creates box plots of the alpah/theta powers of the NoSlowing,Slowing and
%%Normal-Set it needs the path of the EEG Slowing Corpus and the normal
%%recods. 
funcs=functionsForTUHData;
%windowsizes and overlpas for the alph/theta power extraction
windowsize=[1 5 10];
overlap=[0 4 9];
slwoingPath='D:\EEGData\Slowing\v1.0.1';
excelSheet='D:\EEGData\Slowing\_SLOW_v02.xlsx';
normalData='D:\EEGData\Normal';
names={'NoSlowing-set', 'Slowing-set','Normal-set'};
%create list of normal edf files
normalFileList=funcs.createFileList('edf',normalData);
f=[];
%create list of edf file containing slowing annotations and extract
%annotations
[slowFileList,slowings]=funcs.extractSlowingFiles(excelSheet,slwoingPath);
%create boxplot for eac windowsize
for i=1:length(windowsize)
    %extraxt alpha/theta power
    [alphaByThetaSlowing,times]=funcs.createAlphaByThetas(slowFileList,windowsize(i),overlap(i));
    alphaByThetaNormal=funcs.createAlphaByThetas(normalFileList,windowsize(i),overlap(i));
    %convert cell alpoha/theta cells arrays to a single num array
    inputs=cell2mat(cat(2,alphaByThetaSlowing,alphaByThetaNormal));
    outputs=[];
    
    %lables for the data of the normal-set, slowing-set and noSlowing-set
    for j=1:size(slowings,1)
        output=funcs.createLableVec(times{j},slowings{j},windowsize(i));
        outputs=cat(2,outputs,output);
    end
    
    outputs=cat(2,outputs,2*ones(size(cell2mat(alphaByThetaNormal))));
    %create boxplot
    f(i)=figure('Name',strcat('BoxPlot indowsize',num2str(windowsize(i))));
    figure(f(i));
    boxplot(inputs,outputs,'labels',names);
    axis([0.5 3.5 0 20])
end