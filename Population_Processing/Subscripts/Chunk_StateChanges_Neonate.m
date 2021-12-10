function [PopulationData]=Chunk_StateChanges_001(ChunkData,animalAge,subfields,subNum,PopulationData)
%% READ ME
%Use this function to aggregate physiological data of different arousal
%states at different developmental ages

%% Get Animal Arousal States
stateFields=fieldnames(ChunkData.(subfields{subNum}));
for stateNum=1:size(stateFields,1)
    if ~isfield(PopulationData.(animalAge).(subfields{subNum}),stateFields{stateNum})
        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum})=[];
    end
    dataFields=fieldnames(ChunkData.(subfields{subNum}).(stateFields{stateNum}));
    for dataNum=1:size(dataFields,1)
        if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}),dataFields{dataNum})
            PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum})=[];
        end
        signalTypes=fieldnames(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}));
        for signalNum=1:size(signalTypes,1)
            if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}),signalTypes{signalNum})
                PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})=[];
            end
            if isstruct(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}))
                finalFields=fieldnames(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}));
                for finalNum=1:size(finalFields,1)
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),finalFields{finalNum})
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).(finalFields{finalNum})=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).(finalFields{finalNum}),1)+1;
                    end
                    if strcmpi(dataFields{dataNum},'IOS')
                        if ~strcmpi(signalTypes{signalNum},'Pixelwise')
                            PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).(finalFields{finalNum})(eventCount,:)=mean(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).(finalFields{finalNum}),1);
                        end
                    end
                end
            else
                if strcmpi(dataFields{dataNum},'LFP')
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}),signalTypes{signalNum})
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),1)+1;
                    end
                   PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})(eventCount,:)=mean(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),1);
                end
                if strcmpi(dataFields{dataNum},'EMG')
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}),signalTypes{signalNum})
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum} )=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),1)+1;
                    end
                   PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})(eventCount,:)=mean(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),1);
                end
                
                if strcmpi(dataFields{dataNum},'Spectrograms')
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}),signalTypes{signalNum})
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),3)+1;
                    end
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})(:,:,eventCount)= mean(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),3);
                end
            end
        end
    end
end
end