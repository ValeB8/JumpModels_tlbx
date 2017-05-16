function [optimal_cost,optimal_models,optimal_switch]=costEvaluation(T,K,y,X,f,rgl,param,theta,s,lambda)
%Function used to assess the value of the functional.
%Inputs:
% - T : time horizon (number of samples).
% - K : number of sud-models.
% - y : output samples.
% - X : regressor samples.
% - f : loss function (symbolic function).
% - rgl : regularization term
%           - rgl.c : constant associated to the regularization term;
%           - rgl.f : chosen regularization term.
% - param : parameters characterizing the loss function f.
% - theta : vector of the optimization variables.
% - s : optimal sequence of modes.
% - lambda : constant weighting the mode transition.
%Outputs:
% - optimal_cost : optimal global cost;
% - optimal_models : optimal model fitting cost;
% - optimal_switch : optimal cost of the selected mode sequence.

%Written by v.Breschi, September 2016

L=zeros(T,1);

%Compute the value of the optimum for each point
for t=1:T
    L(t)=f(theta(:,:,s(t)),y(t,:),X(t,:),param);
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

rgl_cost=zeros(K,1);
for k=1:K
    rgl_cost(k)=rgl.c*rgl.f(theta(:,:,k),y,X,param);
end

optimal_models=(1/T)*sum(L)+sum(rgl_cost);
optimal_switch=sum(e);
optimal_cost=optimal_models+optimal_switch;