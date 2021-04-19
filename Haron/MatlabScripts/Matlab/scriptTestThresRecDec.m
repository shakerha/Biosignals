%This spript test the preformance of the record detection algorithm for
%differndt sets of threholds it needs the path of the EEG Slowing Corpus,
%the corrssbonding annoation table and the path of the nrmal data
slwoingPath='D:\EEGData\Slowing\v1.0.1';
normalData='D:\EEGData\Normal';
excelSheet='D:\EEGData\Slowing\_SLOW_v02.xlsx';
funcs=functionsForTUHData;
%windowsize and overlap for the alpha/theta power extraction
windowsize=10;
overlap=9;
%array of the thresholds which are tested
thresAlphaThtea=0:.01:4;
thresRate=0.98:.01:1;
%teledt raste 1 because it is not possible to reach
thresRate(end)=[];
%create list of files that contain slowing annotations
%the annoations for the files are stored in slowing
[slowFileList,slowings]=funcs.extractSlowingFiles(excelSheet,slwoingPath);
%create list of edf files from the normal set
normalFileList=funcs.createFileList('edf',normalData);
%extract the alpha/theta powers for each record listed in slowFileList
alphaThetaSlowing=funcs.createAlphaByThetas(slowFileList,windowsize,overlap);
%extract the alpha/theta powers for each record listed in normalFileList
alphaThetaNormal=funcs.createAlphaByThetas(normalFileList,windowsize,overlap);
%creates roc curve for the differndt thresholds wher each line corresbonds
%to the rate threshold. The rows correbond to the alpha/theta threshold and
%the column to the rate threshold. Pref conatins preformance information su
%ch as acuracy,specifisity and sensifcisity.
[spec,sens,pref]=funcs.rocCurvePercent(thresRate,thresAlphaThtea,alphaThetaNormal,alphaThetaSlowing);