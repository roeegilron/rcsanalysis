function reportEventLogInEachFolder()
%% 
rootdir = '/Volumes/RCS_DATA/RCS05/all_data/RCS05L';
ff = findFilesBVQX(rootdir,'EventLog.json'); 
for f = 1:length(ff)
    el = loadEventLog(ff{f});
    if ~isempty(el)
        elr = [el.Event];
        fprintf('in file %s events:\n',ff{f}); 
        fprintf('\t%s\n',elr.EventSubType)
        fprintf('\n\n');
    end
end



end

