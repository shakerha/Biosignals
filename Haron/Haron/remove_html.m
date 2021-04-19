% file= dir('aprikose_edfs');

files = dir('/Users/haron/Desktop/Work/Haron/haloperidol_edf/*.edf.html');
for ii=1:length(files)
    oldname = fullfile(files(ii).folder,files(ii).name);
    [path,newname,ext] = fileparts(oldname);
    movefile(oldname,fullfile(path, newname));
end
