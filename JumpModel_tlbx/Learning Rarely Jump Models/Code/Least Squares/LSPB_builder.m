function[X_model,param2,f2,rgl]=LSPB_builder(T,model,X,regularization,cons_rgl)
%Function used to built the regression problem.
%Inputs:
% - T : time horizon (number of samples).
% - model : decide the model to construct among the following options
%           - affine : the new regressor is [X ones(T,1)];
%           - linear : the regressor is not modified;
%           - static : the entry X is supposed to be empty and the
%                      regressor is imposed equal to ones(T,1);
% - X : not modified regressor; 
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
% - param2 : parameters needed to evaluate the selected loss function f2.
% - f2 : selected loss function.
% - rgl : chosen regularization term.

%Written by V.Breschi, September 2016

%% Modify the regressor accounting for the kind of model
if strcmpi(model,'static')
    if ~isempty(X)
        warning(['The selected kind of model will be constructed not '...
            'using the provided regressor']);
    end
    X_model=ones(T,1);
elseif strcmpi(model,'affine')
    X_model=[X ones(T,1)];
elseif strcmpi(model,'linear')
    X_model=X;
else
    error(['The selected kind of model is not among the possible models '... 
        'the solver accounts for']);
end

%% Define cost function and regularization

param2=cell([2,1]);

param2{1}=@(y,Xop) Xop;
param2{2}=@(y,Xop) y;

f2=@(x,y,Xop,param2) (x*param2{1}(y,Xop)-param2{2}(y,Xop)).^2;


if regularization==0
    if ~isempty(cons_rgl)
        warning(['The selected weight for the regularization term will '...
            'not be used']);
    end
    rgl.f=@(x,y,Xop,param) 0;
    rgl.c=0;
elseif regularization==1
    rgl.f=@(x,y,Xop,param) norm(x,1);
    rgl.c=cons_rgl;
elseif regularization==2
    rgl.f=@(x,y,Xop,param) x^2;
    rgl.c=cons_rgl;
elseif regularization==3
    rgl.f=@(x,y,Xop,param) cons_rgl*norm(x,1)+(1-cons_rgl)*norm(x,2);
    rgl.c=1;
else
    error(['The selected regularization strategy is not accounted for by '... 
        'the solver']);
end