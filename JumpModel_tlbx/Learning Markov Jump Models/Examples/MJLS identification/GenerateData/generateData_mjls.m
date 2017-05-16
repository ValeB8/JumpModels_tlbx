function [model,nmodes,delaymax,y,u,h,Phi,SNR]=generateData_mjls(N,seedrn,seedr,option,noise_std)
%Function used to generate the synthetic data used to test the approach
%to identify Markov Jump Linear Systems presented in Section 3.2 [1].
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
%Multiple cases could be selected:
%  -case 1 and 2: Same system with 3 hidden discrete states and different
%                 transition matrices (Case 2: Example in section 4.2.1).
%  -case 3: System with 5 hidden states and higly diagonally dominant
%           transition matrix.
%  -case 4: Higly jumping MIMO system with 2 hidden states.
%
%Inputs:
% - N : number of samples;
% - seedrn : seed for the random number generator (when using randn);
% - seedr : seed for the random number generator (when using rand);
% - option : see the multiple cases leasted above;
% - noise_std : standard deviation of the noise corrupting the output.
%Ouptuts:
% - model : considered kind of model;
% - nmodes : number of modes;
% - delaymax : delay before the first sample is processed;
% - {y,u} : output/input sequences;
% - h : mode sequence;
% - Phi : not modified regressor;
% - SNR : Signal-to-Noise Ratio [dB].

% Written by V.Breschi, March 2016

