function plotCoherenceChronicStim()
%% panel A new way of doing data - single subject on off chronic stim 
 
 
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
patientAnalyze = {'RCS02'};
dataTable = table();
cntTbl = 1;
ff = findFilesBVQX(rootdir,['RCS02' '*psdAndCoherence*stim*.mat']);
for f = 1:length(ff)
    load(ff{f},'allDataCoherencePsd','database');
    allDataPkgRcsAcc = allDataCoherencePsd;
    databaseUse = database;
    allDataPkgRcsAcc.database = databaseUse;
    [pn,fn] = fileparts(ff{f});
    descriptor = fn(strfind(fn,'__'):end);
    dataTable.patient{cntTbl} = fn(1:5);
    dataTable.side{cntTbl} = fn(7);
    dataTable.stim(cntTbl) = database.stimulation_on(1);
    dataTable.descriptor{cntTbl} = descriptor;
    dataTable.allDataPkgRcsAccq{cntTbl} = allDataPkgRcsAcc;
    cntTbl = cntTbl + 1;
end
% plot shaded error bars 
dataTable = sortrows(dataTable,{'stim'});
areasUse = {'key0fftOut','key1fftOut','key2fftOut','key3fftOut',...
    'stn02m10810','stn02m10911','stn13m10810','stn13m0911'};
areasUse = {'key0fftOut','key3fftOut',...
  'stn02m10911'};
ttlUse = {'STN','cortex','STN-cortex coherence'};
xUse = {'ffPsd','ffPsd','ffCoh'};
  
coloruse = [  0 0.8 0;0.5 0.5 0.5];
 
hfig = figure();
hfig.Color = 'w';
for a = 1:length(areasUse)
    hsb(a) = subplot(1,3,a);
    hold(hsb(a),'on');
    for t = 1:size(dataTable,1)
        dataStruc = dataTable.allDataPkgRcsAccq{t};
        y = dataStruc.(areasUse{a});
        x = dataStruc.(xUse{a});
        hsbH = shadedErrorBar(x,y',{@mean,@(y) std(y)*0.5});
%         hsbH = shadedErrorBar(x',y',{@median,@(yy) std(yy)./sqrt(size(yy,1))});
        hsbH.mainLine.Color = [coloruse(t,:) 0.5];
        hsbH.mainLine.LineWidth = 3;
        hsbH.patch.FaceColor = coloruse(t,:);
        hsbH.edge(1).Color = [1 1 1 0.5];
        hsbH.edge(2).Color = [1 1 1 0.5];
        hsbH.patch.FaceAlpha = 0.1;    
        xlim([3 100]);
        title(ttlUse{a});
        ylabel('Power (log_1_0\muV^2/Hz)');
        xlabel('Frequency (Hz)');
        hLeg(t) = hsbH.patch;
    end
    legend(hLeg,{'stim off','stim on'}); 
    set(gca,'FontSize',16);
end
