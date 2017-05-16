function [theta_opt,s,frequences,cost,mean_filling,mean_eval,eval_time]=jumpOptimizer_remCritDWE(y,X,K,f,param,rgl,cons0,opt)
%Function used to train the jump model based on the selected loss function.
%Inputs:
% - y : outputs used for training.
% - X : regressor used for training.
% - K : number of sub-models.
% - f : function to be minimzied in order to train the jump model.
% - param : parameters of the function f.
% - rgl : regularization term
%           - rgl.f : considered regularization term;
%           - rgl.c : constant multiplying the regularization term.
% - cons0 :
%           - lambda0 : initial value of the parameter lambda (default 0.9);
%           - min_iter : number of iteration in which lambda0 is used,
%                        before being replaced by the mode frequencies
%                        (default 4).
% - opt : Options that can be set by the user:
%           - opt.check : If set to 'true' (default) leads to the check
%                            of all the fields of opt.
%           - opt.init_mtd : Initialization method. This can be chosen
%                            either equal to 'K-models' (default) or to
%                            'K-means';
%           - opt.init_seqL : Length of the randomly generated sequences
%                             that are used to select the initial sequence
%                             of modes (default value 10);
%           - opt.maxiter : Maximum number of times that the method could
%                           be iterated (default value 100);
%           - opt.showCon : Set if the convergence of the algorithm has to
%                           be shown. If opt.showCon=false (default) the
%                           iterations terminates when one of the stopping
%                           criteria is satisfied, otherwise they end when
%                           the maximum number of iterations is reached.
%           - opt.analitic : Solve the problem using its analitic solution.
%           - opt.switchw : Weight for the penalty on the switches. If set
%                           to 'constant' te initially selected value
%                           const0.lambda0 will be always used as a weight
%                           for the switch. If 'frequencies' is selected
%                           the value of the weight is changed following
%                           the relative frequence of each mode.
%Outputs:
% - theta_opt : optimal parameters of the submodels.
% - s : optimal sequence of modes.
% - frequences : frequency of permanence in the same mode.
% - cost : cost of the optimal solution.
% - mean_filling : mean time required to fill the graph used to compute the
%                  maximum likelihood path.
% - mean_eval : mean time needed to evaluate the optimal path.

% Written by V.Breschi, September 2016


%% Check the inputs
if nargin<7
    opt.warn='on';
    opt.check=true;
    opt.init_mtd='K-models';
    opt.init_seqL=10;
    opt.maxiter=100;
    opt.showCon=false;
    opt.analitic=false;
    opt.switchw='frequences';
end

%Check if opt has all the required fields, otherwise set the missing ones
%to the default values.

if ~isfield(opt,'warn')
    opt.warn='on';
elseif strcmpi(opt.warn,'off')
    warning('No warning will be shown.');
    warning(opt.warn);
elseif ~strcmpi(opt.warn,'on') && ~strcmpi(opt.warn,'off')
    warning(['Improper choice for the checking option. '...
        'The default value is used.']);
    opt.warn='on';
end

if ~isfield(opt,'check')
    opt.check=true;
elseif ~isequal(opt.check,true) && ~isequal(opt.check,false)
    warning(['Improper choice for the checking option. '...
        'The default value is used.']);
    opt.check=true;
end


if opt.check
    if ~isfield(opt,'init_mtd')
        opt.init_mtd='K-models';
    else
        if ~strcmpi(opt.init_mtd,'K-models') && ~strcmpi(opt.init_mtd,'K-means')
            warning(['The method selected to initialize the sequence is not '...
                'considered in the solver. The deafult method is used.']);
            opt.init_mtd='K-models';
        end
    end
    
    if ~isfield(opt,'init_seqL')
        opt.init_seqL=10;
    else
        if opt.init_seqL<=0
            warning(['Invalid number of sequences to be generated to '...
                'initialize the mode sequence. The default value is used.']);
            opt.init_seqL=10;
        end
    end
    
    if ~isfield(opt,'maxiter')
        opt.maxiter=100;
    else
        if opt.maxiter<=0 || opt.maxiter>1e3
            warning(['Invalid maximum number of iterations. The default value ' ...
                'is used.']);
            opt.maxiter=100;
        end
    end
    
    if ~isfield(opt,'showCon')
        opt.showCon=false;
    else
        if ~isequal(opt.showCon,true) && ~isequal(opt.showCon,false)
            warning(['Improper choice for the convergence evaluation. '...
                'The default value is used.']);
            opt.showCon=false;
        end
    end
