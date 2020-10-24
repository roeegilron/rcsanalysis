function adaptiveLogTable = read_adaptive_txt_log(fn)
clc; close all;
% initialize table
adaptiveLogTable = table();

%% get time
str = fileread( fn );

newBlocks = regexp(str, {'\n\r'});
newBlockLines = newBlocks{1};  
newBlockLines = [1 newBlockLines];
% loop on text and get each new block in a cell array 
cntBlock = 1;
while cntBlock ~= (length(newBlockLines)-1)
    events{cntBlock} = str(newBlockLines(cntBlock) : newBlockLines(cntBlock+1));
    cntBlock = cntBlock + 1; 
end
%% get all event types 
for e = 1:length(events)
    str = events{e};

    xpruse1 = '(';
    cac1 = regexp( str, xpruse1 );
    
    xpruse1 = ')';
    cac2 = regexp( str, xpruse1 );
    
    
    strraw = str(cac1(2)+1:cac2(2)-1);
    adaptiveLogEvents.EventID{e} = strraw;
end
idxuse = strcmp(adaptiveLogEvents.EventID,'AdaptiveTherapyStateChange');
allEvents = events; 
%%
events = allEvents(idxuse);
for e = 1:length(events)
    str = events{e};
    car = regexp(str, '\r');
    
    xpr = ['Seconds = '];
    cac1 = regexp( str, xpr );
    
    xpr = ['DateTime = '];
    cac2 = regexp( str, xpr );
    
    clear hexstr
    for t = 1:length(cac1)
        hexstr(t,:) = str(cac1(t)+12:cac2(t)-3);
    end
    rawsecs = hex2dec(hexstr);
    startTimeDt = datetime(datevec(rawsecs./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    adaptiveLogTable.time(e) = startTimeDt;
    %%
    
    %% get status
    xpr = ['AdaptiveTherapyModificationEntry.Status '];
    cac1 = regexp( str, xpr );
    
    
    xpr = ['(EmbeddedActive)'];
    cac2 = regexp( str, xpr );
    
    clear status
    for t = 1:length(cac1)
        status(t,:) = str(cac1(t)+68:cac2(t)-3);
    end
    statusdec = hex2dec(status);
    adaptiveLogTable.status(e) = statusdec;
    
    %%
    
    %% new state
    xpr = ['AdaptiveTherapyModificationEntry.NewState '];
    cac1 = regexp( str, xpr );
    
    clear newstate
    for t = 1:length(cac1)
        newstate(t,:) = str(cac1(t)+68:cac1(t)+69);
    end
    newstate = hex2dec(newstate);
    adaptiveLogTable.newstate(e) = newstate;
    %%
    
    %% old state
    xpr = ['AdaptiveTherapyModificationEntry.OldState '];
    cac1 = regexp( str, xpr );
    
    clear oldstate
    for t = 1:length(cac1)
        if (cac1(t)+69) > length(str)
            oldstate(t,:) = NaN;
        else
            oldstate(t,:) = str(cac1(t)+68:cac1(t)+69);
        end
    end
    oldstate = hex2dec(oldstate);
    adaptiveLogTable.oldstate(e) = oldstate;
    %%
    
    %% loop on programs
    for p = 0:3
        xpruse = sprintf('AdaptiveTherapyModificationEntry.Prog%dAmpInMillamps ',p);
        cac1 = regexp( str, xpruse );
        
        clear prog progNum
        for t = 1:length(cac1)
            prog(t,:) = str(cac1(t)+66:cac1(t)+71);
        end
        progNum = str2num(prog);
        fnuse = sprintf('prog%d',p);
        adaptiveLogTable.(fnuse)(e) = progNum;
    end
    
    %% rate
    xpruse = 'AdaptiveTherapyModificationEntry.RateAtTimeOfModification ';
    cac1 = regexp( str, xpruse );
    
    clear rate
    for t = 1:length(cac1)
        rate(t,:) = str(cac1(t)+66:cac1(t)+73);
    end
    ratenum = str2num(rate);
    %%
    adaptiveLogTable.rateHz(e) = ratenum;
    
    % events ID 
    xpruse1 = 'CommonLogPayload`1.EventId      = 0x00 (';
    cac1 = regexp( str, xpruse1 );
    xpruse2 = 'CommonLogPayload`1.EntryPayload = ';
    cac2 = regexp( str, xpruse2 );
    strraw = str(cac1:cac2-4);
    strtmp = strrep( strrep(strraw,xpruse1,''), ')','');
    adaptiveLogTable.EventID{e} = strtmp(1:end-3);
    

    
end
%%
at = adaptiveLogTable(1:100,:);
idxzero = at.newstate==0;
unique(at.prog0(idxzero))
%%
end