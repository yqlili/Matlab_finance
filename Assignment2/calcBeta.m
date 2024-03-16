function betaEst = calcBeta(y,X)

nObs=size(X,1);
intercept=ones(nObs,1);

X2=[intercept,X];
knum=size(X2,2);

b_ols=((X2'*X2)\eye(knum))*X2'*y;       % beta
e=y-X2*b_ols;                % error
sigmaE=e'*e./(nObs-knum);   % variance of errors
varcovE=sigmaE.*inv(X2'*X2);  % covariance-matrix of errors
se_ols=sqrt(diag(varcovE)); % SE

betaEst.beta=b_ols;
betaEst.se=se_ols;
