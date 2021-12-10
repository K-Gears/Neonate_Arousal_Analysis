function [ChunkData]=create_sleep_histograms_Neonate(ChunkData,age)
%% READ ME
% This function creates histograms of amplitudes and concentration of HbT
% and electrophysiological measures for individual animals.
close all

%% Aggegrate Quiescent periods for P10 animals
if strcmpi(age,'P10')
behavioralQuiescence_ios=[ChunkData.ArousalStates.Quiescent_Awake.IOS.forepaw.dHbT;ChunkData.ArousalStates.Quiescent_Asleep.IOS.forepaw.dHbT]; 
behavioralQuiescence_EMG=[ChunkData.ArousalStates.Quiescent_Awake.EMG.EMGPower;ChunkData.ArousalStates.Quiescent_Asleep.EMG.EMGPower]; 
behavioralQuiescence_Ball=[ChunkData.ArousalStates.Quiescent_Awake.Ball.velocity;ChunkData.ArousalStates.Quiescent_Asleep.Ball.velocity]; 
end
%%  Get mean of quiescent arousals
if strcmpi(age,'P10')
re_centerHbT=mean(behavioralQuiescence_ios,'all');
re_centerEMG=log10(mean(behavioralQuiescence_EMG,'all'));
re_centerBall=mean(behavioralQuiescence_Ball,'all');
else
re_centerHbT=mean(ChunkData.ArousalStates.Quiescent_Awake.IOS.forepaw.dHbT,'all');
re_centerEMG=log10(mean(ChunkData.ArousalStates.Quiescent_Awake.EMG.EMGPower,'all')); 
re_centerBall=mean(ChunkData.ArousalStates.Quiescent_Awake.Ball.velocity,'all'); 
end

