load('powerData.mat')

oneweek_cde=[];
oneweek_dwe=[];
oneweek_fge=[];
oneweek_hpe=[];
oneweek_bme=[];
oneweek_woe=[];
%oneweek_ofe=[];

for idx1=23:29
    %oneweek_cde=[oneweek_cde;powerData.CDE(:,idx1)];
    oneweek_fge=[oneweek_fge;powerData.FGE(:,idx1)];
    %oneweek_dwe=[oneweek_dwe;powerData.DWE(:,idx1)];
    oneweek_hpe=[oneweek_hpe;powerData.HPE(:,idx1)];
    oneweek_bme=[oneweek_bme;powerData.BME(:,idx1)];   
end

for idx1=170:176
    oneweek_dwe=[oneweek_dwe;powerData.DWE(:,idx1)];
    %oneweek_hpe=[oneweek_hpe;powerData.HPE(:,idx1)];
end

for idx1=74:80
    oneweek_cde=[oneweek_cde;powerData.CDE(:,idx1)];
end

for idx1=1:2
    oneweek_woe=[oneweek_woe;powerData.WOE(:,idx1)];
%      oneweek_ofe=[oneweek_ofe;powerData.WOE(:,idx1)];
 end


% mean_cde=mean(oneweek_cde);
% mean_dwe=mean(oneweek_dwe);
% mean_fge=mean(oneweek_fge);
% mean_hpe=mean(oneweek_hpe);
%
% oneweek_cde=oneweek_cde-ones(size(oneweek_cde,1),1)*mean_cde;
% oneweek_dwe=oneweek_dwe-ones(size(oneweek_dwe,1),1)*mean_dwe;
% oneweek_fge=oneweek_fge-ones(size(oneweek_fge,1),1)*mean_fge;
% oneweek_hpe=oneweek_hpe-ones(size(oneweek_hpe,1),1)*mean_hpe;

clear idx1