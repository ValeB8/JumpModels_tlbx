function h = genSequenceState(h1,P,N)
%Generate sequence of Markov states given:
% h1: initial state
% P: Transition probabity
% N: Length of state sequence

% (C) D.Piga
 
Tresh=zeros(size(P,1),size(P,1));
for indstate=1:size(P,1)   
    for indstate2=1:size(P,1)
        Tresh(indstate,indstate2)=[  sum(P(indstate,1:indstate2)) ];
    end
    
end

randnumber=rand(N,1);
h=zeros(N,1);
h(1)=h1;

for indstate=2:N
    
    %Evaluate in which interval the number randnumber(ind) is located
    
    for indvec=1:size(P,1)
        if randnumber(indstate)<= Tresh(h(indstate-1),indvec)
        h(indstate)=indvec; 
        break
        end
    end
    
end

end