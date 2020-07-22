function strOut = getAdaptiveHumanReadaleSettings(varargin)
% input - this function takes as input DeviceSettings.json
% option additional input - plot (0 = no, default, 1 = plot) 

% output - a cell array (human readable) of all adaptive settings

% assumptions - this assume you have only one adaptive settings in the
% session that is not changing - so it is better suited for cases in which
% no change is done
% it can be adapted to mulitple changes given adaptive settings table
if length(varargin) == 1 
    adaptiveSettings = varargin{1}; 
    plotData = 0; 
elseif length(varargin) == 2
    adaptiveSettings = varargin{1}; 
    plotData = varargin{2}; 
end

deviceSettingsOut = adaptiveSettings.deviceSettings;
stimStatus = adaptiveSettings.stimStatus;
stimState = adaptiveSettings.stimState;
fftTable = adaptiveSettings.ffTable;
powerTable = adaptiveSettings.powerTable;
adaptiveSettings = adaptiveSettings.adaptiveSettings;

stimStateRaw = stimState;
stimState = table();
% choose the stim state with the longest duration and with an
% active group

sortedStates = sortrows(stimStateRaw,{'activeGroup','duration'},{'descend','descend'});
stimState = sortedStates(1,:);



% params to write
% power
strline = 1;
strOut{strline,1} = 'settings';
strline = strline + 1;

strOut{strline,1} = '_______';
strline = strline + 1;

strOut{strline,1} = '_______';
strline = strline + 1;
strOut{strline,1} = '';
strline = strline + 1;



strOut{strline,1} = '';
strline = strline + 1;

strOut{strline,1} = sprintf('power bands used:');
strline = strline + 1;

strOut{strline,1} = '_______';
strline = strline + 1;
strOut{strline,1} = '';
strline = strline + 1;

if size(powerTable,1) == 1 & length(fieldnames(powerTable))>= 1
    binaryFlipped = fliplr(dec2bin( adaptiveSettings.Ld0_detectionInputs,8));
    for b = 1:length(binaryFlipped)
        if strcmp(binaryFlipped(b) ,'1')
            strOut{strline,1} = sprintf('\t\t[%0.2d] %s',...
                b,powerTable.powerBandInHz{1}{b}); % note assumes only 1 setting in power table
            strline = strline + 1;
        end
    end
end
% stim
strOut{strline,1} = '';
strline = strline + 1;


strOut{strline,1} = sprintf('stim rates:');
strline = strline + 1;
strOut{strline,1} = '_______';
strline = strline + 1;
strOut{strline,1} = '';
strline = strline + 1;


% state 0 
strOut{strline,1} = sprintf('\t[state %d] %0.1fmA',0,adaptiveSettings.currentMa_state0(1));
strline = strline + 1;

% state 1 
if adaptiveSettings.currentMa_state1(1) == 25.5 
    strOut{strline,1} = sprintf('\t[state %d] HOLD',1);
else
    strOut{strline,1} = sprintf('\t[state %d] %0.1fmA',1,adaptiveSettings.currentMa_state1(1));
end
strline = strline + 1;

% state 2
strOut{strline,1} = sprintf('\t[state %d] %0.1fmA',2,adaptiveSettings.currentMa_state2(1));
strline = strline + 1;

% active Recharge 
if stimState.active_recharge
    strOut{strline,1} = sprintf('\t active recharge %s','ON');
else
    strOut{strline,1} = sprintf('\t active recharge %s','OFF');
end
strline = strline + 1;

strOut{strline,1} = sprintf('\tgroup %s',stimState.group);
strline = strline + 1;

strOut{strline,1} = sprintf('\tstim contact: %s',stimState.electrodes{1});
strline = strline + 1;

strOut{strline,1} = sprintf('\trate: %.2fHz',stimState.rate_Hz);
strline = strline + 1;



strOut{strline,1} = '';
strline = strline + 1;


