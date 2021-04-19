%delete empty rows

C=readcell('founded_medicine_test.xls');
C(:,[2]) = [];
empty    = cellfun('isclass', C, 'missing');
C(empty) = [];
celldisp(C)
list= cellfun(@(x) x(1:end-1,1), C, 'UniformOutput', false);
writecell(C,'founded_medicine_folder_ohne.xls') 