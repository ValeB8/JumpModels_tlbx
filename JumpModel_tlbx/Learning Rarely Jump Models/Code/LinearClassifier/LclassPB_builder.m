function[X_model,param2,f2,rgl]=LclassPB_builder(T,X,regularization,cons_rgl)
%Function used to built the regression problem.
%Inputs:
% - T : time horizon (number of samples).
% - regularization : regularization term selected among the following
%                    options
%                    - 0 : No regularization (the last input is supposed to
%                          be empty in this case;
%                    - 1 : norm 1 regularization;
%                    - 2 : norm 2 regularization.
%                    - 3 : elastic net.
% - cons_rgl : weight for the regularization term.
%Outputs:
% - X_model : regressor vector as chosen with model.
% - m : dimension of the regressor.
% - param2 : parameters needed to evaluate the selected loss function f2.
% - f2 : selected loss function.
% - rgl : chosen regularization term.

%Written by V.Breschi, September 2016

X_model=[X -ones(T,1)];

param2=cell([2,1]);

param2{1}=@(y,Xop) Xop';
param2{2}=@(y,Xop) y;

f2=@(x,y,Xop,param2) max(0,1-param2{2}(y,Xop).*(x*param2{1}(y,Xop))');

if regularization==0
    if ~isempty(cons_rgl)
        warning(['The selected weight for the regularization term will'...
            'not be used']);
    end
    rgl.f=@(x,y,Xop,param) 0;
    rgl.c=0;
elseif regularization==1
    rgl.f=@(x,y,Xop,param) norm(x,1);
    rgl.c=cons_rgl;
elseif regularization==2
    rgl.f=@(x,y,Xop,param) norm(x,2);
    rgl.c=cons_rgl;
elseif regularization==3
    rgl.f=@(x,y,Xop,param) cons_rgl*norm(x,1)+(1-cons_rgl)*norm(x,2);
    rgl.c=1;
else
    error(['The selected regularization strategy is not accounted for by'... 
        'the solver']);
end