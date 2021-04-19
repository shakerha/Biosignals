%%The IformationExtractor class includes methodes that extract patinet
%%information from the corresbonding txt file
classdef InformationExtraxtor 
    properties
        data
        medication
        slowing
    end
    methods (Access = public)
        % Find and open the txt file for the the given edf file
        function obj=InformationExtraxtor(file,typ)
            if typ =='edf'
                file=regexprep(file,"_....edf",".txt");
            end
            fileID=fopen(file,'r');
            obj.data=fscanf(fileID,'%c');
            fclose(fileID);
        end
        %extrcat the age from the txt file
        function age=extractAge(obj)
            ageStringPattern=["-year-old"," year old"];
            for patternNr=1:size(ageStringPattern,2)
                ageEnd= strfind(obj.data,ageStringPattern(patternNr));
                if ~isempty(ageEnd) 
                    ageNr=str2num(obj.data(ageEnd-2:ageEnd-1));
                    if ~isempty(ageNr)
                        age=ageNr;
                    end
                end
            end
        end
        
        %extract the medication from the txt file
        function medication=extractMedication(obj)
            medicationStringPattern=["MEDICATIONS:","MEDICINES:","MEDICATION:"];
            medicationStringPattern=lower(medicationStringPattern);
            medication={'noMatch'};
            %fileID=fopen(textfile,'r');
            data=obj.data;%fscanf(fileID,'c');
            data=lower(data);
            data=split(data,'.');
            %findings=regexp(data,medicationStringPattern)
            %medicationsString=data{findings};
            for patternNr=1:size(medicationStringPattern,2)
                findings=contains(data,medicationStringPattern(patternNr));
                if  sum(findings)==1
                    medicationsString=data(findings);
                    patternNr=size(medicationStringPattern,2);
                    medicationsString=split(medicationsString,':');
                    medicationsString=medicationsString(2);
                    medication=split(medicationsString,',');
                end
            end
            obj.medication=medication;
        end
        
        function [abnormalSlowing,pat,normalSlowing]=extractSlowing(obj)
            pattern=["IMPRESSION:"];
            pattern=lower(pattern);
            slowPattern=["slowing"];
            findings=0;
            clinicalReport=obj.data;%fscanf(fileID,'c');
            clinicalReport=lower(clinicalReport);
            normalSlowing=contains(clinicalReport,slowPattern);
            clinicalReport=split(clinicalReport,'.');
            findPat=contains(clinicalReport,pattern);
            findings=or(findings,sum(contains(clinicalReport(findPat),slowPattern)));
            abnormalSlowing=findings;
            pat=sum(findPat);
        end
        
        % looking for clozapine in the medications
        function containTable=containAntipsychotics(obj,drugTable)
            clinicalReport=lower(obj.data);
            tableLength=size(drugTable,1);
            containTable=zeros([1 tableLength]);
            for row=1:tableLength
                pat=drugTable.GenericName(row);
                buffer=drugTable.BrandNames(row);
                buffer=split(buffer,",");
                if pat==""
                    pat=[];
                end
                if buffer==""
                    buffer=[];
                end
                buffer=transpose(buffer);
                pattern=[pat buffer];
                pattern=regexprep(pattern,'\s','');
                pattern=lower(pattern);
                containTable(row)=contains(clinicalReport,pattern);
            end
        end
        
        %Creates an cell array of the Files of the typ "Typ" existing in the
        %folder""folder"
        function [noMatchvec,index]=createnoMatchVec(listofFiles)
            ind=[];
            for row=1:size(listofFiles,1)
                ind{row}=0;
                buf=contains(listofFiles{row,2},'noMatch');
                if buf==1
                    ind{row}=1;
                end
            end
            index=find(logical(cell2mat(ind)));
            noMatchvec=listofFiles(index);
        end
    end
end