%% Apply to HbT histograms
figure(101);subplot(4,1,3); hold on; 
I_awk=histogram(ChunkData.ArousalStates.Active_Awake.IOS.forepaw.dHbT-re_centerHbT,'BinEdges',[-150:2:150],'Normalization','probability');
ChunkData.ArousalStates.Histograms.Active_Awake.IOS.Counts=I_awk.BinCounts;
ChunkData.ArousalStates.Histograms.Active_Awake.IOS.Edges=I_awk.BinEdges;
ChunkData.ArousalStates.Histograms.Active_Awake.IOS.Avg=mean(ChunkData.ArousalStates.Active_Awake.IOS.forepaw.dHbT-re_centerHbT,'all');
ChunkData.ArousalStates.Histograms.Active_Awake.IOS.conf_99=bootci(10000,{@mean,reshape((ChunkData.ArousalStates.Active_Awake.IOS.forepaw.dHbT-re_centerHbT),1,numel(ChunkData.ArousalStates.Active_Awake.IOS.forepaw.dHbT))},'Type','norm','Alpha',0.01);
if strcmpi(age,'P10')
    I_Q=histogram(behavioralQuiescence_ios-re_centerHbT,'BinEdges',[-150:2:150],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.IOS.Counts=I_Q.BinCounts;
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.IOS.Edges=I_Q.BinEdges;
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.IOS.Avg=mean(behavioralQuiescence_ios-re_centerHbT,'all');
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.IOS.conf_99=bootci(10000,{@mean,reshape((behavioralQuiescence_ios-re_centerHbT),1,numel(behavioralQuiescence_ios))},'Type','norm','Alpha',0.01);
else
    I_qui=histogram(ChunkData.ArousalStates.Quiescent_Awake.IOS.forepaw.dHbT-re_centerHbT,'BinEdges',[-150:2:150],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.IOS.Counts=I_qui.BinCounts;
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.IOS.Edges=I_qui.BinEdges;
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.IOS.Avg=mean(ChunkData.ArousalStates.Quiescent_Awake.IOS.forepaw.dHbT-re_centerHbT,'all');
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.IOS.conf_99=bootci(10000,{@mean,reshape((ChunkData.ArousalStates.Quiescent_Awake.IOS.forepaw.dHbT-re_centerHbT),1,numel(ChunkData.ArousalStates.Quiescent_Awake.IOS.forepaw.dHbT))},'Type','norm','Alpha',0.01);
    
    I_NREM=histogram(ChunkData.ArousalStates.Quiescent_Asleep.IOS.forepaw.dHbT-re_centerHbT,'BinEdges',[-150:2:150],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.IOS.Counts=I_NREM.BinCounts;
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.IOS.Edges=I_NREM.BinEdges;
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.IOS.Avg=mean(ChunkData.ArousalStates.Quiescent_Asleep.IOS.forepaw.dHbT-re_centerHbT,'all');
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.IOS.conf_99=bootci(10000,{@mean,reshape((ChunkData.ArousalStates.Quiescent_Asleep.IOS.forepaw.dHbT-re_centerHbT),1,numel(ChunkData.ArousalStates.Quiescent_Asleep.IOS.forepaw.dHbT))},'Type','norm','Alpha',0.01);
    
end
I_REM=histogram(ChunkData.ArousalStates.Active_Asleep.IOS.forepaw.dHbT-re_centerHbT,'BinEdges',[-150:2:150],'Normalization','probability');
ChunkData.ArousalStates.Histograms.Active_Asleep.IOS.Counts=I_REM.BinCounts;
ChunkData.ArousalStates.Histograms.Active_Asleep.IOS.Edges=I_REM.BinEdges;
ChunkData.ArousalStates.Histograms.Active_Asleep.IOS.Avg=mean(ChunkData.ArousalStates.Active_Asleep.IOS.forepaw.dHbT-re_centerHbT,'all');
ChunkData.ArousalStates.Histograms.Active_Asleep.IOS.conf_99=bootci(10000,{@mean,reshape((ChunkData.ArousalStates.Active_Asleep.IOS.forepaw.dHbT-re_centerHbT),1,numel(ChunkData.ArousalStates.Active_Asleep.IOS.forepaw.dHbT))},'Type','norm','Alpha',0.01);

if strcmpi(age,'P10')
    legend({'Active Awake','Behavioral Quiescence','Active Asleep'});
else
    legend({'Active Awake','Quiescent Awake','Quiescent Asleep','Active Asleep'});
end
xlabel('\DeltaHbT (\muM)');
ylabel('Probability');
title('\DeltaHbT by arousal state P10');


%% EMG Histograms
figure(101);subplot(4,1,2);hold on;
E_awk=histogram(real(log10(ChunkData.ArousalStates.Active_Awake.EMG.EMGPower))-re_centerEMG,'BinEdges',[-4:0.01:4],'Normalization','probability');
ChunkData.ArousalStates.Histograms.Active_Awake.EMG.Counts=E_awk.BinCounts;
ChunkData.ArousalStates.Histograms.Active_Awake.EMG.Edges=E_awk.BinEdges;
ChunkData.ArousalStates.Histograms.Active_Awake.EMG.Avg=mean(real(log10(ChunkData.ArousalStates.Active_Awake.EMG.EMGPower))-re_centerEMG,'all');
ChunkData.ArousalStates.Histograms.Active_Awake.EMG.conf_99=bootci(10000,{@mean,reshape((real(log10(ChunkData.ArousalStates.Active_Awake.EMG.EMGPower))-re_centerEMG),1,numel(ChunkData.ArousalStates.Active_Awake.EMG.EMGPower))},'Type','norm','Alpha',0.01);

if strcmpi(age,'P10')
    E_Q=histogram(real(log10(behavioralQuiescence_EMG))-re_centerEMG,'BinEdges',[-4:0.01:4],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.EMG.Counts=E_Q.BinCounts;
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.EMG.Edges=E_Q.BinEdges;
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.EMG.Avg=mean(real(log10(behavioralQuiescence_EMG))-re_centerEMG,'all');
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.EMG.conf_99=bootci(10000,{@mean,reshape((real(log10(behavioralQuiescence_EMG))-re_centerEMG),1,numel(behavioralQuiescence_EMG))},'Type','norm','Alpha',0.01);
    
else
    E_qui=histogram(real(log10(ChunkData.ArousalStates.Quiescent_Awake.EMG.EMGPower))-re_centerEMG,'BinEdges',[-4:0.01:4],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.EMG.Counts=E_qui.BinCounts;
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.EMG.Edges=E_qui.BinEdges;
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.EMG.Avg=mean(real(log10(ChunkData.ArousalStates.Quiescent_Awake.EMG.EMGPower))-re_centerEMG,'all');
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.EMG.conf_99=bootci(10000,{@mean,reshape((real(log10(ChunkData.ArousalStates.Quiescent_Awake.EMG.EMGPower))-re_centerEMG),1,numel(ChunkData.ArousalStates.Quiescent_Awake.EMG.EMGPower))},'Type','norm','Alpha',0.01);
    
    E_NREM=histogram(real(log10(ChunkData.ArousalStates.Quiescent_Asleep.EMG.EMGPower))-re_centerEMG,'BinEdges',[-4:0.01:4],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.EMG.Counts=E_NREM.BinCounts;
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.EMG.Edges=E_NREM.BinEdges;
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.EMG.Avg=mean(real(log10(ChunkData.ArousalStates.Quiescent_Asleep.EMG.EMGPower))-re_centerEMG,'all');
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.EMG.conf_99=bootci(10000,{@mean,reshape((real(log10(ChunkData.ArousalStates.Quiescent_Asleep.EMG.EMGPower))-re_centerEMG),1,numel(ChunkData.ArousalStates.Quiescent_Asleep.EMG.EMGPower))},'Type','norm','Alpha',0.01);
    
end
E_REM=histogram(real(log10(ChunkData.ArousalStates.Active_Asleep.EMG.EMGPower))-re_centerEMG,'BinEdges',[-4:0.01:4],'Normalization','probability');
ChunkData.ArousalStates.Histograms.Active_Asleep.EMG.Counts=E_REM.BinCounts;
ChunkData.ArousalStates.Histograms.Active_Asleep.EMG.Edges=E_REM.BinEdges;
ChunkData.ArousalStates.Histograms.Active_Asleep.EMG.Avg=mean(real(log10(ChunkData.ArousalStates.Active_Asleep.EMG.EMGPower))-re_centerEMG,'all');
ChunkData.ArousalStates.Histograms.Active_Asleep.EMG.conf_99=bootci(10000,{@mean,reshape((real(log10(ChunkData.ArousalStates.Active_Asleep.EMG.EMGPower))-re_centerEMG),1,numel(ChunkData.ArousalStates.Active_Asleep.EMG.EMGPower))},'Type','norm','Alpha',0.01);

if strcmpi(age,'P10')
    legend({'Active Awake','Behavioral Quiescence','Active Asleep'});
else
    legend({'Active Awake','Quiescent Awake','Quiescent Asleep','Active Asleep'});
end
ylabel('Probability');
xlabel('EMG [300-5000Hz] power (log10)');
title('EMG power by arousal state P10');
sgtitle('Arousal state distribution of EMG and \DeltaHbT');
xlim([-4 4]);

%% Ball Velocity Histograms
figure(101);subplot(4,1,1);hold on;
B_awk=histogram(real(ChunkData.ArousalStates.Active_Awake.Ball.velocity)-re_centerBall,'BinEdges',[0:0.1:50],'Normalization','probability');
ChunkData.ArousalStates.Histograms.Active_Awake.Ball.Counts=B_awk.BinCounts;
ChunkData.ArousalStates.Histograms.Active_Awake.Ball.Edges=B_awk.BinEdges;
ChunkData.ArousalStates.Histograms.Active_Awake.Ball.Avg=mean(ChunkData.ArousalStates.Active_Awake.Ball.velocity-re_centerBall,'all');
ChunkData.ArousalStates.Histograms.Active_Awake.Ball.conf_99=bootci(10000,{@mean,reshape((ChunkData.ArousalStates.Active_Awake.Ball.velocity-re_centerEMG),1,numel(ChunkData.ArousalStates.Active_Awake.Ball.velocity))},'Type','norm','Alpha',0.01);

if strcmpi(age,'P10')
    B_Q=histogram(behavioralQuiescence_Ball-re_centerBall,'BinEdges',[0:1:4],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.Ball.Counts=E_Q.BinCounts;
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.Ball.Edges=E_Q.BinEdges;
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.Ball.Avg=mean(real(log10(behavioralQuiescence_EMG))-re_centerBall,'all');
    ChunkData.ArousalStates.Histograms.Behavioral_Quiescence.Ball.conf_99=bootci(10000,{@mean,reshape((real(log10(behavioralQuiescence_Ball))-re_centerBall),1,numel(behavioralQuiescence_Ball))},'Type','norm','Alpha',0.01);
    
else
    B_qui=histogram(ChunkData.ArousalStates.Quiescent_Awake.Ball.velocity-re_centerBall,'BinEdges',[0:0.1:50],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.Ball.Counts=B_qui.BinCounts;
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.Ball.Edges=B_qui.BinEdges;
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.Ball.Avg=mean(ChunkData.ArousalStates.Quiescent_Awake.Ball.velocity-re_centerBall,'all');
    ChunkData.ArousalStates.Histograms.Quiescent_Awake.Ball.conf_99=bootci(10000,{@mean,reshape((ChunkData.ArousalStates.Quiescent_Awake.Ball.velocity-re_centerBall),1,numel(ChunkData.ArousalStates.Quiescent_Awake.Ball.velocity))},'Type','norm','Alpha',0.01);
    
    B_NREM=histogram(ChunkData.ArousalStates.Quiescent_Asleep.Ball.velocity-re_centerBall,'BinEdges',[0:0.1:50],'Normalization','probability');
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.Ball.Counts=B_NREM.BinCounts;
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.Ball.Edges=B_NREM.BinEdges;
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.Ball.Avg=mean(ChunkData.ArousalStates.Quiescent_Asleep.Ball.velocity-re_centerBall,'all');
    ChunkData.ArousalStates.Histograms.Quiescent_Asleep.Ball.conf_99=bootci(10000,{@mean,reshape((ChunkData.ArousalStates.Quiescent_Asleep.Ball.velocity-re_centerEMG),1,numel(ChunkData.ArousalStates.Quiescent_Asleep.Ball.velocity))},'Type','norm','Alpha',0.01);
    
end
B_REM=histogram(ChunkData.ArousalStates.Active_Asleep.Ball.velocity-re_centerBall,'BinEdges',[0:0.1:50],'Normalization','probability');
ChunkData.ArousalStates.Histograms.Active_Asleep.Ball.Counts=B_REM.BinCounts;
ChunkData.ArousalStates.Histograms.Active_Asleep.Ball.Edges=B_REM.BinEdges;
ChunkData.ArousalStates.Histograms.Active_Asleep.Ball.Avg=mean(ChunkData.ArousalStates.Active_Asleep.Ball.velocity-re_centerBall,'all');
ChunkData.ArousalStates.Histograms.Active_Asleep.Ball.conf_99=bootci(10000,{@mean,reshape((ChunkData.ArousalStates.Active_Asleep.Ball.velocity-re_centerBall),1,numel(ChunkData.ArousalStates.Active_Asleep.Ball.velocity))},'Type','norm','Alpha',0.01);

if strcmpi(age,'P10')
    legend({'Active Awake','Behavioral Quiescence','Active Asleep'});
else
    legend({'Active Awake','Quiescent Awake','Quiescent Asleep','Active Asleep'});
end
ylabel('Probability');
xlabel('Ball velocity (cm/s)');
title('Ball velocity by arousal state P15');
sgtitle('Arousal state distribution of EMG Ball Velocity and \DeltaHbT');
xlim([0 50]);

figure(105); hold on;
T_awk=histogram(ChunkData.ArousalStates.Active_Awake.IOS.forepaw.dHbT-re_centerHbT,'BinEdges',[-150:2:150]);
T_REM=histogram(ChunkData.ArousalStates.Active_Asleep.IOS.forepaw.dHbT-re_centerHbT,'BinEdges',[-150:2:150]);
if strcmpi(age,'P10')
    T_Q=histogram(behavioralQuiescence_ios-re_centerHbT,'BinEdges',[-150:2:150]);
    ChunkData.ArousalStates.Histograms.Probabilities.allCounts=T_awk.BinCounts+T_REM.BinCounts+T_Q.BinCounts;
    ChunkData.ArousalStates.Histograms.Probabilities.prob_Q=(T_Q.BinCounts./ChunkData.ArousalStates.Histograms.Probabilities.allCounts)*100;
    ChunkData.ArousalStates.Histograms.Probabilities.prob_Q(isnan(ChunkData.ArousalStates.Histograms.Probabilities.prob_Q))=0;
else
    T_qui=histogram(ChunkData.ArousalStates.Quiescent_Awake.IOS.forepaw.dHbT-re_centerHbT,'BinEdges',[-150:2:150]);
    T_NREM=histogram(ChunkData.ArousalStates.Quiescent_Asleep.IOS.forepaw.dHbT-re_centerHbT,'BinEdges',[-150:2:150]);
    ChunkData.ArousalStates.Histograms.Probabilities.allCounts=T_awk.BinCounts+T_REM.BinCounts+T_qui.BinCounts+T_NREM.BinCounts;
    ChunkData.ArousalStates.Histograms.Probabilities.prob_Q=(T_qui.BinCounts./ChunkData.ArousalStates.Histograms.Probabilities.allCounts)*100;
    ChunkData.ArousalStates.Histograms.Probabilities.prob_Q(isnan(ChunkData.ArousalStates.Histograms.Probabilities.prob_Q))=0;
    ChunkData.ArousalStates.Histograms.Probabilities.prob_NREM=(T_NREM.BinCounts./ChunkData.ArousalStates.Histograms.Probabilities.allCounts)*100;
    ChunkData.ArousalStates.Histograms.Probabilities.prob_NREM(isnan(ChunkData.ArousalStates.Histograms.Probabilities.prob_NREM))=0;
end
ChunkData.ArousalStates.Histograms.Probabilities.prob_awk=(T_awk.BinCounts./ChunkData.ArousalStates.Histograms.Probabilities.allCounts)*100;
ChunkData.ArousalStates.Histograms.Probabilities.prob_awk(isnan(ChunkData.ArousalStates.Histograms.Probabilities.prob_awk))=0;
ChunkData.ArousalStates.Histograms.Probabilities.prob_REM=(T_REM.BinCounts./ChunkData.ArousalStates.Histograms.Probabilities.allCounts)*100;
ChunkData.ArousalStates.Histograms.Probabilities.prob_REM(isnan(ChunkData.ArousalStates.Histograms.Probabilities.prob_REM))=0;

figure(101);subplot(4,1,4);hold on;
yyaxis right;
bar(T_awk.BinEdges(2:end),ChunkData.ArousalStates.Histograms.Probabilities.allCounts,'FaceColor',[0 0 0],'FaceAlpha',0.2);
yyaxis left; hold on;
plot(T_awk.BinEdges(2:end),ChunkData.ArousalStates.Histograms.Probabilities.prob_awk,'-g');
plot(T_awk.BinEdges(2:end),ChunkData.ArousalStates.Histograms.Probabilities.prob_Q,'-r');
plot(T_awk.BinEdges(2:end),ChunkData.ArousalStates.Histograms.Probabilities.prob_REM,'-c');