%This sheet contains the methods created to work with the TUH Corpus
function funcTUHData = functionsForTUHData
  funcTUHData.splitAnd=@splitAnd;
  funcTUHData.createCorrelationTable=@createCorrelationTable;
  funcTUHData.findDiffernetMedicines=@findDiffernetMedicines;
  funcTUHData.searchClozapine=@searchClozapine;
  funcTUHData.matchResults=@matchResults;
  funcTUHData.createresult=@createresult;
  funcTUHData.createFileList=@createFileList;
  funcTUHData.extractInformations=@extractInformations;
  funcTUHData.getT5O1=@getT5O1;
  funcTUHData.getEEGFromTar=@getEEGFromTar;
  funcTUHData.edfAlphaThetaExraction=@edfAlphaThetaExraction;
  funcTUHData.createAlphaTheta=@createAlphaTheta;
  funcTUHData.createCoefficients=@createCoefficients;
  funcTUHData.createAlphaByThetas=@createAlphaByThetas;
  funcTUHData.rocCurvePercent=@rocCurvePercent;
  funcTUHData.extractSlowingFiles=@extractSlowingFiles;
  funcTUHData.detection=@detection;
  funcTUHData.createNetwork=@createNetwork;
  funcTUHData.createLableVec=@createLableVec;
  funcTUHData.extractWavelets=@extractWavelets;
  funcTUHData.createWavelets=@createWavelets;
  funcTUHData.extractData=@extractData;
end
%functions that deletes and in the medication vectors extracted from the
%clinical reports
function medications=splitAnd(medications)
    for i=1:size(medications,1)
        meds=split(medications(i),'and');
        medications(i)=meds(1);
        if size(meds,1)>1
            medications(end+1)=meds(2);
        end
    end
end

%This methode creates the distribution tabels for anti-psychotics and as
%slow labeld records drugs contains the results from method antipsychtable
%conatins the names of the differndt anti-psychotics, uesedDrugsId conatins
%the idnice of antipsychotics that are applied in the TUH corpus and
%slowing contains the abels for slow records.
function correlationTable=createCorrelationTable(drugs,antipsychTable,usedDrugsId,slowing)
% names for columns
vars={'NoDrug_NoSlow','NoDrug_Slow','Drug_NoSlow','Drug_Slow'};
correlationTable=table([0],[0],[0],[0],'VariableNames',vars);
%create row for each antipschotic drug
    for index=1:size(drugs,1)
        if usedDrugsId(index)
        correlationTable.Drug_Slow(end+1)=sum(sum(antipsychTable(:,index),2)>0&slowing);
        correlationTable.Drug_NoSlow(end)=sum(sum(antipsychTable(:,index),2)>0&slowing==0);
        correlationTable.NoDrug_Slow(end)=sum(sum(antipsychTable(:,index),2)==0&slowing);
        correlationTable.NoDrug_NoSlow(end)=sum(sum(antipsychTable(:,index),2)==0&slowing==0);
        end
    end
 %create row for the differndt groupes of anti-psychotics
    correlationTable(1,:)=[];
    statistics={'All Antipsychotics'; 'Typical Antipsychotics'; 'Aypical Antipsychotics'; 'Under Development'};
    statisticsInd={[1:size(drugs,1)] [1:51] [52:83] [84:size(drugs,1)]};
    for i=1:size(statistics,1)
        correlationTable.Drug_Slow(end+1)=sum(sum(antipsychTable(:,statisticsInd{i}),2)>0&slowing);
        correlationTable.Drug_NoSlow(end)=sum(sum(antipsychTable(:,statisticsInd{i}),2)>0&slowing==0);
        correlationTable.NoDrug_Slow(end)=sum(sum(antipsychTable(:,statisticsInd{i}),2)==0&slowing);
        correlationTable.NoDrug_NoSlow(end)=sum(sum(antipsychTable(:,statisticsInd{i}),2)==0&slowing==0);
    end
    rowNames=[cellstr(drugs(usedDrugsId)); statistics];
    correlationTable.Properties.RowNames=rowNames;