else
    warning('The fields of opt has not been checked.');
end

%Check the fields of cons0 and substitute the default value if needed.
if ~isfield(cons0,'lambda0')
    cons0.lambda0=0.9;
elseif cons0.lambda0<=0 || cons0.lambda0>=1
    warning(['The selected initial value for lambda is not correct. '...
        'It will be substituted with the default value.'])
    cons0.lambda0=0.9;
end


T=size(y,1); %Time horizon
p=size(y,2); %Dimension of the output
m=size(X,2); %Dimension of the regressor

rng('default');

%% Initialization

%Initialize mode frequences
frequences=cons0.lambda0*ones(K,1);

%Load the initial sequences that have to be avoided
load('s_initcritDWE.mat')
scrit=s;
clear s

tic
if opt.analitic==false
    f_reg=@(x,vary,varX,param)sum(f(x,vary,varX,param))+rgl.c*rgl.f(x,vary,varX,param);
    
    switch opt.init_mtd
        case 'K-means'
            
            %Initialize the sequence of states through K-means
            s=kmeans(X,K,'Replicates',100);
            
        case 'K-models'
            
            best_sinit=1e8;
            s=ones(T,1);
            for init_ind=1:opt.init_seqL
                
                %Generate a sequence of random states which has at least ten
                %equal states
                if init_ind==1
                    seq=zeros(T,opt.init_seqL);
                    for k=1:K
                        seq((((k-1)*(T/K))+1):k*(T/K),1)=k;
                    end
                    if seq(:,1)==scrit
                        indexes=randperm(T);
                        seq(:,1)=(seq(indexes,1));
                        
                    end
                else
                    indexes=randperm(T);
                    seq(:,init_ind)=(seq(indexes,1));
                end
                
                %Solve the problem for the considered sequence
                [theta_init]=solve_jump(p,m,y,X,K,param,seq(:,init_ind),f_reg);
                [opt_c,~,~]=costEvaluation(T,K,y,X,f,rgl,param,theta_init,seq(:,init_ind),frequences);
                
                if opt_c<best_sinit
                    best_sinit=opt_c;
                    s=seq(:,init_ind);
                end
            end
    end
    
    theta_opt=zeros(p,m,K);
    
    filling_matrix=zeros(opt.maxiter,1);
    evaluate_path=zeros(opt.maxiter,1);
    
    %% Solve learning problem
    switch opt.showCon
        % Use stop criteria
        case false
            iter=1;
            exit_flag=0;
            while  exit_flag==0
                s_prev=s;
                
                %% Step 1
                
                %Solve the problem for each sub-model with fixed state
                %sequence
                [theta_opt]=solve_jump(p,m,y,X,K,param,s,f_reg);
                
                
                switch opt.switchw
                    case 'constant'
                        frequences=cons0.lambda0*ones(K,1);
                    case 'frequences'
                        %Update the frequences of each mode after a minimum number
                        %of iterations
                        if iter>=cons0.min_iter
                            frequences=zeros(K,1);
                            
                            for ind=2:T
                                if s(ind-1)==s(ind)
                                    frequences(s(ind))=frequences(s(ind))+1;
                                end
                            end
                            
                            for k=1:K
                                frequences(k,:)=frequences(k,:)/(length(find(s(1:T-1)==k)));
                            end
                        end
                end
                
                %% Step 2
                
                %Compute the optimal path and the new mode sequence
                [l,time_filling]=filling_graph(T,y,X,K,f,param,theta_opt);
                filling_matrix(iter)=time_filling;
                [s,~,evaluate_path(iter)]=dp_path_mex(T,K,l,frequences);
                
                [opt_c,opt_models,opt_switch]=costEvaluation(T,K,y,X,f,rgl,param,theta_opt,s,frequences);
                
                %Update the exit_flag, that becomes true if convergence on the
                %mode sequence or maximum number of iterations is achieved
                if iter>cons0.min_iter && length(find(s==s_prev))==T
                    disp(iter)
                    exit_flag=1;
                elseif iter>=opt.maxiter
                    disp(iter)
                    exit_flag=1;
                else
                    iter=iter+1;
                end
            end
            %Reach the maximum number of iterations to show convergence
        case true
            opt_c=zeros(opt.maxiter,1);
            opt_models=zeros(opt.maxiter,1);
            opt_switch=zeros(opt.maxiter,1);
            for iter=1:opt.maxiter
                
                %% Step 1
                
                %Solve the problem for each sub-model
                [theta_opt]=solve_jump(p,m,y,X,K,param,s,f_reg);
                
                %Update the transition matrix after a minimum number of
                %iterations
                switch opt.switchw
                    case 'constant'
                        frequences=cons0.lambda0*ones(K,1);
                    case 'frequences'
                        if iter>=cons0.min_iter
                            frequences=zeros(K,1);
                            
                            for ind=2:T
                                if s(ind-1)==s(ind)
                                    frequences(s(ind))=frequences(s(ind))+1;
                                end
                            end
                            
                            for k=1:K
                                frequences(k,:)=frequences(k,:)/(length(find(s(1:T-1)==k)));
                            end
                        end
                end
                
                %% Step 2
                
                %Compute the optimal path and update mode sequence
                [l,time_filling]=filling_graph(T,y,X,K,f,param,theta_opt);
                filling_matrix(iter)=time_filling;
                [s,~,evaluate_path(iter)]=dp_path_mex(T,K,l,frequences);
                
                [opt_c(iter),opt_models(iter),opt_switch(iter)]=costEvaluation(T,K,y,X,f,rgl,param,theta_opt,s,frequences);
            end
    end
    
    cost={opt_c,opt_models,opt_switch};
    mean_filling=mean(filling_matrix);
    mean_eval=mean(evaluate_path);
    
    if strcmp(opt.switchw,'frequences')
        frequences=zeros(K,1);
        
        for ind=2:T
            if s(ind-1)==s(ind)
                frequences(s(ind))=frequences(s(ind))+1;
            end
        end
        
        for k=1:K
            frequences(k)=frequences(k)/(length(find(s==k)));
        end
    end
