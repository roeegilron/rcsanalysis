function copyFolderInDateRange()
% this function copies folders in a certain date range from 
% dropbox to another folder 
% origin folder: 
params.dropboxOrigin = '/Users/roee/Starr Lab Dropbox/RC02LTE/SummitData/SummitContinuousBilateralStreaming/RCS02L';
% destination folder: 
params.destFolder    = '/Users/roee/Documents/potential_adaptive/RCS02/RCS02L';
fdirs = findFilesBVQX(params.dropboxOrigin,'*ess*',struct('depth',1,'dirs',1));
% report fast 
clc; 
for f = 1:size(fdirs,1)
    [pn,fn,ext] = fileparts(fdirs{f});
    rawTime = str2num(strrep(lower(fn),'session',''));
    times(f) = datetime(rawTime/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    fprintf('[%0.3d] \t %s\n',f,times(f));
end
idxstart = input('what is index of start? ');
idxend = input('what is index of start? ');
fdirsMove = fdirs(idxstart:idxend); 
for f = 1:length(fdirsMove)
    start = tic; 
    jsonsmove = findFilesBVQX(fdirsMove{f},'*.json'); 
    [pn,sessFold] = fileparts(fdirsMove{f});
    [pn,~] = fileparts(jsonsmove{1});
    [~,devName] = fileparts(pn);
    fullDest = fullfile(params.destFolder,sessFold,devName); 
    mkdir(fullDest); 
    for j = 1:length(jsonsmove)
        copyfile(jsonsmove{j},fullDest);
    end
    fprintf('copied folder %d/%d in %f\n',f,length(fdirsMove),toc(start));
end
end