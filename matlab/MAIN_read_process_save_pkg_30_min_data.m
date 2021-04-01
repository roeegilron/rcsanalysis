function MAIN_read_process_save_pkg_30_min_data()
params.reloadData = 1;
params.plotDayPlots = 1;
rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/pkg_data/pkg_reports_30_min/';

    
if params.reloadData
    %% load data
    ff = findFilesBVQX(rootdir,'*PKG-I_*.csv');
    for f = 2:length(ff)
        dataTable = readtable(ff{f});
        if f == 2
            dataTableOut = dataTable;
            clear dataTable
        else
            dataTableOut = [dataTableOut; dataTable];
        end
    end
    %%
    % get some information about unique patients
    rawPatients = dataTableOut.SUBJID;
    rawDate = dataTableOut.INT_START_DATE;
    rawTime = dataTableOut.INT_START_TIME;
    % see if unique changes will work: 
    outPat = {};
    unqRawPat = unique(rawPatients);
    for u = 1:length(unqRawPat)
                upperPat = upper(unqRawPat{u});
                tmp = strrep(upperPat,' ','');
                tmp = strrep(tmp,'OL','');
                tmp = strrep(tmp,'HAND','');
                tmp = strrep(tmp,'RIGHT','');
                tmp = strrep(tmp,'CL','');
                tmp = strrep(tmp,'GROUPB','');
                
                if strcmp(tmp,'005A')
                    tmp = 'UNKNOWN';
                end
                if strcmp(tmp,'06')
                    tmp = 'UNKNOWN';
                end
                if strcmp(tmp,'11')
                    tmp = 'UNKNOWN';
                end
                if strcmp(tmp,'')
                    tmp = 'UNKNOWN';
                end
                if strcmp(tmp,'RCS3')
                    tmp = 'RCS03L';
                end
                if strcmp(tmp,'RCS01')
                    tmp = 'RCS01L';
                end
                if strcmp(tmp,'RCS05')
                    tmp = 'RCS05L';
                end
        outPat{u} = tmp;
    end
    uniquePatinets = unique(outPat);
    outPat = {};
    % make some changes to get at unique patients better:
    for p = 1:length(rawPatients)
        upperPat = upper(rawPatients{p});
        tmp = strrep(upperPat,' ','');
        tmp = strrep(tmp,'OL','');
        tmp = strrep(tmp,'HAND','');
        tmp = strrep(tmp,'RIGHT','');
        tmp = strrep(tmp,'CL','');
        tmp = strrep(tmp,'GROUPB','');
        
        if strcmp(tmp,'005A')
            tmp = 'UNKNOWN';
        end
        if strcmp(tmp,'06')
            tmp = 'UNKNOWN';
        end
        if strcmp(tmp,'11')
            tmp = 'UNKNOWN';
        end
        if strcmp(tmp,'')
            tmp = 'UNKNOWN';
        end
        if strcmp(tmp,'RCS3')
            tmp = 'RCS03L';
        end
        if strcmp(tmp,'RCS01')
            tmp = 'RCS01L';
        end
        if strcmp(tmp,'RCS05')
            tmp = 'RCS05L';
        end
        outPat{p} = tmp;
        timestr = num2str(rawTime(p));
        if length(timestr) == 3
            timestr = ['0' timestr];
        elseif length(timestr) == 1
            timestr = ['000' timestr];
        elseif length(timestr) == 2
            timestr = ['00' timestr];
        end
        dateUse(p) = datetime([num2str(rawDate(p))  ' ' timestr],'InputFormat','yyyyMMdd HHmm');
    end
    uniquePatinets = unique(outPat);
    %%
    for p = 1:length(uniquePatinets)
        patIdx = cellfun(@(x) strcmp(x,uniquePatinets{p}),outPat);
        % data table with duplicates
        rawDataTable = dataTableOut(patIdx,:);
        rawDataTable = addvars(rawDataTable,dateUse(patIdx)',outPat(patIdx)','Before',1,'NewVariableNames',{'localTime','patient'});
        rawDataTable = rawDataTable(:,{'localTime','patient','DAY_NUM','MEDIAN_BK_RAW','MEDIAN_BK_CLEAN','MEDIAN_DK_RAW','MEDIAN_DK_CLEAN'});
        [uniqueDates,unqidx] = unique(rawDataTable.localTime);
        patTable = rawDataTable(unqidx,:);
        patTable = sortrows(patTable,'localTime');
        dirSave = fullfile(rootdir,'matFiles');
        if ~exist(dirSave,'dir')
            mkdir(dirSave);
        end
        filenamesave = sprintf('%s.mat',patTable.patient{1});
        fullfilenamesave = fullfile(dirSave,filenamesave);
        save(fullfilenamesave,'patTable');
    end
end
dirSave = fullfile(rootdir,'matFiles');
ff = findFilesBVQX(dirSave,'*.mat');
%%
clc;
if params.plotDayPlots
    for f  =  1:length(ff)
        load(ff{f});
        allDays = dateshift(patTable.localTime,'start','day');
        fprintf('patient %s\n',patTable.patient{1}); 
        uniqDays = unique(allDays);
        for u = 1:length(uniqDays)
            fprintf('\t\t %s\n',uniqDays(u)); 
        end
    end
end