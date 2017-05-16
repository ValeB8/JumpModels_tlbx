function[theta,delta_pre,delta_post,transition_init,transition,var_error,iR,alpha_up]=MJLSid(niter,K,Y,X,lambda)
%Function used to learn a MJLS using the method proposed in [1].
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
%Inputs:
% - niter : number of iterations used to refine the parameters' estimates;
% - K : number of modes;
% - Y : output vector (N x p);
% - X : regressor (N x p x d);
% - lambda : forgetting factor (0,1].
%Outputs:
% - theta : estimated parameters for each mode (m x K);
% - delta_pre : estimated mode sequence before refinement (N x K); 
% - delta_post : estimated mode sequence after refinement (N x K);
% - transition_init : estimated transition matrix, before refinement (K x K);
% - transition : estimated transition matrix, after refinement (K x K);
% - var_error : sampled error variance (p x p);
% - iR : last computed matrix in the RLS scheme (m x m) - for online learning;
% - alphaup : predicted probabilities for sample N+1 (K x 1) - for online
%             learning.

% (C) Written by V.Breschi, September 2016

N=size(Y,1); % Number of samples
p=size(Y,2); % Output dimension

%% (1) Compute parameters' estimates, perform initial mode assignement and estimate transition matrix

%compute parameters' estimates and perform assignement
[theta,delta_pre,iR]=multi_rls_mex(Y,X,K,lambda,niter+1);

curr_mode=zeros(N,1);
curr_mode(1)=find(delta_pre(1,:)==1);

%Initialize the transition matrix
transition_init=zeros(K,K);

for n=2:N
    curr_mode(n)=find(delta_pre(n,:)==1); 
    for k1=1:K
        for k2=1:K
            if curr_mode(n-1)==k1 && curr_mode(n)==k2
                transition_init(k1,k2)=transition_init(k1,k2)+1;
            end
        end
    end
end

transition_init(curr_mode(end),curr_mode(end))=transition_init(curr_mode(end),curr_mode(end))+1;

for k=1:K
    transition_init(k,:)=transition_init(k,:)/(length(find(curr_mode==k)));
end

%% (2) Refine the computed transition matrix

%Compute sampled error variance
err=zeros(N,p);
summ_elem=zeros(p,p);

 for n=1:N
     err(n,:)=Y(n,:)-X(n,:,:)*theta(:,:,curr_mode(n));
     summ_elem=summ_elem+err(n,:)'*err(n,:);
 end

var_error=(1/(N-1))*summ_elem; % sampled error variance

alpha_update=(1/K)*ones(K,1); % initial probability for each mode

disp('Refine the estimate of the transition matrix')
[curr_mode2,~,alpha_up]=probabilistic_clustering_mex(Y,X,K,theta,var_error,alpha_update,transition_init);

delta_post=zeros(N,K);
delta_post(1,curr_mode2(1))=1;

transition=zeros(K,K);

for n=2:N
    delta_post(n,curr_mode2(n))=1;
    for k1=1:K
        for k2=1:K
            if curr_mode2(n-1)==k1 && curr_mode2(n)==k2
                transition(k1,k2)=transition(k1,k2)+1;
            end
        end
    end
end

transition(curr_mode2(end),curr_mode2(end))=transition(curr_mode2(end),curr_mode2(end))+1;

for k=1:K
    transition(k,:)=transition(k,:)/(length(find(curr_mode2==k)));
end
end