function plot_spiral_test()
params.rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS02/OL vs CL Finger Taps Videos/Spiral task Data';
params.figdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS02/OL vs CL Finger Taps Videos/figures';
warning('off','MATLAB:table:RowsAddedExistingVars');
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
spiralDb = table(); 
cntDb = 1; 
    
% background 
ff = findFilesBVQX (params.rootdir,'*Back*.png');
for f = 1:length(ff) 
    [~,fn,ext] = fileparts(ff{f}); 
    spiralDb.fn{cntDb} = [fn  ext];
    spiralDb.pat{cntDb} = fn(1:5);
    spiralDb.time(cntDb) = ...
        datetime(fn(7:24),'InputFormat','yyyy_MM_DD_hh_mmaa');
    spiralDb.side{cntDb} = fn(26);
    spiralDb.type{cntDb} = 'Background';
    cntDb = cntDb + 1;
end

% image 
ff = findFilesBVQX (params.rootdir,'*image*.png');
for f = 1:length(ff) 
    [~,fn, ext] = fileparts(ff{f}); 
    spiralDb.fn{cntDb} = [fn  ext];
    spiralDb.pat{cntDb} = fn(1:5);
    spiralDb.time(cntDb) = ...
        datetime(fn(7:24),'InputFormat','yyyy_MM_DD_hh_mmaa');
    spiralDb.side{cntDb} = fn(26);
    spiralDb.type{cntDb} = 'image';
    cntDb = cntDb + 1;
end

% touch 
ff = findFilesBVQX (params.rootdir,'*touch*.csv');
for f = 1:length(ff) 
    [~,fn, ext] = fileparts(ff{f}); 
    spiralDb.fn{cntDb} = [fn  ext];
    spiralDb.pat{cntDb} = fn(1:5);
    spiralDb.time(cntDb) = ...
        datetime(fn(7:24),'InputFormat','yyyy_MM_DD_hh_mmaa');
    spiralDb.side{cntDb} = fn(26);
    spiralDb.type{cntDb} = 'touch';
    cntDb = cntDb + 1;
end


