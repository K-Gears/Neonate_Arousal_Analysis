function [figHandle,ax1,ax2,ax4,ax5] = GenerateSingleFigures_Neonate(samplingRate,ballVelocity,EMG,dHbT,SpecData,EMGThresh,EMGmua,theLFP)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figure for visualized sleep scoring
%________________________________________________________________________________________________________________________

%% prepare data
trialDuration = round(length(ballVelocity)/samplingRate);
timeVec = (1:length(ballVelocity))/samplingRate;
[B,A] = butter(3,1/(samplingRate/2),'low');
% ball velocity - apply any extra processing or filters
% ballVelocity = ballVelocity(1:trialDuration*samplingRate); 
% EMG - apply any extra processing or filters
% EMG = log(EMG(1:trialDuration*samplingRate)); 
% EMGline(1:length(EMG))=EMGThresh;
% change in total hemoglobin
% procHbT = filtfilt(B,A,dHbT(1:trialDuration*samplingRate));
% hippocampal LFP
S = SpecData.S5_Norm;%*100;
T = SpecData.T5;
F = SpecData.F5;

%% Figure
figHandle = figure;
% EMG multi unit activity
ax2=subplot(12,1,(3:5));
muaTime=(1:length(EMGmua))/20000;
yyaxis left; plot(muaTime,EMGmua,'Color','k');
theaxes=gca;
theaxes.YColor='black';
ylabel('EMG [300-5000Hz] (uV)');
theLabel=get(gca,'YLabel');
set(theLabel,'rotation',0,'VerticalAlignment','middle','HorizontalAlignment','right');

yyaxis right; plot(muaTime,EMG);
ylabel('EMG Power (log units)');
theLabel=get(gca,'YLabel');
set(theLabel,'rotation',0,'VerticalAlignment','middle','HorizontalAlignment','left');
xticks([]);

% ball velocity and EMG
ax1 = subplot(12,1,(1:2)); hold on;
plot(muaTime,abs(ballVelocity),'k');
ylabel('Ball Velocity (cm/s)');
theLabel=get(gca,'YLabel');
set(theLabel,'rotation',0,'VerticalAlignment','middle','HorizontalAlignment','right');
xticks([]);
% dHbT
% ax3 = subplot(4,1,3);
% plot(timeVec,procHbT,'LineWidth',1,'color',colors_GT('dark candy apple red'));
% ylabel('\DeltaHbT (\muM)')
% hippocampal spec
ax4 = subplot(12,1,(9:12));
SemiLogImageSC_Neonate(T,F,S,'y')
c8 = colorbar;
ylabel(c8,'\DeltaP/P (%)')
caxis([-100 100])
ylim([1 100])
xlabel('Time (s)')
ylabel({'Hippocampal LFP';'Frequency (Hz)'})

ax5=subplot(12,1,(6:8));
plot(muaTime,theLFP,'k');
ylim([(-5*std(theLFP,0,'all')) (5*std(theLFP,0,'all'))]);
theaxes=gca;
theaxes.YColor='black';
ylabel('Hippocampus LFP [1-150hz] (uV)');
theLabel=get(gca,'YLabel');
set(theLabel,'rotation',0,'VerticalAlignment','middle','HorizontalAlignment','right');
xticks([]);


set(gca,'TickLength',[0,0])
set(gca,'box','off')
% align axes in position after colorbar
ax1Pos = get(ax1,'position');
ax2Pos = get(ax2,'position');
% ax3Pos = get(ax3,'position');
ax4Pos = get(ax4,'position');
ax2Pos(3:4) = ax1Pos(3:4);
% ax3Pos(3:4) = ax1Pos(3:4);
ax4Pos(3) = ax1Pos(3);
set(ax2,'position',ax2Pos);
% set(ax3,'position',ax3Pos);
set(ax4,'position',ax4Pos);
linkaxes([ax1,ax2,ax4,ax5],'x')%,ax3
xlim([0 trialDuration]);
end
