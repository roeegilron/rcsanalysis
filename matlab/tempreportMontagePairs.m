function tempreportMontagePairs()
%% pairs 
stn_elecs = nchoosek(0:3,2);
ecg_elecs = nchoosek(8:11,2);
idx = nchoosek(1:6,2);

%% report montage 
for i = 1:size(idx,1)
    fprintf('stn %d %d , ecog %d %d\n',...
        stn_elecs(idx(i,1),1),stn_elecs(idx(i,1),2),...
        ecg_elecs(idx(i,2),1),ecg_elecs(idx(i,2),2))
end

end

