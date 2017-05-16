%Script generated to evaluate the convergence of the method proposed in [1]
%to learn MJLS.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
% Written by V.Breschi, March 2016

maxiter=40; %Refinement iterations
N=5000; %Number of training samples

%Noise seeds and variance
seedrn_train=400;
seedr_train=600;
noise_std=0.1;
seedrn_val=600;
seedr_val=200;
noise_stdval=0.01;

lambda=1; %forgetting factor

BFR_pred=cell([length(1:maxiter) 1]);

%% Generate the validation set
Nval=200;
[model,~,~,yval,uval,hval,Phival,~]=generateData_mjls(Nval,seedrn_val,seedr_val,2,noise_stdval);
if strcmp(model,'affine')
    Xval=[Phival ones(size(Phival,1),1)];
else
    Xval=Phival;
end

%% Train and valudate models for the training sets increasing the number of refinement iterations
[model,nmodes,delaymax,y,u,h,Phi,SNR]=generateData_mjls(N,seedrn_train,seedr_train,2,noise_std);
for iter=1:maxiter
    [theta,transition,var_error,~]=solveMJLS(nmodes,model,y,Phi,delaymax,iter,lambda);
    [path_vit,ypred,BFR_pred{iter}]=ValMJLS(nmodes,delaymax,yval,Xval,theta,transition,var_error);
    clear theta transition var_error
end

BFR_predMat=cell2mat(BFR_pred);
figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
plot(BFR_predMat,'k','LineWidth',1)
grid on
xlim([1 40])
ylim([0.9 1])
xlabel('runs','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('BFR','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

save 'ConvergenceTest.mat' BFR_pred
clear all