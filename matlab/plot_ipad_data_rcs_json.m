function [timeparams] = plot_ipad_data_rcs_json(event_indices,ecog,ecogsr,figdir,timeparams,varargin)
% addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));
% set some subplot prarams 
if ~isempty(varargin{1})
    nrows = varargin{1}; 
    ncols = varargin{2}; 
    saveFig = varargin{3}; 
    minimum_frequency= varargin{4};
    maximum_frequency= varargin{5};

else
    nrows = 2; 
    ncols = 2; 
    saveFig = 1;
    minimum_frequency=2;%lowest freq to examine
    maximum_frequency= 123;

end

%load ecog file
%load event file
num_channels = ecog.numChannels; 
% for ch_index = 1:num_channels
%     ecog.contact_pair(1,ch_index).remontaged_ecog_signal =  ecog.contact_pair(1,ch_index).raw_ecog_signal - ecog.contact_pair(1,ch_index+1).raw_ecog_signal;
% end
start_epoch_at_this_time    = timeparams.start_epoch_at_this_time;%-8000; % ms relative to event (before), these are set for whole analysis
stop_epoch_at_this_time     = timeparams.stop_epoch_at_this_time; % ms relative to event (after)
start_baseline_at_this_time = timeparams.start_baseline_at_this_time;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
stop_baseline_at_this_time  = timeparams.stop_baseline_at_this_time;%5-6000; % ms relative to event
start_window_at_this_time   = -500;

if maximum_frequency >= ecogsr/2
    maximum_frequency = ecogsr/2 - 10;
end
number_of_frequencies = 180;
minimum_frequency_step_size = .5;
sampling_rate = ecogsr;

center_frequencies=...     %picking frequencies to break up into
    make_center_frequencies(...  %generates a 128 point vector from min to max freq
    minimum_frequency,...           %with step size at least step size
    maximum_frequency,...          %and more spacing at the higher freq
    number_of_frequencies,...
    minimum_frequency_step_size)';


[epoch_time,...
    start_epoch_at_this_sample_point,...
    stop_epoch_at_this_sample_point,...
    start_baseline_at_this_sample_point,...
    stop_baseline_at_this_sample_point,...
    number_of_sample_points_in_epoch]=...
    make_epoch_time(...
    start_epoch_at_this_time,...
    stop_epoch_at_this_time,...
    start_baseline_at_this_time,...
    stop_baseline_at_this_time,...
    sampling_rate);


for ch_index = 1:num_channels
    cnm = sprintf('chan%d',ch_index);
    signal = ecog.(cnm)';
    if size(signal,1) > size(signal,2) 
        signal = signal';
    end
    number_of_sample_points_in_signal=length(signal(1,:));
    number_of_conditions=1;  %event indices are cell arrays by condions
    number_of_epochs_per_condition=length(event_indices);
    
    
    
    %calculate whole spectorgram
    if ch_index == 1
        ertf=zeros(...                          %initialize variables
            number_of_frequencies,...
            number_of_sample_points_in_epoch,...
            number_of_conditions,num_channels,...
            'single');
        zertf=zeros(size(ertf),'single');
        
        prestim_ertf_mean=zeros(...  %one less dimension b/c one value per frequency
            number_of_frequencies,...
            number_of_conditions,num_channels,'single');
        
        prestim_ertf_std=zeros(...  %one less dimension b/c one value per frequency
            number_of_frequencies,...
            number_of_conditions,num_channels,'single');
        
    end
    
    for frequency_index=1:number_of_frequencies %loops through one freq at a time
        disp(number_of_frequencies-frequency_index+1);
        %         filtered_signal = eegfilt_fir1(signal,sampling_rate,center_frequencies(frequency_index) - 1,center_frequencies(frequency_index) + 1);
        filtorder = 0; % choose defaults
        revfilt = 0; % choose d efault
        epochframes = 0;
        
        switch timeparams.filtertype
            case 'fir1'
                %% option 1
                pathGen = genpath('/Users/roee/Box/movement_task_data_at_home/code/eeglab');
                addpath(pathGen);
                firtypeuse = 'fir1';
                filtered_signal      = ...
                    eegfilt(signal,sampling_rate,center_frequencies(frequency_index) - 1,center_frequencies(frequency_index) + 1,...
                    epochframes,filtorder, revfilt, firtypeuse);
                
                analytic_signal = hilbert(filtered_signal);
                rmpath(pathGen);
            case 'ifft-gaussian'
                %% option 2
                fractional_bandwidth = .35;
                analytic_signal =...
                    gaussian_filter_signal(...
                    'output_type',...
                    'analytic_signal',...
                    'raw_signal',...
                    signal,...
                    'sampling_rate',...
                    ecogsr,...
                    'center_frequency',...
                    center_frequencies(frequency_index),...
                    'fractional_bandwidth',...
                    fractional_bandwidth);
        end

        % make z-scored event-related time-frequency (zertf)
        for condition=1:number_of_conditions
            
            [ertf(frequency_index,:,condition,ch_index),...   %generated a variable zertf (frequencies, time, conditons)
                zertf(frequency_index,:,condition,ch_index),... %ertf is the raw average amplitude values, zertf does the permutations
                prestim_ertf_mean(frequency_index,condition,ch_index),...
                prestim_ertf_std(frequency_index,condition,ch_index)]=...
                make_zertf_and_zitc_for_many_ipad_eegfilt(...
                analytic_signal,...
                event_indices,...
                start_epoch_at_this_sample_point,...
                stop_epoch_at_this_sample_point,...
                start_baseline_at_this_sample_point,...
                stop_baseline_at_this_sample_point);
        end
    end
