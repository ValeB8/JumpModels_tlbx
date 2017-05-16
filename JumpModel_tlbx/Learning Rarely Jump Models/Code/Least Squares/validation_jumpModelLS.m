function[path_val,y_est,PerformanceIndex]=validation_jumpModelLS(K,opt,f,param,theta,lambda,yval,Xval,uval)
%Function used to validate the model obtained through the iterations of the
%jump modelling method.
%Inputs:
% - K : number of sub-models.
% - opt : indicates the chosen modelling strategy and, conseuquently, the
%         model that has to be simulated.
% - f : chosen loss function
% - param : parameters of the chosen loss function.
% - theta : optimal parameters of the model.
% - lambda : weights for the mode transitions.
% - yval : output of the validation dataset.
% - Xval : regressor of the validation set.
% - uval : exogenous input in the validation dataset.
%Outputs:
% - path_val : mode sequence obtained for the validation dataset.
% - y_est : cell containing the outpus obtained with the model.
% - PerformanceIndex : cell containing the value of the index
%                      used to evaluate the performance of the model.

%Written by V.Breschi, September 2016

Tval=size(yval,1);
p=size(yval,2);

%% Check the inputs
if ~isfield(opt,'model')
    error('The model to be reconstructed has to be provided');
else
    if strcmpi(opt.model,'affine')
        Phival=[Xval ones(Tval,1)];
    elseif strcmpi(opt.model,'static')
        if nargin>7
            if nargin<9
                if ~isempty(Xval)
                    warning(['The provided regressor is not be used and it will'...
                        'be replaced with a vector of ones']);
                end
                if nargin==9
                    if ~isempty(Xval)
                        warning(['The provided regressor is not be used and it will'...
                            'be replaced with a vector of ones']);
                    end
                    if ~isempty(uval)
                        warning('The provided input is not be used');
                    end
                end
            end
        end
        Phival=ones(Tval,1);
    elseif strcmpi(opt.model,'linear')
        Phival=Xval;
    else
        warning(['The selected kind of model is ot among the ones'...
            'considered by the solver. The model is supposed to' ...
            'be linear']);
        opt.model='linear';
        Phival=Xval;
    end
end

if ~strcmpi(opt.model,'static')
    if ~isfield(opt,'delay')
        error(['The delay has to be specified to built the regressor in'...
            'the open loop simulation of the system']);
    elseif opt.delay<0
        error('The provided delay is not correct');
    end
end

if ~strcmpi(opt.model,'static')
    if ~isfield(opt,'autonomous')
        if isempty(uval) || nargin<9
            warning(['The system is supposed to be autonomous as no input'...
                'is provided.']);
            opt.autonomous=true;
        else
            warning(['The system is supposed to be driven by an exogenous'...
                'input.']);
            opt.autonomous=false;
        end
    else
        if isequal(opt.autonomous,true) && nargin<9
            error('The input needed to simulate the system is not provided');
        end
    end
end

%% Valiate the model

PerformanceIndex=zeros(p,1);
y_est=zeros(Tval,p);

%Compute the maximum likely path through dynamic programming
[l,~]=filling_graph(Tval,yval,Phival,K,f,param,theta);
[path_val,~,~]=dp_path(Tval,K,l,lambda);

%One-step ahead prediction

for ind=1:Tval
    y_est(ind,:)=theta(:,:,path_val(ind))*Phival(ind,:)';
end

for ind=1:p
    PerformanceIndex(ind)=max(1-(norm(y_est(:,ind)-yval(:,ind)))/(norm(yval(:,ind)-mean(yval(:,ind)))),0);
end