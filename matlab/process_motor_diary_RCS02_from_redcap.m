function process_motor_diary_RCS02_from_redcap() 
%% load data 
datafn = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig7.1_new_adaptive/RCS02-MotorDiaryExportWear_DATA_2020-08-14_1059.csv';
dataRaw = readtable(datafn); 
dataRaw = dataRaw(end-1:end,:);
rawFieldNames = fieldnames(dataRaw);
idxDate = cellfun(@(x) any(strfind(x,'date_day')),rawFieldNames);
idxState = cellfun(@(x) any(strfind(x,'state')),rawFieldNames);
idxTrem = cellfun(@(x) any(strfind(x,'trem')),rawFieldNames);
idxDysk = cellfun(@(x) any(strfind(x,'dsyk')),rawFieldNames);

datesFn = rawFieldNames(idxDate); 
stateFn = rawFieldNames(idxState); 
tremFn = rawFieldNames(idxTrem); 
dyskFn = rawFieldNames(idxDysk); 
fieldNamesUse = {stateFn , tremFn, dyskFn};
fieldNameCats = {'state','tremor','dyksinesia'};
%%
motorDiaryTable = table();
cntTbl = 1;

for d = 1:size(dataRaw,1)
      individFieldNames1 = fieldNamesUse{1};
      individFieldNames2 = fieldNamesUse{2};
      individFieldNames3 = fieldNamesUse{3};
      for i = 1:length(individFieldNames1)
          motorDiaryTable.subject_id{cntTbl} = dataRaw.subject_id{d};
          motorDiaryTable.redcap_event_name{cntTbl} = dataRaw.redcap_event_name{d};
          motorDiaryTable.day1{cntTbl} = datetime(dataRaw.(datesFn{1}){d});
          motorDiaryTable.day2{cntTbl} = datetime(dataRaw.(datesFn{2}){d});
          motorDiaryTable.day3{cntTbl} = datetime(dataRaw.(datesFn{3}){d});
          
          if d == 1
              sessionUse = 'open loop';
          else
              sessionUse = 'closed loop';
          end
          motorDiaryTable.session{cntTbl} = sessionUse;
          switch dataRaw.(individFieldNames1{i})(d)
              case 1 
                  motorDiaryTable.(fieldNameCats{1}){cntTbl} = 'sleep'; 
              case 2 
                  motorDiaryTable.(fieldNameCats{1}){cntTbl} = 'off'; 
              case 3 
                  motorDiaryTable.(fieldNameCats{1}){cntTbl} = 'on'; 
          end
          
          switch dataRaw.(individFieldNames2{i})(d)
              case 1 
                  motorDiaryTable.(fieldNameCats{2}){cntTbl} = 'Non Troublesome tremor'; 
              case 2 
                  motorDiaryTable.(fieldNameCats{2}){cntTbl} = 'Troublesome tremor'; 
              otherwise
                  motorDiaryTable.(fieldNameCats{2}){cntTbl} = '';
          end
          
          
          switch dataRaw.(individFieldNames3{i})(d)
              case 1
                  motorDiaryTable.(fieldNameCats{3}){cntTbl} = 'Non Troublesome dyskinesia';
              case 2
                  motorDiaryTable.(fieldNameCats{3}){cntTbl} = 'Troublesome dyskinesia';
              otherwise 
                  motorDiaryTable.(fieldNameCats{3}){cntTbl} = '';
          end
          
          
          full_state = sprintf('%s %s %s',...
              motorDiaryTable.(fieldNameCats{1}){cntTbl} ,...
              motorDiaryTable.(fieldNameCats{2}){cntTbl} ,...
              motorDiaryTable.(fieldNameCats{3}){cntTbl} );
          motorDiaryTable.full_state{cntTbl} = full_state;
          cntTbl = cntTbl + 1; 
      end
end

%% plot motor diary comparison 
clc;
conditionsUse = unique(motorDiaryTable.session);
for t = 1:2
    fprintf('%s\n_________\n',conditionsUse{t});
    idxuse = strcmp(motorDiaryTable.session,conditionsUse{t});
    tblUse = motorDiaryTable(idxuse,:);
    Conditions = categorical(tblUse.full_state,...
        unique(tblUse.full_state));
    summary(Conditions);
end
%%
close all;
y = [];
c = [];
conditionsUse = unique(motorDiaryTable.session);
for t = 1:2
    idxuse = strcmp(motorDiaryTable.session,conditionsUse{t});
    tblUse = motorDiaryTable(idxuse,:);
    Conditions = categorical(tblUse.state,...
        unique(tblUse.state));
    % remove sleep 
    Conditions = removecats(removecats(Conditions,'sleep'));
    idxremove  = isundefined(Conditions);
    Conditions = Conditions(~idxremove);

    % new way 
    summary(Conditions);
    c = countcats(Conditions);
    cats = categories(Conditions);
    y (t,:) = c./sum(c);

    % old way 
%     Conditions = removecats(removecats(Conditions,'state unknown'));
%     Conditions = removecats(removecats(Conditions,'state rule conflict'));
%     Conditions = removecats(removecats(Conditions,'sleep'));
%     Conditions = removecats(removecats(Conditions,'tremor'));
%     idxremove  = isundefined(Conditions);
%     Conditions = Conditions(~idxremove);
%     summary(Conditions);
%     c = countcats(Conditions);
%     cats = categories(Conditions); 
%     y (t,:) = c./sum(c); 
    % 
end
% motor 
resultdirsave = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig7.1_new_adaptive';
fnsmv = fullfile(resultdirsave,'motor_diary_results_rcs02_open_loop_vs_closed_loop.mat'); 
filepath = pwd; 
functionname = 'process_motor_diary_RCS02_from_redcap';
save(fnsmv,'motorDiaryTable','filepath','functionname');

hfig = figure;
hfig.Color = 'w'; 
hbar = bar(y,'stacked');
legend(cats);
hsb = gca;
hsb.XTickLabel = conditionsUse;
hsb.XTickLabelRotation = 45; 
ylabel('% time/state');
title('motor diary results - open loop / closed loop'); 
set(gca,'FontSize',16);

%% 
end