% fft settings
if size(fftTable,1) == 1 & length(fieldnames(fftTable))>= 1
    strOut{strline,1} = sprintf('fft settings:');
    strline = strline + 1;
    strOut{strline,1} = '_______';
    strline = strline + 1;
    strOut{strline,1} = '';
    strline = strline + 1;
    
    
    fftsize = fftTable.fftSize;
    sr = deviceSettingsOut.samplingRate(end);
    
    fftinterval = fftTable.interval;
    fftime = ceil((fftsize/sr).*1000);
    % xxx
    percentOverlap = fftime/ (fftime +fftinterval);
    strOut{strline} = sprintf('\t%d ms FFt interval',...
        fftinterval);
    strline = strline + 1;
    
    updateRate = adaptiveSettings.Ld0_updateRate;
    
    strOut{strline} = sprintf('\teach FFT represents %d ms of data',...
        ceil((fftsize/sr).*1000));
    strline = strline + 1;
    
    strOut{strline} = sprintf('\t%.2f overlap (fft size %d sr %d Hz)',...
        percentOverlap,fftsize,sr);
    strline = strline + 1;
    
    
    
    timeAvg = seconds(   fftinterval/1000 *updateRate ) ;
    timeAvg.Format = 'hh:mm:ss.SSS';
    strOut{strline} = sprintf('\t%d ffts are averaged',updateRate);
    strline = strline + 1;
    
    strOut{strline} = sprintf('\t%s (hh:mm:ss.SSS) of data',timeAvg);
    strline = strline + 1;
    
    strOut{strline} = sprintf('\tbefore being input to LD');
    strline = strline + 1;
    
    strOut{strline,1} = '';
    strline = strline + 1;
end

%% detector settings
strOut{strline,1} = sprintf('detector settings:');
strline = strline + 1;
strOut{strline,1} = '_______';
strline = strline + 1;
strOut{strline,1} = '';
strline = strline + 1;


strOut{strline} = sprintf('\tupdate rate %d',...
    adaptiveSettings.Ld0_updateRate);
strline = strline + 1;

strOut{strline} = sprintf('\tonset %d',...
    adaptiveSettings.Ld0_onsetDuration);
strline = strline + 1;

strOut{strline} = sprintf('\ttermination %d',...
    adaptiveSettings.Ld0_terminationDuration);
strline = strline + 1;

if size(fftTable,1) == 1 & length(fieldnames(fftTable))>= 1
    strOut{strline} = sprintf('\tstate change blank %d (%d ms)',...
        adaptiveSettings.Ld0_blankingDurationUponStateChange,...
        adaptiveSettings.Ld0_blankingDurationUponStateChange * fftTable.interval);
    strline = strline + 1;
else
     strOut{strline} = sprintf('\tstate change blank %d',...
        adaptiveSettings.Ld0_blankingDurationUponStateChange);
    strline = strline + 1;
    
end



strOut{strline} = sprintf('\tramp up rate %.2f mA/sec',...
    (adaptiveSettings.rise_rate(1)/655360)*10);
strline = strline + 1;

strOut{strline} = sprintf('\tramp down rate %.2f mA/sec\t',...
    (adaptiveSettings.fall_rate(1)/655360)*10);
strline = strline + 1;



% power vals

strOut{strline} = sprintf('\tB0 - %d',adaptiveSettings.Ld0_biasTerm(1));
strline = strline + 1;

strOut{strline} = sprintf('\tB1 - %d',adaptiveSettings.Ld0_biasTerm(2));
strline = strline + 1;

if plotData
    hfig = figure; 
    hfig.Position = [776   539   375   742];
    hfig.Color = 'w';
    nrows = 1;
    ncols = 1; 
    cntplt = 1; 
    hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    
    a = annotation('textbox', hsub(1).Position, 'String', "hi");
    a.FontSize = 14;
    
    set(gca,'FontSize',16);
    set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    set(gca,'XColor','none')
    set(gca,'YColor','none')

    
    a.String = strOut;
    a.EdgeColor = 'none';
end
end