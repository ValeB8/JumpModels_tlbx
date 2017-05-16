function[y,yval,X,Xval,h,hval]=classJM_Data(N,Nval,p,seeds,mean,std,P)
%Generate the data belonging to two classes in the p-dimensional space, with 
%clusters centroids chainging with time. The costruction of the dataset is  
%such that the classes might be unbalanced.
%Inputs:
% - N : number of data of the training set.
% - Nval : number of samples of the validation set.
% - p : dimension of the regressor.
% - seeds : structure containing the seeds associated to the random number
%           generators
%           - seeds.rand : seed associated to the generators of random
%                          number from a uniform distribution; 
%           - seeds.randn : seed associated to the generators of random
%                           number from a normal distribution.
% - mean : cell containing the centroids of each class for each mode.
% - std : cell containing the standard deviation of the clusters of points.    
%--Both mean and std has the same dimension as the number of possible modes--        
% - P : transition matrix associated to the Markov chain governing the
%       jumps between modes.
%Outputs:
% - y : labels for the training set.
% - yval : labels for the validation set.
% - X : regressor of the training set.
% - Xval : regressor of the validation set.
% - h : mode sequence for the training set.
% - hval : mode sequence for the validation set.

%Written by V.Breschi, September 2016

if ~isempty(seeds)
    if ~isfield(seeds,'rand')
        warning(['The seed for rand() has not been set.'...
                'It is set equal to the default value']);
    elseif ~isfield(seeds,'randn')
        warning(['The seed for randn() has not been set.'...
                'It is set equal to the default value']);
    end
else
    warning(['The seeds for the random number generators have not been'...
            'set. They are set to the default value']);
    seeds.rand=500;
    seeds.randn=500;
end


rand('seed',seeds.rand);
randn('seed',seeds.randn);

%Generate state sequence for the training set
h(1)=randi([1,2]); 
h=genSequenceState(h(1),P,N);

y=zeros(N,1);
X=zeros(N,p);

%Generate training data
for ind=1:N
    if h(ind)==1
        ind2=randi([1,2]);
        X(ind,:)=mean{h(ind)}(ind2,:)+std{h(ind)}*randn(1,p);
        if ind2==1
            y(ind)=1;
        elseif ind2==2
            y(ind)=-1;
        end
    else
        ind2=randi([1,2]);
        X(ind,:)=mean{h(ind)}(ind2,:)+std{h(ind)}*randn(1,p);
        if ind2==1
            y(ind)=-1;
        elseif ind2==2
            y(ind)=1;
        end    
    end
end


%Generate state sequence for the validation set
hval(1)=randi([1,2]); 
hval=genSequenceState(hval(1),P,Nval);

yval=zeros(Nval,1);
Xval=zeros(Nval,p);

%Generate validation data
for ind=1:Nval
    if hval(ind)==1
        ind2=randi([1,2]);
        Xval(ind,:)=mean{hval(ind)}(ind2,:)+std{hval(ind)}*randn(1,p);
        if ind2==1
            yval(ind)=1;
        elseif ind2==2
            yval(ind)=-1;
        end
    else
        ind2=randi([1,2]);
        Xval(ind,:)=mean{hval(ind)}(ind2,:)+std{hval(ind)}*randn(1,p);
        if ind2==1
            yval(ind)=-1;
        elseif ind2==2
            yval(ind)=1;
        end    
    end
end