switch option
    case 1
        
        model='linear';
        
        randn('seed',seedrn);
        rand('seed',seedr);
        
        %Define the number of states
        nmodes=3;
        
        %Define the transition matrix
        P=zeros(nmodes,nmodes);
        
        P(1,:)=[0.8 0.2 0];
        P(2,:)=[0 0.9 0.1];
        P(3,:)=[0.4 0 0.6];
        
        %Define the coefficients of esch submodel
        a=[0.4;-0.2;0.7];
        b=[0.7;0.4;0.5];
        
        true_theta=zeros(2,1,nmodes);
        for ind=1:nmodes
            true_theta(:,:,ind)=[a(ind);b(ind)];
        end
        
        %Define the sequence of inputs
        u=randn(N,1);
        
        %Define the sequence of noise
        noise=randn(N,1)*noise_std;
        
        %Generate the evolution of the Markov chain
        h(1)=round(1+(nmodes-1)*rand);
        h=genSequenceState(h(1),P,N);
        
        %Generate the outputs
        delaymax=1;
        
        y=zeros(N,1);
        y(1:delaymax)=0;
        
        for ind=delaymax+1:N
            y(ind)=a(h(ind))*y(ind-1)+b(h(ind))*u(ind-1)+noise(ind);
        end
        
        %Compute the Signal-to-Noise Ratio
        SNR=10*log10(sum((y-noise).^2)/sum(noise.^2));
        
        %Generate the regressor
        Phi=zeros(N,2);
        
        for k=delaymax+1:N
            Phi(k,:)=[y(k-1,:) u(k-1,:)];
        end
    case 2
        
        model='linear';
        
        randn('seed',seedrn);
        rand('seed',seedr);
        
        %Define the number of states
        nmodes=3;
        
        %Define the transition matrix
        P=zeros(nmodes,nmodes);
        
        P(1,:)=[0.6 0.25 0.15];
        P(2,:)=[0.25 0.5 0.25];
        P(3,:)=[0.2 0.1 0.7];
        
        %Define the coefficients of esch submodel
        a=[0.4;-0.2;0.7];
        b=[0.7;0.4;0.5];
        
        true_theta=zeros(2,1,nmodes);
        for ind=1:nmodes
            true_theta(:,:,ind)=[a(ind);b(ind)];
        end
        
        %Define the sequence of inputs
        u=randn(N,1);
        
        %Define the sequence of noise
        noise=randn(N,1)*noise_std;
        
        %Generate the evolution of the Markov chain
        h(1)=round(1+(nmodes-1)*rand);
        h=genSequenceState(h(1),P,N);
        
        %Generate the outputs
        delaymax=1;
        
        y=zeros(N,1);
        y(1:delaymax)=0;
        
        for ind=delaymax+1:N
            y(ind,1)=a(h(ind))*y(ind-1)+b(h(ind))*u(ind-1)+noise(ind);
        end
        
        
        %Compute the Signal-to-Noise Ratio
        SNR=10*log10(sum((y-noise).^2)/sum(noise.^2));
        
        %Generate the regressor
        Phi=zeros(N,2);
        
        for k=delaymax+1:N
            Phi(k,:)=[y(k-1,:) u(k-1,:)];
        end
        
    case 3
        
        model='linear';
        
        randn('seed',seedrn);
        rand('seed',seedr);
        
        %Define the number of hidden states
        nmodes=5;
        
        %Define the transition matrix
        P=zeros(nmodes,nmodes);
        
        P(1,:)=[0.97 0.005 0.0025 0.0025 0.02];
        P(2,:)=[0.005 0.98 0.005 0.005 0.005];
        P(3,:)=[0.01 0.005 0.97 0.005 0.01];
        P(4,:)=[0.015 0.005 0.01 0.96 0.01];
        P(5,:)=[0.01 0.02 0.01 0.01 0.95];
        
        %Define the coefficients of each model
        a=[0.4;-0.2;0.7;0.1; 0.5];
        b=[0.7;0.4;0.5; -0.8; -0.3];
        true_theta=zeros(2,1,nmodes);
        for ind=1:nmodes
            true_theta(:,:,ind)=[a(ind);b(ind)];
        end
        
        %Define the input vector
        u=randn(N,1);
        
        %Generate noise sequence
        noise=randn(N,1)*noise_std;
        
        %Generate the evolution of the Markov chain
        h(1)=round(1+(nmodes-1)*rand);
        h=genSequenceState(h(1),P,N);
        
        %Generate the outputs
        delaymax=1;
        
        y=zeros(N,1);
        y(1:delaymax)=0;
        
        for ind=delaymax+1:N
            y(ind,1)=a(h(ind))*y(ind-1)+b(h(ind))*u(ind-1)+noise(ind);
        end
        
        %Compute the Signal-to-Noise Ratio
        SNR=10*log10(sum((y-noise).^2)/sum(noise.^2));
        
        %Generate the regressor
        Phi=zeros(N,2);
        
        for k=delaymax+1:N
            Phi(k,:)=[y(k-1,:) u(k-1,:)];
        end
    case 4
        
        model='affine';
        
        rand('seed',seedr)
        randn('seed',seedrn)
        
        %Define the transition matrix
        P=[0.6 0.4;0.4 0.6];
        
        %Define the number of states
        nmodes=2;
        
        %Define the parameters of each submodel
        A=cell([nmodes 1]);
        
        A{1}=[-0.8 0.2 0.3;
            0.4 0.2 -0.1];
        A{2}=[0.3 -0.1 -2;
            -0.5 0.1 1];
        
        %Build the sequence of discrete states
        h=zeros(N,1);
        Init_prob1=0.5; %Initial probability to be in the first mode
        
        %Selection of the initial mode
        select_init=rand;
        
        if select_init<=Init_prob1
            h(1)=1;
        else
            h(1)=2;
        end
        
        %As the system is autonomous return u as an empty array
        u=[];
        
        %Generate the evolution of the Markov chain
        h=genSequenceState(h(1),P,N);
        
        %Generate the sequence of noise
        noise=randn(N,2)*noise_std;
        
        %Generate the sequence of outputs and the regressor
        Phi=zeros(N,2);
        
        y=zeros(N,2);
        y(1,:)=[1 -0.5];
        delaymax=1;
        
        for ind=delaymax+1:N
            Phi(ind,:)=y(ind-delaymax,:);
            y(ind,:)=(A{h(ind)}*[Phi(ind,:) 1]')'+noise(ind,:);
        end
        
        SNR=zeros(size(y,2),1);
        
        %Compute the Signal-to-Noise Ratio
        for ind=1:size(y,2)
            SNR=10*log10(sum((y(:,ind)-noise(:,ind)).^2)/sum(noise(:,ind).^2));
        end
end