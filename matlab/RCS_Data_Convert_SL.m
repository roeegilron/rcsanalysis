%% Analyse Dystonia data %%

clear all
close all

% Load up the data folder with all the files in %
SVFlLoc=fullfile('..','Neural_Data');
FlNames=dir(SVFlLoc); FlNames(1:2,:)=[];

for FL=1:size(FlNames,1)
    clearvars -except SVFlLoc FlNames FL;
    
    %% LOAD the DATA
    Fln=FlNames(FL).name;
    load(fullfile(SVFlLoc,Fln))
    dat=outdatcomplete;
    SR=unqsrates;
    
    % Locate sample positions of the ends of each packet 
    whz=dat.timestamp~=0;
    whzf=find(dat.timestamp~=0);  
    
    % Assign new data array %
    dsd=[];                                 
    
    % Mean subtract to remove some of the offset. 
    dsd(:,1)=dat.key0-mean(dat.key0);
    dsd(:,2)=dat.key1-mean(dat.key1);
    dsd(:,3)=dat.key2-mean(dat.key2);
    dsd(:,4)=dat.key3-mean(dat.key3);

    % Trim data before the first changeover in the timestamp so that you
    % are roughly aligned (100ms or so) to the beginning of the timestamp second
    % counter. 
    firstpacket=find(dat.timestamp(whzf)==dat.timestamp(whzf(1))+1,1);
    firstpackInd=whzf(firstpacket);
    
    % Trim all the data and features so it starts at this same beginning
    % (beginning of the first timestamp turnover).
    dsd1=dsd(firstpackInd-dat.packetsizes(firstpackInd)+1:end,:);
    timestamp=dat.timestamp(firstpackInd-dat.packetsizes(firstpackInd)+1:end,:);
    systemTick=dat.systemTick(firstpackInd-dat.packetsizes(firstpackInd)+1:end,:);
    packetsizes=dat.packetsizes(firstpackInd-dat.packetsizes(firstpackInd)+1:end,:);
    
    % Rederive the indices of the packets sample positions using the new trimmed data %
    whz=[]; whzf=[];     % Delete the old indices so they dont corrupt the new indices.
    whz2=timestamp~=0;
    whzf2=find(timestamp~=0);
    
    % Find timestamp and systemTick of the first packet in the new trimmed space %
    start = timestamp(whzf2(1));
    starttick = systemTick(whzf2(1));
    
    % Find duration of the (trimmed) recording (and add 5 seconds buffer to the end)
    dur=timestamp(whzf2(end))-timestamp(whzf2(1))+5;
    
    % Create a time axis in INS systemTicks (every 100mcs).
    timaxis=[0:dur*10000];
    
    % Get start of the 65535 systemTick vector to be the same as the first
    % packet of the new trimmed data so they run on the same "clocks".
    timaxisS=timaxis+starttick-1;
    
    % Then use mod to make it restart counting at 65535 (like the INS systemTick)
    % Add 1 so that it goes between 1 and 65535, rather than 0 and 64434
    % (which would be the output of mod)
    timemod=mod(timaxisS,65535)+1;
    
    % Create virtual timeseries in ms on the systemTick timebase.
    timX=[0:0.0001:dur];
    
    % Make a new time series in seconds - with the same resolution as INS systemTicks. 
    % This will be slightly  offset according to when the INS second counter (timestamp)transitions within 
    % a packet (rather than being at the end of a packet).
    timXSec=timX+timestamp(whzf2(1));
    
    % PUT THE PACKETS IN THE RIGHT PLACE ACCORDING TO INS TIME %
    % Start with second packet - as we use the first packet in the trimmed
    % data to be the formal first timestamp - ie all time will be relative
    % to Timestamp / systemTick of the first packet in the trimmed data. 
    
    % Pre-allocate the data as zeros. 
    datar=zeros(dur*SR,4);
    
    % Start with 2 as we want to use the first packet as marker and work
    % relative to that. 
    for g=2:size(dat.timestamp(whzf2),1)
        
        pcklength=packetsizes(whzf2(g));
        
        % Extract the packet data %
        tmp=[];
        tmp(:,1)=dsd1(whzf2(g)-(pcklength-1):whzf2(g),1);
        tmp(:,2)=dsd1(whzf2(g)-(pcklength-1):whzf2(g),2);
        tmp(:,3)=dsd1(whzf2(g)-(pcklength-1):whzf2(g),3);
        tmp(:,4)=dsd1(whzf2(g)-(pcklength-1):whzf2(g),4);
        
        % First index the start on the constructed time series with the same second ticker %
        secmrk=timestamp(whzf2(g));
        secDiff=secmrk-timestamp(whzf2(1));
        strMark=secDiff*10000;
        
        % Look for the TickerStamp in 1.5 seconds before and after %
        whrTim=[strMark-15000:strMark+15000]; 
        
        % Remove negative indices that might occur in the first few seconds to prevent a crash.
        whrTim(whrTim<=0)=[];
        
        % Then find the location of the system tick within that selection
        % in INS time within that 3 second of data.
        % -1 because the first sample of the timemod time series is the end
        % of the first trimmed packet. Whereas the difference (pckdiff) is
        % the difference between the packets (fencepost problem). 
        whrTickSec=find(timemod(whrTim)==systemTick(whzf2(g)))-1;
        
        % Then account for the fact that its not always the first second of data.
        whrTickFinal=whrTickSec+whrTim(1)-1;
        
        % Now convert from INS time (Sample rate = 10,000) to SR of
        % recording and place packet in correct place. Convert this into sample space
        ms=whrTickFinal./10;
        smp=round(ms/(1000/SR))+1;
        
        % Check data using different method (sequential packet differences)
        % Less robust as it assumes no gaps more than 6.5 seconds where you
        % would lose track of timing. But works as a check in data without
        % long gaps. 
