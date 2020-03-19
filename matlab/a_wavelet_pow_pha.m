function [wtmat,fr] = a_wavelet_pow_pha(varargin)
% Input must contains at list 2 argument;
% dx - data massive
% SampleRate - SampleRate
% fr1 - Start freq.
% fr2 - Stopt freq.
% Optional - 
% dfr - Frequency resolution; = 1  if not define
% w_strectch -  = 3    if not define

ninp=length(varargin);
if ninp < 4 ; error('Number of input arguments must be >=4 '); end
dx=varargin{1};
SampleRate=varargin{2};
fr1=varargin{3};
fr2=varargin{4};

if ninp >=5; dfr=varargin{5}; 
else         dfr=1;           
end;

if ninp >=6; w_strectch=varargin{6};
else         w_strectch=3;
end

ndata=length(dx);
fr=[]; in=1;
startlen=5*SampleRate*w_strectch;
wtmat=[];
for xfr=fr1:dfr:fr2
    fr(in)=xfr;
    halflen=floor(startlen/xfr)+1;  wscal=SampleRate/xfr;
    nwlt=-halflen:halflen;
    wave_mat=(2/sqrt(2*pi*wscal))*(sqrt(1/(wscal*w_strectch)))*exp(1i*2*pi*nwlt/wscal).*exp(-(nwlt/(wscal*w_strectch)).^2/2);
    wconvres=conv(wave_mat,dx);
    wtmat(in,:)=wconvres(halflen:(halflen+ndata-1));
    in=in+1;
end
fr=fr';
