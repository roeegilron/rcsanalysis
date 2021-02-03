function plot_apple_watch_data_from_csv()
warning('off','MATLAB:table:RowsAddedExistingVars');

%% load data
% rood
params.rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/apple_watch_data/data';
params.figdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/apple_watch_data/figures';

% create databaseL
ff = findFilesBVQX(params.rootdir,'rcs*.csv');
patdb = table();
for f = 1:length(ff)
    [pn,fn,ext] = fileparts(ff{f});
    pat = fn(1:5);
    side = fn(7);
    dateData = datetime(fn(11:21),'InputFormat','MMM_dd_yyyy');
    patdb.time(f) =  dateData;
    patdb.patient{f} = pat;
    patdb.side{f} = side;
    patdb.file{f} = ff{f};
    if any(strfind(fn,'accel'))
        type = 'rawAcc';
    end
    if any(strfind(fn,'dyskinesia'))
        type = 'dyskinesia';
    end
    if any(strfind(fn,'tremor'))
        type = 'tremor';
    end
    patdb.type{f} = type;
end
%%

for p = 1:size(patdb,1)
    switch patdb.type{p}
        case 'accel'
            x =2;
        case 'dyskinesia'
            dyskdata = readtable(patdb.file{p});
            fprintf('reading data from files dyskiniesia: %s \n',patdb.file{p});
            if ~isempty(dyskdata)
                idxkeep = ~isnan(dyskdata.probability);
                dyskdataOnly = dyskdata(idxkeep,:);
                totalOnes = ones(size(dyskdataOnly,1),1);
                
                %% creat summary metrics
                dyskSummary = struct();
                dyskSummary.probability =    sum(dyskdataOnly.probability .* totalOnes);
                dyskSummary.totalmin = sum(totalOnes);
                patdb.dyskSummary{p} = dyskSummary;
            end
            
        case 'tremor'
            % to open properly need matlab 2020a
            tremdata = readtable(patdb.file{p});
            fprintf('reading data from files %s \n',patdb.file{p});
            %% creat summary metrics
            tremSummary = struct();
            if ~isempty(tremdata)
                idxkeep = ~isnan(tremdata.mild) & ~(tremdata.unknown==1);
                
                tremDataOnly = tremdata(idxkeep,:);
                totalOnes = ones(size(tremDataOnly,1),1);
                tremSummary.mildPerc =   sum(tremDataOnly.mild .* totalOnes);
                tremSummary.modrPerc =   sum(tremDataOnly.moderate .* totalOnes);
                tremSummary.slightPerc = sum(tremDataOnly.slight .* totalOnes);
                tremSummary.strongPerc = sum(tremDataOnly.strong .* totalOnes);
                tremSummary.nonePerc =   sum(tremDataOnly.none .* totalOnes);
                tremSummary.unknown =    sum(tremDataOnly.unknown .* totalOnes);
                tremSummary.totalmin = sum(totalOnes);
                patdb.tremSummary{p} = tremSummary;
            end
    end
end

