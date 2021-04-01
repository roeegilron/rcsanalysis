function plot_motor_diary_redcap()
% this function relied on read_motor_diary_redcap() to read the data
params.resdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/motor_diary_data/results';
params.resdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/motor_diary_data/results/RCS02_temp';
params.datadir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/motor_diary_data/data/';
params.figdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/motor_diary_data/figures';
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));

%%
ff = findFilesBVQX(params.resdir,'allData.mat');
%%
% motorDiaryAll = table();
% for f = 1:length(ff)
%         load(ff{f})
%         if f == 1
%             motorDiaryAll  = motorDiary;
%         else
%             motorDiaryAll = [motorDiaryAll; motorDiary];
%         end
% end
% fnsave = fullfile(params.resdir,'allData.mat');
% clear motorDiary
% motorDiary = motorDiaryAll;
% save(fnsave,'motorDiary');
%%
for f = 1:length(ff)
    % load the data
    load(ff{f})
    [~,plotname] = fileparts(ff{f});
    %% get rid of data in whihc no data
    dataexists = sum(motorDiary{:,end-7:end},2) > 0 ;
    motorDiaryClean = motorDiary(dataexists,:);
    [yy,mm,dd] = ymd(motorDiaryClean.timeStart);
    unqY = unique(yy);
    unqM = unique(mm);
    unqD = unique(dd);
    % figure out hoe many unique days you have first
    cntrows = 1;
    for y = 1:length(unqY)
        for m = 1:length(unqM)
            for d = 1:length(unqD)
                idxplot = unqY(y) == yy & ...
                    unqM(m) == mm & ...
                    unqD(d) == dd;
                diaryPlot = motorDiaryClean(idxplot,:);
                if ~isempty(diaryPlot)
                    cntrows = cntrows +1;
                end
            end
        end
    end
    
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('v',{0.05, 0.95 0.1});
    hpanel(2).pack(cntrows,1);
    hsb = gobjects();
    nrows = 1;
    for y = 1:length(unqY)
        for m = 1:length(unqM)
            for d = 1:length(unqD)
                idxplot = unqY(y) == yy & ...
                    unqM(m) == mm & ...
                    unqD(d) == dd;
                diaryPlot = motorDiaryClean(idxplot,:);
                if ~isempty(diaryPlot)
                    plot_motor_diary_24_hours(diaryPlot,hpanel(2,nrows,1).select());
                    hsb(nrows,1) = hpanel(2,nrows,1).select();
                    nrows = nrows + 1;
                end
                
            end
        end
    end
    % loop on unique days and plot stuff in 24 hour clock
    
    % format the plot and add some elements:
    for i = 1:length(hsb)-1
        hsb(i,1).XTick = [];
        hsb(i,1).XTickLabel = '';
    end
    hpanel(2).de.margin = 0;
    hpanel.marginleft = 30;
    %
    plot_legend(diaryPlot,hpanel(3).select());
    hpanel.marginbottom = 40;
    
    %% plot the graph
    figdirsave = fullfile(params.figdir, diaryPlot.subject_id{1});
    if ~exist(figdirsave,'dir')
        mkdir(figdirsave);
    end
    %% make title
    hsb = hpanel(1).select();
    axes(hsb);
    title(strrep(plotname,'_',' '));
    hpanel(1).marginbottom = 0;
    set(hsb, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    %% plot
    prfig.plotwidth           = 16;
    prfig.plotheight          = 9;
    prfig.figdir              = figdirsave;
    prfig.figname             = plotname;
    prfig.closeafterprint     = 0;
    prfig.figtype             = '-djpeg';
    plot_hfig(hfig,prfig)
    %%
end
%%


end

function  plot_motor_diary_24_hours(diaryPlot,hsb)
cla(hsb)
hold(hsb,'on');
fnmsloop = diaryPlot.Properties.VariableNames(9:end);
for dd = 1:size(diaryPlot,1)
    for ff = 1:length(fnmsloop)
        % set colors:
        switch fnmsloop{ff}
            case 'asleep'
                colorUse = [0 0 0.8];
            case 'off'
                colorUse = [0.8 0 0];
            case 'on_without_dysk'
                colorUse = [0 0.8 0];
            case 'on_with_ntrb_dysk'
                colorUse = [0 0.8 0.8];
            case 'on_with_trbl_dysk'
                colorUse = [0.8 0 0.8];
            case 'no_tremor'
                colorUse = [0.8 0.8 0.8];
            case 'non trbl tremor'
                colorUse = [0.5 0.8 0.8];
            case 'trbl_tremor'
        end
        if logical(diaryPlot.(fnmsloop{ff})(dd))
            
            
            starttime = diaryPlot.timeStart(dd);
            endtime = diaryPlot.timeStart(dd) + minutes(30);
            
            % get limits in 24 hours clock:
            startVec = datevec(starttime);
            startVec(4:6) = 0;
            xlim(1) = datenum(datetime(startVec));
            
            endVec = datevec(endtime-minutes(1));
            endVec(4) = 23;
            endVec(5) = 59;
            endVec(6) = 0;
            xlim(2) = datenum(datetime(endVec));
            
            
            ticksuse = datenum([datetime(startVec): hours(3) : datetime(endVec),  datetime(endVec)]);
            
            
            x = datenum([starttime endtime endtime starttime]);
            y = [0 0 1 1];
            hPatch = patch('XData', x, 'YData',y,'Parent',hsb);
            
            starttime.Format = 'dd-MMM-uuuu';
            [~,dayRec] = weekday(starttime);
            
            dataRecPrint{1,1} = sprintf('%s (%s)',starttime,dayRec);
            dataRecPrint{1,2} = sprintf('%s',diaryPlot.md_description{1});
            dataRecPrint = {};
            dataRecPrint{1,1} = sprintf('%s (%s) %s',starttime,dayRec,diaryPlot.md_description{1});
            %             hyLabel = ylabel( dataRecPrint );
            %             hyLabel.Rotation = 0;
            if dd == 1 & ff == 1
                text(datenum( starttime) ,0.2 ,dataRecPrint,'Parent',hsb,'FontSize',8);
            end
            
            
            set(hsb,'XLim',xlim);
            hsb.XTick = ticksuse;
            hPatch.FaceColor = colorUse;
            hPatch.FaceAlpha = 0.3;
            datetick('x',15,'keeplimits','keepticks');
            hsb.YTick = [];
            hsb.YTickLabel = '';
        end
    end
end
end

function plot_legend(diaryPlot,hsb)
fnmsloop = diaryPlot.Properties.VariableNames(9:end);
cla(hsb);
hold(hsb,'on');
for ff = 1:length(fnmsloop)
    % set colors:
    switch fnmsloop{ff}
        case 'asleep'
            colorUse = [0 0 0.8];
        case 'off'
            colorUse = [0.8 0 0];
        case 'on_without_dysk'
            colorUse = [0 0.8 0];
        case 'on_with_ntrb_dysk'
            colorUse = [0 0.8 0.8];
        case 'on_with_trbl_dysk'
            colorUse = [0.8 0 0.8];
        case 'no_tremor'
            colorUse = [0.8 0.8 0.8];
        case 'non trbl tremor'
            colorUse = [0.5 0.8 0.8];
        case 'trbl_tremor'
    end
    axes(hsb);
    hbar = bar(ff,1);
    hbar.FaceColor = colorUse;
    hbar.FaceAlpha = 0.3;
end
hsb.XTick = 1:1:length(fnmsloop);
xlabels = cellfun(@(x) strrep(x,'_',' '),fnmsloop,'UniformOutput',false);
hsb.XTickLabel = xlabels;



end