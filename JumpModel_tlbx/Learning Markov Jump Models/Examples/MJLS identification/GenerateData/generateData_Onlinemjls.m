function [N,model,nmodes,delaymax,y,u,h,Phi,SNR]=generateData_Onlinemjls(seedrn,seedr,noise_std)
%Function used to generate the synthetic data used to test the approach
%to identify Markov Jump Linear Systems presented in Section 3.2 [1]. The 
%generated dataset is used to evaluate the performance of the method for
%online learning.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
%
%Inputs:
% - seedrn : seed for the random number generator (when using randn);
% - seedr : seed for the random number generator (when using rand);
% - noise_std : standard deviation of the noise corrupting the output.
%Ouptuts:
% - N : number of samples;
% - model : considered kind of model;
% - nmodes : number of modes;
% - delaymax : delay before the first sample is processed;
% - {y,u} : output/input sequences;
% - h : mode sequence;
% - Phi : not modified regressor;
% - SNR : Signal-to-Noise Ratio [dB].

% Written by V.Breschi, March 2016

N=30000; %Number of samples

model='linear'; %Kind of model

randn('seed',seedrn);
rand('seed',seedr);

%Define the number of states
nmodes=3;

%Define the transition matrix
P1=zeros(nmodes,nmodes);

P1(1,:)=[0.6 0.25 0.15];
P1(2,:)=[0.25 0.5 0.25];
P1(3,:)=[0.2 0.1 0.7];

%Define the transition matrix
P2=zeros(nmodes,nmodes);

P2(1,:)=[0.8 0.2 0];
P2(2,:)=[0 0.9 0.1];
P2(3,:)=[0.3 0.2 0.5];


%Define the coefficients of esch submodel
a(:,1)=[0.4;-0.2;0.7];
b(:,1)=[0.7;0.4;0.5];

a(:,2)=[0.8;0.2;-0.1];
b(:,2)=[0.4;0.8;0.2];

true_theta=zeros(2,1,nmodes);
for ind=1:nmodes
    true_theta(:,:,ind)=[a(ind);b(ind)];
end

%Define the sequence of inputs
u=randn(N,1);

%Define the sequence of noise
noise=randn(N,1)*noise_std;


%Generate the evolution of the Markov chain
h1(1)=round(1+(nmodes-1)*rand);
h1=genSequenceState(h1(1),P1,6000);
h2=genSequenceState(h1(end),P2,N-6000);

h=[h1;h2];

%Generate the outputs
delaymax=1;

y=zeros(N,1);
y(1:delaymax)=0;

for ind=delaymax+1:N   
    if ind<=6000
        ind2=1;
    else
        ind2=2;
    end
    y(ind)=a(h(ind),ind2)*y(ind-1)+b(h(ind),ind2)*u(ind-1)+noise(ind);       
end

%Compute the Signal-to-Noise Ratio
SNR=10*log10(sum((y-noise).^2)/sum(noise.^2));

%Generate the regressor
Phi=zeros(N,2);

for k=delaymax+1:N
    Phi(k,:)=[y(k-1,:) u(k-1,:)];
end

