%Script generated to perform the example on electric power consumption in 
%[1] allows. The dataset described in [2] is used.
%
% [1] V.Breschi, D.Piga, S.Boyd, A.Bemporad, Learning Jump Models.
% [2] Stephen Makonin, Bradley Ellert, Ivan V. Bajic, and Fred Popowich. Electricity,
%     water, and natural gas consumption of a residential house in Canada from 2012 to
%     2014. Scientific Data, 3(160037):1-12, 2016.
%
% Written by V.Breschi, March 2016

%Train and validate the MJLS models
EnergyPatternRJM

%Evaluate if the models allow to distinguish between different appliances
DistApplRJM