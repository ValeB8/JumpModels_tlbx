function [mode_val,ypred,BFR_pred]=ValMJLS(K,delaymax,Yval,Xval,theta,transition,var_error)
%Function used to validate the MJL model obtained with the approach
%proposed in [1].
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
%Inputs:
% - K : number of modes;
% - delaymax : number of initial samples that are not processed;
% - Yval : output vector;
% - Xval : modified regressor;
% - theta : estimated parameters;
% - transition : estimated transition matrix;
% - var_error : sampled error variance.
%Outputs:
% - mode_val : estimated mode sequence;
% - ypred : predicted output (one-step head prediction);
% - BFR : Best Fit Rate (on one-step head prediction). 

% Written by V.Breschi, March 2016

alpha_init=(1/K)*ones(K,1); %Initial mode probabilities
Nval=size(Yval,1); % Number of samples
p=size(Yval,2);

%% Determine the MAP path through Viterbi algorithm
yest=zeros(Nval,p,K);
for k=1:K
    yest(1:delaymax,:,k)=Yval(1:delaymax,:);
end

for n=delaymax+1:Nval
    for k=1:K
        yest(n,:,k)=Xval(n,:,:)*theta(:,:,k);
    end
end

[mode_val,~]=HMMViterbi(transition,alpha_init,Yval,yest,var_error);

%% One-step ahead prediction
ypred=zeros(Nval,p);

if delaymax~=0
    ypred(1:delaymax,:)=Yval(1:delaymax,:);
end

for ind=delaymax+1:Nval
    ypred(ind,:)=Xval(ind,:,:)*theta(:,:,mode_val(ind));
end

%% BFR computation
BFR_pred=zeros(p,1);

for ind=1:p
    BFR_pred(ind)=max(1-(norm(ypred(:,ind)-Yval(:,ind))/(norm(Yval(:,ind)-mean(Yval(:,ind))))),0);
end

end