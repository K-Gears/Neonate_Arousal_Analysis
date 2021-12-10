%% READ ME
% This function plots the change in arousal state around somatosensory stimulus and optogenetic simulus
% of juvenile animals

figure(102); hold on
plotTime=(1:length(PopData.P10.NC_SLP005.Whisker_Stim.ArousalProbability.ActiveAwake))-5;

plot(plotTime,PopData.P10.NC_SLP008.Whisker_Stim.ArousalProbability.ActiveAwake,'k');
plot(plotTime,PopData.P10.NC_SLP008.Whisker_Stim.ArousalProbability.QuiescentAwake,'b');
plot(plotTime,PopData.P10.NC_SLP008.Whisker_Stim.ArousalProbability.QuiescentAsleep,'g');
plot(plotTime,PopData.P10.NC_SLP008.Whisker_Stim.ArousalProbability.REM,'m');
legend({'Active Awake','Quiescent Awake','Quiescent Asleep','REM'});

figure(101); hold on
plotTime=(1:length(Averages.P10.Whisker_Stim.PopulationAverages.Probability_in_State.ActiveAwake))-5;

plot(plotTime,Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.ActiveAwake,'k');
plot(plotTime,Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.QuiescentAwake,'b');
plot(plotTime,Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.QuiescentAsleep,'g');
plot(plotTime,Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.REM,'m');
legend({'Active Awake','Quiescent Awake','Quiescent Asleep','REM'});
xlabel('Time (sec)');

figure(103);
plot(plotTime,Averages.P10.Whisker_Stim.PopulationAverages.Probability_in_State.ActiveAwake,'k');
plot(plotTime,Averages.P10.Whisker_Stim.PopulationAverages.Probability_in_State.QuiescentAwake,'b');
plot(plotTime,Averages.P10.Whisker_Stim.PopulationAverages.Probability_in_State.QuiescentAsleep,'g');
plot(plotTime,Averages.P10.Whisker_Stim.PopulationAverages.Probability_in_State.REM,'m');
legend({'Active Awake','Quiescent Awake','Quiescent Asleep','REM'});
xlabel('Time (sec)');

figure(104); hold on
plotTime=(1:length(Averages.P10.Whisker_Stim.PopulationAverages.Probability_in_State.ActiveAwake))-5;

REM=Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.REM;
NREM=Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.REM+Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.QuiescentAsleep;
Q_Awk=NREM+Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.QuiescentAwake;
A_Awk=Q_Awk+Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.ActiveAwake;

area(plotTime,A_Awk);
area(plotTime,Q_Awk);
area(plotTime,NREM);
area(plotTime,REM);
legend({'Active Awake','Quiescent Awake','Quiescent Asleep','REM'});
xlabel('Time (sec)');


tempMap_1=brewermap(11,'RdGy');
tempMap_2=brewermap(11,'RdBu');
colors(1,:)=tempMap_2(2,:);
colors(2,:)=tempMap_2(9,:);
colors(3,:)=tempMap_1(7,:);
colors(4,:)=tempMap_1(9,:);
colors(5,:)=[1 1 1];
        
figure(105);
hold on
plotTime=(1:length(Averages.P10.Whisker_Stim.PopulationAverages.Probability_in_State.ActiveAwake))-5;
A_Awk=Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.ActiveAwake;
Q_Awk=A_Awk+Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.QuiescentAwake;
NREM=Q_Awk+Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.QuiescentAsleep;
REM=NREM+Averages.P15.Whisker_Stim.PopulationAverages.Probability_in_State.REM;
area(plotTime,REM,'FaceColor',colors(1,:));
area(plotTime,NREM,'FaceColor',colors(2,:));
area(plotTime,Q_Awk,'FaceColor',colors(3,:));
area(plotTime,A_Awk,'FaceColor',colors(4,:));

legend({'REM','Quiescent Asleep','Quiescent Awake','Active Awake'});
xlabel('Time (sec)');

