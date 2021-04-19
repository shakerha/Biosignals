eeglab;
edfFile='D:\Development\GitProjects\University\Studienarbeit_EEG\Matlab\Data_xls\00000169_s001_t001.edf';
chanels=[11];%select the chanels you will plot
%values is the dataset on which the alpha/theta will be computed
EEG.etc.eeglabvers = '14.1.1'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_biosig(edfFile);
EEG = eeg_checkset( EEG );
theta=[3.5 7.5];%defines the theta wave chanel
alpha=[7.5 12.5];%defines the alpha wave chanel
delta=[0.5 3.5];%defines the delta wave chanel
load('labelsets.mat');%import the label data
times=EEG.times;
fs=EEG.srate;window=fs;%defines the windowsize
overlap=0;%defines the windowsize
values=EEG.data(chanels(1),:);%
% search the right lablet data for the selcted EDF file
selectfile=split(EEG.comments,'/');
selectfile=selectfile(size(selectfile,1));
selectfile=split(selectfile,'.');
selectfile=selectfile{1};
searchfile=split(dataSets.Var2,'/');
index=[];
k=0;
for i=1:size(searchfile,1)
    if  strfind(searchfile{i,5},selectfile)
        k=k+1;
        index(k)=i;
    end
end
%end
%delete artifacts
label=LMatrix(index,:);
label=sum(label,1);
j=1;
artif=[];
AlphaTheta=[];
[s,f,t,ps]=spectrogram(values,window,overlap,[],fs);
rowsTh=f>theta(1)&f<theta(2);
rowsAl=f>alpha(1)&f<alpha(2);
AlphaTheta=sum(ps(rowsAl,:))./sum(ps(rowsTh,:));

%AlphaTheta=sum(ps(rowsAl,:));
%end
%plot the result
x=label==1|label==3;
x_1=times(x)/1000;
x_1=reshape(x_1,1,[]);
x_1=[x_1;x_1];
y=[0 max(AlphaTheta)];
meanAll=mean(AlphaTheta);
meanSlow=[];

for i=1:(size(x_1,2)/2)
    start=find(t>=x_1(1,2*i-1),1);
    stop=find(t>x_1(1,2*i),1)-1;
    slowarray=AlphaTheta(start:stop);
    meanSlow(i)=mean(slowarray);
end

meanAll=string(meanAll);
meanSlow=string(meanSlow);
figure
plot(t,AlphaTheta,x_1,y,'--');
title('Mean='+meanAll+', Meanslowing='+meanSlow)
%plotAT=plot(x_1,y,'--');