%         pckdiff=systemTick(whzf2(g))-systemTick(whzf2(g-1));
%         
%         if pckdiff<1
%             pckdiff=pckdiff+65535;
%         end
%         pckdiffst(g)=pckdiff;
%         whrTickFinalS(g)=whrTickFinal;
%         
        % Allocate the data.
        datar(smp-pcklength+1:smp,:)=tmp;
    end
    
    %% INTERPOLATION OF GAPS %%
    % Find gaps (zeros).
    gaps=datar==0;
    sm=sum(gaps,2);
    gapI=find(sm==4);
    gapl=sm==4; gapl(1)=0;
    
    % Put NaNs in for all the zeros %
    datar(datar==0)=NaN;
    
    % Find end of each gap block
    blcktran=find(gapl(1:end-1) & diff(gapl==0));
    
    % Find beginning of each block
    whrbeg=[];
    for g=1:size(blcktran,1)
        whrbeg=find(gapl(1:blcktran(g))~=1); whrbeg=whrbeg(end);
        whrbegS(g)=whrbeg;
    end
    
    gaplength=blcktran-whrbegS';
    
    % Put the zeros back in where there is significant gaps - so we don't
    % intepolate large gaps and cause artifacts within the frequency range
    % of interest.
    
    % Set Gap size cutoff, which will be sampling rate dependent (in samples)
    gapcutoff=2;
    whr=gaplength>gapcutoff;
    
    %     figure;
    %     plot(gapl); hold on;
    %     scatter(whrbegS,ones(length(whrbegS),1),'r')
    %     scatter(blcktran,ones(length(blcktran),1),'k')
  
    % Restore large gap with Zeros so they don't get interpolated.
    
    whrGP=find(gaplength>2);
    
    for g=1:length(whrGP)
        datar(whrbegS(whrGP(g)):blcktran(whrGP(g)),:)=0;
    end
    
    % Now intepolate on smaller gaps (< gapcutoff) %
    % This function works on NaNs, not on zeros.
    % So Zeros - remain the marker of long gaps.
    % You can then search for these or ignore as they should have less
    % effect on derived power (except for edge effects). 
    datarI=[];
    for g=1:4
        datarI(:,g)=fillmissing(datar(:,g),'linear');
    end
    
    figure;
    sb1=subplot(4,1,1);
    plot(datar(:,3));
    title('Original Data with gaps for small missing data and zeros for large missing data');
    sb2=subplot(4,1,2);
    plot(datarI(:,3));
    title('Interpolated data for small gaps');
    sb3=subplot(4,1,3);
    plot(gapl);
    title('Marker of all gaps');
    sb4=subplot(4,1,4);
    plot(datar(:,3)==0)
    title('Marker of large gaps (not interpolated)');
    linkaxes([sb1,sb2,sb3,sb4],'x')
    
    outFileName=strcat(Fln,'_convert');
    save(outFileName,'datar','SR');

end

%% NOW ALIGN IT WITH THE OTHER DATA SYSTEMS %%

%% Now that everything is hopefully on an accurate INS timebase - Next job is to pair with external computer time - to get an absolute time base
%  To do this - one would plot a distribution of the difference in the time between every 
%  packet in the new derived INS time compared to the estimate derived (Packet Gen) time. 
%  The peak of this distribution should be the best estimate of the lag
%  between the (now) non - jittering INS time and external computer time. 
%  Subtract that time from every packet (or the INS time series) - and you
%  will get. INS time in external time. 




