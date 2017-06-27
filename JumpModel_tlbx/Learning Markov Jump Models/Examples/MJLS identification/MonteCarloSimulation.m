%Script generated to evaluate the convergence of the method proposed in [1]
%to learn MJLS.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
% Written by V.Breschi, March 2016

niter=15; %Refinement iterations
N=5000; %Number of training samples

%Noise seeds and variance
rand('seed',1);
seedrn_train=10:20:1000;
index=randperm(length(seedrn_train));
seedr_train=seedrn_train(index);
noise_std=0.1;
seedrn_val=600;
seedr_val=200;
noise_stdval=0.01;

lambda=1; %forgetting factor

BFR_pred=cell([length(seedrn_train) 1]);

%% Generate the validation set
Nval=200;
[model,~,~,yval,uval,hval,Phival,~]=generateData_mjls(Nval,seedrn_val,seedr_val,2,noise_stdval);
if strcmp(model,'affine')
    Xval=[Phival ones(size(Phival,1),1)];
else
    Xval=Phival;
end

meanBFR_pred=zeros(size(yval,2),1);
varBFR_pred=zeros(size(yval,2),1);

%% Monte Carlo trials
for trial=1:length(seedrn_train)
    [model,nmodes,delaymax,y,u,h,Phi,SNR]=generateData_mjls(N,seedrn_train(trial),seedr_train(trial),2,noise_std);
    [theta,~,transition,var_error]=solveMJLS(nmodes,model,y,Phi,delaymax,niter,lambda);
    [path_vit,ypred,BFR_pred{trial}]=ValMJLS(nmodes,delaymax,yval,Xval,theta,transition,var_error);
    clear theta transition var_error
end

curr_BFRpred=zeros(length(seedrn_train),size(yval,2));

for ind=1:length(seedrn_train)
    curr_BFRpred(ind,:)=BFR_pred{ind}';
end

for ind2=1:size(yval,2)
    meanBFR_pred(ind2)=mean(curr_BFRpred(:,ind2));
    varBFR_pred(ind2)=cov(curr_BFRpred(:,ind2));
end

BFR_predMat=cell2mat(BFR_pred);
figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
plot(BFR_predMat,'k','LineWidth',1)
grid on
xlim([1 50])
ylim([0.7 1])
xlabel('M (runs)','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('BFR','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

save 'MCTest.mat' BFR_pred meanBFR_pred varBFR_pred
clear all
