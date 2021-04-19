%This function does the same as createFileList defined in functionsForTUHData.m


folder = '/Users/haron/Desktop/Work/Haron/aprikose_edfs'
typ = 'html'

createList(typ, folder)

function createlist = createList(typ, folder)
    T = sprintf('*.%s',typ);
    G = genpath(folder);
    F = regexp(G,'[^:]+','match');
    C = cell(size(F));
    for k = 1:numel(F)
        C{k} = dir(fullfile(F{k},T));
    end
    S = vertcat(C{:});
    L = fullfile({S.folder},{S.name})
    K=transpose(L)
    writecell(K, 'aprikose_edf.xlsx')
end


