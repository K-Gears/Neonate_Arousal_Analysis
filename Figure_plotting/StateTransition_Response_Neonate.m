%% READ ME
% This script plots the time course of HbT and EMG level changes around changes in 
% arousal state from population level data structures

PopData_table=[];
animalData_table=[];
theInds=[15*30, 25*30];
startleInds=[10*30, 12*30];
anAges=fieldnames(PopData);
for anNum=1:length(anAges)
    popAvg=[];
    popStd=[];
    popSize=[];
    theAge=[];
    transName=fieldnames(PopData.(anAges{anNum}).stateTransitions);
    for transNum=1:length(transName)
        test=abs(all(PopData.(anAges{anNum}).stateTransitions.(transName{transNum}).IOS.forepaw.dHbT,2)-1);
        if max(test)==1
        test=logical(test);
        PopData.(anAges{anNum}).stateTransitions.(transName{transNum}).IOS.forepaw.dHbT(test,:)=NaN;
        end
        animalAvg{anNum,transNum}=nanmean(PopData.(anAges{anNum}).stateTransitions.(transName{transNum}).IOS.forepaw.dHbT(:,(theInds(1):theInds(2))),2);
        popAvg(transNum)=nanmean(animalAvg{anNum,transNum});
        popStd(transNum)=std(animalAvg{anNum,transNum},'omitnan');
        popSize(transNum)=sum(~isnan(animalAvg{anNum,transNum}));
        stimNames{anNum,transNum}=transName{transNum};
    end
    for num=1:length(transName)
        theAge{num,1}=anAges{anNum};
    end
    if anNum==1
        animalAvg{anNum,transNum+1}=nanmean(PopData.P10.Startle.IOS(:,(startleInds(1):startleInds(2))),2);
        popAvg(transNum+1)=nanmean(animalAvg{anNum,transNum+1});
        popStd(transNum+1)=std(animalAvg{anNum,transNum+1},'omitnan');
        popSize(transNum+1)=sum(~isnan(animalAvg{anNum,transNum+1}));
        stimNames{anNum,transNum+1}='Myoclonic_Twitch';
        theAge{length(transName)+1,1}=anAges{anNum};
        transName{length(transName)+1}='Myoclonic_Twitch';
                
        varName={'Transition_Type','Age','Population_Avg','Population_Std','Population_Size'};
        PopData_table=table(transName,theAge,popAvg',popStd',popSize','VariableNames',varName);
    else
        tempTable=[];
        tempTable=table(transName,theAge,popAvg',popStd',popSize','VariableNames',varName);
        PopData_table=[PopData_table;tempTable];
    end
end

%% P10 state change averages
Inds=[1,3,4,6,9,10,13];
TransitionLabel=PopData_table.Transition_Type(Inds,:);
TransitionAvg=PopData_table.Population_Avg(Inds,:);
[sortedAvg,sortedInds]=sort(TransitionAvg,'descend');
figure(303); hold on;
bar(sortedAvg);
xticks([1:1:length(sortedAvg)]);
for num=1:length(sortedInds)
theLabel{num}=strrep(TransitionLabel{sortedInds(num)},'_',' ');
end
xticklabels(theLabel);
for indNum=1:length(Inds)
    xVals=[];
    xVals(1:length(animalAvg{1,Inds(sortedInds(indNum))}))=indNum;
    scatter(xVals,animalAvg{1,Inds(sortedInds(indNum))},'k','filled');
end
title('P10 State transition [HbT]')
ylabel('[HbT]');
xlabel('Arousal State');

%% P15 State Change Averages
Inds=[14,15,18,19,20,22,23];
TransitionLabel=PopData_table.Transition_Type(Inds,:);
TransitionAvg=PopData_table.Population_Avg(Inds,:);
[sortedAvg,sortedInds]=sort(TransitionAvg,'descend');
figure(303); hold on;
bar(sortedAvg);
xticks([1:1:length(sortedAvg)]);
for num=1:length(sortedInds)
theLabel{num}=strrep(TransitionLabel{sortedInds(num)},'_',' ');
end
xticklabels(theLabel);
for indNum=1:length(Inds)
    xVals=[];
    xVals(1:length(animalAvg{2,(Inds(sortedInds(indNum))-13)}))=indNum;
    scatter(xVals,animalAvg{2,(Inds(sortedInds(indNum))-13)},'k','filled');
end
title('P15 State transition [HbT]')
ylabel('[HbT]');
xlabel('Arousal State');