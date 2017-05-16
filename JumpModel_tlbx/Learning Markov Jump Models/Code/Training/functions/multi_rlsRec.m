function [w,delta,iR]=multi_rlsRec(Y,X,s,lambda,w0,iR)
%#codegen
% Inverse QR method for Multi-model Recursive Least Squares.
%
% [w,delta]=rlsiqr(Y,X,s,lambda) identifies a set 'w' of 's' linear models
% and clusters the data (Y,X) into subsets (Yi,Xi), i=1,...,s, such that
% Yi=Xi*w(:,:,i). The output matrix 'delta' identifies the subsets Xi=X(delta(:,i)).
%
% Recursive least-squares are used to update the vectors of coefficients.
%
% Y      = output data
% X      = regressor data
% s      = desired number of modes.
% lambda = forgetting factor (0<<lambda<=1)
% w0     = initial value for the parameter matrices.
% iR     = initial value for the matrix iR.
%
% The RLS update algorithm is based on the recursive update of the inverse R
% matrix of a QR factorization, following the algorithm in [1].
%
% [1] S.T. Alexander and A.L. Ghirnikar, "A Method for Recursive
% Least Squares Filtering Based Upon an Inverse QR Decomposition", IEEE
% Trans. Signal Processing, vol. 41, no. 1, January 1993, pp. 20-30.
%
% (C) 2014 by A. Bemporad, December 3, 2014
% Modified by V.Breschi, August 2, 2016

% To compile the code:
%
% fun='multi_rlsRec';
% Cfg = coder.config('mex');
% Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
% Cfg.IntegrityChecks = false;
% Cfg.ResponsivenessChecks = false;
% Cfg.SaturateOnIntegerOverflow = false;
% Y = coder.typeof(0,[inf,inf]);
% X = coder.typeof(0,[inf,inf]);
% s = coder.typeof(0,[1,1]);
% lambda = coder.typeof(0,[1,1]);
% w0 = coder.typeof(0,[inf,inf,inf]);
% iR = coder.typeof(0,[inf,inf,inf,inf]);
% outputFileName = [fun '_mex'];
% codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{Y, X, s, lambda,w0,iR},...
%     '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));


[Nf,N]=size(X); % N = # parameters per output, Nf  = # data to fit
nd=size(Y,2);

if size(Y,1)~=Nf
    error('Y and X must have the same number of rows');
end

delta=zeros(Nf,s); % Indicator variables

w=zeros(N,nd,s); % One set of parameters per dimension of vector d and per mode

for k=1:s
    w(:,:,k)=w0(:,:,k);
end

lam2=1/sqrt(lambda);

    
for n=1:Nf % go through all data
    e=zeros(nd,s);
  
    for h=1:nd % go through all outputs
            
        x=X(n,:)'; % get current sample of regressor
        y=Y(n,h)'; % get current sample of data point to fit
            
        for k=1:s % go through all modes
            e(h,k)=y-w(:,h,k)'*x;  % local fit error at step n on output h using model k
        end
    end
        
    % Pick up "best" mode
    err=sum(e.*e,1); % vector of dimension s with norms^2 of y(n)-w(:,:,k)'*x, k=1,...,s
    [~,kmin]=min(err);
    delta(n,kmin)=1;
        
    % Only update estimate for mode kmin
        
    for h=1:nd % go through all outputs
        x=X(n,:)'; % get current sample of regressor
            
        u=zeros(N,1);
        b=1;
        for i=1:N
            a=lam2*iR(i,1:i,h,kmin)*x(1:i);
            b1=b;
            b=sqrt(b^2+a^2);
            ss=a/b;
            c=b1/b;
            for j=1:i
                rij1=iR(i,j,h,kmin);
                iR(i,j,h,kmin)=lam2*c*iR(i,j,h,kmin)-ss*u(j);
                u(j)=c*u(j)+lam2*ss*rij1;
            end
        end
        z=e(h,kmin)/b;
        for i=1:N
            w(i,h,kmin)=w(i,h,kmin)+z*u(i);
        end

    end
end
end