%% find triplets of spiral files that go together and extract data 
spiralDataOut = table();
cntOut = 1; 
[yy,mm,dd] = ymd(spiralDb.time);
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
            spiralDay = spiralDb(idxplot,:);
            if ~isempty(spiralDay)
                unqTimes = unique(spiralDay.time);
                unqSides = unique(spiralDay.side); 
                for ut = 1:length(unqTimes)
                    for us = 1:length(unqSides)
                        idxChoose = spiralDay.time == unqTimes(ut) & ... 
                             cellfun(@(x) strcmp(x,unqSides{us}), spiralDay.side);
                        testDab = spiralDay(idxChoose,:);
                        if size(testDab,1) == 3
                            % make a new spiral registry 
                            idxBack = cellfun(@(x) strcmp(x, 'Background'),testDab.type);
                            idxImg = cellfun(@(x) strcmp(x, 'image'),testDab.type);
                            idxTouch = cellfun(@(x) strcmp(x, 'touch'),testDab.type);
                            spiralImageFn = fullfile(params.rootdir,testDab.fn{idxImg});
                            spiralBackrFn = fullfile(params.rootdir,testDab.fn{idxBack});
                            spiralCSVfn   = fullfile(params.rootdir,testDab.fn{idxTouch});
                            spiralData = readtable(spiralCSVfn);
                            imgSpiral = imread(spiralImageFn,'BackgroundColor',[0 0 0]);
                            imgBackgr = imread(spiralBackrFn);
                            imCompple = imcomplement(imgSpiral);
                            
                            timesraw = spiralData.t_received;
                            t = datetime(timesraw,'ConvertFrom','posixTime',...
                                'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                            timeComplte = t(end) - t(1);

                            tRep = t(1);
                            tRep.Format = 'dd-MMM-uuuu HH:mm';
                            [~,dayRec] = weekday(tRep);
                            
                            
                            resizedImage = imresize(imCompple,[size(imgBackgr,1), size(imgBackgr,2)]);
                            
                            spiralDataOut.patient{cntOut} = testDab.pat{1};
                            spiralDataOut.side{cntOut} = testDab.side{1};
                            spiralDataOut.tRep(cntOut) = tRep;
                            spiralDataOut.dayRec{cntOut} = dayRec;
                            spiralDataOut.resizedImage{cntOut} = resizedImage;
                            spiralDataOut.imgBackgr{cntOut} = imgBackgr;
                            
                            
                            
                            
                           
                            spiralTime0 = sprintf('%s %s',testDab.pat{1}, testDab.side{1});
                            spiralDataOut.spiralTime0{cntOut} = spiralTime0;
                            
                            spiralTime = sprintf('t = %.2f sec',seconds(timeComplte));
                             spiralDataOut.spiralTime{cntOut} = spiralTime;
                            
                            spiralTime2 = sprintf('%s (%s)',tRep,dayRec);
                            spiralDataOut.spiralTime2{cntOut} = spiralTime2;
                            
                            spiralDataOut.spiralTimeInSec(cntOut) = seconds(timeComplte);
                            
                            cntOut = cntOut + 1;
                            
                        end
                    end
                end
            end
        end
    end
end

%% plot all the images 
[yy,mm,dd] = ymd(spiralDataOut.tRep);
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
            spiralDay = spiralDataOut(idxplot,:);
            
            if ~isempty(spiralDay)
                spiralDay = sortrows(spiralDay,{'side','tRep'});
                hfig = figure;
                hfig.Color = 'w';
                hpanel = panel();
                hpanel.pack(2,3);
                hsb = gobjects();
                cntplt = 1; 
                for ii = 1:2
                    for jj = 1:3
                        hsb(cntplt,1) = hpanel(ii,jj).select();
                        cntplt = cntplt + 1;
                    end
                end
                for ss = 1:size(spiralDay,1)
                    if ss > 6
                        break; 
                    end
                    axes(hsb(ss,1));
                    resizedImage = spiralDay.resizedImage{ss};
                    imshow(resizedImage);
                    hold on;
                    imgBackgr = spiralDay.imgBackgr{ss};
                    hImg = imshow(imgBackgr);
                    hImg.AlphaData = 0.5;
                    spiralTime = spiralDay.spiralTime0{ss};
                    text(100,100,spiralTime,'FontSize',12)
                    
                    spiralTime = spiralDay.spiralTime{ss};
                    text(100,200,spiralTime,'FontSize',12)
                    
                    spiralTime = spiralDay.spiralTime2{ss};
                    text(100,300,spiralTime,'FontSize',12)
                end
                % plot the figure; 
                hpanel.de.margin = 0;
                
                %%
                figdirsave = params.figdir;
                timeDay = spiralDay.tRep(1);
                timeDay.Format = 'uuuu_MM_dd';
                plotname = sprintf('%s_%s',spiralDay.patient{1},timeDay);
                prfig.plotwidth           = 16;
                prfig.plotheight          = 9;
                prfig.figdir              = figdirsave;
                prfig.figname             = plotname;
                prfig.closeafterprint     = 0;
                prfig.figtype             = '-djpeg';
                plot_hfig(hfig,prfig)

            end
        end
    end
end

%% plot a summary plot of all spiral data 
spiralDataOut = sortrows(spiralDataOut,{'side','tRep'});
sides = {'L','R'};
hfig = figure;
hfig.Color = 'w'; 

for s = 1:length(sides)
    idxSide = strcmp(spiralDataOut.side,sides{s});
    spiralDataSide = spiralDataOut(idxSide,:);
    hsb = subplot(2,1,s);
    hold on; 
    for d = 1:size(spiralDataSide,1)
        timeTest = spiralDataSide.tRep(d);
        dataVector = datevec(spiralDataSide.tRep(d));
        if dataVector(3) < 21
            colorUse = [0.8 0 0]; % open loop
        else
            colorUse = [0 0.8 0]; % closed loop
        end
        dataVector(1) = 0;
        dataVector(2) = 0;
        dataVector(3) = 0;
        timePlot = datenum(dataVector);
        yPlot = spiralDataSide.spiralTimeInSec(d); 
        
        hsc = scatter(timePlot,yPlot,3e2,'filled',...
            'MarkerFaceColor',colorUse,...
            'MarkerFaceAlpha', 0.4);
    end
    datetick(hsb,'x',15,'keeplimits','keepticks');
    set(gca,'FontSize',16); 
    ylabel('time/sprial (sec)'); 
    title(sides{s});
end

figdirsave = params.figdir;

plotname = 'spiral_data_OL_vs_CL_manual_save';
prfig.plotwidth           = 16;
prfig.plotheight          = 9;
prfig.figdir              = figdirsave;
prfig.figname             = plotname;
prfig.closeafterprint     = 0;
prfig.figtype             = '-djpeg';
plot_hfig(hfig,prfig)

%%
figure
hc = boxchart(T.idx, T.Recharges); % group by index
hold on
% overlay the scatter plots
for n=1:max(unique(T.idx))
    hs = scatter(ones(sum(T.idx==n),1) + n-1, T.Recharges(T.idx == n),"filled",'jitter','on','JitterAmount',0.1);
    hs.MarkerFaceAlpha = 0.5;
end
set(gca,"XTick", unique(T.idx),"XTickLabel",categories(T.model))

end