%Script generated to evaluate the behaviour of the method proposed in [1]
%to learn MJLS when the dimension of the training set increases.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
% Written by V.Breschi, March 2016

niter=15; %Refinement iterations

%Noise seeds and variances
seedrn_train=400;
seedr_train=600;
noise_std=0.1;
seedrn_val=600;
seedr_val=200;
noise_stdval=0.01;

lambda=1; %Forgetting Factor

N=[5000 10000 20000 100000]; %Possible lengths of the training set

BFR_pred=cell([length(N) 1]);
path_vit=cell([length(N) 1]);
y_pred=cell([length(N) 1]);
theta=cell([length(N) 1]);
transition=cell([length(N) 1]);
eval_time=cell([length(N) 1]);

%% Generate the validation set
Nval=200; 
[model,~,~,yval,uval,hval,Phival,~]=generateData_mjls(Nval,seedrn_val,seedr_val,2,noise_stdval);
if strcmp(model,'affine')
    Xval=[Phival ones(size(Phival,1),1)];
else
    Xval=Phival;
end

%% Train and valudate models for the training sets with different length
for trial=1:length(N)
    [model,nmodes,delaymax,y,u,h,Phi,SNR]=generateData_mjls(N(trial),seedrn_train,seedr_train,2,noise_std);
    [theta{trial},transition{trial},var_error,eval_time{trial}]=solveMJLS(nmodes,model,y,Phi,delaymax,niter,lambda);
    [path_vit{trial},y_pred{trial},BFR_pred{trial}]=ValMJLS(nmodes,delaymax,yval,Xval,theta{trial},transition{trial},var_error);
    clear var_error
end

save 'NTest.mat' yval hval path_vit y_pred BFR_pred theta transition eval_time
clear all