function read_motor_diary_redcap()
%%
warning('off','MATLAB:table:RowsAddedExistingVars');
params.savedir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/motor_diary_data/results';
params.datadir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/motor_diary_data/data/';
ff = findFilesBVQX(params.datadir,'RCS02*.mat');
for f =  1:length(ff)
    datafn = ff{f};
    load(datafn);
    dataRaw = data; 
    if strcmp('motor_diary_no_med_v2',type_data)
        %%
        for d = 1:size(dataRaw,1) % each row is one day
            start = tic;
            dayTableRaw = dataRaw(d,:);
            rawFieldnames = dayTableRaw.Properties.VariableNames';
            badFile = 0; 
            
            try
                if isdatetime(dayTableRaw.md_date_day1(1))
                    if isnat(dayTableRaw.md_date_day1(1))
                        badFile = 1;
                    end
                end
            end
            
            try
                if strcmp(dayTableRaw.md_date_day1(1),'') % check if data is empty - if so, form is empty
                    badFile = 1;
                    fprintf('EMPTY day %s done in %.2f secs\n','XXXX',toc(start));
                end
            end
            
            try
                if isnan(dayTableRaw.md_date_day1(1))
                    fprintf('EMPTY day %s done in %.2f secs\n','XXXX',toc(start));
                    badFile = 1;
                end
            end
            
            if ~badFile
                % parse columns
                cntMotor = 1;
                
                idxcols = cellfun(@(x) any(strfind(x, '__')),rawFieldnames);
                fieldNamesParse = rawFieldnames(idxcols); 
                
                
                dateDay1 = datetime(dayTableRaw.md_date_day1(1));
                [timeStartFile ,~] = getTime(fieldNamesParse{1},dateDay1);
                [timeStartEndFile ,~] = getTime(fieldNamesParse{end},dateDay1);
                timeStartFile.Format = 'uuuu-MM-dd';
                timeStartEndFile.Format = 'uuuu-MM-dd';
            
                
                fnsave = sprintf('%s_%s--%s.mat',patient,timeStartFile,timeStartEndFile);
                foldersave = fullfile(params.savedir,patient);
                fullfnsave = fullfile(foldersave, fnsave);
                
                motorDiary = table();
                
                
                if ~exist(fullfnsave,'file')
                    for i = 1:length(fieldNamesParse)
                        
                        dateDay1 = datetime(dayTableRaw.md_date_day1(1));
                        [timeStart timeEnd] = getTime(fieldNamesParse{i},dateDay1);
                        if i > 1
                            if timeStart ~= motorDiary.timeStart(end)
                                cntMotor = cntMotor + 1;
                            end
                        end
                        
                        if isfield(dayTableRaw,'subject_id')
                            motorDiary.subject_id{cntMotor} = dayTableRaw.subject_id{1};
                        else
                            motorDiary.subject_id{cntMotor} = patient;
                        end
                        if isfield(dayTableRaw,'redcap_event_name')
                            motorDiary.redcap_event_name{cntMotor} = dayTableRaw.redcap_event_name{1};
                        else
                            motorDiary.redcap_event_name{cntMotor} = 'NA';
                        end
                        if isfield(dayTableRaw,'redcap_repeat_instrument')
                            motorDiary.redcap_repeat_instrument{cntMotor} = dayTableRaw.redcap_repeat_instrument{1};
                        else
                            motorDiary.redcap_repeat_instrument{cntMotor} = 'NA';
                        end
                        if isfield(dayTableRaw,'redcap_repeat_instance')
                            motorDiary.redcap_repeat_instance{cntMotor} = dayTableRaw.redcap_repeat_instance(1);
                        else
                            motorDiary.redcap_repeat_instance{cntMotor} = 'NA';
                        end
                        if isfield(dayTableRaw,'md_description')
                            motorDiary.md_description{cntMotor} = dayTableRaw.md_description{1};
                        else
                            motorDiary.md_description{cntMotor} = 'NA';
                        end
                        
                        
                        % do some parsing
                        [timeStart timeEnd] = getTime(fieldNamesParse{i},dateDay1);
                        [cond] = getCond(fieldNamesParse{i});
                        [value] = getValue(dayTableRaw.(fieldNamesParse{i}));
                        motorDiary.md_date_day1{cntMotor} = dateDay1;
                        
                        
                        motorDiary.timeStart(cntMotor) = timeStart;
                        motorDiary.timeEnd(cntMotor) = timeStart;
                        motorDiary.(cond)(cntMotor) = value;
                        
                        
                    end
                    fprintf('day %s done in %.2f secs\n',motorDiary.timeStart(end),toc(start));
                    if ~isempty(motorDiary)
                        % save the file
                        foldersave = fullfile(params.savedir,motorDiary.subject_id{1});
                        if ~exist(foldersave,'dir')
                            mkdir(foldersave);
                        end
                        idxcols = cellfun(@(x) any(strfind(x, '__')),rawFieldnames);
                        fieldNamesParse = rawFieldnames(idxcols);
                        
                        
                        dateDay1 = datetime(dayTableRaw.md_date_day1(1));
                        [timeStartFile ,~] = getTime(fieldNamesParse{1},dateDay1);
                        [timeStartEndFile ,~] = getTime(fieldNamesParse{end},dateDay1);
                        timeStartFile.Format = 'uuuu-MM-dd';
                        timeStartEndFile.Format = 'uuuu-MM-dd';
                        
                        
                        fnsave = sprintf('%s_%s--%s.mat',patient,timeStartFile,timeStartEndFile);
                        foldersave = fullfile(params.savedir,patient);
                        fullfnsave = fullfile(foldersave, fnsave);
                        
                        save(fullfnsave,'motorDiary');
                    end
                    clear motorDiary
                end
            end
        end
    end
