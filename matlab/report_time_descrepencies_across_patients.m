function report_time_descrepencies_across_patients()
%% report time descrepenceis between comptuer time and INS time across patients: 

close all; clear all; clc;
% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir = fullfile(dirname,'database');
else
    error('can not find dropbox folder, you may be on a pc');
end


load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');


%%

%% loop on each subjet, find last session that is at least 20 minutes long, then extract some timing information
rcsIdx = cellfun(@(x) any(strfind(x,'RCS')),masterTableLightOut.patient);
mTable = masterTableLightOut(rcsIdx,:); 
uniquePatients = unique(mTable.patient); 
uniqueSides = unique(mTable.side); 
%% 
fid = fopen('gap_between_computer_time_ins_time.csv','w+'); 
fprintf(fid,'patient\t,');
fprintf(fid,'side\t,');
fprintf(fid,'computer time\t,');
fprintf(fid,'ins time\t,');
fprintf(fid,'difference\t,');
fprintf(fid,'\n');


for p = 1:size(uniquePatients)
    for s = 1:size(uniqueSides) 
        idxuse = strcmp(mTable.patient,uniquePatients{p}) & ... 
                 strcmp(mTable.side,uniqueSides{s}) & ... 
                 mTable.duration > minutes(20) ;
        % potential table 
        tblPatientAndSide = mTable(idxuse,:); 
        tblUse = sortrows(tblPatientAndSide,{'timeStart'},'descend');
        if ~isempty(tblUse)
            for t = 1:size(tblUse,1)
                [flderData,~] = fileparts(tblUse.deviceSettingsFn{t});
                tdMat = fullfile(flderData,'RawDataTD.mat');
                if exist(tdMat,'file') 
                    load(tdMat,'outdatcomplete');
                    if ~isempty(outdatcomplete)
                        break;
                    end
                end
            end
            % find packet gen time that is not zero, use the 100th index to
            % make sure not bad packet:
            idxnotzero = find(outdatcomplete.PacketGenTime ~=0);
            packetGenTime = outdatcomplete.PacketGenTime(idxnotzero(100));
            timestamp = outdatcomplete.timestamp(idxnotzero(100));
            timeStampHuman = datetime(datevec(timestamp./86400 + datenum(2000,3,1,0,0,0)),...
                'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); % medtronic time - LSB is seconds
            packetGenTimeHuman =  datetime(packetGenTime/1000,...
                'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            gapInTime = packetGenTimeHuman - timeStampHuman;
            fprintf(fid,'%s\t,',tblUse.patient{1});
            fprintf(fid,'%s\t,',tblUse.side{1});
            fprintf(fid,'%s\t,',packetGenTimeHuman);
            fprintf(fid,'%s\t,',timeStampHuman);
            fprintf(fid,'%s\t',gapInTime);
            fprintf(fid,'\n');
            fprintf('patient %s side %s\n',tblUse.patient{1},tblUse.side{1});
            clear outdatcomplete
            clear tblUse;
        end
        
    end
end
fclose(fid);
% 
    

end