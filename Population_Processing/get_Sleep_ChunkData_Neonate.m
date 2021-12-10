function [PopulationData]=get_Sleep_ChunkData_Neonate(~)
%% READ ME
% This script aggregates processed and scored arousal state datasets of
% neonate animals and organizes them by age before calculating population
% level averages and responses
%Subfunctions: ChunkArousalState001, Chunk_StateChanges_001, Average_AgeGroups_NeonateSleep_001
Drive_IDs={'E:','F:','G:'};%
folderName='NeonateSleepIndividualAnimals';
PopulationData=[];
for driveNum=1:length(Drive_IDs)
    anNames=[];
    filDate=[];
    saveDate=[];
    anAge=[];
    theDir=[Drive_IDs{driveNum} '\' folderName];
    cd(theDir);
    filesChunkData=dir(fullfile(theDir,'**','*_ArousalStateChunkData_*.mat'));
    for sampleNum=1:size(filesChunkData,1)
        dashFind=strfind(filesChunkData(sampleNum).name,'_');
        dotFind=strfind(filesChunkData(sampleNum).name,'.');
        slashFind=strfind(filesChunkData(sampleNum).folder,'\');
        anNames{sampleNum}=filesChunkData(sampleNum).name(1:(dashFind(2)-1));
        filDate{sampleNum}=filesChunkData(sampleNum).name((dashFind(3)+1):(dashFind(4)-1));
        saveDate{sampleNum}=filesChunkData(sampleNum).name((dashFind(5)+1):(dotFind-1));
        anAge{sampleNum}=filesChunkData(sampleNum).folder((slashFind(3)+1):(slashFind(4)-1));
    end
    uniqueAnimals=unique(anNames);
    for anNum=1:size(uniqueAnimals,2)
        dateTime=[];
        saveNum=[];
        anFind=strcmpi(anNames,uniqueAnimals{anNum});
        anInds=find(anFind==1);
        recordingDates=filDate(anFind);
        uniqueDates=unique(recordingDates);
        for dateNum=1:size(uniqueDates,2)
            dateFind=strcmpi(filDate,uniqueDates{dateNum});
            savefind=logical(anFind.*dateFind);
            tempSaves=saveDate(savefind);
            for nxt=1:size(tempSaves,2)
                datestr=strrep(tempSaves{nxt},'_','-');
                dateTime(nxt)=str2num(datestr(13:18));
                saveNum(nxt)=datenum(datestr(1:11));
            end
            dateLogic=saveNum==max(saveNum);
            if sum(dateLogic)>1
                filInd=find(dateTime(dateLogic)==max(dateTime(dateLogic)));
                animalAge=anAge{anInds(filInd)};
            else
                filInd=find(dateLogic==1);
                animalAge=anAge{anInds(filInd)};
            end
        end
        cd(filesChunkData(anInds(filInd)).folder);
        load(filesChunkData(anInds(filInd)).name);
        fprintf(['Analyzing ' Drive_IDs{driveNum} ' ' num2str(anNum) ' of ' num2str(size(uniqueAnimals,2)) ' ' animalAge ' ' uniqueAnimals{anNum} ' ' saveDate{anInds(filInd)} '\n'])
        subfields=fieldnames(ChunkData);
        if ~isfield(PopulationData,animalAge)
            PopulationData.(animalAge)=[];
        end
        for subNum=1:size(subfields,1)
            
            if strcmpi(subfields{subNum},'Params')
                if ~isfield(PopulationData.(animalAge),subfields{subNum})
                    PopulationData.(animalAge).(subfields{subNum})=ChunkData.(subfields{subNum});
                end
            end
            if ~isfield(PopulationData.(animalAge),subfields{subNum})
                PopulationData.(animalAge).(subfields{subNum})=[];
            end
            
            if strcmpi(subfields{subNum},'ArousalStates')
                [PopulationData]=Chunk_ArousalState_Neonate(ChunkData,animalAge,subfields,subNum,PopulationData);
            end
            
            if strcmpi(subfields{subNum},'StateChanges')
                [PopulationData]=Chunk_StateChanges_Neonate(ChunkData,animalAge,subfields,subNum,PopulationData);
            end
            
            if strcmpi(subfields{subNum},'EventDurations')
                stateFields=fieldnames(ChunkData.(subfields{subNum}));
                for fieldNum=1:size(stateFields,1)
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}),stateFields{fieldNum})
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{fieldNum}).eventLengths={};
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{fieldNum}).eventLengths,1)+1;
                    end
                    PopulationData.(animalAge).(subfields{subNum}).(stateFields{fieldNum}).eventLengths{eventCount,1}=ChunkData.(subfields{subNum}).(stateFields{fieldNum}).eventLengths;
                end
            end
            
            if strcmpi(subfields{subNum},'BehaviorFractions')
                stateFields=fieldnames(ChunkData.(subfields{subNum}));
                for fieldNum=1:size(stateFields,1)
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}),stateFields{fieldNum})
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{fieldNum})=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{fieldNum}),1)+1;
                    end
                    PopulationData.(animalAge).(subfields{subNum}).(stateFields{fieldNum})(eventCount)=ChunkData.(subfields{subNum}).(stateFields{fieldNum});
                end
            end
                
            
            if strcmpi(subfields{subNum},'Hypnogram')
                if ~isfield(PopulationData.(animalAge),subfields{subNum})
                    PopulationData.(animalAge).(subfields{subNum}){1}=ChunkData.(subfields{subNum});
                else
                    anCount=size(PopulationData.(animalAge).(subfields{subNum}),1)+1;
                    PopulationData.(animalAge).(subfields{subNum}){anCount,1}=ChunkData.(subfields{subNum});
                end
            end
            
            
            
        end                        
    end
end
[PopulationData]=Average_AgeGroups_Sleep_Neonate(PopulationData);
    
end
            
            