function[theta,delta,transition,var_error,eval_timeMJLS,iR,alpha_up]=solveMJLS(K,model,y,Phi,delaymax,niter,lambda)
%Function that allows to define the regressor and the output to be used to
%learn the jump model and to identify the model.
%Inputs:
% - K : number of modes;
% - model : kind of model to learn. The options are:
%           - 'static'; 
%           - 'linear';
%           - 'affine';
% - y : output vector (N x p);
% - Phi : not modified regressor (N x p x d);
% - delaymax : initial samples to be discarded;
% - niter : number of iterations used to refine the estimates of the
%           parameters;
% - lambda : forgetting factor (0,1].
%Outputs:
% - theta : estimated parameters for each mode (m x K);
% - delta : mode assignement (N x K);
% -transition : estimated transition matrix (K x K);
% - var_error : error sampled variance (p x p);
% - eval_timeMJLS : time required to learn the model [s];
% - iR : last computed matrix in the RLS scheme (m x m) - for online learning;
% - alphaup : predicted probabilities for sample N+1 (K x 1) - for online
%             learning.

%Written by V.Breschi, September 2016

N=size(y,1); %Number of samples

%Define the output/regressor based on the selected model
switch model
    case 'static'
        X=ones(N,1);
        Y=y;
    case 'linear'
        X=Phi(delaymax+1:end,:,:);
        Y=y(delaymax+1:end,:);
    case 'affine'
        X=[Phi(delaymax+1:end,:,:) ones(N-delaymax,1)];
        Y=y(delaymax+1:end,:);
end

%Learn the jump model
tic
[theta,~,delta,~,transition,var_error,iR,alpha_up]=MJLSid(niter,K,Y,X,lambda);
eval_timeMJLS=toc;
end