%Script generated to evaluate the behaviour of the method proposed in [1]
%to learn MJLS when the noise corrupting the output increases.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
% Written by V.Breschi, March 2016
 
niter=15; %Refinement iterations
N=5000; %Number of training samples

%Noise seeds and variances
seedrn_train=400;
seedr_train=600;
noise_std=[0.02 0.05 0.1 0.15 0.3]; %Possible values of the noise std (training)
seedrn_val=600;
seedr_val=200;
noise_stdval=0.01;

lambda=1; %forgetting factor

BFR_pred=cell([length(noise_std) 1]);
mode_seq=cell([length(noise_std) 1]);
y_pred=cell([length(noise_std) 1]);
SNR=cell([length(noise_std) 1]);
theta=cell([length(noise_std) 1]);
transition=cell([length(noise_std) 1]);

%% Generate the validation set
Nval=200;
[model,~,~,yval,uval,hval,Phival,~]=generateData_mjls(Nval,seedrn_val,seedr_val,2,noise_stdval);
if strcmp(model,'affine')
    Xval=[Phival ones(size(Phival,1),1)];
else
    Xval=Phival;
end

%% Train and valudate models for the training sets with different SNR
for trial=1:length(noise_std)
    [model,nmodes,delaymax,y,u,h,Phi,SNR{trial}]=generateData_mjls(N,seedrn_train,seedr_train,2,noise_std(trial));
    [theta{trial},~,transition{trial},var_error,~]=solveMJLS(nmodes,model,y,Phi,delaymax,niter,lambda);
    [mode_seq{trial},y_pred{trial},BFR_pred{trial}]=ValMJLS(nmodes,delaymax,yval,Xval,theta{trial},transition{trial},var_error);
    clear var_error
end

save 'SNRTest.mat' yval hval BFR_pred mode_seq y_pred SNR theta transition
clear all

load('SNRTest.mat')
%% Computation of misclassified points
misclassified=zeros(length(SNR),1);
for ind=1:length(SNR)
    mode_seqMat=mode_seq{ind};
    hval_con=zeros(size(hval,1),1);
    if ind==1 || ind==3 || ind==4
        for ind2=1:size(hval,1)
            if hval(ind2)==1
                hval_con(ind2)=3;
            elseif hval(ind2)==2
                hval_con(ind2)=2;
            else
                hval_con(ind2)=1;
            end
        end
    elseif ind==5
        hval_con=hval;
    else
        for ind2=1:size(hval,1)
            if hval(ind2)==1
                hval_con(ind2)=2;
            elseif hval(ind2)==2
                hval_con(ind2)=3;
            else
                hval_con(ind2)=1;
            end
        end
    end
    misclassified(ind)=length(find(hval_con~=mode_seqMat));
end

clear mode_seqMat
clear hval_con
clear ind ind2

misclassified_per=(misclassified/200)*100;

y_predplot=y_pred{3};

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
plot(yval,'k','LineWidth',1)
grid on
hold on
plot(y_predplot,'r','LineWidth',1)
xlim([1 200])
ylim([-3 3])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$y_{t},\hat{y}_t$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure2=figure;
axes2=axes('Parent',figure2,'FontSize',8,'FontName','Times New Roman');
box(axes2,'on');
hold(axes2,'all');
plot(yval-y_predplot,'k','LineWidth',1)
grid on
xlim([1 200])
ylim([-0.2 0.2])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$y_{t}-\hat{y}_t$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex') 

save('SNRTestMisclass.mat')
clear all
