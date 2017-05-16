%Script generated to evaluate the behaviour of the method proposed in [1]
%to learn MJLS online.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
% Written by V.Breschi, March 2016

%% Generate the dataset 
[N,model,K,delaymax,y,u,h,Phi,SNR]=generateData_Onlinemjls(600,200,0.1);
% Define an initial subset of the data used for batch estimation
offline_limit=5500;
y_offline=y(1:offline_limit,:);
Phi_offline=Phi(1:offline_limit,:);

transition=cell([N-offline_limit+1 1]);
theta=cell([N-offline_limit+1 1]);
curr_mode=zeros(N,1);

lambda=0.9975; %Forgetting factor

%% Perform batch learning
disp('Batch identification of the model')
niter=15;
[theta{1},delta,transition{1},var_errorOff,~,iR,alpha_update]=solveMJLS(K,model,y_offline,Phi_offline,delaymax,niter,lambda);

%Initialize the transition matrix (not normalized) that is used to update
%the transition matrix estimate online.
transition_onl=zeros(K,K);
for ind=2:offline_limit
    curr_mode(ind)=find(delta(ind-1,:)==1);
    for k1=1:K
        for k2=1:K
            if curr_mode(ind-1)==k1 && curr_mode(ind)==k2
                transition_onl(k1,k2)=transition_onl(k1,k2)+1;
            end
        end
    end
end
last_mode=curr_mode(offline_limit);
transition_onl(last_mode,last_mode)=transition_onl(last_mode,last_mode)+1;

%Initialize the sampled error variance and its inverse
var_error=var_errorOff;
invS=inv(var_errorOff);

%Number of points associated to each mode (for the offline sample)  
N_k=zeros(K,1);
for k=1:K
    if curr_mode(offline_limit)==k
        N_k(k)=length(find(curr_mode(1:offline_limit)==k))+1;
    else
        N_k(k)=length(find(curr_mode(1:offline_limit)==k));
    end
end

