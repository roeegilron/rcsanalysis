function delete_all_processed_data_in_folder()
% use with caution this will delete all processed data in this fodler 
rootdir = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06R';

ffAcc = findFilesBVQX(rootdir,'processedAccData.mat');
ffTd = findFilesBVQX(rootdir,'processedTDdata.mat');
fprintf('found %d acc files and %d td files, are you sure you want to delete?\n',...
    length(ffAcc),length(ffTd)); 
delteFiles = input('press 1 for yes 0 for no \n'); 
if delteFiles
    cellfun(@(x) delete(x),ffAcc);
    cellfun(@(x) delete(x),ffTd);
end
end