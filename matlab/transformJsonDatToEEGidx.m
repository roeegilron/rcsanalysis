function eventsTable = transformJsonDatToEEGidx(timeDat, srate,locuse)

fsv  = {'sound',... % Sound
        'start',...
        'rest_ON',...% Rest epoch Beg Fixation point ON red dot
        'rest_OFF',...% Rest epoch End Fixation point OFF red dot
        'rest_error',...  % Rest epoch Error Fixation error by mvt
        'prep_ON',...% Preparation epoch Beg ON Cue ON blue dot
        'prep_OFF',...% Preparation epoch End Cue OFF blue dot
        'prep_error',... % Preparation  epoch error by mvt
        'target1_ON',... % Target1 ON
        'touch1_OFF',...% Touch1 
        'prep_error',...% Error_touch 
        'target_appear',...% target appers (all targets)  
        'target_touched'% target touched (all targets) 
        };
events = struct();
cnt = 1;
% for f = 1:length(fsv)
%     dat = timeDat.(fsv{f})./1000;
%     for t = 1:length(dat)
%         events(cnt).label = fsv{f};
%         events(cnt).timestamp = dat(t);
%         if strcmp(fsv{f},'sound')
%             events(cnt).eegtimestamp = locuse(t);
%         else 
%             events(cnt).eegtimestamp = NaN;
%         end
%         cnt = cnt +1;
%     end
% end
for f = 1:length(fsv)
    dat = timeDat.(fsv{f})./1000;
    for t = 1:length(dat)
        events(cnt).label = fsv{f};
        events(cnt).timestamp = dat(t);
        events(cnt).eegtimestamp = NaN;
        cnt = cnt +1;
    end
end

% calculate sound time stamps 

eventsTable = struct2table(events);
eventsTable = sortrows(eventsTable,'timestamp');
idxfound = cellfun(@(x) strcmp(x,'sound'),eventsTable.label);
idxuse = find(idxfound==1); 
ipadtime = eventsTable.timestamp(idxuse);
outidx =  allignSoundFromJsonAndEEG(locuse,ipadtime);
eventsTable.eegtimestamp( idxuse(outidx.ipad)) = locuse(outidx.eeg);
eventsTable.useNewLineUp = repmat(1,size(eventsTable,1),1);
curidx = 1; 
soundidx = find(cellfun(@(x) strcmp(x,'sound'),eventsTable.label)==1,1);
%% loop on sounds idx - using only non NaNs 
while curidx <= size(eventsTable,1)
    if ~strcmp(eventsTable.label{curidx},'sound')
        if soundidx > curidx
            eventsTable.eegtimestamp(curidx) = eventsTable.eegtimestamp(soundidx) - ...
                (eventsTable.timestamp(soundidx) - eventsTable.timestamp(curidx));
        elseif soundidx < curidx
            eventsTable.eegtimestamp(curidx) = eventsTable.eegtimestamp(soundidx) + ...
                (eventsTable.timestamp(curidx) - eventsTable.timestamp(soundidx) );

        end
    else
        soundidx = curidx; 
    end
    curidx = curidx +1;
end
eventsTable.eegidxtimestamp = ceil(eventsTable.eegtimestamp .* srate);
end