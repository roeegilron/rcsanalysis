% function plot_subject_specific_data_psd_coherence_home_data_raw_soff_son()
close all, clear all, clc

onlyMean = 1;

MAX_SUBSET = 1e3;
OPPACITY = 0.1;
COLOR_FACTOR = 2;
LINE_WIDTH_TRACES = 0.002; % traces
LINE_WIDTH_MEAN = 1; % traces

%% load data
rootdir = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/';
figdirout = fullfile(rootdir,'figures');
ff = findFilesBVQX(rootdir,'RCS09_L*psdAndCoherence*.mat');

%% plot all raw data PSS plots
ff
idStimON = input('Indicate position of "Stim on" file? 1,2,3 ...: ','s');
idStimOFF = input('Indicate position of "Stim off" file? 1,2,3 ...: ','s');
disp('...')

for fnf = 1:2
    if fnf == 1
        load(ff{str2num(idStimOFF)});
        grandTitle = {};
        grandTitle{1,1} = sprintf('%s %s',database.patient{1},database.side{1});        
        grandTitle{1,2}  = 'stim off';
        database.duration.Format = 'hh:mm';
        grandTitle{1,3} = sprintf('%s (hh:mm) hours of data',sum(database.duration));
        saveFileNamePart1 = 'stim-off';
    else
        load(ff{str2num(idStimON)});
        grandTitle{1,4}  = sprintf('stim on (%s, %.2f mA, %.2f Hz)',database.electrodes{1},database.amplitude_mA(1),database.rate_Hz(1));
        database.duration.Format = 'hh:mm';
        grandTitle{1,5} = sprintf('%s (hh:mm) hours of data',sum(database.duration));
        saveFileNamePart2 = sprintf('stim-on_%s_%.2f-mA_%.2f-Hz',database.electrodes{1},database.amplitude_mA(1),database.rate_Hz(1));
    end
    
    %% identify channels
    fieldnamesRaw = fieldnames(allDataCoherencePsd );
    idxPlot = cellfun(@(x) any(strfind(x,'key')),fieldnamesRaw);
    fieldNamesPlot = fieldnamesRaw(idxPlot);
    for f = 1:length(fieldNamesPlot)
        chanFn = sprintf('chan%d',f);
        chlFilUse{fnf,f} = database.(chanFn){1};
        endChStr = findstr('lpf1',database.(chanFn){1})-2;
        chlUse{fnf,f} = chlFilUse{fnf,f}(1:endChStr);

    end
end


for ii=1:size(chlFilUse,1)
    switch ii
        case 1, disp('------------ STIM OFF ------------')
        case 2, disp('------------ STIM ON ------------')
    end
    for jj=1:size(chlFilUse,2)
        disp(['ch',num2str(jj),': ', chlFilUse{ii,jj}])
    end
end
disp('...')

%% set up figure
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
addpath(genpath(fullfile(pwd,'toolboxes','plot_reducer')));
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.05 0.95});
hpanel(2).pack(2,4);
xticks = [4 8 12 20 30 60 80];
coloruse  = [0.8 0 0; % Stim Off, red
                0 0.8 0]; % Stim On, green