end

%This function extract the differndt drugs find in the medication vectors
function drugs=findDiffernetMedicines(medication)
drugs={};
    for i=1:size(medication,1)
        actuelMed=medication{i,2};
        for j=1:size(actuelMed,1)
            med=actuelMed{j,1};
            if iscell(med)
            med=med{1,1};
            end
            if sum(contains(drugs,med))==0
                drugs{end+1}=med;
            end
        end
    end
end

%Look for clozapine im the extracted medication
function clozapineintake=searchClozapine(medication)
    clozapinePatterns=["clozapin","clozaril","clopine","fazaclo","denzapine"];
    clozapineintake=false;
    
    %check what kind of input was given to the function
    if ischar(medication)
        medication = lower(medication); 
    elseif ismissing(medication) || isa(medication, 'double')
        return;  
    else 
        medication=lower(medication{:,:});
    end
    for patternNr=1:size(clozapinePatterns)
        if sum(contains(medication,clozapinePatterns(patternNr))>0)
            clozapineintake=true;
            break;
        end
    end
end

%this function matches the information extracted from the clinicl reports
%with the results of the record detection on the full TUH EEG corpus
function matchedResults=matchResults(clinicalreports,results,edfFiles)
for i=1:size(clinicalreports,1)
    file=clinicalreports{i,1};
    file=split(file,"\");
    %file=strcat(file(end-2),"\",file(end-1));
    file=file(end-1);
    index=find(contains(edfFiles,file), 1);
    if isempty(index)
       matchedResults(i,1)=0;
    else
       matchedResults(i,1)=results(index);
    end
    %fulltable{i,2}=searchClozapine(clinicalreports{i,2});
end
end

function result=createresult(list)
for i=1:size(list,1)
    if isstring(list{i,1})
        if list{i,1}=="4"
            result(i,1)=4;
            result(i,2)=NaN;
        end
        if list{i,2}=="5"
            result(i,1)=5;
            result(i,2)=NaN;
        end
    else
         result(i,1)=list{i,1};
         result(i,2)=list{i,3};
    end
end
end

%creates list of files of the defined typ that are included in the folder
function fileList= createFileList(typ,folder)
    fileCount=0;
    listofFiles={};
    folders=genpath(folder);
    folders=regexp([folders ';'],'(.*?);','tokens');
    for pathNr=1:size(folders,2)
        folder=cell2mat(folders{pathNr});
        if ~isempty(folder)
            files=dir(fullfile(folder,strcat('*.',typ)));
            if ~isempty(files)
                for fileNr=1:size(files,1)
                    fileCount=fileCount+1;
                    file=strcat(folder,'\',files(fileNr).name);
                    listofFiles{fileCount,1}=file;
                    %infEx=InformationExtraxtor(file,'txt');
                    %listofFiles{fileCount,2}=infEx.extractMedication();
                    %[listofFiles{fileCount,3},listofFiles{fileCount,4}]=infEx.extractSlowing();
                    
                end
            end
        end
    end
    fileList=listofFiles;
end

%creates a matrix for the detectedt antipsychotic drugs in the clincal
%reports. Each row in drugs corresbonds to a record in clinicalReportsList and each coulmn corresbonds to a
%drug of antipsychTable. filelist consists of a list af paths of clinical
%reports. drugtable contains the brand and generica names of antipsychotic
%drugs. antipsychtable conatins the generic names, 
%NormalSlowing is an array that is one for each record that contain the word slowing 
%abnormalSlowing is one if the record contain the word slowing in the IMPRESSION:  part
%pat is one if the pattern for impression was found
function [antipsychTable,drugs,normalSlowing,abnormalSlowing,pat]=extractInformations(fileList,drugTable)
    drugs=drugTable.GenericName;
    for fileNr=1:size(fileList,1)
        infEx=InformationExtraxtor(fileList{fileNr,1},'txt');
        antipsychTable(fileNr,:)=infEx.containAntipsychotics(drugTable);
        [abnormalSlowing{fileNr,1},pat{fileNr,1},normalSlowing{fileNr,1}]=infEx.extractSlowing;
    end
end

%extract srate and the differnce between the first and the second chanel
%from a given eeg file
function [data,srate]=getT5O1(EEG)
%channelNum = [9, 15];
srate=EEG.srate;
data=EEG.data(1, :)-EEG.data(2, :);
end

%returns a list of eeg files that are contained in the unpacked tar file.
%it only opens channel 9 and 15
function EEG=getEEGFromTar(tar)
unpacked=untar(tar);
index=contains(unpacked,'.edf');
edffiles=unpacked(index);
EEG=cell(size(edffiles));
    for edfNr=1:size(edffiles,2)
        EEG{edfNr,2}=edffiles{edfNr};
        EEG{edfNr,1}=pop_biosig(edffiles{edfNr},'channels', [9 15],'importevent','off','importannot','off');
        %delete the unpacked foleder
        delete(edffiles{edfNr});
    end
end

%Compute the alphaByThetaValue fort the given tar files.
%files are the corresbonding edf/tar files 
%error 1 package defect 2 samplingrate infinity 3 alphabytheta is not a
%number
%windowSize and overlapSize are for the fouruer windows in seconds
function [files,alphaByThetas,error]=edfAlphaThetaExraction(fileList,windowSize,overlapSize,files,alphaByThetas,error)
    fileIndex=1;
    
    for index=1:size(fileList,1)
        file=fileList{index,1};
        EDFs=[];
        try
            EDFs=getEEGFromTar(file);
        catch errormessage
            files(fileIndex)=file;
            error(fileIndex)=1;
            fileIndex=fileIndex+1;
        end
        
        while(~isempty(EDFs))
            files(fileIndex)=EDFs{1,2};
            sesion=split(EDFs{1,2},"\");
            sesion=sesion{end-1};
            sesionIdex=contains(EDFs(:,2),sesion);
            sesionEDFs=EDFs(sesionIdex,1);
            EDFs(sesionIdex,:)=[];
            alphThetaSes=[];
            for i=1:size(sesionEDFs,2)
                [data,srate]=getT5O1(sesionEDFs{i});
            if(isinf(srate))
                error(fileIndex)=2;
                break;
            else
                data(isnan(data))=[];
                alphTheta=createAlphaTheta(data,srate,windowSize,overlapSize);
                alphThetaSes=[alphThetaSes alphTheta];
            end
            end
            alphaByThetas{fileIndex}=alphThetaSes;
            if isnan(alphThetaSes)
                 error(fileIndex)=3;
            else
                error(fileIndex)=0;
            end
            fileIndex=fileIndex+1;

        end
        if(mod(index,20)==0)
        save("FullTUHFiles","files");
        save("FullTUHAlphaByTheta","alphaByThetas");
        save("FullTUHError","error");
        end
    end
end

%create alpha/theta power for a given data vector,winowsize(sec), overlap(sec) and  srate
function [alphaTheta,times]=createAlphaTheta(data,srate,windowsize,overlap)
    theta=[3.5 7.5];%defines the theta wave chanel
    alpha=[7.5 12.5];%defines the alpha wave chanel
    length=size(data,2);
    windowsize=windowsize*srate;
    if windowsize>length
        windowsize=length;
        overlap=0;
    end
    overlap=overlap*srate;
    %fshort time fourier transform an the data.
    [~,f,times,ps]=spectrogram(data,windowsize,overlap,[],srate);
    rowsTh=f>theta(1)&f<theta(2);
    rowsAl=f>alpha(1)&f<alpha(2);
    al=sum(ps(rowsAl,:));
    th=sum(ps(rowsTh,:));
    alByTh=al./th;
    %delet NaN
    %label(isnan(alByTh))=[];
    times(isnan(alByTh))=[];
    alByTh(isnan(alByTh))=[];
    alphaTheta=alByTh;
    %labels=cell2mat(labels);
    %labels(isnan(alphaTheta))=[];
end

function coefficinets=createCoefficients(data,thres)
    coefficinets=sum(data<thres)/size(data,2);
end

%ths function extracts the alpha/theta power for a given list of edf
%files,windowsize(sec) and overlap
%eac row of alphaByTheta and times corresbonds to one edf file. Times
%contains the middle time point of each window/intervall
function [alphaByTheta,times]=createAlphaByThetas(filelist,windowsize,overlap)
    alphaByTheta=[];
    for i=1:size(filelist,1)
        %open edf file 
        edf=pop_biosig(filelist{i},'channels', [9 15],'importevent','off','importannot','off');
        [data,srate]=getT5O1(edf);
        [alphaByTheta{i},times{i}]=createAlphaTheta(data,srate,windowsize,overlap);
    end
end

%this methode extrac the wavele features for a list of edf files.
function [features,times]=createWavelets(filelist,windowsize,overlap)
    for i=1:size(filelist,1)
        edf=pop_biosig(filelist{i},'channels', [9 15],'importevent','off','importannot','off');
        [data,srate]=getT5O1(edf);
        [features{i},times{i}]=extractWavelets(data,srate,windowsize,overlap);
    end
end

%this function extract the raw eeg data from a given list of edf files
function [features,times]=extractData(filelist)
    for i=1:size(filelist,1)
        edf=pop_biosig(filelist{i},'channels', [9 15],'importevent','off','importannot','off');
        [data,srate]=getT5O1(edf);
        features{i}=reshape(data,srate,[]);
        times{i}=0:size(features{i},2)-1;
    end
end

%this function extracts the wavelet veatures for a given data vector
function [values,times]=extractWavelets(data,srate,windowsize,overlap)
            artiThres=100;
            threshold=50;
            timestart=(windowsize/2);
            % Add discrete wavelet transformation
            fMgr=WaveletExtraction(6, 'sym7'); % 6, sym7
            windowsize=windowsize*srate;
            overlap=overlap*srate;
            winDat=buffer(data,windowsize,overlap,'nodelay');
            times=timestart:(size(winDat,2)-1+timestart);
            [winDat,times]=deleteArtifact(winDat,times,artiThres);
            for datColumn=1:size(winDat,2)
                x=winDat(:,datColumn);
                x=transpose(x);
                x=filterDat(x,threshold,srate);
                features(:,datColumn)=fMgr.createFeatureVector(x);
            end
            values=features;
end

function [win,times]=deleteArtifact(win,times,threshold)
    [~,col]=find(abs(win)>threshold);
    col=unique(col);
    col=find(col);
    win(:,col)=[];
    times(:,col)=[];
end

function dummy=filterDat(data,threshold,fs)
    [b,a] = butter(6,threshold/(fs/2));
    dummy=filter(b,a,data);
end

%this function creates the rocCureves of the recordDetection algorithm for
%given thresholds where alphaThteatZero contains the data which is correct
%labeld with zero and alphaThtaOne which are correct labeld with one.
function [spec,sens,pref]=rocCurvePercent(rateThres,alphaThetaThres,alphaThetaZero,alphaThetaOne)
outputs=[];
targets=[];
data=[alphaThetaZero alphaThetaOne];
for trNr=1:length(alphaThetaThres)
    for trPercNr=1:length(rateThres)
        output=[];
        for i=1:size(data,2)
            if iscell(data)
            lenght=size(data{i},2);
            numberOfSlow=sum(data{i}<alphaThetaThres(trNr));
            else
            lenght=length(data(i));
            numberOfSlow=sum(data(i)<alphaThetaThres(trNr));
            end
            output(i)=(numberOfSlow/lenght)>rateThres(trPercNr);
        end
        targetsNormal=zeros(size(alphaThetaZero));
        targetsSlowing=ones(size(alphaThetaOne));
        outputs=output;
        targets=logical([targetsNormal targetsSlowing]);
        pref(trNr,trPercNr)=classperf(targets,outputs,'Positive',1,'Negative',0);
        spec(trNr,trPercNr)=pref(trNr,trPercNr).Specificity;
        sens(trNr,trPercNr)=pref(trNr,trPercNr).Sensitivity;
    end
end
    plot(1-spec,sens)
    xlabel('1-Specificity')
    ylabel('Sensitivity')
    legend(string(rateThres),'Location','southeast');
    %perfcurve(targets,double(outputs),1)
end

%this function creates a list of edf files that contain slowing from the
%EEG Slowing Corpus.slow files are the list ofe files and slowings contain
%the annotation information.Path have to be the path of the Corpus as
%excelSheet the path of the annotationtable.
function [slowFiles,slowings]=extractSlowingFiles(excelSheet,path)
%find files that contain slowings
slowTable=readtable(excelSheet,'sheet',3);
slowTable.Properties.VariableNames{'Var12'}='SLOW';
slowTable.Properties.VariableNames{14}='Start';
slowTable.Properties.VariableNames{15}='Stop';
slowInd=contains(slowTable.SLOW,'1');
slowFilesBuf=slowTable.Filename(slowInd);
start=slowTable.Start(slowInd);
stop=slowTable.Stop(slowInd);
%extract the correct paths for the files
slowFilesBuf=regexprep(slowFilesBuf,'/','\');
slowFilesBuf=regexprep(slowFilesBuf,{'\.'},'');
slowFilesBuf=regexprep(slowFilesBuf,'_(\d+)tse','.edf');
slowFilesBuf=strcat(path,slowFilesBuf);
slowFiles=unique(slowFilesBuf);
%extract the slowing annotation for the differendt files
slowings=cell(size(slowFiles));
for i=1:size(slowFiles)
    index=find(contains(slowFilesBuf,slowFiles(i)));
    a=start(index);
    b=stop(index);
    a=char(a);
    b=char(b);
    a=str2num(a);
    b=str2num(b);
    slowings{i}=cat(2,a,b);
end
end

%this function classifies a list of alphaTheza powers as "slow" or "not"
%each row corresbonds to one record
function [slowing,c]=detection(rateThres,alphaThetaThres,alphaByThetas)
for i=1:size(alphaByThetas,2)
            lenght=size(alphaByThetas{1,i},2);
            numberOfSlow=sum(alphaByThetas{1,i}<alphaThetaThres);
            c(i)=numberOfSlow/lenght;
            slowing(i)=c(i)>rateThres;
end
end

%creates feed forward network
function net=createNetwork()
            %obj.net = patternnet(obj.hiddenlayer, trainFcn);
            net = patternnet([15 15]);
            % obj.net.layers{1}.transferFcn = 'poslin';
            %obj.net.performFcn = 'sse';
            net.performFcn = 'crossentropy'; 
            net.divideFcn = 'dividerand';  % Divide data randomly
            net.divideParam.trainRatio = 85/100;
            net.divideParam.valRatio = 15/100;
            net.divideParam.testRatio = 0/100;
end

%creates a labels vector for each window from the annotations extracted
%from the Slowing Corpus
function labelVec=createLableVec(times,slowIntervals,window)
labelVec=zeros(size(times));
lower=times+window/2<=slowIntervals(:,2);
upper=times-window/2>=slowIntervals(:,1);
labelInd=sum(double(lower&upper),1);
labelVec(logical(labelInd))=1;
end
% {'D:\EEGData\Slowing\v1.0.1\edf\01_tcp_ar\065\00006514\s028_2010_06_30\00006514_s028_t000.edf'}
 %{'D:\EEGData\Slowing\v1.0.1\edf\01_tcp_ar\065\00006514\s028_2010_06_30\00006514_s028_t000.edf'}

