function analyzeVariabilitySleep()
%% load data
load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/psdDataInChunk.mat;

%% loop on data and create matrix per channel
cnt = 1;
for i = 1:1596%length(resChunks)
    
    for c = 1:4
        if i == 1
            chan(c).f = resChunks(i).f(c,:);
            chan(c).chanStr = resChunks(i).time{c};
        end
        if size(resChunks(i).fftOut,1) ==4
            chan(c).fftOut(cnt,:) = resChunks(i).fftOut(c,:);
            chan(c).mins(cnt) = min(chan(c).fftOut(i,:));
            chan(c).maxs(cnt) = max(chan(c).fftOut(i,:));
            chan(c).times{cnt} = resChunks(i).time{c};
            
        end
    end
    cnt = cnt +1;
end



%% plot all 6k lines
hfig = figure;
for c = 1:4
    subplot(2,2,c);
    hold on;
    plot(chan(c).f,chan(c).fftOut,...
        'LineWidth',0.1,...
        'Color',[0 0 0.7 0.005]);
    title(chan(c).chanStr);
    xlabel('Frequency (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
    set(gca,'FontSize',16);
    
end

%% plot 3 main cluster for each line
hfig = figure;
for c = 1:4
    subplot(2,2,c);
    hold on;
    idx = kmeans(chan(c).fftOut,4);
    for i = 1: length(  unique(idx) ); 
        clustFFt = mean(chan(c).fftOut(idx==i,:),1);
        plot(chan(c).f,clustFFt,...
            'LineWidth',2);
        title(chan(c).chanStr);
        xlabel('Frequency (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        set(gca,'FontSize',16);
    end
end

%% do k means with concatenating all clusters 
idx = kmeans([chan(1).fftOut chan(2).fftOut chan(3).fftOut chan(4).fftOut],4);
hfig = figure;
for c = 1:4
    subplot(2,2,c);
    hold on;
    
    for i = 1: length(  unique(idx) ); 
        clustFFt = mean(chan(c).fftOut(idx==i,:),1);
        plot(chan(c).f,clustFFt,...
            'LineWidth',2);
        title(chan(c).chanStr);
        xlabel('Frequency (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        set(gca,'FontSize',16);
    end
end
