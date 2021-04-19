%This spript test the preformance of the interval detection via threshold algorithm for
%differndt sets of threholds it needs the path of the EEG Slowing Corpus,
%the corrssbonding annoation table
funcs=functionsForTUHData;
slwoingPath='D:\EEGData\Slowing\v1.0.1';
excelSheet='D:\EEGData\Slowing\_SLOW_v02.xlsx';
windowsize=[1 5 10];
overlap=[0 4 9];
thresAlphaTheta=[0:.01:4];
%set rate threshold to zero what correbonds to no threshold
thresRate=0;
%create list of edf files containing slowing annotations and extract
%annotations
[slowFileList,slowings]=funcs.extractSlowingFiles(excelSheet,slwoingPath);
%create a roc curve for each windowsize
for i=1:length(windowsize)
[alphaByThetaSlowing,times]=funcs.createAlphaByThetas(slowFileList,windowsize(i),overlap(i));
labels=[];
%create table of correct labeks for slowings
for j=1:size(slowings,1)
    output=funcs.createLableVec(times{j},slowings{j},windowsize(i));
    labels=cat(2,labels,output);
end
%convert cell array of poers to a single num array
alphaByThetaSlowing=cell2mat(alphaByThetaSlowing);
f(i)=figure('Name',strcat('Thres1 windowsize',num2str(windowsize(i))));
figure(f(i));
%create roc curve 
[spec,sens,pref]=funcs.rocCurvePercent(thresRate,thresAlphaTheta,alphaByThetaSlowing(labels==0),alphaByThetaSlowing(labels==1));
end