function[path_DP,y_est,PerformanceIndex]=validation_jumpModelclass(K,f,param,theta,lambda,yval,Xval,hval)
%Function used to validate the model obtained through the iterations of the
%jump modelling method.
%Inputs:
% - K : number of sub-models.
% - f : chosen loss function.
% - param : parameters of the chosen loss function.
% - theta : optimal parameters of the model.
% - lambda : weights for the mode transitions.
% - yval : output of the validation dataset.
% - Xval : regressor of the validation set.
% - hval : real mode sequence.
%Outputs:
% - path_val : mode sequence obtained for the validation dataset.
% - y_est : cell containing the outpus obtained with the model.
% - PerformanceIndex : cell containing the value of the index
%                      used to evaluate the performance of the model.

%Written by V.Breschi, September 2016

Tval=size(yval,1);

y_est=zeros(Tval,1);

Phival=[Xval -ones(Tval,1)];

%Compute the maximum likely path through dynamic programming
[l,~]=filling_graphClass(Tval,Phival,K,f,param,theta);
[path_DP,~,~]=dp_path(Tval,K,l,lambda);

%Determine if the estimated modes are the same as the true one or they are
%"inverted".
path_corr=zeros(Tval,1);
for ind=1:Tval
    if path_DP(ind)==1
        path_corr(ind)=2;
    elseif path_DP(ind)==2
        path_corr(ind)=1;
    end
end

dp_mode=length(find(hval==path_DP));
inv_mode=length(find(hval==path_corr));

%Consider, as an indicator of the performance of the method, the number of
%points associated to the wrong mode.


%Label prediction 
for ind=1:Tval
     y_est(ind,:)=sign(theta(:,:,path_DP(ind))*Phival(ind,:)');
end

PerformanceIndex(2)=100*(Tval-length(find(y_est==yval)))/Tval;

if dp_mode>=inv_mode
    PerformanceIndex(1)=100*(Tval-dp_mode)/Tval;
else
warning(['The estimated mode 1 corresponds to the true mode 2 and'...
    'the estimated mode 2 corresponds to the true mode 1'...
             'for the sake of validation the modes are inverted']);
     PerformanceIndex(1)=100*(Tval-inv_mode)/Tval;
end