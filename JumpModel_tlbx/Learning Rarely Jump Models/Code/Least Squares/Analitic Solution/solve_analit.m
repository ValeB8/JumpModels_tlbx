function[x_opt]=solve_analit(p,m,y,X,K,s,gamma)
%Function that is used to solve the jump model problem based on the
%provided function f analitically.
%Inputs:
%   - (p,m) : dimension of the variable to be optimized;
%   - y : output samples;
%   - X : regressor samples;
%   - K : number of sub-models;
%   - param : structure containing all the parameters that depends on the
%             output and the regressor.
%   - s : sequence of modes.
%Output: optimal value of the variable of interest.

%Written by V.Breschi, September 2016

% %To compile the code:
% 
% fun='solve_analit';
% Cfg = coder.config('mex');
% Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
% Cfg.IntegrityChecks = false;
% Cfg.ResponsivenessChecks = false;
% Cfg.SaturateOnIntegerOverflow = false;
% p = coder.typeof(0,[1,1]);
% m = coder.typeof(0,[1,1]);
% y= coder.typeof(0,[inf,inf]);
% X= coder.typeof(0,[inf,inf]);
% K= coder.typeof(0,[1,1]);
% s= coder.typeof(0,[inf,inf]);
% gamma = coder.typeof(0,[1,1]);
% outputFileName = [fun '_mex'];
% codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{p, m, y, X, K, s, gamma},...
%     '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));


x_opt=zeros(p,m,K);

for k=1:K
    
    index_k=find(s==k);
    Y=y(index_k,:);
    x=X(index_k,:);
    if length(index_k)==0 %if no point is associated with a mode
        x_opt(:,:,k)=10^9;
    else %otherwise
        x_opt(:,:,k)=((x'*x)+gamma*eye(size(x,2)))\(x'*Y);
    end
    
    index_k=[];
    Y=[];
    x=[];
end