else
    %% Initialization
    
    %Initialize mode frequences
    frequences=cons0.lambda0*ones(K,1);
    
    switch opt.init_mtd
        case 'K-means'
            
            %Initialize the sequence of states through K-means
            s=kmeans(X,K,'Replicates',100);
            
        case 'K-models'
            
            best_sinit=1e8;
            s=ones(T,1);
            for init_ind=1:opt.init_seqL
                
                if init_ind==1
                    seq=zeros(T,opt.init_seqL);
                    for k=1:K
                        seq((((k-1)*(T/K))+1):k*(T/K),1)=k;
                    end
                    if seq(:,1)==scrit
                        indexes=randperm(T);
                        seq(:,1)=(seq(indexes,1));
                        
                    end
                else
                    indexes=randperm(T);
                    seq(:,init_ind)=(seq(indexes,1));
                end
                
                %Solve the problem for the considered sequence
                [theta_init]=solve_analit_mex(p,m,y,X,K,seq(:,init_ind),rgl.c);
                [opt_c,~,~]=costEvaluation2_mex(T,K,y,X,theta_init,seq(:,init_ind),frequences,rgl.c);
                
                if opt_c<best_sinit
                    best_sinit=opt_c;
                    s=seq(:,init_ind);
                end
            end
    end
    
    theta_opt=zeros(p,m,K);
    
    filling_matrix=zeros(opt.maxiter,1);
    evaluate_path=zeros(opt.maxiter,1);
    
    switch opt.showCon
        case false
            iter=1;
            exit_flag=0;
            while  exit_flag==0
                s_prev=s;
                
                %% Step 1
                
                %Solve the problem for each sub-model
                [theta_opt]=solve_analit_mex(p,m,y,X,K,s,rgl.c);
                
                
                switch opt.switchw
                    case 'constant'
                        frequences=cons0.lambda0*ones(K,1);
                    case 'frequences'
                        %Update the transition matrix after a minimum number of
                        %iterations
                        if iter>=cons0.min_iter
                            frequences=zeros(K,1);
                            
                            for ind=2:T
                                if s(ind-1)==s(ind)
                                    frequences(s(ind))=frequences(s(ind))+1;
                                end
                            end
                            
                            for k=1:K
                                frequences(k,:)=frequences(k,:)/(length(find(s(1:T-1)==k)));
                            end
                        end
                end
                
                %% Step 2
                
                %Compute the optimal path and compute the new sequence
                [l,time_filling]=filling_graph3_mex(T,y,X,K,theta_opt);
                filling_matrix(iter)=time_filling;
                [s,~,evaluate_path(iter)]=dp_path_mex(T,K,l,frequences);
                
                [opt_c,opt_models,opt_switch]=costEvaluation2_mex(T,K,y,X,theta_opt,s,frequences,rgl.c);
                
                %Update the exit_flag, that becomes true if convergence on the
                %mode sequence or maximum number of iterations is achieved
                if iter>cons0.min_iter && length(find(s==s_prev))==T
                    disp(iter)
                    exit_flag=1;
                elseif iter>=opt.maxiter
                    exit_flag=1;
                else
                    iter=iter+1;
                end
            end
        case true
            opt_c=zeros(opt.maxiter,1);
            opt_models=zeros(opt.maxiter,1);
            opt_switch=zeros(opt.maxiter,1);
            for iter=1:opt.maxiter
                
                %% Step 1
                
                %Solve the problem for each sub-model
                [theta_opt]=solve_analit_mex(p,m,y,X,K,s,rgl.c);
                
                %Update the transition matrix after a minimum number of
                %iterations
                if iter>=cons0.min_iter
                    frequences=zeros(K,1);
                    
                    for ind=2:T
                        if s(ind-1)==s(ind)
                            frequences(s(ind))=frequences(s(ind))+1;
                        end
                    end
                    
                    for k=1:K
                        frequences(k,:)=frequences(k,:)/(length(find(s(1:T-1)==k)));
                    end
                end
                
                %% Step 2
                
                %Compute the optimal path and update the mode sequence
                [l,time_filling]=filling_graph3_mex(T,y,X,K,theta_opt);
                filling_matrix(iter)=time_filling;
                [s,~,evaluate_path(iter)]=dp_path_mex(T,K,l,frequences);
                [opt_c1,opt_models1,opt_switch1]=costEvaluation2(T,K,y,X,theta_opt,s,frequences,rgl.c);
                
                opt_c(iter)=opt_c1;
                opt_models(iter)=opt_models1;
                opt_switch(iter)=opt_switch1;
            end
    end
    
    cost={opt_c,opt_models,opt_switch};
    mean_filling=mean(filling_matrix);
    mean_eval=mean(evaluate_path);
    
    if strcmp(opt.switchw,'frequences')
        frequences=zeros(K,1);
        for ind=2:T
            if s(ind-1)==s(ind)
                frequences(s(ind))=frequences(s(ind))+1;
            end
        end
        
        for k=1:K
            frequences(k)=frequences(k)/(length(find(s==k)));
        end
    end
end
eval_time=toc; %Evaluate computational time required to learn the model