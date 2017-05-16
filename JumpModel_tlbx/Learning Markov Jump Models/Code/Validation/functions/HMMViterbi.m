function [Xopt X0]=HMMViterbi(PI,PI0,Y,Ymean,Cov)

% function [Xopt X0]=HMMViterbi(PI,PI0,Y,Ymean,Cov)
% Viterbi algorithm for estimation of the hidden state sequence in HMMs 
% under assumption of Gaussian distribution of the noise corrupting the output measurements  
% N: Number of measuremts
% n: number of possible states
% ny: dimension of the output channel
% Inputs: PI: nxn probability transition matrix
%         PI0: nx1 matrix of probability of the initial state
%         Y: Nxny matrix with output observations
%         Ymean: Nxnyxn matrix with expected value of the output for each model
%         Cov: nyxny covariance matrix on the output noise
% Output: Xopt: Nx1 matrix with optimal state sequence
%         X0: Eastimate of the initial state

% (C) Written by D.Piga
        
N=size(Y,1); %Length of dataset
n=size(PI,1);
PIlog= -ones(n,n)*10000000;  % -infinity
PI0log=-ones(n,1)*10000000; % -infinity
for ind=1:n
    if ne(PI0(ind),0)
        PI0log(ind)=log(PI0(ind));
    end
end


%Compute log of the Transition Matrix
for indr=1:n
    for indc=1:n
        if ne(PI(indr,indc),0)
            PIlog(indr,indc)=log(PI(indr,indc)); 
        end
    end
end

invCov=inv(Cov);

pastcost=-PI0log;
pastcostindt=zeros(n,1);
for ind=1:N   
    %Compute cost-to-go 
   for indtime=1:n
       for indtimem1=1:n
           cost2go(indtimem1,1)=-(-(Y(ind,:)-Ymean(ind,:,indtime))*invCov*(Y(ind,:)-Ymean(ind,:,indtime))'*0.5-log(det(invCov))+PIlog(indtimem1,indtime)); %Cost to go from mode x(indtimem1) to x(indtime)     
       end
        %Find minimum cost
        [minc ,I] = min(cost2go+pastcost);
        pastcostindt(indtime,1)=minc(1);
        Ivec(ind,indtime)=I(1);        
   end   
   pastcost=pastcostindt;
end

[mincpc ,Iopt]=min(pastcost);
Xopt=[Ivec(2:N,Iopt); Iopt];
X0=Ivec(1,Iopt);

end