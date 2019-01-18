function [beepIdxBR] = createEventMatrices(alligninfo,beepsfound)
beepSecsEEG = beepsfound ./ alligninfo.eegsr  - alligninfo.eegsync(1) ./ alligninfo.eegsr;
beepSecsBR  = beepSecsEEG + alligninfo.ecogsync(1) ./ alligninfo.ecogsr;
beepIdxBR   = round(beepSecsBR .* alligninfo.ecogsr);

end