%% plot some summary metrics
unqpatients = unique(patdb.patient);
types = {'tremor','accel','dyskinesia'};
unqsides = {'L','R'};
for t = 3%1:length(types)
    for p = 1:length(unqpatients)
        for ss = 1:length(unqsides)
            % tremor:
            idxpat = cellfun(@(x) any(strfind(x,unqpatients{p})),patdb.patient) & ...
                cellfun(@(x) any(strfind(x,unqsides{ss})),patdb.side) & ...
                cellfun(@(x) any(strfind(x,types{t})),patdb.type);
            patientDb = patdb(idxpat,:);
            switch types{t}
                case 'tremor'
                    if ~isempty([patientDb.tremSummary{:}])
                        table_data = struct2table([patientDb.tremSummary{:}]);
                        divBy = repmat(table_data.totalmin,1,size(table_data,2)-1) ;
                        % subtract the "unknown data"
                        divBy = repmat(table_data.totalmin -  table_data.unknown,1,size(table_data,2)-1) ;
                        times = patientDb.time;
                        times.Format = 'dd-MMM';
                        xticksLabs = {};
                        for dt = 1:length(times)
                            xticksLabs{dt,1} = sprintf('%s',times(dt));
                        end
                        
                        %%
                        hfig = figure;
                        hfig.Color = 'w';
                        
                        hsb =  subplot(2,2,1);
                        durs = hours(hours(minutes(table_data.totalmin)));
                        bar(durs);
                        hsb.XTick = 1:length(xticksLabs);
                        hsb.XTickLabel = xticksLabs;
                        hsb.XTickLabelRotation = 45;
                        ylabel('hours');
                        title('total time');
                        
                        %
                        hsb =  subplot(2,2,2);
                        bar(table_data{:, 1:6}./divBy,'stacked');
                        legend(table_data.Properties.VariableNames(1:end-1)');
                        hsb.XTick = 1:length(xticksLabs);
                        hsb.XTickLabel = xticksLabs;
                        hsb.XTickLabelRotation = 45;
                        ylim([0 1]);
                        title('tremor categories');
                        ylabel('%/cat');
                        
                        % set zoom level:
                        maxLevel = max(sum(table_data{:,1:4},2)./table_data.totalmin);
                        
                        % zoom
                        hsb =  subplot(2,2,3);
                        bar(table_data{:, 1:6}./divBy,'stacked');
                        legend(table_data.Properties.VariableNames(1:end-1)');
                        hsb.XTick = 1:length(xticksLabs);
                        hsb.XTickLabel = xticksLabs;
                        hsb.XTickLabelRotation = 45;
                        ylim([0 maxLevel]);
                        title('tremor categories zoom');
                        ylabel('%/cat');
                        
                        % abs trremor cases
                        divBy = repmat(table_data.totalmin,1,size(table_data,2)-3);
                        hsb =  subplot(2,2,4);
                        bar(table_data{:, 1:4}./divBy,'stacked');
                        legend(table_data.Properties.VariableNames(1:end-1)');
                        hsb.XTick = 1:length(xticksLabs);
                        hsb.XTickLabel = xticksLabs;
                        hsb.XTickLabelRotation = 45;
                        ylim([0 maxLevel]);
                        title('abs tremor cases');
                        ylabel('%/cat');
                        % large  title:
                        figtitle = sprintf('%s %s tremor',patientDb.patient{1},patientDb.side{ss});
                        sgtitle(figtitle);
                        
                        figname = sprintf('%s_%s_tremor',patientDb.patient{1},patientDb.side{ss});
                        prfig.plotwidth           = 16;
                        prfig.plotheight          = 16*0.6;
                        prfig.figdir              = params.figdir;
                        prfig.figtype             = '-djpeg';
                        prfig.closeafterprint     = 1;
                        prfig.resolution          = 300;
                        prfig.figname             = figname;
                        plot_hfig(hfig,prfig);
                    end
                case 'dyskinesia'
                    % dyskinesia
                    hfig = figure;
                    hfig.Color = 'w';
                    
                    times = patientDb.time;
                    times.Format = 'dd-MMM';
                    xticksLabs = {};
                    for dt = 1:length(times)
                        xticksLabs{dt,1} = sprintf('%s',times(dt));
                    end
                    
                    
                    % abs dyskesina  cases
                    table_data = struct2table([patientDb.dyskSummary{:}]);
                    divBy = repmat(table_data.totalmin,1,size(table_data,2)-1);
                    hsb =  subplot(1,1,1);
                    bar(table_data{:, 1}./divBy,'stacked');
                    legend(table_data.Properties.VariableNames(1:end-1)');
                    hsb.XTick = 1:length(xticksLabs);
                    hsb.XTickLabel = xticksLabs;
                    hsb.XTickLabelRotation = 45;
%                     ylim([0 maxLevel]);
                    title('dysk prob');
                    ylabel('%/cat');
                    % large  title:
                    figtitle = sprintf('%s %s dyskinesia',patientDb.patient{1},patientDb.side{ss});
                    sgtitle(figtitle);
                    
                    figname = sprintf('%s_%s_dyskinesia',patientDb.patient{1},patientDb.side{ss});
                    prfig.plotwidth           = 16;
                    prfig.plotheight          = 16*0.6;
                    prfig.figdir              = params.figdir;
                    prfig.figtype             = '-djpeg';
                    prfig.closeafterprint     = 1;
                    prfig.resolution          = 300;
                    prfig.figname             = figname;
                    plot_hfig(hfig,prfig);
            end
        end
        
    end
end



end