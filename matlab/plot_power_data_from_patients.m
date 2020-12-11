function plot_power_data_from_patients()
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

masterTableOut = masterTableLightOut;

idxkeep = cellfun(@(x) any(strfind(x,'RCS')), masterTableOut.patient);
tblall =  masterTableOut(idxkeep,:);

unqpatients = unique(tblall.patient);
plotwhat = input('choose patient and side (1) or plot all(2)? ');
if plotwhat == 1 % choose patients and side
    fprintf('choose patient by idx\n');
    unqpatients = unique(tblall.patient);
    for uu = 1:length(unqpatients)
        fprintf('[%0.2d] %s\n',uu,unqpatients{uu})
    end
    patidx = input('patientidx ?');
end
idxPatient = strcmp(tblall.patient , unqpatients(patidx));
tblPatient = tblall(idxPatient,:);



% choose year 
[y,m,d] = ymd(tblPatient.timeStart); 
uniqueYears = unique(y);
for yy = 1:length(uniqueYears)
    fprintf('[%0.2d] %d\n',yy,uniqueYears(yy))
end
yearidx = input('year idx ?');
tblPatient = tblPatient(y == uniqueYears(yearidx),:);

% choose month  
[y,m,d] = ymd(tblPatient.timeStart); 
uniqueMonths = unique(m); 
for mm = 1:length(uniqueMonths)
    fprintf('[%0.2d] %d\n',mm,uniqueMonths(mm))
end
monthidx = input('month idx?');
tblPatient = tblPatient(m == uniqueMonths(monthidx),:);

% choose day  
[y,m,d] = ymd(tblPatient.timeStart);
uniqueDays = unique(d); 
for dd = 1:length(uniqueDays)
    fprintf('[%0.2d] %d\n',dd,uniqueDays(dd))
end
dayidx = input('day idx?');
tblPatient = tblPatient(d == uniqueDays(dayidx),:);
tblPatient.duration.Format = 'hh:mm:ss';

idxLonger = tblPatient.duration > minutes(20);
tblPatient = tblPatient(idxLonger,:);
% loop on sides 
uniqueSides = unique(tblPatient.side);
for s = 1:length(uniqueSides) 
    idxSide = strcmp(tblPatient.side,uniqueSides{s});
    tblSide = tblPatient(idxSide,:); 
    if ~isempty(tblSide)
        %% plot 
        hfig = figure; 
        hfig.Color = 'w';
        sgtitle('place holder'); 
        
        for p = 1:9
            hsb(p) = subplot(9,1,p);
        end
        % initialize data that is plotted: 
        powerDatPlot = struct();
        for p = 1:8
            fnuse = sprintf('Band%d',p);
            powerDatPlot.(fnuse) = [];
        end
        for ss = 1:size(tblSide,1)
            [pn,fn] = fileparts(tblSide.deviceSettingsFn{ss});
            [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(pn);
            pt = powerOut.powerTable; 
            pt = pt(10:end-10,:);
            bandInHz = powerOut.bands.powerBandInHz;
            uxtimes = datetime(pt.PacketGenTime/1000,...
                'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            % XXXX 
            fftInterval = 500;
%             fftInterval = tblPatient.fftTable{1}.interval; 
            % XXXX 
            timeAverage = 30; % in seconds 
            reshapeFactor = timeAverage/(fftInterval/1000);
            
            for p = 1:8
                axes(hsb(p));
                hold(hsb(p),'on');
                % plot power
                uxtimesPower = datetime(pt.PacketGenTime/1000,...
                    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                fnuse = sprintf('Band%d',p);
                yDat = pt.(fnuse);
                % reshape data to average 
                yDatReshape = yDat(1:end-(mod(size(yDat,1), reshapeFactor)));
                timeToReshape= uxtimesPower(1:end-(mod(size(yDat,1), reshapeFactor)));
                yDatToAverage  = reshape(yDatReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
                timeToAverage  = reshape(timeToReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
                
                yAvg = mean(yDatToAverage,1); % average power value 
                tUse = timeToAverage(reshapeFactor,:);
                powerDatPlot.(fnuse) = [powerDatPlot.(fnuse), yAvg];
%                 plot(hsb(p),uxtimesPower,yDat);
                hsc = scatter(hsb(p),tUse,yAvg);
                hsc.MarkerFaceColor = [0 0 0.8];
                hsc.MarkerFaceAlpha = 0.5;
                hsc.SizeData = 20;
                hsc.MarkerEdgeColor = [1 1 1];
                hsc.MarkerEdgeAlpha = 1.0;
                outlierIdx = isoutlier(yAvg);
%                 hsb(p).YLim = [ min(yAvg(~outlierIdx)) max(yAvg(~outlierIdx))];
                title(bandInHz{p});
            end
        end
        
        for pl = 1:length(hsb)-1
            fnuse = sprintf('Band%d',pl);
            yAvg = powerDatPlot.(fnuse);
            prctilesPlot = [25 50 75];
            for pr = 1:length(prctilesPlot)
                prctlPlt = prctile(yAvg,prctilesPlot(pr));
                xlims = hsb(p).XLim;
                plot(hsb(pl),xlims,[prctlPlt prctlPlt],'LineWidth',1,'LineStyle','-.','Color',[0.8 0 0 0.8]);
            end
            % zoom: 
            ylimsUse(1) = prctile(yAvg,1);
            ylimsUse(2) = prctile(yAvg,99);
            if ylimsUse(2) > ylimsUse(1)
                hsb(pl).YLim = ylimsUse;
            end
        end
        dateRec = tblPatient.timeStart(1);
        dateRec.Format = 'dd-MMM-uuuu';
        cntttl = 1;
        ttlLrg{cntttl,1} = sprintf('%s %s %s',tblSide.patient{1},tblSide.side{1},dateRec);
        sgtitle(ttlLrg);
        %%
        
    end
end

end