%% Online update of the model (parameters+transition matrix)
for t=offline_limit+1:N
    disp('Online update of the model')
    
    %Update the estimates of the parameters
    [theta{t-offline_limit+1},delta,iR]=multi_rlsRec_mex(y(t,:),Phi(t,:),K,lambda,theta{t-offline_limit},iR);
    
    %Update the sampled error covariance and its inverse
    err=y(t,:)-theta{t-offline_limit+1}(:,:,find(delta==1))'*Phi(t,:)';
    delta_e=(1/t)*err;
    time_q=(t-2)/(t-1);
    var_error=time_q*var_error+(1/(t-1))*(err'*err);
    Q=invS-((invS*(err*err')*invS)/(t-2+err'*invS*err));
    invS=(1/time_q)*(Q-((Q*(delta_e*delta_e')*Q)/((1/time_q)+delta_e'*Q*delta_e)));
    
    %Assign the data point to a mode using the probablistic clustering
    %method
    [curr_mode(t,:),~,alpha_update]=probabilistic_clusteringRec_mex(y(t,:),Phi(t,:),K,theta{t-offline_limit+1},var_error,invS,alpha_update,transition{t-offline_limit});
    
    %Update the transition matrix
    for k=1:K
        for k2=1:K
            if curr_mode(t-1)==k && curr_mode(t)==k2
                transition_onl(k,k2)=transition_onl(k,k2)+1;
            end
        end
    end
    
    for k=1:K
        transition{t-offline_limit+1}(k,:)=transition_onl(k,:)/(N_k(k));
        if curr_mode(t)==k
            N_k(k)=N_k(k)+1;
        end
    end
end

%% Plots

a(:,1)=[0.4;-0.2;0.7];
b(:,1)=[0.7;0.4;0.5];

a(:,2)=[0.8;0.2;-0.1];
b(:,2)=[0.4;0.8;0.2];


y_plotA1ideal=[ones(6000,1)*a(1,1);ones(N-6000,1)*a(1,2)];
y_plotA2ideal=[ones(6000,1)*a(2,1);ones(N-6000,1)*a(2,2)];
y_plotA3ideal=[ones(6000,1)*a(3,1);ones(N-6000,1)*a(3,2)];
y_plotB1ideal=[ones(6000,1)*b(1,1);ones(N-6000,1)*b(1,2)];
y_plotB2ideal=[ones(6000,1)*b(2,1);ones(N-6000,1)*b(2,2)];
y_plotB3ideal=[ones(6000,1)*b(3,1);ones(N-6000,1)*b(3,2)];

parama1(1:offline_limit)=theta{1}(1,:,2);
parama2(1:offline_limit)=theta{1}(1,:,1);
parama3(1:offline_limit)=theta{1}(1,:,3);

paramb1(1:offline_limit)=theta{1}(2,:,2);
paramb2(1:offline_limit)=theta{1}(2,:,1);
paramb3(1:offline_limit)=theta{1}(2,:,3);

for t=offline_limit+1:N
   if t>6000 
    parama1(t)=theta{t-offline_limit+1}(1,:,3);
    parama2(t)=theta{t-offline_limit+1}(1,:,2);
    parama3(t)=theta{t-offline_limit+1}(1,:,1);
    
    paramb1(t)=theta{t-offline_limit+1}(2,:,3);
    paramb2(t)=theta{t-offline_limit+1}(2,:,2);
    paramb3(t)=theta{t-offline_limit+1}(2,:,1);
    
   else
            
    parama1(t)=theta{t-offline_limit+1}(1,:,2);
    parama2(t)=theta{t-offline_limit+1}(1,:,1);
    parama3(t)=theta{t-offline_limit+1}(1,:,3);
    
    paramb1(t)=theta{t-offline_limit+1}(2,:,2);
    paramb2(t)=theta{t-offline_limit+1}(2,:,1);
    paramb3(t)=theta{t-offline_limit+1}(2,:,3);
    
   end
end

figure1=figure(1);
axes1=axes('Parent',figure1,'FontSize',8,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
plot(y_plotA1ideal,'k','LineWidth',1)
grid on 
hold on
plot(parama1,'r','LineWidth',1)
xlim([5500 30000])
ylim([0.2 0.85])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$\theta_{1}^{(1)}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure2=figure(2);
axes2=axes('Parent',figure2,'FontSize',8,'FontName','Times New Roman');
box(axes2,'on');
hold(axes2,'all');
plot(y_plotB1ideal,'k','LineWidth',1)
grid on 
hold on
plot(paramb1,'r','LineWidth',1)
xlim([5500 30000])
ylim([0.35 0.8])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$\theta_{1}^{(2)}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure3=figure(3);
axes3=axes('Parent',figure3,'FontSize',8,'FontName','Times New Roman');
box(axes3,'on');
hold(axes3,'all');
plot(y_plotA2ideal,'k','LineWidth',1)
grid on 
hold on
plot(parama2,'r','LineWidth',1)
xlim([5500 30000])
ylim([-0.5 0.45])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$\theta_{2}^{(1)}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure4=figure(4);
axes4=axes('Parent',figure4,'FontSize',8,'FontName','Times New Roman');
box(axes4,'on');
hold(axes4,'all');
plot(y_plotB2ideal,'k','LineWidth',1)
grid on 
hold on
plot(paramb2,'r','LineWidth',1)
xlim([5500 30000])
ylim([0.3 0.9])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$\theta_{2}^{(2)}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure5=figure(5);
axes5=axes('Parent',figure5,'FontSize',8,'FontName','Times New Roman');
box(axes5,'on');
hold(axes5,'all');
plot(y_plotA3ideal,'k','LineWidth',1)
grid on 
hold on
plot(parama3,'r','LineWidth',1)
xlim([5500 30000])
ylim([-0.25 1])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$\theta_{3}^{(1)}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

figure6=figure(6);
axes6=axes('Parent',figure6,'FontSize',8,'FontName','Times New Roman');
box(axes6,'on');
hold(axes6,'all');
plot(y_plotB3ideal,'k','LineWidth',1)
grid on 
hold on
plot(paramb3,'r','LineWidth',1)
xlim([5500 30000])
ylim([0 0.6])
xlabel('Samples','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')
ylabel('$\theta_{3}^{(2)}$','FontSize',10,'FontName','Times New Roman','Interpreter','Latex')

save('OnlineTest.mat');