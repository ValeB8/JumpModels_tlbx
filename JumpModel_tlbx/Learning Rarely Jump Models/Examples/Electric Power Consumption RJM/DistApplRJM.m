%Script generated to assess if the models obtained running EnergyPattern.m
%allow to distinguish among different appliances. The dataset described in [2]
%is used.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
% [2] Stephen Makonin, Bradley Ellert, Ivan V. Bajic, and Fred Popowich. Electricity,
%     water, and natural gas consumption of a residential house in Canada from 2012 to
%     2014. Scientific Data, 3(160037):1-12, 2016.
%
% Written by V.Breschi, September 2016

%Load the data and the models obtained running EnergyPatternRJM.m
load('EstEnergyPatternRJM.mat')

%Create the new validation dataset presented in [1]
validation_combined=[powerData.CDE(:,40);powerData.DWE(:,60);powerData.FGE(:,60);powerData.HPE(:,60)];

K=[3 3 2 2]; %number of modes

%Consider windows of samples
win_len=60; %length of the window
num_wind=size(validation_combined,1)/win_len;

BFR_predComb=cell([num_wind 1]);
y_predComb=cell([num_wind 1]);
yvalwind=cell([num_wind 1]);
BFR_plot=zeros(size(validation_combined,1),4);

%% Validate the models on the new dataset. The active appliance will be the one with the highest BFR
for wind=1:num_wind
    yval=validation_combined(((wind-1)*win_len)+1:wind*win_len);
    yvalwind{wind}=yval;
    Phival=ones(size(yval,1),size(yval,2));
    for j=1:4
        [~,~,BFR_predComb{wind,j}]=validation_jumpModelLS(K(j),opt_val,f{j},param{j},theta{j},F{j},yval);
        BFR_plot(((wind-1)*win_len)+1:wind*win_len,j)=BFR_predComb{wind,j}*ones(win_len,1);
    end
end

col={'b','r','m','c'};
figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
hold on
grid on
for ind=1:4
    plot(BFR_plot(:,ind),col{ind});
end
xlim([1 5760])
ylim([-0.2 1.5])
ax=gca;
ax.XTickMode='manual';
ax.XTick=1:60:5760;
ax.XTickLabelMode='manual';
ax.XTickLabel=cell([96 1]);
for ind=1:96
    if ind==1
        ax.XTickLabel{ind}='1';
    elseif ind==24
        ax.XTickLabel{ind}='1440';
    elseif ind==48
        ax.XTickLabel{ind}='2880';
    elseif ind==72
        ax.XTickLabel{ind}='4320';
    elseif ind==96
        ax.XTickLabel{ind}='5760';
    else
        ax.XTickLabel{ind}='';
    end
end
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('BFR','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')


truesystem=zeros(5760,1);
for ind=1:4
    truesystem(1440*(ind-1)+1:1440*ind)=ind;
end

figure2=figure;
axes2=axes('Parent',figure2,'FontSize',8,'FontName','Times New Roman');
box(axes2,'on');
hold(axes2,'all');
plot(truesystem,'k','LineWidth',1);
hold on
grid on
xlim([1 5760])
ylim([0 5])
ax=gca;
ax.XTickMode='manual';
ax.XTick=1:60:5760;
ax.XTickLabelMode='manual';
ax.XTickLabel=cell([96 1]);
for ind=1:96
     if ind==1
         ax.XTickLabel{ind}='1';
     elseif ind==24
         ax.XTickLabel{ind}='1440';
    elseif ind==48
        ax.XTickLabel{ind}='2880';
    elseif ind==72
        ax.XTickLabel{ind}='4320';
    elseif ind==96
        ax.XTickLabel{ind}='5760';
    else
        ax.XTickLabel{ind}='';
    end
end
ax.YTickMode='manual';
ax.YTick=0:1:5;
ax.YTickLabelMode='auto';
ax.YTickLabel=cell([6 1]);
for ind=1:6
    if ind==2
        ax.YTickLabel{ind}='CDE';
    elseif ind==3
        ax.YTickLabel{ind}='DWE';
    elseif ind==4
        ax.YTickLabel{ind}='FGE';
    elseif ind==5
        ax.YTickLabel{ind}='HPE';
    else
        ax.YTickLabel{ind}='';
    end
end
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('True Load','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')