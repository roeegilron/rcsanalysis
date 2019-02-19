function ...
    output_signal=...
    gaussian_filter_signal(varargin);

% function ...
%     output_signal=...
%     gaussian_filter_signal(...
%     'output_type',...
%     'analytic_signal',...
%     'raw_signal',...
%     raw_signal,...
%     'sampling_rate',...
%     sampling_rate,...
%     'center_frequency',...
%     center_frequency,...
%     'frequency_domain_standard_deviation',...
%     frequency_domain_standard_deviation);
%
% The above pairs of variable names and values can be in any order
%
% OPTIONS AND ALTERNATE ENTRIES:
%
% 'output_type' can be:
%       1) 'analytic_signal': complex-valued vector of amplitude and phase of filtered signal at each sample point
%       2) 'power': real-valued [0,realmax) vector of instantaneous power of filtered signal at each sample point
%                power=abs(analytic_signal).^2;
%       3) 'phase': real-valued vector (-pi,pi] vector of instantaneous phase of filtered signal at each sample point
%                phase=angle(analytic_signal);
%       4) 'real_signal': real-valued vector of instantaneous values of filtered signal
%                real_signal=real(analytic_signal);
%
% the filter width can be specified by giving one of the following parameters:
%       1) 'frequency_domain_standard_deviation' (Hz),
%           (standard deviation of Gaussian envelope of filter in the frequency domain),
%       2) 'time_domain_standard_deviation' (seconds),
%           (standard deviation of Gaussian envelope of filter in the time domain),
%       3) 'fractional_bandwidth' (unitless positive real number),
%       4) 'Q_value' (unitless positive real number)
%       5) 'full_width_at_half_maximum', (Hz),
%       6) 'number_of_cycles', (unitless positive real number).
% the parameter frequency_domain_standard_deviation is computed
% from any of the above 6 filter width parameters and used in the function
% if in doubt, use 0.2 for fractional bandwidth
%
% 'raw_signal': signal to be filtered in time domain representation
% user can instead input:
%       1) 'ffted_signal', signal to be filtered in frequency domain representation,
%           where ffted_signal=fft(raw_signal,number_of_fft_points) and
%           number_of_fft_points >= length(raw_signal)
% IMPORTANT! If user passes 'ffted_signal',
%   then they must also pass name/value pair:
%   'number_of_sample_points_in_signal',length(raw_signal)
% e.g.:
%     output_signal=...
%     gaussian_filter_signal(...
%     'output_type',...
%     'real_signal',...
%     'ffted_signal',...
%     x,...
%     'number_of_sample_points_in_signal',...
%     648972,... % note that length(x)=2^20 since log2(648972)=19.3077967
%     'sampling_rate',...
%     2003,...
%     'center_frequency',...
%     35,...
%     'fractional_bandwidth',...
%     0.2);
% (pass ffted_signal if using in script; do 1 fft and many different iffts rather
% than many indentical ffts and many different iffts, and use next power of 2 for number_of_fft_points)
%
% REMAINING NAME/VALUE PAIRS:
% 'center_frequency': center of frequency band for filtering e.g., 110 for 110 Hz
% 'sampling_rate': number of samples per second, in Hz

for n=1:2:length(varargin)-1
    switch lower(varargin{n})
        case 'output_type'
            output_type=varargin{n+1};
        case 'raw_signal'
            raw_signal=varargin{n+1};
            number_of_sample_points_in_signal=length(raw_signal);
            number_of_fft_points=...
                2^ceil(log2(number_of_sample_points_in_signal));  %number of fft points is 2^log number of points int eh signal
            ffted_signal=...
                single(...
                fft(...
                raw_signal,...
                number_of_fft_points));
        case 'ffted_signal'
            ffted_signal=varargin{n+1};
            number_of_fft_points=length(ffted_signal);
        case 'number_of_sample_points_in_signal'
            number_of_sample_points_in_signal=varargin{n+1};
        case 'sampling_rate'
            sampling_rate=varargin{n+1};
        case 'center_frequency'
            center_frequency=varargin{n+1};
    end
end

