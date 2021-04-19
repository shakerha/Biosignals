% Load data from edf files into MATLAB
classdef TrainingData
    properties
        labelFile="C:\Users\mckeu\Documents\Bachelorarbeit\EEGData\Slowing\_SLOW_v00.xlsx";
        inputFolder = 'C:\Users\mckeu\Documents\Bachelorarbeit\EEGData\Slowing\v1.0.0\edf';
        outputFolder= 'C:\Users\mckeu\Documents\Bachelorarbeit\EEGData\mat\';
        files;
        medicationVecs;
        labelVecs;%1.colum label for raw data 2. interval start 3. interval stop
        dataVecs;% colum for each channel
        sRateVecs;
        slowingdata;
        topThresholdFreq=20;
        buttomThresholdFreq=0.5;
        theta=[3.5 7.5];%defines the theta wave chanel
        alpha=[7.5 12.5];%defines the alpha wave chanel
    end
    methods (Access = public)
    function obj=createVectors(obj)
    eeglab;

    fileNames = {'trainA'};
    % fileNames = {'evalt', 'trainT'};
    s1 = 'data';
    s2 = 'samplingRate';
    %extract the labeinformation from the xlsx file 
    obj=obj.getSlowings();
        for fileRun = 1:size(fileNames, 2)
        %% Folder & file specification
        filelist = strcat(fileNames{fileRun}, '.txt');
   
        %% Load data paths
        fileID = fopen(cat(2, obj.outputFolder, filelist), 'r');
        formatSpec = '%s';
        filePaths = textscan(fileID,formatSpec);
        fclose(fileID);
        numOfSets = length(filePaths{1});


        %% Variables
        % Indices of the desired channel
        % channelNum = 1:21;
        channelNum = [9, 15];
        add = 1;
        %for n= 1:numOfSets
        for n = 1:size(obj.files,1)
        %open the edf file
        curPath = obj.files{n,1};
        %curPath =cat(2,obj.inputFolder,filePaths{1}{n});
        curEEG = pop_biosig(curPath, 'channels', 1:21 ,'importevent','off','importannot','off');
        %get data fromn each chanel in results
            for ch = 1:size(channelNum, 2)
             obj.dataVecs{ch,n} = curEEG.data(channelNum(ch), :);
            end
        %get sampling rate,create label vector 
        obj.sRateVecs{n}=curEEG.srate;
        obj.labelVecs{n}=obj.createSlowingVector(curPath,size(curEEG.data,2),curEEG.srate);
        add = add + 1;
        %get mediaction
        inEx=InformationExtraxtor(curPath,'edf');
        obj.medicationVecs{n}=inEx.extractMedication();
        end
        end
    end
    %Save the important vectors to the corresbonding files
    function []=saveVectsToFiles(obj,outputFolder)
    dataVecs=obj.dataVecs;
    sRateVecs=obj.sRateVecs;
    labelVecs=obj.labelVecs;
    medicationVecs=obj.medicationVecs;
    save(strcat(outputFolder,"dataVecs"), "dataVecs");
    save(strcat(outputFolder,"sRateVecs"), "sRateVecs");
    out=strcat(outputFolder,"medicationVecs");
    save(out,"medication");
    save(strcat(outputFolder,"labelVecs"), "labelVecs");
    end
    %create vectors of the frequnzies and the corresbonding labelVectors from the dataVector 
    %This methode is based on the spectogram method
    function [data,label,freq,time]=createFrequenzieVectors(obj,window,overlap)
        for column=1:size(obj.dataVecs,2)
            for row=1:size(obj.dataVecs,1)
                dataSet=obj.dataVecs{row,column};
                fs=obj.sRateVecs{column};
                [s,f,t,ps]=spectrogram(dataSet,window,overlap,[],fs);
                freqRows=f>obj.buttomThresholdFreq&f<obj.topThresholdFreq;
                f=f(freqRows);
                data{row,column}=ps(freqRows,:);
                
            end
            %create corresbonding label vec
            newlabel=[];
            newlabel=zeros(0,size(t,2));
            labels=obj.labelVecs{column};
            labels=labels{2};
            for entryNr=1:size(t,2)
                 newlabel(entryNr)=0;
                 for labelNr=1:size(labels,1)
                    if t(entryNr)-(window/(2*fs))>=labels.Start(labelNr) && t(entryNr)+(window/(2*fs))<=labels.Stop(labelNr)
                        newlabel(entryNr)=1;
                    end
                 end
            end
            label{column}=newlabel;
            freq{column}=f;
            time{column}=t;
        end
    end
    function [alpha, theta]=createAlphaThetaVec(obj,f,data)
    %extract the slowing intervalls and corresbonding EDF files from the xlsx
    for row=1:size(data,1)
    for column=1:size(data,2)
        ps=data{row,column};
        rowsTh=f{column}>obj.theta(1)&f{column}<obj.theta(2);
        rowsAl=f{column}>obj.alpha(1)&f{column}<obj.alpha(2);
        alpha{row,column}=sum(ps(rowsAl,:));
        theta{row,column}=sum(ps(rowsTh,:));
    end
    end
    end
    function obj=getSlowings(obj)
    sheet="events";
    xlRange="L2:O302";
    data=readtable(obj.labelFile,'Sheet',sheet,'Range',xlRange);
    slowRows=data.SLOW==1;
    obj.slowingdata=data(slowRows,:);
    end
    %create the slowinglabel vecotor for the given EDF file
    function [slowingVec,intervals]=createSlowingVector(obj,edfFile,length,sRate)
    edfFile=regexprep(edfFile,'/','\');
    file=regexprep(edfFile,'.edf','');
    file=split(file,'\');
    file=file(end);
    vec={};
    rows=find(contains(obj.slowingdata.Var2(:),file));
        for i=1:size(rows,1)
        start=obj.slowingdata.Start(rows(i));
        stop=obj.slowingdata.Stop(rows(i));
        vec{i,1}=obj.labelrow(start,stop,sRate,length);
        end
    vec=cell2mat(vec);
    slowingVec{1}=sum(vec,1);
    slowingVec{2}=obj.slowingdata(rows,3:4);
    end
    end
    methods(Static)
    %create an vector of size lenght with 1 in the intervall between start and stop time
    %for the given sampling rate fs
    
    function lVec = labelrow(start,stop,fs,length)
        for i = 0:(length-1)
        column=i+1;
        sec=i*(1/fs);
            if sec==start
            lVec(column)=1;
            elseif sec==stop
            lVec(column)=1;%3;
            elseif sec<stop && sec>start
            lVec(column)=1;%2;
            else
            lVec(column)=0;
            end
        end
    end
    end
end