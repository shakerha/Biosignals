%list has as input the corpus 
%meds,tempmeds,meds2 have to be empty as iput

list = readcell('/Users/haron/Desktop/Work/Haron_olanzapine/createxls.xlsx')
meds = {}; 
tempmeds = {};
meds2 = {}; 
% function find_medicine(medicine)

    for i = 1:length(list)
    
        tempmeds = [];
        meds2 = []; 
    
        tempmeds = meds;   
        meds = []; 
        
        file = list{i}; 
        xlsData = readcell(file, 'DateTimeType', 'text'); 

        xlsTxtData = xlsData(strcmp(xlsData(:,3), 'txt'), :)
    
        pattern=["haloperidol", "Haloperidolum", "PhEur", "Haloperidoli", "Haloperidoldecanoat"]
           
        meds2 = a.findClozapineInCellArray(xlsTxtData, meds, pattern); 
        meds = [tempmeds; meds2]; 
     
    end
    writecell(meds,'founded_medicine_test.xls') 
    
%  end 
%     pattern = ["quetiapine","seroquel", "quetiapina", "quetiapinum", "quetiapin"];
  % pattern = ["clozapin","clozaril","clopine","fazaclo","denzapine"]; 
   % pattern= ["dilantin", "epilan", "phenytoin"];
   %pattern = ["olanzapine","zypadhera","zyprexa"];

%         pattern =["risperidone", "risperdal", "belivon", "rispen", "risperidal", "rispolept", "risperin", "rispolin", "sequinan", "apexidone", "risperidonum", "risperidona", "psychodal", "spiron"];
%   pattern = ["olanzapine","zypadhera","zyprexa"];
% pattern = ["aripiprazole", "Aripiprazolum", "monohydricum", "Monohydrat","Aripiprazol"];