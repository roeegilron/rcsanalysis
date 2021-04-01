classdef dreamDataReader < handle 

    properties
        FileNames
        Data
        Patient
    end
    
    %%%%%%
    %
    % public methods 
    %
    %%%%%%
    methods
        %%%%%%
        %
        % init object    
        %
        %%%%%%                                
        function obj = dreamDataReader()
            obj.FileNames = {}; % these are valid session with data
            obj.Data = struct(); % these are just fodlers that may or may not have data
            obj.Patient = 'XXX';
        end
        
        
        %%%%%%
        %
        % add folder    
        %
        %%%%%%                        
        function addFolder(obj,foldername)
            %% add folder to rcsPlotter object to open / plot 
            % 
            %% Input: 
            %      1. path (str) to folder with dream data (text)
            % 
            %% Usage: 
            %       dr.addFile('path to folder'); 
            %  
            % next run dr.loadData() to  load all fienames added 
            if ischar(foldername)
                if exist(foldername,'dir')
                    fnms = dir(fullfile(foldername,'*.txt'));
                    filenames = {fnms.name}';
                    if ismac
                        idxkeep = ~cellfun(@(x) any(strfind(x,'._')),filenames);
                        filenames = filenames(idxkeep);
                    end
                    for f = 1:length(filenames)
                        obj.addFile(fullfile(foldername,filenames{f}));
                    end
                else
                    error('folder can not be reached');
                end
            else
                error('input should be char array representing folder');
            end
        end


                
        %%%%%%
        %
        % add files    
        %
        %%%%%%                        
        function addFile(obj,filename)
            %% add file to rcsPlotter object to open / plot 
            % 
            %% Input: 
            %      1. path (str) to file with dream data (text)
            % 
            %% Usage: 
            %       dr.addFile('path to folder'); 
            %  
            % next run dr.loadData() to  load all fienames added 
            if ischar(filename)
                if exist(filename,'file')
                    idx = length(obj.FileNames) + 1;
                    obj.FileNames{idx,1} = filename;
                else
                    error('file can not be reached');
                end
            else
                error('input should be char array representing folder');
            end
        end
        
        %%%%%%
        %
        % load data     
        %
        %%%%%%                        
        function loadData(obj,filename)
            %% load / read all the dream data into object 
            %% write  out the data as mat -  so easier to reload next time
            %% Usage: 
            %       rc.loadData();
            %  
            for f = 1:length(obj.FileNames)
                timeStr = NaT;   
                data = importdata(obj.FileNames{f});
                % find idx for first event
                idx = find(cellfun(@(x) any(strfind(x,'Scorer Time:')),data.textdata(:,1))==1);
                idxdatastart = idx + 2;
                % get events 
                event = data.textdata(idxdatastart:end,1);
                c =  categorical(event);
                % get times 
                timeRaw = data.textdata(idxdatastart:end,2);
                % get date string 
                timeStartRaw = strrep(data.textdata{idx,1},'Scorer Time: ','');
                timeStart = datetime(timeStartRaw,'Format','MM/dd/uu - HH:mm:ss');
                timeVec = datevec(timeStart);
                timeVec(1) = timeVec(1) + 2000; % will only work during this century :-) 
                timeStart = datetime(timeVec);
                timeStart.Format = 'MM/dd/uuuu';
                wasDayInc = 0;% (allow only one 
                for t = 1:length(timeRaw)
                    timeStr(t) = datetime(sprintf('%s %s',timeStart,timeRaw{t}));
                    [h,m,s] = hms(timeStr(t));
                    if t > 1 
                        [hBefore,~,~] = hms(timeStr(t-1));
                    else
                        hBefore = h;
                    end
                    if h == 0  & hBefore ~=0
                        if ~wasDayInc % only increment day once 
                            wasDayInc = 1; 
                            timeVec = datevec(timeStart);
                            timeVec(3) = timeVec(3) + 1;
                            timeStart = datetime(timeVec);
                            timeStart.Format = 'MM/dd/uuuu';
                            timeStr(t) = datetime(sprintf('%s %s',timeStart,timeRaw{t}));
                        end
                    end
                    
                end
                
                dataDreem = table();
                dataDreem.time = timeStr';
                dataDreem.event = c; 
                dataDreem.duration = [diff(timeStr) seconds(0)]';
                
                % save data 
                [pn,fn] = fileparts(obj.FileNames{f});
                timeSOut = dataDreem.time(1);
                timeEOut = dataDreem.time(end);
                timeSOut.Format = 'uuuu-MM-dd--HH-mm-ss';
                timeEOut.Format = 'uuuu-MM-dd--HH-mm-ss';
                filename = sprintf('%s___%s__%s.mat',obj.Patient,timeSOut,timeEOut);
                fullfn = fullfile(pn,filename);
                save(fullfn,'dataDreem');
                
                % object save 
                obj.Data(f).dataDreem = dataDreem;
            end
        end
        
        %%%%%%
        %
        % load data from mat file 
        %
        %%%%%%
        function dataDreem = loadDataFromMat(obj,filename)
            %%%%%%
            %
            % load data from mat file
            %
            %%%%%%
            load(filename);
            if isempty(fieldnames(obj.Data(1)))
                load(filename);
                obj.Data(1).dataDreem = dataDreem;
            else
                cnt = length(obj.Data) + 1;
                obj.Data(1).dataDreem = dataDreem;
            end
        end
        
        function plotAllData(obj,filename)
            %% plot all the dream data into object
            %% write  out the data as csv -  so easier to reload next time
            %% Usage:
            %       rc.plotData();
            %
            for i = 1:length(obj.Data)
                hfig = figure;
                hfig.Color = 'w';
                hsb = gobjects();
                hsb(1,1) = subplot(1,1,1);
                dreemDataTable = obj.Data(i).dataDreem;
                obj.plotData(dreemDataTable,hsb(1,1))
            end
        end
        
                
        %%%%%%
        %
        % report data
        %
        %%%%%%
        function reportData(obj,filename)
            sumTable = table();
           for i = 1:length(obj.Data)
               sumTable.startTime(i) = obj.Data(i).dataDreem.time(1);
               sumTable.endTime(i) = obj.Data(i).dataDreem.time(end);
               sumTable.duration(i) = sumTable.endTime(i) - sumTable.startTime(i);
           end
           sumTable = sortrows(sumTable,{'startTime'});
        end
        
        %%%%%%
        %
        % plot data 
        %
        %%%%%%
        function plotData(obj,dreemDataTable,handleAxes)
            %% plot data 
            % 
            %% Input: 
            %      1. dreeam Data table
            %      2. handle axes 
            % 
            %% Usage: 
            %       dr.plotData(dreamDataTable,handleToSubPlotAxes);
            %  
            hsb = handleAxes;
            time = dreemDataTable.time;
            events = dreemDataTable.event;
            % insert another states on transition to make graph nicer
            timeUse = time;
            eventsUse = events;
            cnt = 1;
            timeUse(cnt) = time(1);
            eventsUse(cnt) = events(1);
            cnt = cnt + 1;
            for e = 1:length(events)
                if e > 1
                    if events(e) ~= events(e-1)
                        timeUse(cnt) = time(e);
                        eventsUse(cnt) = events(e-1);
                        cnt = cnt + 1;
                    end
                end
                timeUse(cnt) = time(e);
                eventsUse(cnt) = events(e);
                cnt = cnt + 1;
                
            end
            time = timeUse;
            events = eventsUse;
            hplt = plot(datenum(time),events,'LineWidth',2,'Color',[0 0 0.8 0.6]);
            obj.addLocalTimeDataTip(hplt,time);
            timeStart = dateshift(time(1) - hours(1),'start','hour');
            timeEnd   = dateshift(time(end) + hours(1),'start','hour');
            xticks = datenum(timeStart : minutes(30) : timeEnd);
            hsb(1,1).XTick = xticks;
            datetick('x',15,'keepticks','keeplimits');
            
            timeStart.Format
            datePrt = timeStart;
            datePrt.Format = 'MMM-uuuu';
            [~,~,dSt] = ymd(time(1));
            [~,~,dEn] = ymd(time(end));
            durRec = time(end) - time(1);
            if dSt ==  dEn
                title(sprintf('%d-%s (%s)',dSt,datePrt,durRec))
            else
                title(sprintf('%d-%d %s (%s)',dSt,dEn,datePrt,durRec))
            end
            hsb.FontSize = 16;
           
        end

    end
    



    %%%%%%
    %
    % private methods / utility functions for class 
    %
    %%%%%%

    methods (Access = private)
        
        %%%%%%
        %
        % utility function add local time to data tip of local time
        %
        %%%%%%
        %
        % all of the plotting function use datenum as the x axis
        % reason is that for plotting spectral data using imagesc (fastest
        % performance, compared to pcolor etc. which is slow in
        % largedatasets) you need a numeric axee.
        % This utility function allows one to see a human readable time on
        % mouseover
        function addLocalTimeDataTip(obj,hplt,xTime)
            % add data tip for human readable time if matlab
            % version allows this:
            %
            if ~verLessThan('matlab','9.8') % it only work on 9.6 and above...
                row = dataTipTextRow('local time',xTime);
                hplt.DataTipTemplate.DataTipRows(end+1) = row;
            end
        end
    end


end

