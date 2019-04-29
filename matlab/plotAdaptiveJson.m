function plotAdaptiveJson(res)
%% input is the "res" structure from read adaptive .json
%% not that fig dir is hard coded here 
%% it opens a dynamic chooser to plot everything 
%% and also plots all the fields indiivually though this is commmented out 
%% on line 36
prfig.plotwidth           = 10;
prfig.plotheight          = 10; 
prfig.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v18_adaptive_month5/figures'; 
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 1; 
prfig.resolution          = 100; 


% see populateTimeStamp for more tips and how we did this 
% time - PacketGenTime is time in miliseconds backstamped to where it in UTC since Jan 1 1970. 
% this is when it hit the bluetooth on computer 
% systemTick ? INS clock-driven tick counter, 16bits, LSB is 100microseconds, (highly accurate, high resolution, rolls over)
% timestamp ? INS clock-driven time, LSB is seconds (highly accurate, low resolution, does not roll over)
% PacketGenTime ? API estimate of when the data packet was created on the INS within the PC clock domain. Estimate created by using results of latest latency check (one is done at system initialization, but can re-perform whenever you want) and time sync streaming. Potentially useful for syncing with other sensors or devices by bringing things into the PC clock domain, but is only accurate within 50ms give or take.
% PacketRxUnixTime ? PC clock-driven time when the packet was received via Bluetooth, as accurate as a C# DateTime.now (10-20ms)
% SampleRate ? defined in HTML doc as enum TdSampleRates: 0x00 is 250Hz, 0x01 is 500Hz, 0x02 is 1000Hz, 0xF0 is disabled

uxtime = [res.timing.PacketRxUnixTime];
dtnums = datenum(uxtime./86400./1000 + datenum(1970,1,1))';
uxtimes = datetime(datevec( dtnums),'TimeZone','America/Chicago'); 

fnms = fieldnames(res.adaptive); 
for f = 1:length(fnms)
    hfig = figure; 
    plot(uxtimes,res.adaptive.(fnms{f}));
    ttluse = strrep(fnms{f},'_',' ');
    title(ttluse); 
    % save
    prfig.figname = fnms{f}; 
%     plot_hfig(hfig,prfig); 
end

%%
% Create text area
fig = uifigure('Position', [100 100 350 800]);
fig.UserData = res; 
pltBtn = uibutton(fig,...
    'Position',[125 90 100 22],...
    'Text','Plot',...
    'ButtonPushedFcn',@plotData); 
% Create list box
lbox = uilistbox(fig,...
    'Position',[20 120 300 600],...
    'Items',fnms,...
    'Multiselect','on'); 


end

% ValueChangedFcn callback
function plotData(src,event) 
fnmsPlot = src.Parent.Children(1).Value; 
adaptive = src.Parent.UserData.adaptive; 
timing = src.Parent.UserData.timing; 

uxtime = [timing.PacketRxUnixTime];
dtnums = datenum(uxtime./86400./1000 + datenum(1970,1,1))';
uxtimes = datetime(datevec( dtnums),'TimeZone','America/Chicago'); 

hfig = figure;
nrows = length(fnmsPlot); 
for f = 1:length(fnmsPlot)
    hsub(f) =  subplot(nrows,1,f); 
    hplt = plot(uxtimes,adaptive.(fnmsPlot{f}));
    for h = 1:length(hplt)
        hplt(h).LineWidth = 3;
        hplt(h).Color = [0 0 0.8 0.7];
    end
    ttluse = strrep(fnmsPlot{f},'_',' ');
    title(ttluse); 
end
linkaxes(hsub,'x'); 

end