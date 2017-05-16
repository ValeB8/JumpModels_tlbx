%Script generated to assess if the method proposed in [1] allows 
%to learn electric power consumption patterns. The dataset described in [2]
%is used.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
% [2] Stephen Makonin, Bradley Ellert, Ivan V. Bajic, and Fred Popowich. Electricity,
%     water, and natural gas consumption of a residential house in Canada from 2012 to
%     2014. Scientific Data, 3(160037):1-12, 2016.
%
% Written by V.Breschi, September 2016

%% Create the dataset used to train the models
load('powerData.mat')
create_oneweekData

delaymax=zeros(4,1);
K=[2 3 2 2]; % Number of modes for each appliance 
lambda=1; % Forgetting factor
niter=10; %Number of iterations for refinement

theta=cell([4,1]);
transition=cell([4 1]);
var_error=cell([4 1]);
y_pred=cell([4 4]);
BFR=cell([4 4]);
path_val=cell([4 1]);

%% Training 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CDE (Cloth Dryer)

ycde=oneweek_cde; %training set

[theta_cde,~,transition_cde,S_cde]=solveMJLS(K(1),'static',ycde,[],delaymax(1),niter,lambda);

theta{1}=theta_cde;
transition{1}=transition_cde;
var_error{1}=S_cde;

%% DWE (Dishwasher)

ydwe=oneweek_dwe; %training set

[theta_dwe,~,transition_dwe,S_dwe]=solveMJLS(K(2),'static',ydwe,[],delaymax(2),niter,lambda);

theta{2}=theta_dwe;
transition{2}=transition_dwe;
var_error{2}=S_dwe;

%% FGE (Fridge)

yfge=oneweek_fge; %training set

[theta_fge,~,transition_fge,S_fge]=solveMJLS(K(3),'static',yfge,[],delaymax(3),niter,lambda);

theta{3}=theta_fge;
transition{3}=transition_fge;
var_error{3}=S_fge;

%% HPE (Heat Pump)

yhpe=oneweek_hpe; %training set

[theta_hpe,~,transition_hpe,S_hpe]=solveMJLS(K(4),'static',yhpe,[],delaymax(4),niter,lambda);

theta{4}=theta_hpe;
transition{4}=transition_hpe;
var_error{4}=S_hpe;

%% Validation

%Validation sets
yval{1}=powerData.CDE(:,170);
yval{2}=powerData.DWE(:,45);
yval{3}=powerData.FGE(:,234);
yval{4}=powerData.HPE(:,80);

for ind1=1:4
    for ind2=1:4
        if ind1==ind2
            [path_val{ind1},y_pred{ind2,ind1},BFR{ind2,ind1}]=ValMJLS(K(ind1),delaymax(ind1),yval{ind2},ones(size(yval{ind2},1),1),theta{ind1},transition{ind1},var_error{ind1});
        else
            [~,y_pred{ind2,ind1},BFR{ind2,ind1}]=ValMJLS(K(ind1),delaymax(ind1),yval{ind2},ones(size(yval{ind2},1),1),theta{ind1},transition{ind1},var_error{ind1});
        end
    end
end

save('EstEnergyPattern.mat')

%% Plots

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
plot(yval{1},'k','LineWidth',1)
grid on
hold on
plot(y_pred{1,1},'r','LineWidth',1)
xlim([1200 1440])
ylim([-10 6000])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$y_{t},\hat{y}_{t}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure2=figure;
axes2=axes('Parent',figure2,'FontSize',8,'FontName','Times New Roman');
box(axes2,'on');
hold(axes2,'all');
plot(yval{2},'k','LineWidth',1)
grid on
hold on
plot(y_pred{2,2},'r','LineWidth',1)
xlim([1000 1240])
ylim([-10 1000])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$y_{t},\hat{y}_{t}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure3=figure;
axes3=axes('Parent',figure3,'FontSize',8,'FontName','Times New Roman');
box(axes3,'on');
hold(axes3,'all');
plot(yval{3},'k','LineWidth',1)
grid on
hold on
plot(y_pred{3,3},'r','LineWidth',1)
xlim([400 640])
ylim([-10 300])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$y_{t},\hat{y}_{t}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure4=figure;
axes4=axes('Parent',figure4,'FontSize',8,'FontName','Times New Roman');
box(axes4,'on');
hold(axes4,'all');
plot(yval{4},'k','LineWidth',1)
grid on
hold on
plot(y_pred{4,4},'r','LineWidth',1)
xlim([500 740])
ylim([-10 2000])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$y_{t},\hat{y}_{t}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure5=figure;
axes5=axes('Parent',figure5,'FontSize',8,'FontName','Times New Roman');
box(axes5,'on');
hold(axes5,'all');
plot(path_val{1},'k','LineWidth',1)
grid on
xlim([1200 1440])
ylim([0 4])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$s(t)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure6=figure;
axes6=axes('Parent',figure6,'FontSize',8,'FontName','Times New Roman');
box(axes6,'on');
hold(axes6,'all');
plot(path_val{2},'k','LineWidth',1)
grid on
xlim([1000 1240])
ylim([0 4])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$s(t)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure7=figure;
axes7=axes('Parent',figure7,'FontSize',8,'FontName','Times New Roman');
box(axes7,'on');
hold(axes7,'all');
plot(path_val{3},'k','LineWidth',1)
grid on
xlim([400 640])
ylim([0 3])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$s(t)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure8=figure;
axes8=axes('Parent',figure8,'FontSize',8,'FontName','Times New Roman');
box(axes8,'on');
hold(axes8,'all');
plot(path_val{4},'k','LineWidth',1)
grid on
xlim([500 740])
ylim([0 3])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$s(t)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')