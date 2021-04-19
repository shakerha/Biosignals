%%This script computes the distribution from the full TUH EEG Corpus 
% it needs the alpha/theta list computed by scriptFullTuhAlphaTheta 
% and the list of antipsychotic drugs and the path of the clinical reports
funcs=functionsForTUHData;
listofDrugs='C:\Users\mckeu\Documents\Bachelorarbeit\Data\listAntipsychcotics.xlsx';
drugtable=readtable(listofDrugs);
clinicalReportsPath='D:\EEGData\reports\v1.0.0';
clinicalReportsList=funcs.createFileList('txt',clinicalReportsPath);
%creates a matrix for the detectedt antipsychotic drugs in the clincal
%reports. each row in drugs corresbonds to a record in clinicalReportsList and each coulmn corresbonds to a
%drug of antipsychTable.
[antipsychTable,drugs,~,abnormalSlowing,~]=funcs.extractInformations(clinicalReportsList,drugtable);
abnormalSlowing=cell2mat(abnormalSlowing);
%load the alph/the powers computed by scriptFullTuhAlphaTheta
load('C:\Users\mckeu\Documents\Bachelorarbeit\Data\FullTUHAlphaByTheta');
load('C:\Users\mckeu\Documents\Bachelorarbeit\Data\FullTUHFiles');
%fitler for antipsychotics that are applied in the data-set
usedDrugsId=sum(antipsychTable,1)>0;
%defines theresholds for the classifier
thresAlphaTheta=1.94;
thresRate=0.98;
%classifie records
slowing=funcs.detection(thresRate,thresAlphaTheta,alphaByThetas);
%match the results with the clincal reports
res=funcs.matchResults(clinicalReportsList,slowing,files);
%creates table for the distripuntion of antipsychotic and classified
%records
corrCompSlow=funcs.createCorrelationTable(drugs,antipsychTable,usedDrugsId,res);
%creates table for the distripuntion of antipsychotic and classified
%records vis the extracted data from the 
corrExtrSlow=funcs.createCorrelationTable(drugs,antipsychTable,usedDrugsId,abnormalSlowing);
%create bar diagrams
y_1=cat(2,corrCompSlow.Drug_Slow,corrCompSlow.Drug_NoSlow);
y_2=cat(2,corrExtrSlow.Drug_Slow,corrExtrSlow.Drug_NoSlow);
c=categorical(corrCompSlow.Row);
f1=figure('Name','CorrDrugsComp');
f2=figure('Name','CorrDrugsExtr');
figure(f1);
barh(c,y_1,'stacked');
figure(f2);
barh(c,y_2,'stacked');
