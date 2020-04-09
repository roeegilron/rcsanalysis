function adaptiveLogTable = read_adaptive_txt_log(fn)
clc; close all;
% initialize table
adaptiveLogTable = table();

%% get time
str = fileread( fn );

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
adaptiveLogTable.time = startTimeDt;
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
adaptiveLogTable.status = statusdec;

%%

%% new state
xpr = ['AdaptiveTherapyModificationEntry.NewState '];
cac1 = regexp( str, xpr );

clear newstate
for t = 1:length(cac1)
    newstate(t,:) = str(cac1(t)+68:cac1(t)+69);
end
newstate = hex2dec(newstate);
adaptiveLogTable.newstate = newstate;
%%

%% old state
xpr = ['AdaptiveTherapyModificationEntry.OldState '];
cac1 = regexp( str, xpr );

clear oldstate
for t = 1:length(cac1)
    oldstate(t,:) = str(cac1(t)+68:cac1(t)+69);
end
oldstate = hex2dec(oldstate);
adaptiveLogTable.oldstate = oldstate;
%%

%% loop on programs
for p = 0:3
    xpruse = sprintf('AdaptiveTherapyModificationEntry.Prog%dAmpInMillamps ',p);
    cac1 = regexp( str, xpruse );
    
    clear prog
    for t = 1:length(cac1)
        prog(t,:) = str(cac1(t)+66:cac1(t)+71);
    end
    prog = str2num(prog);
    fnuse = sprintf('prog%d',p);
    adaptiveLogTable.(fnuse) = prog;
end
%%

%% rate
xpruse = 'AdaptiveTherapyModificationEntry.RateAtTimeOfModification ';
cac1 = regexp( str, xpruse );

clear rate
for t = 1:length(cac1)
    rate(t,:) = str(cac1(t)+66:cac1(t)+73);
end
ratenum = str2num(rate);
%%
adaptiveLogTable.rateHz = ratenum;

%%
end