function exportDelsysVideoExperiment 
%% read csv header 
fnm = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v07-home-visit-long-walking-session/delsys/Rcs-walking-fulll-test_Plot_and_Store_Rep_2.1.csv';
data = readtable(fnm);
convertDelsysToMat(fnm,'process'); 

%% plot 
delsysStartTime = datetime('2018/11/07 13:56:58.000',...
                           'InputFormat','yyyy/MM/dd HH:mm:ss.SSS',...
                           'TimeZone','America/Los_Angeles'); 
                       
fnmsDelsys = fieldnames(dataraw);
pressurefnm = fnmsDelsys{...
cellfun(@(x) any(regexpi(x,'pres')), fnmsDelsys) & ...
cellfun(@(x) any(regexpi(x,'emg')), fnmsDelsys)};

lenuse = size(dataraw.(pressurefnm),1) - 1; % since time starts at zero 
timeVecDelsys = seconds( (0:1:lenuse) ./ dataraw.srates.trig); 
secUseDelsys = timeVecDelsys + delsysStartTime; 

pressureRawDat = dataraw.(pressurefnm);
pressProcessed = zeros(lenuse+1,1); 
minPres        = min(pressureRawDat); 
idxPress       = pressureRawDat < minPres/2; 
pressProcessed(idxPress) = 1; 

hfig = figure; 
hplt = plot(secUseDelsys,pressProcessed); 
hplt.LineWidth = 2; 
hplt.Color = [0 0 0.8 0.6]; 
ylim([-0.1 1.1]); 

%% write video of pressure signal

open('/Users/roee/Starr_Lab_Folder/Presenting/Talks/2018_05_DBS_think_tank/figures/TremorMovideFig.fig');
secStart = 45;

fnm = sprintf('detector-%d-%d-secs.mp4',secStart,secEnd);

v = VideoWriter(fnm,'MPEG-4');


hvid = subplot(2,2,1); axis tight; box off; axis off;
inc = 1/v.FrameRate ;
incvid =  1/vread.FrameRate;
open(v);

startframeEm = timestartemp;
endframeEm = startframeEm + seconds(framesize);
incEm = seconds(inc);

fcnt = 1;
while endframe < secEnd
    try
        start = tic;
        % detector
        xlim(hdet,[startframe endframe]);
        hVidLine.XData = hVidLine.XData + inc;
        % video
        vidFrame = readFrame(vread);
        image(vidFrame, 'Parent', hvid);axis tight; axis off;
        %    vread.CurrentTime = vread.CurrentTime +  incvid;
        
        % empatica
        xlim(hemp,[startframeEm endframeEm]);
        hVidLineEmp.XData = hVidLineEmp.XData + incEm;
        hVidLineEmp.YData = hemp.YLim;
        %    datetick(hemp,'x','MM:SS:FFF');
        % grab frame
        frame(fcnt) = getframe(hfig);
        writeVideo(v,frame(fcnt));
        
        %    X = screencapture(hfig);
        %
        %    frame(fcnt) = im2frame(X);
        
        % increment time counters
        fcnt = fcnt + 1;
        startframe = startframe + inc;
        endframe = endframe + inc;
        startframeEm = startframeEm + incEm;
        endframeEm = endframeEm + incEm;
        %         fprintf('frame %d end time %.2f written in %f\n',...
        %             fcnt, endframe,toc(start));
        fprintf('vid time = %0.3f, em time = %s, br time = %0.3f\n',...
            vread.CurrentTime,endframeEm-seconds(framesize/2),hVidLine.XData(1))
    catch
        close(v);
    end
    
end

close(v);
close(hfig);




end