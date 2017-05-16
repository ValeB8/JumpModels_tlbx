%Script that allows to reproduce the results of the example reported in
%Section 4.1.1 of [1], i.e. it allows to learn a juping classifier.

%CVX is REQUIRED!

%Written by V.Breschi, September 2016

%% Test 1: Learn and Validate a jump classifier

%Generate Training and Validation datasets
N=400;
Nval=200;
p=2;

mean=cell([2 1]);
mean{1}=[0.25 0.4;1 0.5];
mean{2}=[-0.25 0.8;0.5 1];

seeds.rand=500;
seeds.randn=seeds.rand;

std=cell([2 1]);
std{1}=0.15;
std{2}=std{1};

p1=[0.99 0.01]; 
p2=[0.01 0.99];

P=zeros(2,2);
P(1,:)=p1;
P(2,:)=p2;

[y,yval,X,Xval,h,hval]=classJM_Data(N,Nval,p,seeds,mean,std,P);

%Set the parameters for jumpOptimizer
K=2;
regularization=2;
cons_rgl=5;
opt.init_mtd='K-models';
opt.init_seqL=10;
opt.maxiter=30;
opt.showCon=false;
opt.analitic=false;
opt.switchw='frequences';

cons.lambda0=0.99;
cons.min_iter=4;

%Define the cost function and the regressor
[X_model,param2,f2,rgl]=LclassPB_builder(N,X,regularization,cons_rgl); 
%Learn the model
[theta,tr,F,~,~,~]=jumpOptimizer(y,X_model,K,f2,param2,rgl,cons,opt);

%Validate the model
[path_val,y_est,PerformanceIndex]=validation_jumpModelclass(K,f2,param2,theta,F,yval,Xval,hval);

save('Test1_jumpClass.mat')

%% Plots
figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=1:length(y)
    if y(ind)==1 
        plot(X(ind,1),X(ind,2),'sb','MarkerFaceColor','blue','MarkerSize',2);
        hold on
    elseif y(ind)==-1
        plot(X(ind,1),X(ind,2),'r^','MarkerFaceColor','red','MarkerSize',2);
        hold on
    end
end
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Training Set: Labels','FontSize',10,'FontName','Times New Roman')

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=1:262
    if y(ind)==1 
        plot(X(ind,1),X(ind,2),'sb','MarkerFaceColor','blue','MarkerSize',2);
        hold on
    elseif y(ind)==-1
        plot(X(ind,1),X(ind,2),'r^','MarkerFaceColor','red','MarkerSize',2);
        hold on
    end
end
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Training Set: Labels for mode 1','FontSize',10,'FontName','Times New Roman')

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=263:400
    if y(ind)==1 
        plot(X(ind,1),X(ind,2),'sb','MarkerFaceColor','blue','MarkerSize',2);
        hold on
    elseif y(ind)==-1
        plot(X(ind,1),X(ind,2),'r^','MarkerFaceColor','red','MarkerSize',2);
        hold on
    end
end
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Training Set: Labels for mode 2','FontSize',10,'FontName','Times New Roman')

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=1:length(yval)
    if yval(ind)==1 
        plot(Xval(ind,1),Xval(ind,2),'sb','MarkerFaceColor','blue','MarkerSize',2);
        hold on
    elseif yval(ind)==-1
        plot(Xval(ind,1),Xval(ind,2),'r^','MarkerFaceColor','red','MarkerSize',2);
        hold on
    end
end
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Validation Set: Labels','FontSize',10,'FontName','Times New Roman')

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=1:length(yval)
    if y_est(ind)==1 
        plot(Xval(ind,1),Xval(ind,2),'sb','MarkerFaceColor','blue','MarkerSize',2);
        hold on
    elseif y_est(ind)==-1
        plot(Xval(ind,1),Xval(ind,2),'r^','MarkerFaceColor','red','MarkerSize',2);
        hold on
    end
end
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Validation Set: Estimated Labels','FontSize',10,'FontName','Times New Roman')


figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=1:length(yval)
    if hval(ind)==1 
        plot(Xval(ind,1),Xval(ind,2),'k*','MarkerSize',1);
        hold on
    elseif hval(ind)==2
        plot(Xval(ind,1),Xval(ind,2),'m*','MarkerSize',1);
        hold on
    end
end
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Validation Set: Modes','FontSize',10,'FontName','Times New Roman')

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=1:length(path_val)
    if path_val(ind)==1 
        plot(Xval(ind,1),Xval(ind,2),'k*','MarkerSize',1);
        hold on
    elseif path_val(ind)==2
        plot(Xval(ind,1),Xval(ind,2),'m*','MarkerSize',1);
        hold on
    end
end
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Validation Set: Estimated modes','FontSize',10,'FontName','Times New Roman')

y_class1=y(find(h==1));
X_class1=X(find(h==1),:);
figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=1:length(y_class1)
    if y_class1(ind)==1 
        plot(X_class1(ind,1),X_class1(ind,2),'sb','MarkerFaceColor','blue','MarkerSize',2);
        hold on
    elseif y_class1(ind)==-1
        plot(X_class1(ind,1),X_class1(ind,2),'r^','MarkerFaceColor','red','MarkerSize',2);
        hold on
    end
end
gridding = linspace(-0.7,1.6,100);
plot(gridding,(theta(1,3,1)-theta(1,1,1)*gridding)/theta(1,2,1),'k','LineWidth',1)
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Training set: Separator for mode 1','FontSize',10,'FontName','Times New Roman')

