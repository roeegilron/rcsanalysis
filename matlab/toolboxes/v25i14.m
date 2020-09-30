
load audio
X = [month group cons];
varnames = {'month','group','cons'};

psdresul
% Outcome: percent;

[betahat, alphahat, results] = qls(id, percent, month, X, 'n', 'equi', varnames);
[betahat, alphahat, results] = gee(id, percent, month, X, 'n', 'equi', varnames);

[betahat,alphahat,results] = qls(id, percent, month, X, 'n', 'markov', varnames);

% Outcome: high;

[betahat, alphahat, results] = qls(id, high, month, X, 'b', 'equi', varnames);
[betahat, alphahat, results] = gee(id, high, month, X, 'b', 'equi', varnames);