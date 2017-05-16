function[s,V,time_path]=dp_path(T,K,l,lambda)
%Function used to evaluate the maximum likelihood path through dynamic
%programming.
%Inputs:
% - T : time horizon (number of samples).
% - K : number of sub-models.
% - l : value of the loss function computed for each data point and each of
%       the possible submodels.
% - lambda : weights associated to the change of mode (Kx1 vector).
%Outputs:
% - s : maximum likelihood path.
% - V : value of the functional at each time step (excluding the
%       regularization term).
% - time_path : time required to compute the optimal path. 

%Written by V.Breschi, September 2016

% To compile the code:
% 
% fun='dp_path';
% Cfg = coder.config('mex');
% Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
% Cfg.IntegrityChecks = false;
% Cfg.ResponsivenessChecks = false;
% Cfg.SaturateOnIntegerOverflow = false;
% T = coder.typeof(0,[1,1]);
% K = coder.typeof(0,[1,1]);
% l = coder.typeof(0,[inf,inf]);
% lambda = coder.typeof(0,[inf,inf]);
% outputFileName = [fun '_mex'];
% codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{T, K, l, lambda},...
%     '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

coder.extrinsic('tic')
coder.extrinsic('toc')

V=zeros(K,T);

V(:,T)=l(:,T);
s=zeros(T,1);

%tic
for t=T-1:-1:1
    for k=1:K
        e=ones(K,1);
        e(k)=0;
        v=V(:,t+1)+lambda(k)*e;
        V(k,t)=l(k,t)+min(v);
    end
end

for t=1:T
    ml_mode=find(V(:,t)==min(V(:,t)));
    if length(ml_mode)>1
        ml_mode=ml_mode(1);
    end
    s(t)=ml_mode;
end
%time_path=toc;
time_path=0;