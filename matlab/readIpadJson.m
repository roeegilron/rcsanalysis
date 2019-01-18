function timeDat = readIpadJson(jsonfn)
% ipadroot = '/Users/roee/Desktop/Desktop_files/ipad_raw_data';
% % fnms = findFilesBVQX(ipadroot,'*.json');
% % for f = 1:length(fnms)
% %     [pn,fn,ext] = fileparts(fnms{f});
% %     datetrial = datestr(datevec(fn(end-18:end),'yyyy-mm-dd-hh-MM-ss'));
% %     ipadb.date{f,1} = datetrial;
% %     ipadb.patname{f,1} = lower(fn(1:end-20));
% % end
% % ipadTab = struct2table(ipadb);
% % ipadTabSort = sortrows(ipadTab,'date');
addpath(genpath(fullfile(pwd,'toolboxes','json')));

[pn,fn] = fileparts(jsonfn);
datetrial = datestr(datevec(fn(end-18:end),'yyyy-mm-dd-hh-MM-ss'));
timeDat.date = datetrial;
timeDat.patname = fn(1:end-20);

jsonstruc = loadjson(jsonfn,'SimplifyCell',0);
if size(jsonstruc,1) > size(jsonstruc,2)
    
else
    jsonstruc = jsonstruc';
end

for i = 1:size(jsonstruc,1)
    description{i} = jsonstruc{i,1}{1,1};
    timestamp(i) = str2double(jsonstruc{i,1}{1,2});
end

searchStr = {'Sound ',...             % Sound
             'Trial Start: 0',...           % start 
             'Scene: 0 - Rest',...          % Rest epoch Beg Fixation point ON red dot
             'Timer: 0',...                 % Rest epoch End Fixation point OFF red dot
             'Incorrect touch: 0',...       % Rest epoch Error Fixation error by mvt
             'Scene: 1 - Preparation',...   % Preparation epoch Beg ON Cue ON blue dot
             'Timer: 1',...                 % Preparation epoch End Cue OFF blue dot
             'Incorrect touch: 1',...       % Preparation  epoch error by mvt
             'Scene: 2 - Movement',...      % Target1 ON 
             'Correct touch: 2',...         % Touch1
             'Timer: 2'...                  % Error_touch
             'Movement',...                 % target appers (all targets) 
             'Correct touch'                % target touched (all targets) 
             };

fsv  = {'sound',...
        'start',...
        'rest_ON',...
        'rest_OFF',...
        'rest_error',...
        'prep_ON',...
        'prep_OFF',...
        'prep_error',...
        'target1_ON',...
        'touch1_OFF',...
        'prep_error',...
        'target_appear',...
        'target_touched'
        };
             
for f = 1:length(searchStr)
    idx = cellfun(@(x) any(strfind(x,searchStr{f})),description);
    timeDat.(fsv{f}) = timestamp(idx);
end
n_steps = description{2};
n_steps(length(n_steps));


end