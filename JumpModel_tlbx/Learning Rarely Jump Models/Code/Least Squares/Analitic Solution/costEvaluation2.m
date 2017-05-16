function [optimal_cost,optimal_models,optimal_switch]=costEvaluation2(T,K,y,X,theta,s,lambda,gamma)
%Function used to assess the value of the functional.
%Inputs:
% - T : time horizon (number of samples).
% - K : number of sud-models.
% - y : output samples.
% - X : regressor samples.
% - theta : vector of the optimization variables.
% - s : optimal sequence of modes.
% - lambda : constant weighting the mode transition.
% - gamma: regularization parameter.
%Outputs:
% - optimal_cost : optimal global cost;
% - optimal_models : optimal model fitting cost;
% - optimal_switch : optimal cost of the selected mode sequence.

%Written by v.Breschi, September 2016

% %To compile the code:
% 
% fun='costEvaluation2';
% Cfg = coder.config('mex');
% Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
% Cfg.IntegrityChecks = false;
% Cfg.ResponsivenessChecks = false;
% Cfg.SaturateOnIntegerOverflow = false;
% T = coder.typeof(0,[1,1]);
% K = coder.typeof(0,[1,1]);
% y= coder.typeof(0,[inf,inf]);
% X= coder.typeof(0,[inf,inf]);
% theta= coder.typeof(0,[inf,inf,inf]);
% s= coder.typeof(0,[inf,inf]);
% lambda = coder.typeof(0,[inf,1]);
% gamma = coder.typeof(0,[1,1]);
% outputFileName = [fun '_mex'];
% codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{T, K, y, X, theta, s, lambda, gamma},...
%     '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));


L=zeros(T,1);

%Compute the value of the optimum for each point
for t=1:T
    L(t)=(y(t,:)-X(t,:)*squeeze(theta(:,:,s(t)))')^2;
end

e=zeros(T,1);
for t=2:T
    if s(t-1)==s(t)
        e(t)=0;
    else
        for k=1:K
            if s(t-1)==k
                e(t)=lambda(k);
            end
        end
    end
end

rgl_cost=gamma*sum(theta.^2);

optimal_models=(1/T)*sum(L)+sum(rgl_cost);
optimal_switch=sum(e);
optimal_cost=optimal_models+optimal_switch;