end

timeparams.center_frequencies = center_frequencies;
timeparams.epoch_time = epoch_time;
timeparams.zertf = zertf;
timeparams.ertf = ertf;

% fnmsv = fullfile(figdir,sprintf('analyzed_ipad_data_json_%s.mat',timeparams.analysis ));
% save(fnmsv);

%% plot
hfig = figure;
for ch_plot = 1:num_channels
    for condition=1:1
        h=subplot(nrows,ncols,ch_plot);
        cmax= 2;%max(abs(squeeze(zertf(:))));
        cmin=-cmax;
        tempmat=double(squeeze(zertf(:,:,condition,ch_plot)));
        pcolor(epoch_time,center_frequencies,tempmat);
        shading interp;
        caxis([cmin cmax]);
        colorbar;
        hold on;
        hold off;
%         title(ttluse, 'FontWeight', 'bold','FontSize',16);
        hold on;
        
        plot([0 0 ],[h.YLim ],...
            'LineWidth',4,...
            'LineStyle','-.',...
            'Color',[0.8 0.1 0.1 0.7]);        
        xlabel('time (msec)');
        if timeparams.extralines
            plot([timeparams.extralinesec timeparams.extralinesec],[h.YLim ],...
                'LineWidth',4,...
                'LineStyle','-.',...
                'Color',[0 0.39 0 0.7]);
        end
        ylabel('Frequency (Hz)');
        hold on;
        ttlfnm = sprintf('chan%dTitle',ch_plot);
        title(ecog.(ttlfnm));
    end
end
hfig.Color = 'w';
set(findall(hfig,'-property','FontSize'),'FontSize',12)


if saveFig == 1;
    hfig.Color = 'w';
    set(findall(hfig,'-property','FontSize'),'FontSize',12)
    baselineTtl = sprintf('baseline %d %d',timeparams.start_baseline_at_this_time,...
        timeparams.stop_baseline_at_this_time);
    suptitle(baselineTtl);
    fnmsv = sprintf('ipad_spectrogram_baseline-%d-%d_%s_%s.fig',timeparams.start_baseline_at_this_time,...
        timeparams.stop_baseline_at_this_time,...
        timeparams.analysis,timeparams.filtertype);
    saveas(hfig,fullfile(figdir,fnmsv));
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [14 8];
    hfig.PaperPosition = [0 0 14 8];
    fnmsv = sprintf('ipad_spectrogram_baseline-%d-%d_%s_%s.jpeg',timeparams.start_baseline_at_this_time,...
        timeparams.stop_baseline_at_this_time,...
        timeparams.analysis,timeparams.filtertype);
    print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
    % print(hfig,fullfile(figdir,fnmsv),'-dpdf');
    
    
    fnmsv = sprintf('ipad_spectrogram_baseline-%d-%d_%s_%s.pdf',timeparams.start_baseline_at_this_time,...
        timeparams.stop_baseline_at_this_time,...
        timeparams.analysis,timeparams.filtertype);
    print(hfig,fullfile(figdir,fnmsv),'-dpdf','-r600');
    
    close(hfig);
end
end
