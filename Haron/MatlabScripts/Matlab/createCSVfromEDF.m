outFile1="157RowData.csv";
outFile2="157AlphaThetaData.csv";
edfFile='/home/rene/Documents/Bachelor arbeit/EEG/Slowing/v1.0.0/edf/01_tcp_ar/00000157/s28_2010_07_28/00000157_s28_a00.edf';
theta=[3.5 7.5];%defines the theta wave chanel
alpha=[7.5 12.5];%defines the alpha wave chanel
delta=[0.5 3.5];%defines the delta wave chanel
eeglab;
EEG.etc.eeglabvers = '14.1.1'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_biosig(edfFile);
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, [],50,66,0,[],1);
EEG = eeg_checkset( EEG );
fs=EEG.srate;
chanels=[];
for i=1:size(EEG.chanlocs,1)
chanels{i}=EEG.chanlocs(i).labels
end
chanels=strrep(chanels," ","_");
chanels=strrep(chanels,"-","_");
chanels=cellstr(chanels);
chanels=[chanels 'TIMES'];
values=transpose(EEG.data);
times=transpose(EEG.times);
values=[values times];
rowTable=array2table(values);
rowTable.Properties.VariableNames=chanels;
writetable(rowTable,outFile1);
%Create alphaTheta
AlphaThetaTable=table();
window=fs;%defines the windowsize
overlap=0;%defines the windowsize
for i=1:size(EEG.data,1)
values=EEG.data(i,:);
[s,f,t,ps]=spectrogram(values,window,overlap,[],fs);
rowsTh=f>theta(1)&f<theta(2);
rowsAl=f>alpha(1)&f<alpha(2);
AlphaTheta=sum(ps(rowsAl,:))./sum(ps(rowsTh,:));
AlphaThetaTable{:,i}=transpose(AlphaTheta);
end
t=transpose(t);
t=array2table(t);
AlphaThetaTable=[AlphaThetaTable t];
AlphaThetaTable.Properties.VariableNames=chanels;
writetable(AlphaThetaTable,outFile2);