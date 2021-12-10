function [PopData,Averages]=get_stimulus_StateChange_Neonate(~)
%% Constants
arousalBin_size=5;
Drive_IDs={'E:','F:','G:'};%
folderName='NeonateSleepIndividualAnimals';
for driveNum=1:length(Drive_IDs)
    cd([Drive_IDs{driveNum} '\' folderName]);
    dateFolders=dir;
    tf=ismember({dateFolders.name},{'.','..'});
    dateFolders(tf)=[];
    thedir=[dateFolders.isdir];
    dateFolders(thedir==0)=[];
    for dateNum=1:length(dateFolders)
        cd([dateFolders(dateNum).folder '\' dateFolders(dateNum).name]);
        ageFolder=dir;
        tf=ismember({ageFolder.name},{'.','..'});
        ageFolder(tf)=[];
        thedir=[ageFolder.isdir];
        ageFolder(thedir==0)=[];
        for ageNum=1:length(ageFolder)
            cd([ageFolder(ageNum).folder '\' ageFolder(ageNum).name]);
            animalFolder=dir;
            tf=ismember({animalFolder.name},{'.','..'});
            animalFolder(tf)=[];
            thedir=[animalFolder.isdir];
            animalFolder(thedir==0)=[];
            for anNum=1:length(animalFolder)
                ProcEvents.Sol.Contra.eventBins=[];
                ProcEvents.Sol.Contra.upsampleEvents=[];
                stimCount=1;
                ProcEvents.Opto.Flash.eventBins=[];
                ProcEvents.Opto.Flash.upsampleEvents=[];
                flashCount=1;
                cd([animalFolder(anNum).folder '\' animalFolder(anNum).name]);
                runTime=tic;
                theDir=cd;
                ManualScore_Files=dir(fullfile(theDir,'**','*_TrainingData*.mat'));
                theDate=[];
                for filNum=1:size(ManualScore_Files,1)
                    theUnderscores=strfind(ManualScore_Files(filNum).name,'_');
                    theDate{filNum,1}=ManualScore_Files(filNum).name((theUnderscores(3)+1):(theUnderscores(7)-1));
                end
                fileDates=unique(theDate);
                if exist('filList','var')
                    clear filList
                end
                for filNum=1:size(fileDates,1)
                    filInd=[];
                    compFiles=find(strcmpi(theDate,fileDates{filNum}));
                    for compNum=1:size(compFiles,1)
                    theDot=strfind(ManualScore_Files(compNum).name,'.');
                    filInd(compNum)=str2double(ManualScore_Files(compNum).name((theDot-3):(theDot-1)));
                    end
                    numericTag=~isnan(filInd);
                    if max(numericTag)==0
                        useFil=1;
                    else
                        tempFil=filInd(numericTag);
                        useInd=find(filInd==max(tempFil));
                        useFil=compFiles(useInd);
                    end
                    filList(filNum,1)=ManualScore_Files(useFil);
                end
                if exist('filList','var')
                ManualScore_Files=filList;
                end
                for filNum=1:size(ManualScore_Files,1)
                    fprintf(['analyzing file ' num2str(filNum) ' of ' num2str(size(ManualScore_Files,1)) ' \n']) 
                    load(ManualScore_Files(filNum).name); %This file contains all arousal state scoring
                    dashFind=strfind(ManualScore_Files(filNum).name,'_');
                    an_Name=ManualScore_Files(filNum).name(1:(dashFind(2)-1));
                    an_Hem=ManualScore_Files(filNum).name((dashFind(2)+1):(dashFind(3)-1));
                    an_Date=ManualScore_Files(filNum).name((dashFind(3)+1):(dashFind(4)-1));
                    an_Time=ManualScore_Files(filNum).name((dashFind(4)+1):(dashFind(7)-1));
                    fprintf(['Loading '  an_Name '_' an_Hem '_' an_Date '_' an_Time '_SleepScoringData.mat\n'])
                    theData=load([an_Name '_' an_Hem '_' an_Date '_' an_Time '_SleepScoringData.mat'],'StimulusTriggers','IOS','Opto');
                    
                    %% Define behavior state of each bin
                    ActiveAwake=strcmpi(TrainingTable.behavState,'Active Awake');
                    QuiescentAwake=strcmpi(TrainingTable.behavState,'Quiescent Awake');
                    ActiveAsleep=strcmpi(TrainingTable.behavState,'Active Asleep');
                    QuiescentAsleep=strcmpi(TrainingTable.behavState,'Quiescent Asleep');
                    
                    %% Convert logicals in to numeric values in single array
                    tempArousal=[];
                    tempArousal(1:length(TrainingTable.behavState))=NaN;
                    tempArousal(ActiveAwake)=4;
                    tempArousal(ActiveAsleep)=1;
                    tempArousal(QuiescentAwake)=3;
                    tempArousal(QuiescentAsleep)=2;
                    %% Whisker Stimulus 
                    solTime=theData.StimulusTriggers.Sol.solenoidContralateral;
                    solBin=ceil(solTime/arousalBin_size);
                    if ~isempty(solTime)
                        test=[];
                    end
                    for binNum=1:size(solBin,2)
                        binWin=(solBin(binNum)-1):(solBin(binNum)+1);
                        stimTime=solTime(binNum)-((solBin(binNum)-1)*arousalBin_size); %Where in 5s stimulus bin does stimuli occur
                        smallBin=ceil(stimTime); %within upsampled data where does the stimulus occur at 1s resolution
                        stimBin=smallBin+5; %5 1 second bins will make up the pre stim period followed by smallBin to stim onset 
                        
                        upsampleArousal_stim=upsample(tempArousal(binWin),5);
                        upsampleArousal_stim(1:(stimBin-1))=tempArousal(1);
                        upsampleArousal_stim(stimBin:end)=tempArousal(end);
                        
                        ProcEvents.Sol.Contra.eventBins(stimCount,:)=tempArousal(binWin);
                        ProcEvents.Sol.Contra.upsampleEvents(stimCount,:)=upsampleArousal_stim;
                        stimCount=stimCount+1;
                    end
                    %% OptoStimulus
                    flashTime=theData.StimulusTriggers.Opto.StimWindows;
                    flashBin=ceil(flashTime/arousalBin_size);
                    for binNum=1:size(flashBin,2)
                        binWin=(flashBin(binNum)-1):(flashBin(binNum)+1);
                        stimTime=flashTime(binNum)-((flashBin(binNum)-1)*arousalBin_size); %Where in 5s stimulus bin does stimuli occur
                        smallBin=ceil(stimTime); %within upsampled data where does the stimulus occur at 1s resolution
                        stimBin=smallBin+5; %5 1 second bins will make up the pre stim period followed by smallBin to stim onset
                        
                        upsampleArousal_Opto=upsample(tempArousal(binWin),5);
                        upsampleArousal_Opto(1:(stimBin-1))=tempArousal(1);
                        upsampleArousal_Opto(stimBin:end)=tempArousal(end);
                        
                        ProcEvents.Opto.Flash.eventBins(flashCount,:)=tempArousal(binWin);
                        ProcEvents.Opto.Flash.upsampleEvents(flashCount,:)=upsampleArousal_Opto;
                        flashCount=flashCount+1;
                    end
                end
                %% Define behavior state of each bin
                ActiveAwake_Opto=ProcEvents.Opto.Flash.upsampleEvents==4;
                QuiescentAwake_Opto=ProcEvents.Opto.Flash.upsampleEvents==3;
                QuiescentAsleep_Opto=ProcEvents.Opto.Flash.upsampleEvents==2;
                ActiveAsleep_Opto=ProcEvents.Opto.Flash.upsampleEvents==1;
                
                ActiveAwake_Stim=ProcEvents.Sol.Contra.upsampleEvents==4;
                QuiescentAwake_Stim=ProcEvents.Sol.Contra.upsampleEvents==3;
                QuiescentAsleep_Stim=ProcEvents.Sol.Contra.upsampleEvents==2;
                ActiveAsleep_Stim=ProcEvents.Sol.Contra.upsampleEvents==1;
                
                %% Calculate Probability of state
                probActiveAwake_Opto=sum(ActiveAwake_Opto,1)/size(ActiveAwake_Opto,1);
                probQuiescentAwake_Opto=sum(QuiescentAwake_Opto,1)/size(QuiescentAwake_Opto,1);
                probQuiescentAsleep_Opto=sum(QuiescentAsleep_Opto,1)/size(QuiescentAsleep_Opto,1);
                probREM_Opto=sum(ActiveAsleep_Opto,1)/size(ActiveAsleep_Opto,1);
                
                probActiveAwake_Stim=sum(ActiveAwake_Stim,1)/size(ActiveAwake_Stim,1);
                probQuiescentAwake_Stim=sum(QuiescentAwake_Stim,1)/size(QuiescentAwake_Stim,1);
                probQuiescentAsleep_Stim=sum(QuiescentAsleep_Stim,1)/size(QuiescentAsleep_Stim,1);
                probREM_Stim=sum(ActiveAsleep_Stim,1)/size(ActiveAsleep_Stim,1);
                
%                 figure(1);hold on; plot(probActiveAwake_Opto); plot(probQuiescent_Opto); plot(probREM_Opto);
%                 title('Opto Stimulus'); ylabel('Probability of state'); legend({'Active Awake','Quiescent','REM'});
%                 
%                 figure(2);hold on; plot(probActiveAwake_Stim); plot(probQuiescent_Stim); plot(probREM_Stim);
%                 title('Whisker Stimulus'); ylabel('Probability of state'); legend({'Active Awake','Quiescent','REM'});
               PopData.(ageFolder(ageNum).name).(an_Name).Opto_Stim.EventData=ProcEvents.Opto.Flash.upsampleEvents;
               PopData.(ageFolder(ageNum).name).(an_Name).Opto_Stim.ArousalProbability.ActiveAwake=probActiveAwake_Opto;
               PopData.(ageFolder(ageNum).name).(an_Name).Opto_Stim.ArousalProbability.QuiescentAwake=probQuiescentAwake_Opto;
               PopData.(ageFolder(ageNum).name).(an_Name).Opto_Stim.ArousalProbability.QuiescentAsleep=probQuiescentAsleep_Opto;
               PopData.(ageFolder(ageNum).name).(an_Name).Opto_Stim.ArousalProbability.REM=probREM_Opto;
               
               PopData.(ageFolder(ageNum).name).(an_Name).Whisker_Stim.EventData=ProcEvents.Sol.Contra.upsampleEvents;
               PopData.(ageFolder(ageNum).name).(an_Name).Whisker_Stim.ArousalProbability.ActiveAwake=probActiveAwake_Stim;
               PopData.(ageFolder(ageNum).name).(an_Name).Whisker_Stim.ArousalProbability.QuiescentAwake=probQuiescentAwake_Stim;
               PopData.(ageFolder(ageNum).name).(an_Name).Whisker_Stim.ArousalProbability.QuiescentAsleep=probQuiescentAsleep_Stim;
               PopData.(ageFolder(ageNum).name).(an_Name).Whisker_Stim.ArousalProbability.REM=probREM_Stim;

            end
        end
    end
end
[Averages]=getPopulationAverages(PopData);
end
%% Developmental Age averages
function [Averages]=getPopulationAverages(PopData)
Averages=[];
theages=fieldnames(PopData);
for ageNum=1:size(theages,1)
    if ~isfield(Averages,theages{ageNum})
        Averages.(theages{ageNum})=[];
    end
    animalnames=fieldnames(PopData.(theages{ageNum}));
    for animalNum=1:size(animalnames,1)
        stimTypes=fieldnames(PopData.(theages{ageNum}).(animalnames{animalNum}));
        for stimNum=1:size(stimTypes,1)
            if ~isfield(Averages.(theages{ageNum}),stimTypes{stimNum})
                Averages.(theages{ageNum}).(stimTypes{stimNum})=[];
            end
            stateNames=fieldnames(PopData.(theages{ageNum}).(animalnames{animalNum}).(stimTypes{stimNum}).ArousalProbability);
            for stateNum=1:size(stateNames,1)
                if ~isfield(Averages.(theages{ageNum}).(stimTypes{stimNum}),'Probability_in_State')
                    Averages.(theages{ageNum}).(stimTypes{stimNum}).Probability_in_State=[];
                end
                if ~isfield(Averages.(theages{ageNum}).(stimTypes{stimNum}).Probability_in_State,stateNames{stateNum})
                    Averages.(theages{ageNum}).(stimTypes{stimNum}).Probability_in_State.(stateNames{stateNum})=[];
                end
                if ~isempty(PopData.(theages{ageNum}).(animalnames{animalNum}).(stimTypes{stimNum}).ArousalProbability.(stateNames{stateNum}))
                    if isempty(Averages.(theages{ageNum}).(stimTypes{stimNum}).Probability_in_State.(stateNames{stateNum}))
                        Averages.(theages{ageNum}).(stimTypes{stimNum}).Probability_in_State.(stateNames{stateNum})=PopData.(theages{ageNum}).(animalnames{animalNum}).(stimTypes{stimNum}).ArousalProbability.(stateNames{stateNum});
                    else
                        anCount=size(Averages.(theages{ageNum}).(stimTypes{stimNum}).Probability_in_State.(stateNames{stateNum}),1)+1;
                        Averages.(theages{ageNum}).(stimTypes{stimNum}).Probability_in_State.(stateNames{stateNum})(anCount,:)=PopData.(theages{ageNum}).(animalnames{animalNum}).(stimTypes{stimNum}).ArousalProbability.(stateNames{stateNum});
                    end
                end
                if animalNum==size(animalnames,1)
                    Averages.(theages{ageNum}).(stimTypes{stimNum}).PopulationAverages.Probability_in_State.(stateNames{stateNum})=mean(Averages.(theages{ageNum}).(stimTypes{stimNum}).Probability_in_State.(stateNames{stateNum}),1);
                end
            end
        end
    end
end
        
end   