function [curr_mode,prob,alphaup]=probabilistic_clusteringRec(Y,X,s,w,variance,invS,alpha_update,Pi)
% Probabilistic clustering approach described in [1].
%
% [1] V.Breschi, D.Piga, A.Bemporad, S.Boyd, Learning Jump Models.
%
% Inputs: 
% - Y : output data;
% - X : regressor data;
% - s : desired number of modes;
% - w : estimated parameter matrices;
% - variance : batch variance for the simulation error;
% - invS : inverse of variance;
% - Pi : transition matrix;
% - alpha_update : predicted mode probabilities.
%Outputs: 
% - curr_mode : assigned mode for each sample;
% - prob : probability of each mode;
% - alphaup : predicted probability for each mode.

% (C) V.Breschi, March 2016

% To compile the code:
%
% fun='probabilistic_clusteringRec';
% Cfg = coder.config('mex');
% Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
% Cfg.IntegrityChecks = false;
% Cfg.ResponsivenessChecks = false;
% Cfg.SaturateOnIntegerOverflow = false;
% Y = coder.typeof(0,[inf,inf]);
% X = coder.typeof(0,[inf,inf]);
% s = coder.typeof(0,[1,1]);
% w = coder.typeof(0,[inf,inf,inf]);
% variance = coder.typeof(0,[inf,inf]);
% invS = coder.typeof(0,[inf,inf]);
% alpha_update =coder.typeof(0,[inf,inf]);
% Pi = coder.typeof(0,[inf,inf]);
% outputFileName = [fun '_mex'];
% codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{Y, X, s, w, variance,invS,alpha_update, Pi},...
%     '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

[Nf,~]=size(X); % N = # parameters per output, Nf  = # data to fit

nd=size(Y,2);

if size(Y,1)~=Nf
    error('Y and X must have the same number of rows');
end

curr_mode=zeros(Nf,1); %Assigned cluster
prob=zeros(Nf,s); %Probabilities at each instant

%Define the variance matrix (modified in order to be invertible)
S=variance;

for n=1:Nf % go through all data
    e=zeros(nd,s); 
    like=zeros(s,1);
       
    for h=1:nd % go through all outputs
        
        x=X(n,:)'; % get current sample of regressor
        y=Y(n,h)'; % get current sample of data point to fit
        
        for k=1:s % go through all modes
            e(h,k)=y-w(:,h,k)'*x;  % local fit error at step n on output h using model k
        end
    end
    
    for k=1:s
        e2=(e(:,k))'*(invS)*(e(:,k)); % vector of dimension s with normalized norms^2 of y(n)-w(:,:,k)'*x, k=1,...,s
        like(k)=(1/(sqrt(det(S))*(2*pi)^(nd/2)))*exp(-0.5*e2);
    end

    common_den=(like)'*alpha_update;
    
    alpha=zeros(s,1);
    for k=1:s
        alpha(k)=like(k)*alpha_update(k)/common_den;
    end
    
    for k=1:s
        alpha_update(k)=alpha'*Pi(:,k);
    end    
    
    %Consider the most probable mode
    [~,kmax]=max(alpha);
    
    curr_mode(n)=kmax;
    prob(n,:)=alpha'; 
end

alphaup=alpha_update;