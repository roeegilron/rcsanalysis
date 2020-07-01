function tblout = create_full_database(dirname)
% this function created a database of rcs data

% rows
% rec time
% path to filename
% rawTDdata .mat exist
% plot (boolean)

% depends on:
% turtle json

% add path
ptadd = genpath(fullfile(pwd,'toolboxes','turtle_json'));
addpath(ptadd);

dirsdata = findFilesBVQX(dirname,'Sess*',struct('dirs',1,'depth',1));


% extract times and .mat status
dbout = struct
cntsave = 1;
for d = 1:length(dirsdata)
    diruse = findFilesBVQX(dirsdata{d},'Device*',struct('dirs',1,'depth',1));
    
    if isempty(diruse) % no data exists inside
        % populate everything with raw data 
    else % data may exist, check for time domain ndata
        tdfile = findFilesBVQX(dirsdata{d},'RawDataTD.json');
        
        [pn,fn] = fileparts(dirsdata{d});
        [~,patientRaw] = fileparts(pn);
        dbout(cntsave).rectime = getTime(fn);
        dbout(cntsave).sessname = fn;
        dbout(cntsave).patient = patientRaw(1:end-1);
        dbout(cntsave).side = patientRaw(end);


        if isempty(tdfile) % time data file doesn't exist
            [~,deviceName] = fileparts(diruse{1});
            dbout(cntsave).device = deviceName;
            dbout(cntsave).startTime = NaT;
            dbout(cntsave).endTime = NaT;
            dbout(cntsave).duration = seconds(0);
            dbout(cntsave).number_of_sense_settings = NaN;
        else
            timeReport = report_start_end_time_td_file_rcs(tdfile{1});
            [tdpath,deviceName] = fileparts(tdfile{1});
            [~,deviceName] = fileparts(tdpath);
            dbout(cntsave).device = deviceName;
            dbout(cntsave).patient = patientRaw(1:end-1);
            dbout(cntsave).side = patientRaw(end);
            dbout(cntsave).startTime = NaT;
            dbout(cntsave).endTime = NaT;
            dbout(cntsave).duration = seconds(0);
            dbout(cntsave).number_of_sense_settings = NaN;


            if ~isempty(timeReport.duration)
                
                [~,tdfilename ] = fileparts(tdfile{1});
                % timeReport = reportime(tdfile{1}); % XXX
                timeReport = report_start_end_time_td_file_rcs(tdfile{1});
                dbout(cntsave).startTime = timeReport.startTime;
                dbout(cntsave).endTime = timeReport.endTime;
                dbout(cntsave).duration = timeReport.duration;
                
                % load device settings file
                try
                    evFile = findFilesBVQX(dirsdata{d},'DeviceSettings.json');
                    [~,evfilename ] = fileparts(evFile{1});
                    [deviceSettingsOut,stimStatus,stimState] = loadDeviceSettingsForMontage(evFile{1});
                    if ~isempty(deviceSettingsOut)
                        dbout(cntsave).number_of_sense_settings = size(deviceSettingsOut,1);
                    else
                        dbout(cntsave).number_of_sense_settings = NaN;
                    end
                catch
                end
                
            end
        end

    end
    cntsave = cntsave + 1;
end
tblout = struct2table(dbout);
filesavename = fullfile(dirname,'database_for_simon');
save(filesavename,'tblout');
% reogranize the tblout table  and sort on time
% clean up
rmpath(ptadd);
end

function t = getTime(fn)
%%
tmpcl = regexp(fn,'[0-9]+','match');
timenum = str2num(tmpcl{1});
t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
%%
end



