function [PopulationData]=Chunk_ArousalState_001(ChunkData,animalAge,subfields,subNum,PopulationData)
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
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),[finalFields{finalNum} '_HistogramCounts'])
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).([finalFields{finalNum} '_HistogramCounts'])=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).([finalFields{finalNum} '_HistogramCounts']),1)+1;
                    end
                    if strcmpi(dataFields{dataNum},'IOS')
                        figure(101);
                        tempHist=histogram(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).(finalFields{finalNum}),'BinEdges',[-150:1:150],'Normalization','pdf');
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).([finalFields{finalNum} '_HistogramCounts'])(eventCount,:)=tempHist.Values;
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}).([finalFields{finalNum} '_BinEdges'])=tempHist.BinEdges;
                    end
                end
            else
                if strcmpi(dataFields{dataNum},'LFP')
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}),[signalTypes{signalNum} '_HistogramCounts'])
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).([signalTypes{signalNum} '_HistogramCounts'])=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).([signalTypes{signalNum} '_HistogramCounts']),1)+1;
                    end
                    figure(103);
                    altHist=histogram(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),'BinEdges',[-1500:1:1500],'Normalization','pdf');
                    PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).([signalTypes{signalNum} '_HistogramCounts'])(eventCount,:)=altHist.Values;
                    PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).([signalTypes{signalNum} '_BinEdges'])=altHist.BinEdges;
                end
                if strcmpi(dataFields{dataNum},'EMG')
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}),[signalTypes{signalNum} '_HistogramCounts'])
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).([signalTypes{signalNum} '_HistogramCounts'])=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).([signalTypes{signalNum} '_HistogramCounts']),1)+1;
                    end
                    figure(104);
                    emgHist=histogram(real(log10(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}))),'BinEdges',[-10:0.01:10],'Normalization','pdf');
                    PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).([signalTypes{signalNum} '_HistogramCounts'])(eventCount,:)=emgHist.Values;
                    PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).([signalTypes{signalNum} '_BinEdges'])=emgHist.BinEdges;
                end
                
                if strcmpi(dataFields{dataNum},'Spectrograms')
                    if ~isfield(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}),signalTypes{signalNum})
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})=[];
                        eventCount=1;
                    else
                        eventCount=size(PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),1)+1;
                    end
                    if signalNum==1
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})(eventCount,:)= mean(mean(ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum}),2),3);
                    else
                        PopulationData.(animalAge).(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum})= ChunkData.(subfields{subNum}).(stateFields{stateNum}).(dataFields{dataNum}).(signalTypes{signalNum});
                    end
                end
            end
        end
    end
end
end