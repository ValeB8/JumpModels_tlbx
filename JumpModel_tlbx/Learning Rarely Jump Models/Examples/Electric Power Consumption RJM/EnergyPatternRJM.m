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
create_oneweekData;

%% Set the options to be used to learn the model
model='static';

opt.check=true;
opt.init_mtd='K-models';
opt.init_seqL=10;
opt.maxiter=30;
opt.showCon=false;
opt.switchw='frequences';
opt.analitic=true;


opt_val=struct;
opt_val.model=model;

cons.lambda0=0.9;
cons.min_iter=4;

K=[3 3 2 2]; %number of modes

path_val=cell([4 4]);
y_pred=cell([4 4]);
BFR=zeros(4,4);

%% Create the training set
ycde=oneweek_cde;
T=size(ycde,1); %all the sets have the same dimension
ydwe=oneweek_dwe;
yfge=oneweek_fge;
yhpe=oneweek_hpe;

%% Training 

%% CDE

[X_cde,param{1},f{1},rgl{1}]=LSPB_builder(T,model,[],0,1/K(1));
[theta{1},path_cde,F{1},cost_cde,~,~,eval_time{1}]=jumpOptimizer(ycde,X_cde,K(1),f{1},param{1},rgl{1},cons,opt);

%% DWE

[X_dwe,param{2},f{2},rgl{2}]=LSPB_builder(T,model,[],0,1/K(2));
[theta{2},path_dwe,F{2},cost_dwe,~,~,eval_time{2}]=jumpOptimizer_remCritDWE(ydwe,X_dwe,K(2),f{2},param{2},rgl{2},cons,opt);

%% FGE

[X_fge,param{3},f{3},rgl{3}]=LSPB_builder(T,model,[],0,1/K(3));
[theta{3},path_fge,F{3},cost_fge,~,~,eval_time{3}]=jumpOptimizer(yfge,X_fge,K(3),f{3},param{3},rgl{3},cons,opt);

%% HPE

[X_hpe,param{4},f{4},rgl{4}]=LSPB_builder(T,model,[],0,1/K(4));
[theta{4},path_hpe,F{4},cost_hpe,~,~,eval_time{4}]=jumpOptimizer(yhpe,X_hpe,K(4),f{4},param{4},rgl{4},cons,opt);


%% Create the validation sets
yval{1}=powerData.CDE(:,170);
yval{2}=powerData.DWE(:,45);
yval{3}=powerData.FGE(:,234);
yval{4}=powerData.HPE(:,80);


%% Validation
for ind1=1:4
    for ind2=1:4
        [path_val{ind1,ind2},y_pred{ind1,ind2},BFR(ind1,ind2)]=validation_jumpModelLS(K(ind1),opt_val,f{ind1},param{ind1},theta{ind1},F{ind1},yval{ind2});
    end
end

save('EstEnergyPatternRJM.mat')

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
plot(path_val{1,1},'k','LineWidth',1)
grid on
xlim([1200 1440])
ylim([0 4])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$s(t)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure6=figure;
axes6=axes('Parent',figure6,'FontSize',8,'FontName','Times New Roman');
box(axes6,'on');
hold(axes6,'all');
plot(path_val{2,2},'k','LineWidth',1)
grid on
xlim([1000 1240])
ylim([0 4])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$s(t)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure7=figure;
axes7=axes('Parent',figure7,'FontSize',8,'FontName','Times New Roman');
box(axes7,'on');
hold(axes7,'all');
plot(path_val{3,3},'k','LineWidth',1)
grid on
xlim([400 640])
ylim([0 3])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$s(t)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure8=figure;
axes8=axes('Parent',figure8,'FontSize',8,'FontName','Times New Roman');
box(axes8,'on');
hold(axes8,'all');
plot(path_val{4,4},'k','LineWidth',1)
grid on
xlim([500 740])
ylim([0 3])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$s(t)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')