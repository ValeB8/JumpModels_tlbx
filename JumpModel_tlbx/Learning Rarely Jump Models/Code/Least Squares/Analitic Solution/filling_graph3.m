function[l,time_filling]=filling_graph3(T,y,X,K,theta)
%Function used to create the graph used to evaluate the maximum likelihood path.
%Inputs:
% - T : time horizon (number of samples).
% - y : output samples.
% - X : regressor samples.
% - K : number of sub-models.
% - theta : optimal parameters of the models.
%Outputs:
% - l : value of the loss function for each sample and each mode.
% - time_filling : time required to evaluate the cost for each instant and each mode.

%Written by V.Breschi, September 2016

% % To compile
% fun='filling_graph3';
% Cfg = coder.config('mex');
% Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
% Cfg.IntegrityChecks = false;
% Cfg.ResponsivenessChecks = false;
% Cfg.SaturateOnIntegerOverflow = false;
% T = coder.typeof(0,[1,1]);
% y= coder.typeof(0,[inf,inf]);
% X= coder.typeof(0,[inf,inf]);
% K= coder.typeof(0,[1,1]);
% theta= coder.typeof(0,[inf,inf,inf]);
% outputFileName = [fun '_mex'];
% codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{T, y, X, K, theta},...
%     '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

coder.extrinsic('tic')
coder.extrinsic('toc')

l=zeros(K,T);

tic
for t=1:T
    for k=1:K
        l(k,t)=(y(t,:)-X(t,:)*theta(:,:,k))*(y(t,:)-X(t,:)*theta(:,:,k))';
    end
end
time_filling=toc;