%% PLOT PSD
for chi = 1:size(chlUse,2)
    nextCh = chlUse(1,chi);
    idx = cellfun(@(x) any(strfind(x,nextCh)),chlUse);
    if sum(idx,'all') == 2 % identifies channel in both datasets
        % do Stim Off (dataSet = 1) then Stim On (dataSet = 2)
        for dataSet = 1:2
            if dataSet == 1
                load(ff{str2num(idStimOFF)});
            else
                load(ff{str2num(idStimON)});
            end
            % get only data from 8am -10pm
            t = allDataCoherencePsd.timeStartTd;
            idxTime = hour(t) > 8 & hour(t) < 22;
        
            hsb(chi) = hpanel(2,1,chi).select();
            hold(hsb(chi),'on');
            x = allDataCoherencePsd.ffPsd;
            y = allDataCoherencePsd.(fieldNamesPlot{chi})(:,idxTime);
            yUse = subsetData(y,MAX_SUBSET);
            xlim([1 100]);  
            ylim([-3 3]); 
            if ~onlyMean
                hp = plot(x,yUse,'LineWidth',LINE_WIDTH_TRACES,'Color',coloruse(dataSet,:));
                applyOppacity(hp,OPPACITY);
            end
            plot(x,mean(yUse'),'LineWidth',LINE_WIDTH_MEAN,'Color',coloruse(dataSet,:)/COLOR_FACTOR);
            chanFn = sprintf('chan%d',chi);         
            ttluse = {};
            ttluse{1,dataSet+1} = database.(chanFn){1};
            title(ttluse);            
            hsb(chi).XTick = xticks;
            ylims = hsb(chi).YLim;
            plotXticks(xticks,ylims)    
            ylabel('Power (log_1_0\muV^2/Hz)');                
            clear x, clear y, clear yUse
        end       
    end
end

%% PLOT COHERENCE
idxPlot = cellfun(@(x) any(strfind(x,'gpi')),fieldnamesRaw) | ...
                cellfun(@(x) any(strfind(x,'stn')),fieldnamesRaw);
fieldNamesPlot = fieldnamesRaw(idxPlot);

for subcorchi = 1:2 % for each subcortical ch
    nextCh = chlUse(1,subcorchi);
    idx = cellfun(@(x) any(strfind(x,nextCh)),chlUse);
    if sum(idx,'all') == 2 % if channel is in both datasets (Stim Off & Stim On)
        % ch identifier of subcortical ch existing in both Off and On
        tempNextCh = char(nextCh);
        chpos = tempNextCh(2);
        chneg = tempNextCh(4);
        chstr = [chneg,chpos];
        temp = char(fieldNamesPlot);
        temp2 = temp(:,1:5);
        fieldNamesPlotCharsCell = cellstr(temp2);
        idxchs = find(cellfun(@(x) any(strfind(x,chstr)),fieldNamesPlotCharsCell)==1);
        
        for cohepair = 1:length(idxchs)
        
            % do Stim Off (dataSet = 1) then Stim On (dataSet = 2)
            for dataSet = 1:2
                if dataSet == 1
                    load(ff{str2num(idStimOFF)});
                else
                    load(ff{str2num(idStimON)});
                end
                % get only data from 8am -10pm
                t = allDataCoherencePsd.timeStartTd;
                idxTime = hour(t) > 8 & hour(t) < 22;

%                 % cases where subcortical channels where recorded on other
%                 % channel (e.g. Contact 1,0 in recorded in Ch2 instead of Ch1)
%                 ch1Actual = database.chan1{1}(1:4);
%                 ch2Actual = database.chan2{1}(1:4);
%                 if strcmp(char(nextCh),ch1Actual) || strcmp(char(nextCh),ch2Actual) 
%                     hsb(idxchs(cohepair)) = hpanel(2,2,idxchs(cohepair)).select();
%                     hold(hsb(idxchs(cohepair)),'on');
%                 elseif cohepair == 1 && ~strcmp(char(nextCh),ch1Actual) && sum(idxchs) <=3
%                     ch1is1 = 0; idxchs = idxchs +2;
%                     hsb(idxchs(cohepair)-2) = hpanel(2,2,idxchs(cohepair)-2).select();
%                     hold(hsb(idxchs(cohepair)-2),'on');
%                 end
               
                hsb(idxchs(cohepair)) = hpanel(2,2,idxchs(cohepair)).select();
                hold(hsb(idxchs(cohepair)),'on');
                x = allDataCoherencePsd.ffCoh;
                y = allDataCoherencePsd.(fieldNamesPlot{idxchs(cohepair)})(:,idxTime); 
                yUse = subsetData(y,MAX_SUBSET);
                durationPlot = size(yUse,2) * 30/3600;
                xlim([1 100]); 
                ylim([0 1]); 
                if ~onlyMean
                    p = plot(x',yUse,'LineWidth',LINE_WIDTH_TRACES,'Color',coloruse(dataSet,:));
                    applyOppacity(p,OPPACITY);
                end
                plot(x,mean(yUse'),'LineWidth',LINE_WIDTH_MEAN,'Color',coloruse(dataSet,:)/COLOR_FACTOR);

                idxContact1 = allDataCoherencePsd.paircontact(idxchs(cohepair),1) + 1;
                idxContact2 = allDataCoherencePsd.paircontact(idxchs(cohepair),2) + 1;
                chanFn1 = sprintf('chan%d',idxContact1);
                chanFn2 = sprintf('chan%d',idxContact2);
                ttluse = {};
                ttluse{1,1} = 'cohernece between:';
                ttluse{1,2} = database.(chanFn1){1};
                ttluse{1,3} = database.(chanFn2){1};
                title(ttluse);
                
                % correct again the index for alignment of subplot pannels
%                 if ~(subcorchi == 1 && strcmp(char(nextCh),ch1Actual) || subcorchi == 2 && strcmp(char(nextCh),ch2Actual))
%                     idxchs = idxchs - 2;
%                 end
                hsb(idxchs(cohepair)).XTick = xticks;
                ylims = hsb(idxchs(cohepair)).YLim;
                plotXticks(xticks,ylims)
                ylabel('MS Coherence');
                
                clear x, clear y, clear yUse
            end       
        end
    end
end

% incldue meta data in the top title & save figure
if ~onlyMean
    stimStatusFielSave = strcat(saveFileNamePart1,'_',saveFileNamePart2);
else
    stimStatusFielSave = strcat(saveFileNamePart1,'_',saveFileNamePart2,'_onlyMean');
end
hsb = hpanel(1).select();
httl = title(grandTitle);
set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(gca,'XColor','none')
set(gca,'YColor','none')
hpanel.fontsize = 10;
hpanel(1).marginbottom = -10;
hpanel.de.margin = 30;
hpanel.margintop = 40;
httl.FontSize = 10;
fnSave = sprintf('%s_%s_%s',database.patient{1},database.side{1},stimStatusFielSave);

fac = 0.9;
prfig.plotwidth           = 16*fac;
prfig.plotheight          = 10*fac;
prfig.figdir              = figdirout;
prfig.figtype             = '-djpeg';
prfig.figname             = fnSave;
prfig.resolution          = 150;
plot_hfig(hfig,prfig)


% functions
function applyOppacity(p,oppacityFactor)
    for pi=1:size(p,1)
        p(pi).Color = [p(pi).Color, oppacityFactor]; % add oppacity component
    end
end

function yout = subsetData(yin,max_subset)
% only take a subset of y if larger than 1000 lines ot make plotting easier
    if size(yin,2) > max_subset
        rng(1);
        idxchoose = randperm(size(yin,2));
        idxuse = idxchoose(1:max_subset);
        yout = yin(:,idxuse);
    else
        yout = yin;
    end
                

end

function plotXticks(xTicks,yLims)
    for i = 1:length(xTicks)
        xs = [xTicks(i) xTicks(i)];
        plot(xs,yLims,'LineWidth',1,'Color',[0.5 0.5 0.5 0.2],'LineStyle','-.');
    end

end