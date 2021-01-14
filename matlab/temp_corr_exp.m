rng(1)
x = rand(20,4);
x(:,1) = x(:,1) + [1:20]';
x(:,3) = x(:,3) + [1:20]';

rng(2)
y = rand(20,4);
y(:,1) = y(:,1) + [20:-1:1]';
y(:,3) = y(:,3) + [1:20]';


[corrs pvals] = corr(x,y,'type','Spearman');
% [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
% pvalsCorr = pvals < 0.05/length(pvals(:));
hfig = figure;
hfig.Color = 'w';
corrsDiff = corrs;
%     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
%     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
b = imagesc(corrsDiff');
set(gca,'YDir','normal')