function MAIN_run_process_RCS_data_in_x_min_chunks(dirname)
pruse.minaverage = 10; 
pruse.maxgap = 120; % seconds 

databsefn = fullfile(dirname,'database.mat'); 
if exist(databsefn,'file')
    load(databsefn); 
else
    MAIN_report_data_in_folder(dirname); 
    load(databsefn); 
end

% only look at file in the databse that over a certain sampling rate 

% get rid of empty elements 
idxempty = cellfun(@(x) isempty(x),tblout.duration); 
tblout = tblout(~idxempty,:);
idxovercutoff = cellfun(@(x) (x >= minutes(pruse.minaverage)),tblout.duration);
tblout = tblout(idxovercutoff,:); 


        endTime = curTime + minutes(pruse.minaverage); 
        cntavg = 1; 
        psdResults = struct();
        while endTime < times(end)
            idxbetween = isbetween(times,curTime,endTime); 
            if max(diff(times(idxbetween))) < seconds(pruse.maxgap)
                for c = 1:4
                    fn = sprintf('key%dfftOut',c-1);
                    psdResults.(fn)(cntavg,:) = mean(fftResultsTd.(fn)(:,idxbetween),2);
                end
                psdResults.timeStart(cntavg) = curTime; 
                psdResults.timeEnd(cntavg) = endTime; 
                psdResults.numberOfPsds(cntavg) = sum(idxbetween); 
                cntavg = cntavg + 1; 
            end
            curTime = endTime; 
            endTime = curTime + minutes(pruse.minaverage);
        end



end