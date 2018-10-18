function reportEventLogInEachFolder()
%% 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/rcs-data'; 
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