y_class2=y(find(h==2));
X_class2=X(find(h==2),:);
figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
for ind=1:length(y_class2)
    if y_class2(ind)==1 
        plot(X_class2(ind,1),X_class2(ind,2),'sb','MarkerFaceColor','blue','MarkerSize',2);
        hold on
    elseif y_class2(ind)==-1
        plot(X_class2(ind,1),X_class2(ind,2),'r^','MarkerFaceColor','red','MarkerSize',2);
        hold on
    end
end
gridding = linspace(-0.7,1.5,100);
plot(gridding,(theta(1,3,2)-theta(1,1,2)*gridding)/theta(1,2,2),'k','LineWidth',1)
xlim([-0.7 1.6])
ylim([-0.2 1.5])
xlabel('$x_{t}(1)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$x_{t}(2)$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
title('Training set: Separator for mode 2','FontSize',10,'FontName','Times New Roman')

clear h theta F path_val y_est X_model figure1 axes1

%% Test 2: SVM classifier

%Load the trained classifier
load('QuadraticSVM.mat') 

%Label prediction 
[labels_svm]=predict(trainedClassifierSVM2,Xval);

Tval=size(Xval,1);
PerformanceIndexSVM=100*(Tval-length(find(labels_svm==yval)))/Tval;

PerformanceIndexRJM=PerformanceIndex(2);

save Test2_jumpClass.mat PerformanceIndexRJM PerformanceIndexSVM
clear PerformanceIndex PerformanceIndexSVM trainedClassifierSVM2

%% Test 3: Evaluate the convergence of the method

opt.showCon=true; %Step 1 and 2 will be performed until the maximum number of iterations is reached

%Define the cost function and the regressor
[X_model,param2,f2,rgl]=LclassPB_builder(N,X,regularization,cons_rgl);
%Learn the model
[theta,~,F,cost,~,~]=jumpOptimizer(y,X_model,K,f2,param2,rgl,cons,opt);

%Validate the model
[path_val,y_est,PerformanceIndex]=validation_jumpModelclass(K,f2,param2,theta,F,yval,Xval,hval);

save('Test3_jumpClass.mat')

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
plot(cost{1},'k','LineWidth',1)
xlim([1 30])
xlabel('runs','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('Achieved cost','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

clear y X h theta F cost path_val y_est PerformanceIndex X_model N figure1 axes1


%% Test 4: Increase the number of training points 
%Comment tic and set time_filling (filling_graph.m) and time_path
%(path_dp.m) to zero (The compiled code for path_dp is already set like this)

N=[400 1000 5000 10000];

n=length(N);

opt.maxiter=15;

y=cell([n 1]);
X=cell([n 1]);
h=cell([n 1]);
theta=cell([n 1]);
F=cell([n 1]);
cost=cell([n 1]);
path_val=cell([n 1]);
y_est=cell([n 1]);
PerformanceIndex=cell([n 1]);
eval_time=cell([n 1]);

for ind=1:n
    %Generate data according to the new value of N
    [y{ind},~,X{ind},~,h{ind},~]=classJM_Data(N(ind),Nval,p,seeds,mean,std,P);
    
    %Define the cost function and the regressor
    [X_model,~,~,~]=LclassPB_builder(N(ind),X{ind},regularization,cons_rgl);
    %Learn the model
    [theta{ind},~,F{ind},cost{ind},~,~,eval_time{ind}]=jumpOptimizer(y{ind},X_model,K,f2,param2,rgl,cons,opt);
    
    %Validate the model
    [path_val{ind},y_est{ind},PerformanceIndex{ind}]=validation_jumpModelclass(K,f2,param2,theta{ind},F{ind},yval,Xval,hval);
    
    clear X_model
end

save('Test4_jumpClass.mat')
clear y X h theta F cost path_val y_est PerformanceIndex N seed


%% Test 5: Monte Carlo Simulation
opt.showCon=false;

N=1000; %Select the length of the training set
possible_seedsR=10:10:1000;
possible_seedsRN=possible_seedsR(randperm(length(possible_seedsR)));
n=length(possible_seedsR);

y=cell([n 1]);
X=cell([n 1]);
h=cell([n 1]);
theta=cell([n 1]);
F=cell([n 1]);
cost=cell([n 1]);
path_val=cell([n 1]);
y_est=cell([n 1]);
PerformanceIndex=cell([n 1]);

for ind=1:n
    
    seeds.rand=possible_seedsR(ind);
    seeds.randn=possible_seedsRN(ind);
    %Generate data according to the new noise seeds
    [y{ind},~,X{ind},~,h{ind},~]=classJM_Data(N,Nval,p,seeds,mean,std,P);
   
    %Define the cost function and the regressor
    [X_model,~,~,~]=LclassPB_builder(N,X{ind},regularization,cons_rgl);
    %Learn the model
    [theta{ind},~,F{ind},cost{ind},~,~]=jumpOptimizer(y{ind},X_model,K,f2,param2,rgl,cons,opt);
    
    %Validate the model
    [path_val{ind},y_est{ind},PerformanceIndex{ind}]=validation_jumpModelclass(K,f2,param2,theta{ind},F{ind},yval,Xval,hval);
    
    clear X_model
end

save('Test5_jumpClass.mat')

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
plot(performance_index(:,1),'k','LineWidth',1)
xlim([1 100])
ylim([0 100])
xlabel('runs','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('PMM (\%)','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure1=figure;
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
grid on
plot(performance_index(:,2),'k','LineWidth',1)
xlim([1 100])
ylim([0 100])
xlabel('runs','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('PMP (\%)','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

clear y yval X Xval h hval theta F cost path_val y_est PerformanceIndex N seed