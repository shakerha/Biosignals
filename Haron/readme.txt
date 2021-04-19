functionsForTUHData is a collection of functions that can be used to work with the TUH EEG Corpus.
It includes function for the acess of the TUH data, the extraction of features such as the alpha/theta power,
extraction of medication information, calssifiers and the measuring of the preformance for these classifiers.

We created several scripts for differndt paths of our work:

scrpitFullTuh extrats the alpha/theta power from the packed full TUH Corpus v1.0.0

scriptBoxPlotSlowNormal extracts the alpha/theta power from the normal records of the EEG Abnormal Corpus
and the slowing containing records of the EEG Slowing Corpus. 
The extractet values are used to create poxplots to compare the differnd data-sets.

scriptExtractDrugs creates the distripution for detected "slow" records of the full TUH Corpus and anti-psychotic drugs

scriptMLIntDec creates and validate a classifier for slowing intervals based on a feedforward network

scriptTestThresintDec test differndt alpha/theta power threshold for the interval classifier that should detect slowing intervals
it creates a roc curev for the classification preformance

scriptTestThresRecDec test differndt rate thresholds and alpha/theta power thresholds fr the record detection algorithm
it creates roc curves for the differndt thresholds


---------------------------------------------------------------------------------
general overview for code concerned with cached, downloading data 

ScriptTuhDownload.m
    Get list of files from server depending on url
        folderCellArray =  listAllDirectories(url, folderCellArray, saveFileName)
        Recursive, will go through all subfolder
        Will save file format, data of creation
        If it’s a text file it looks for medical information 
ScriptWorkWithExcelData.m
    (Optional) Filter by medicine 
    medsCell = findClozapineInCellArray(xlsTxtData, medsCell, pattern)
        Takes the read in data returned from listAllDirectories and looks for a pattern in all read in medical data
        Returns a cell array with same layout as foldercellarray
ScriptTuhDownload.m
    Download specified/sorted edf files from tuh server
    downloadFolderContentToCellArray(folderCellArrayData)
        Function not recursive 
        Downloads everything to the current matlab on path folder 
VisualizeEEGData.m
    function calculatePowerForBands(list, windowSize, overlapSize)
        calculates Power for all the bands by Fourier frequencies stuff, allows to specify window and overlapSize for calculation 
        List of edf files for which they are supposed to be created 
        Creates a lot of excel files overall in the folder of the edf file
    (Optional) returnData = createDataForBoxplots(list, channel, frequency)
        Accumulates the data necessary to draw boxplots in matlab
        Requires a list of  excel files 
    calcPValueAndMore(dataNormal, dataMeds, nameMeds, outlierPercentage,outlierPercentageMeds)
        Calculates a lot of statistics from the data created in calculatePowerForBands
        Removes outliers as well
        Clozapine has not a lot of data and usually needs a higher outlier removal percentage 
        Statistics
        Alpha/Theata
        Alpha/Band 
            Band = alpha + beta + gamma + theta + delta
        Amount of data points
        mean
        Std 
        pvalues
        Alpha/tetha between medicine and normal
        Alpha/band between medicine and normal
        In general between medicine and normal data
    calcPValueAndMoreWithSampling(dataNormal, dataMeds, nameMeds, timesSampling, outlierPercentageNormal, ourlierPercentageMeds)
        same as function above but with sampling 

Note:

-If you got problems with downlaoding .edf files and creating medicine datasets please look at: how_to_download_edf.txt

-temp.m
    Trying out of different functions, like a sketch. 

-trytorun.m 
    Trying out of different functions, like a sketch
---------------------------------------------------------------------------------