function[l,time_filling]=filling_graphClass(T,X,K,f,param,theta)
%Function used to create the graph used to evaluate the maximum likelihood path.
%Inputs:
% - T : time horizon (number of samples).
% - y : output samples.
% - X : regressor samples.
% - K : number of sub-models.
% - f : selected loss function.
% - param : parameters of the selected loss function.
% - theta : optimal parameters of the models.
%Outputs:
% - l : value of the loss function for each sample and each mode.
% - time_filling : time required to evaluate the cost for each instant and each mode.

%Written by V.Breschi, September 2016

l=zeros(K,T);

tic
for t=1:T
    for k=1:K
        l(k,t)=f(theta(:,:,k),sign(theta(:,:,k)*X(t,:)'),X(t,:),param); 
    end
end
time_filling=toc;