% determine frequency_domain_standard_deviation given inputs
for n=1:2:length(varargin)-1
    switch lower(varargin{n})
        case 'frequency_domain_standard_deviation'
            frequency_domain_standard_deviation=...
                varargin{n+1};
        case 'time_domain_standard_deviation'
            frequency_domain_standard_deviation=...
                (2*pi*varargin{n+1})^-1;
        case 'fractional_bandwidth'
            frequency_domain_standard_deviation=...
                varargin{n+1}*(center_frequency/(2*(2*log(2))^.5));
        case 'q_value'
            frequency_domain_standard_deviation=...
                varargin{n+1}^-1*(center_frequency/(2*(2*log(2))^.5));
        case 'full_width_at_half_maximum'
            frequency_domain_standard_deviation=...
                varargin{n+1}/(2*(2*log(2))^.5);
        case 'number_of_cycles' % same as q-value
            frequency_domain_standard_deviation=...
                varargin{n+1}^-1*(center_frequency/(2*(2*log(2))^.5));
    end
end

% make list of frequencies used by fft and ifft
frequency_step_size=sampling_rate/number_of_fft_points;  %ends up being very small  about .0004
nyquist=sampling_rate/2;   %250 for 500 Hz
exact_DFT_frequencies=single(frequency_step_size*...  %comes up with exact freq values
    (0:number_of_fft_points-1));
exact_DFT_frequencies(exact_DFT_frequencies>nyquist)=...
    exact_DFT_frequencies(exact_DFT_frequencies>nyquist)-...  %if freq values are more then nyquist, preplace with value minus the sampling rate
    sampling_rate;
center_frequency_index=round(...
    center_frequency/frequency_step_size);
std_frequency_index=round(...
    frequency_domain_standard_deviation/frequency_step_size);
frequency_support=center_frequency_index+...
    (-6*std_frequency_index:6*std_frequency_index);
frequency_support=mod(frequency_support,number_of_fft_points);
frequency_support(frequency_support==0)=number_of_fft_points;

% make gaussian filter in frequency domain
frequency_domain_gabor=...
    zeros(size(exact_DFT_frequencies),'single');
frequency_domain_gabor(frequency_support)=...
    single(exp(-0.5*frequency_domain_standard_deviation^-2*...
    (exact_DFT_frequencies(frequency_support)-center_frequency).^2));
normalizer=sqrt(number_of_fft_points)/...
    norm(frequency_domain_gabor(frequency_support));
frequency_domain_gabor=normalizer*frequency_domain_gabor;

%filter signal in frequency domain
output_signal=...
    ifft(...
    ffted_signal.*...
    frequency_domain_gabor,...
    number_of_fft_points);

output_signal=...
    output_signal(1:number_of_sample_points_in_signal);

switch output_type
    case 'analytic_signal'
        output_signal=output_signal;
    case 'power'
        output_signal=abs(output_signal).^2;
    case 'phase'
        output_signal=angle(output_signal);
    case 'real_signal'
        output_signal=real(output_signal);
end

% fractional_bandwidth=(Q_value)^-1=FWHM bandwidth/center_frequency
% and
% FWHM=...(freq domain)
% fractional_bandwidth*center_frequency=...
% 2*sqrt(2*log(2))*frequency_domain_standard_deviation=...
% 2*sqrt(2*log(2))*(2*pi*time_domain_standard_deviation)^-1;
%
% fractional_bandwidth: used to determine
% full-width half-max (FWHM) bandwidth of filter
% fractional_bandwidth*center_frequency=FWHM bandwidth
% e.g., for fractional_bandwidth=0.3,
% bandwidth at 110 Hz is 33 Hz or 93.5-126.5,
% bandwidth at 20 Hz is 6 Hz or 17-23 Hz.
% NOTE:
% FWHM=frequency_domain_standard_deviation*2*sqrt(2*log(2))
% time_domain_standard_deviation=...
%     (2*pi*frequency_domain_standard_deviation).^-1;
%           when tdsd is in seconds, fdsd is in Hz
%
% Use constant fractional bandwidth
% for overcomplete (Morlet) wavelet decomposition.
% Recommend values between 0.05-0.4;
% if in doubt, use 0.2 as default for ECoG
% %