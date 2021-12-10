function plot_Hypnogram_Sleep_Neonate
%% READ ME
%This function creates age group separated hypnograms plotting the arousal
%state of each animal within an age group for the duration of its imaging
%session
%Subscripts: brewermap
driveNames={'F:\','G:\'};%'E:\',
filNames={};
filAge={};
filFolder={};
for driveNum=1:length(driveNames)
    datefolders=dir([driveNames{driveNum} 'NeonateSleepIndividualAnimals']);
    datefolders(~[datefolders.isdir])=[];
    tf=ismember({datefolders.name},{'.','..','Ignore','PopulationData'});
    datefolders(tf)=[];
    for dateNum=1:size(datefolders,1)
        agefolders=dir([datefolders(dateNum).folder '\' datefolders(dateNum).name]);
        agefolders(~[agefolders.isdir])=[];
        tf=ismember({agefolders.name},{'.','..'});
        agefolders(tf)=[];
        for ageNum=1:size(agefolders,1)
            age=agefolders(ageNum).name;
            anfolders=dir([agefolders(ageNum).folder '\' agefolders(ageNum).name]);
            anfolders(~[anfolders.isdir])=[];
            tf=ismember({anfolders.name},{'.','..','Ignore','PopulationData'});
            anfolders(tf)=[];
            for anNum=1:size(anfolders,1)
                cd([anfolders(anNum).folder '\' anfolders(anNum).name]);
                chunkFil=dir('*_TrainingData_003*');
                if isempty(chunkFil)
                    chunkFil=dir('*_TrainingData_002*');
                end
                if isempty(chunkFil)
                    chunkFil=dir('*_TrainingData*');
                end
                for filNum=1:size(chunkFil,1)
                    filName{filNum}=chunkFil(filNum).name;
                    tempAge{filNum}=age;
                    tempFolder{filNum}=chunkFil(filNum).folder;
                end
                filNames=cat(2,filNames,filName);
                filAge=cat(2,filAge,tempAge);
                filFolder=cat(2,filFolder,tempFolder);
                filName={};
                tempAge={};
                tempFolder={};
            end
        end
    end
end
anAges=unique(filAge);
for ageNum=1%1:2%length(anAges)
    filInds=find(strcmpi(filAge,anAges{ageNum})==1);
    for indNum=1:length(filInds)
        ageFolders{indNum}=filFolder{filInds(indNum)};
    end
    theFolders=unique(ageFolders);
       for foldNum=1:size(theFolders,2)
        cd(theFolders{foldNum});
        fileCount(foldNum)=length(find(strcmpi(filFolder,theFolders{foldNum})==1));
       end
       [sortedCounts,orderInds]=sort(fileCount,'descend');
     folderCount=1;   
    for foldNum=orderInds%1:size(theFolders,2)
        cd(theFolders{foldNum});
        fileNums=find(strcmpi(filFolder,theFolders{foldNum})==1);
        filenames={};
        for numInd=1:length(fileNums)
            filenames{numInd}=filNames{fileNums(numInd)};
        end
        Hypnogram=[];
        for filNum=1:size(filenames,2)
            underscores=strfind(filenames{filNum},'_');
            if filNum>1
                %% Get the date and time of file writing
                filDate=filenames{filNum}((underscores(3)+1):(underscores(4)-1));
                filyr=['20' filDate(1:2)];
                filmo=filDate(3:4);
                filday=filDate(5:6);
                filTime=filenames{filNum}((underscores(4)+1):(underscores(7)-1));
                filTime=strrep(filTime(1:(end-2)),'_',':');
                
                filDate=datetime([filyr '-' filmo '-' filday ' ' filTime]);
                %% Get date and time of previous file
                filLead=filenames{filNum-1}((underscores(3)+1):(underscores(4)-1));
                filyr=['20' filLead(1:2)];
                filmo=filLead(3:4);
                filday=filLead(5:6);
                filTime=filenames{filNum-1}((underscores(4)+1):(underscores(7)-1));
                filTime=strrep(filTime(1:(end-2)),'_',':');
                filLead=datetime([filyr '-' filmo '-' filday ' ' filTime]);
                %% Determine time between files
                fileDur=minutes(5); %duration of files
                binSize=seconds(5); %size of bins for sleep scoring
                filDiff=split(between((filLead+fileDur),filDate),'Time'); %time betweem end of previous file and start of new file
                binSpace=ceil(filDiff/binSize);% number of 5s bins between last recorded data of old file and new file
            end
            
            load(filenames{filNum});
            %% Define behavior state of each bin
            ActiveAwake=strcmpi(TrainingTable.behavState,'Active Awake');
            QuiescentAwake=strcmpi(TrainingTable.behavState,'Quiescent Awake');
            ActiveAsleep=strcmpi(TrainingTable.behavState,'Active Asleep');
            QuiescentAsleep=strcmpi(TrainingTable.behavState,'Quiescent Asleep');
            
            %% Convert logicals in to numeric values in single array
            tempHypnogram=[];
            tempHypnogram(1:length(TrainingTable.behavState))=NaN;
            tempHypnogram(ActiveAwake)=4;
            tempHypnogram(ActiveAsleep)=1;
            tempHypnogram(QuiescentAwake)=3;
            tempHypnogram(QuiescentAsleep)=2;
            %% Add save spacer in to hypnogram
            if filNum>1
                saveSpacer=[];
                saveSpacer(1:binSpace)=NaN;% add between trials to account for saving time
                Hypnogram=horzcat(Hypnogram,saveSpacer);
            end
            %% Concatenate new file data to hypnogram
            Hypnogram=horzcat(Hypnogram,tempHypnogram);
        end
%         firstAwake=find(Hypnogram==4,1,'first');
%         firstQuiescent=find(Hypnogram==3,1,'first');
%         firstNREM=find(Hypnogram==2,1,'first');
%         firstREM=find(Hypnogram==1,1,'first');
        if folderCount==1
            hypnoLength=length(Hypnogram);
            folderCount=folderCount+1;
        else
            currentLength=length(Hypnogram);
            Hypnogram(currentLength+1:hypnoLength)=NaN;
        end
        hypnoTime=(1:length(Hypnogram))*5;
        barHeight(1:length(Hypnogram))=1;
        tempMap_1=brewermap(11,'RdGy');
        tempMap_2=brewermap(11,'RdBu');
%         tempMap=[102/255 0 204/255;0 128/255 255/255;255/255 51/255 255/255;255/255 51/255 100/255];
%         tempMap=brewermap(12,'RdBu');
        
%         colors(1,:)=tempMap(2,:);
%         colors(2,:)=tempMap(4,:);
%         colors(3,:)=tempMap(8,:);
%         colors(4,:)=tempMap(10,:);
        colors(1,:)=tempMap_2(2,:);%tempMap(4,:);
        colors(2,:)=tempMap_2(9,:);%tempMap(1,:);
        colors(3,:)=tempMap_1(7,:);%tempMap(3,:);
        colors(4,:)=tempMap_1(9,:);%tempMap(2,:);
        colors(5,:)=[1 1 1];
        Hypnogram(isnan(Hypnogram))=5;
        
        figure(ageNum);subplot(length(orderInds),1,foldNum);hypnoPlot=imagesc(hypnoTime,(0:1),Hypnogram);colormap(colors);caxis([1 5]);%bar(hypnoTime,barHeight,1);
        dashfind=strfind(theFolders{foldNum},'\');
        anLabel=strrep(theFolders{foldNum}((dashfind(end)+1):end),'_', ' ');
        ylabel(anLabel);
        theLabel=get(gca,'YLabel');
        set(theLabel,'rotation',0,'VerticalAlignment','middle','HorizontalAlignment','right');
        yticks([]);
        if foldNum==4
            xlabel('Time(sec)');
%             ageLabel=anFolders(anNum).folder((length(anFolders(anNum).folder)-2):end);
            age=anAges{ageNum};
            sgtitle([age ' arousal state hypnogram']);
            xticks([0,(0.5*60*60),(1*60*60),(1.5*60*60),(2*60*60),(3*60*60)]);
            xticklabels({'0','0.5hr','1hr','1.5hr','2hr','3hr'});
        else
            xticks([]);
        end
        xlim([0 7200]);
    end
end
end

