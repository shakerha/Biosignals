%This script aplies the alpha/theta power extrcation on the full TUH EEG
%Corpus version 1.0.0. The scrpit needs the path of the packed data set.
funcs=functionsForTUHData;
path='F:\EEGData\FULL TUH\www.isip.piconepress.com\projects\tuh_eeg\downloads\tuh_eeg\v1.0.0\edf';
%Windowsize and overlap for the alpha/theta power extraction 
windowSize=10;
overlapSize=9;
%creates a list of the tar files included in the data set
tarFiles=funcs.createFileList('gz',path);
%Unpack each tar file and extract the alpha/theta power for the record
%from the unpacked folder. The unpacked folder wil be deleted after the
%data was extracted
%files stores the file names of the first edf file of each record or the
%tar file if it could not be unpacked.
%alphaByThetas stores the alpha/theta power for each record it is an cell
%array each entry contains the alpha/theta powers for the corresbonding
%record. 
%Error contains labesl for array that applies by extracting the
%data 
%0 no error 
%1 tar file can not be unpacked
%2 edf file do not contain a samplingrate 
%3 resulting alpha/theta power is not a number
[files,alphaByThetas,error]=funcs.edfAlphaThetaExraction(tarFiles,windowSize,overlapSize,files,alphaByThetas,error);
