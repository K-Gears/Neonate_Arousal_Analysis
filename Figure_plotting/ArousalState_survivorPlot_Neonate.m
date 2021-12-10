function [ChunkData]=ArousalState_survivorPlot_Neonate(ChunkData)
%% READ ME
% This function plots the duration of time spent in a given arousal state
% as a survivor plot for individual animals

arousalStates=fieldnames(ChunkData.EventDurations);
for stateNum=1:size(arousalStates,1)
    numEvents=size(ChunkData.EventDurations.(arousalStates{stateNum}).eventLengths,1);
    ChunkData.ArousalStates.(arousalStates{stateNum}).survivor=[];
    ChunkData.ArousalStates.(arousalStates{stateNum}).eventDuration=[4:1:500];
    for durNum=1:length(ChunkData.ArousalStates.(arousalStates{stateNum}).eventDuration)
        ChunkData.ArousalStates.(arousalStates{stateNum}).survivor(durNum)=(sum(ChunkData.EventDurations.(arousalStates{stateNum}).eventLengths>=ChunkData.ArousalStates.(arousalStates{stateNum}).eventDuration(durNum))/numEvents)*100;
    end
figure(303); hold on;
plot( ChunkData.ArousalStates.(arousalStates{stateNum}).eventDuration,ChunkData.ArousalStates.(arousalStates{stateNum}).survivor)
lgndStr=strrep(arousalStates{stateNum},'_',' ');
theLegend{stateNum}=lgndStr;
end
figure(303);
legend(theLegend);
xlabel('Time in state (s)');
ylabel('Percentage of events (%)');

fracNames=fieldnames(ChunkData.BehaviorFractions);
for fracNum=1:length(fracNames)
    figure(304); hold on;
    bar(fracNum,(ChunkData.BehaviorFractions.(fracNames{fracNum})*100));
    tickStr{fracNum}=fracNames{fracNum}(1:(end-4));
end
title('Percentage of time in Arousal State')
ylabel('Percent (%)');
xlabel('Arousal State');
xticks(1:1:length(fracNames));
xticklabels(tickStr);
end