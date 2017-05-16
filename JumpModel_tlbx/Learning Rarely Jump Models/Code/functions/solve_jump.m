function[x_opt]=solve_jump(p,m,y,X,K,param,s,f_reg)
%Function that is used to solve the jump model problem based on the
%provided function f.
%Inputs:
%   - (p,m) : dimension of the variable to be optimized;
%   - y : output samples;
%   - X : regressor samples;
%   - K : number of sub-models;
%   - f_reg : function to be optimized;
%   - param : structure containing all the parameters that depends on the
%             output and the regressor.
%   - s : sequence of modes.
%Output: optimal value of the variable of interest.

%Written by V.Breschi, September 2016

x_opt=zeros(p,m,K);

for k=1:K
    
    if length(find(s==k))==0
        x_opt(:,:,k)=10^9;
    else
        cvx_begin
        cvx_precision best
            variable x(p,m)
            minimize(f_reg(x,y(s==k,:),X(s==k,:),param))
        cvx_end
        
        x_opt(:,:,k)=x;
    end
    
    clear x
end