end

end

function [timeStart timeEnd] = getTime(str,dateDay1)
idxund = strfind(str,'_');
% see if you have to incerement day?
idxday = strfind(str,'day');
dateDay1 = dateDay1 + days(str2num(str(idxday+3))-1);
splitStrs = strsplit(str,'_');
idxTimeStart = find(cellfun(@(x) ~isempty(str2num(x)),splitStrs)==1,1);
hourNum = str2num(splitStrs{idxTimeStart});
minRaw = splitStrs{idxTimeStart+1};
if any(strfind(minRaw,'am'))
    minNum = str2num(strrep(minRaw,'am',''));
    amOrPm = 'am';
elseif any(strfind(minRaw,'pm'))
    minNum = str2num(strrep(minRaw,'pm',''));
    amOrPm = 'pm';
end

% get date string
dateDay1.Format = 'uuuu-MM-dd';
dayStr = sprintf('%s__%.2d:%.2d%s',dateDay1,hourNum,minNum,amOrPm);
timeStart = datetime(dayStr,'InputFormat','uuuu-MM-dd__hh:mmaa');
timeStart.Format = 'uuuu-MM-dd HH:mm';

% fprintf('raw time:\t %s converted time:\t %s\n',dayStr,timeStart);
timeEnd  = timeStart + minutes(30);
end

function [cond] = getCond(str)
if any(strfind(str,'asleep'))
    cond = 'asleep';
elseif any(strfind(str,'off'))
    cond = 'off';
elseif any(strfind(str,'on_no_dys'))
    cond = 'on_without_dysk';
elseif any(strfind(str,'on_nont_dys'))
    cond = 'on_with_ntrb_dysk';
elseif any(strfind(str,'on_t_dys_'))
    cond = 'on_with_trbl_dysk';
elseif any(strfind(str,'no_tr_'))
    cond = 'no_tremor';
elseif any(strfind(str,'nont_tr_'))
    cond = 'non_trbl_tremor';
elseif any(strfind(str,'t_tr_'))
    cond = 'trbl_tremor';
end

% fprintf('raw cond:\t %s converted cond:\t %s\n',str,cond);

end

function value = getValue(valRaw)
if isnumeric(valRaw)
    value = valRaw;
else
    value = NaN;
end

end