function out = plot_impedance_from_CSV_file(varargin)
% plots the impedance data which is input as a .csv file. In this initial
% case it's taking a file with several columns and ploting them (#). In a
% general future case we have to enter a folder dir with all patient files,
% each file is one impedance data point. (#) this is because we are trying
% to understand in RCS10 if there has been a large change in impedances and
% i created a combined file with the inputs of each single file... (juan)

close all, clc

if isempty(varargin) % hard coded input file
        inputfile = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/SignalQualityCheck08262020/impedanceEvolution_csv.csv';
else
    inputfile = varargin{1};
end 

fulltable = readtable(inputfile);

% remove empty rows
emptyIds = cellfun(@isempty,table2cell(fulltable));
sumrows = sum(emptyIds,2);
emptyrowid = find(sumrows==size(emptyIds,2));
fulltable(emptyrowid,:) = []

sumcols = sum(emptyIds,1);
emptycolid = find(sumcols==size(emptyIds,1));
fulltable(:,emptycolid) = [];

% extract impedance of columns
for ii=1:size(fulltable,2)
    [date,outimp] = extract_impedance_col(fulltable(:,ii));
    tempDatum(ii,:) = char(date.Variables);
    impedances(ii,:) = outimp;
end
impedances = impedances';
year = tempDatum(:,1:4);
month = tempDatum(:,6:7);
day = tempDatum(:,9:10);
datevar = datetime(str2num(year),str2num(month),str2num(day));

%% Plotting data
FONTSIZE = 16;
hfig1 = figure(1);
plot(datevar(1:5),impedances(:,1:5)','-o')
title('Left')
xticks(datevar(1:5))
xticklabels(char(datevar(1:5)))
set(gca,'XTickLabelRotation',45)
set(findall(gcf,'-property','FontSize'),'FontSize',FONTSIZE )
xlabel('datetime')
ylabel('impedance (ohms)')
ylim([0 4500])

hfig1 = figure(2);
plot(datevar(6:end),impedances(:,6:end)','-o')
title('Right')
xticks(datevar(6:end))
xticklabels(char(datevar(6:end)))
set(gca,'XTickLabelRotation',45)
set(findall(gcf,'-property','FontSize'),'FontSize',FONTSIZE )
xlabel('datetime')
ylabel('impedance (ohms)')

hfig3 = figure(3);
boxplot(impedances')
title('All datapoints (Left & Right) per electrode config')
text(1,3500,'subcortex: 1:4 mono, 5:10 bip')
text(11,2000,'ECoG: 11:14 mono, 15:20 bip')
set(findall(gcf,'-property','FontSize'),'FontSize',FONTSIZE )
xlabel('meas config (#see config pairs)')
ylabel('impedance (ohms)')


% extract site, date and first row
    function [date,outimp] = extract_impedance_col(fulltable)
        date = fulltable(1,1);
        tempstring = fulltable(2:end,1);
        tempstring2 = char(tempstring.Variables);
        idxspaces = isspace(tempstring2);
        for n=1:size(idxspaces,1)
            idxtemp = find(idxspaces(n,:)==1);
            idx = idxtemp(2);
            strvalue = tempstring2(n,idx:end);
            val(n) = str2double(strvalue);
%             fprintf('%0d \n',val(n))
        end
        outimp = val';
    end

end

