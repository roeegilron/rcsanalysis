function temp_compare_acc_data()
%% load data 
rootDir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02';
sessionName = 'Session1557172456029';
fdirs = findFilesBVQX(rootDir,sessionName,struct('dirs',1)); 

frawMats = findFilesBVQX(fdirs{1},'RawDataAccel.mat');
frawJsons = findFilesBVQX(fdirs{1},'RawDataAccel.json');

if ~isempty(frawMats)
    for f = 1:length(frawMats)
        accStruct(f) = load(frawMats{f});
    end
else
    for f = 1:length(frawJsons)
        [pn,fn] = fileparts(frawJsons{f});
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  ...
            MAIN_load_rcs_data_from_folder(pn);
    end 
end
%% plot data 
hfig = figure; 
for i = 1:length(accStruct)
    hsub(i) = subplot(2,1,i); 
    hold on; 
    secs = accStruct(i).outdatcomplete.derivedTimes; 
    x = accStruct(i).outdatcomplete.XSamples; 
    y = accStruct(i).outdatcomplete.YSamples; 
    z = accStruct(i).outdatcomplete.ZSamples; 
    plot(secs-secs(1),x-mean(x)); 
    plot(secs-secs(1),y-mean(y)); 
    plot(secs-secs(1),z-mean(z)); 
end
linkaxes(hsub,'x'); 

end