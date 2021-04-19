chanels=[11];%select the chanels you will plot
%values is the dataset on which the alpha/theta will be computed
values=EEG.data(chanels(1),:);%-EEG.data(chanels(1),:);
theta=[3.5 7.5];%defines the theta wave chanel
alpha=[7.5 12.5];%defines the alpha wave chanel
delta=[0.5 3.5];%defines the delta wave chanel
load('labelsets.mat');%import the label data
times=EEG.times;
fs=EEG.srate;
window=fs/2;
overlap=window/2;%defines the windowsize
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

values=reshape(values,window,[]);
times=reshape(times,window,[]);
label=LMatrix(index,:);
label=sum(label,1);
label=reshape(label,window,[]);
j=0;
artif=[];
AlphaTheta=[];
for i=1:size(times,2)
    if sum(values(:,i)>100|values(:,i)<-100)>0
        j=j+1;
        artif(j)=i;
    end
end
% values(:,artif)=[];
% times(:,artif)=[];
% label(:,artif)=[];
%end
%compute the alpha/theta value for each window
for i=1:size(values,2)
    column=values(:,i);
    [pxx,f]=pwelch(column,[],[],[],fs);
    rowsTh=f>theta(1)&f<theta(2);
    rowsAl=f>alpha(1)&f<alpha(2);
    AlphaTheta(i)=sum(pxx(rowsAl))/sum(pxx(rowsTh));
end
%end
%set the marks for the slowings
x=label==1|label==3;
x_1=times(x);
x_1=reshape(x_1,1,[]);
x_1=[x_1;x_1];
y=[0 3];
%end
%plot the result
if isempty(x_1) 
plotAT=plot(times(1,:),AlphaTheta);
else
plotAT=plot(times(1,:),AlphaTheta,x_1,y,'--');
end
%end