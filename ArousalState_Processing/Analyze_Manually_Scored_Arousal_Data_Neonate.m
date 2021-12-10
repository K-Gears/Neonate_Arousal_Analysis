function Analyze_Manually_Scored_Arousal_Data_Neonate(~)
%% READ ME
% This script recursively searches all hard drives in variable 'Drive_IDs'
% for files containing manually scored arousal state data
% '*_TrainingData_002.mat' and loads all IOS, EMG and LFP files to perform
% arousal state based segmentation of data to generate arousal state
% histograms, plots of time and duration in arousal state  and arousal state transition plots.
% REQUIRED SUBSCRIPTS:
%chunk_MyoclonicTwitch_Data_001


%% Chunk Data on each drive
Drive_IDs={'E:','F:','G:'};%
folderName='NeonateSleepIndividualAnimals';
for driveNum=2%1:length(Drive_IDs)
    cd([Drive_IDs{driveNum} '\' folderName]);
    dateFolders=dir;
    dateFolders(~[dateFolders.isdir])=[];
    tf=ismember({dateFolders.name},{'.','..'});
    dateFolders(tf)=[];
    for dateNum=3%1:2%:length(dateFolders)
        cd([dateFolders(dateNum).folder '\' dateFolders(dateNum).name]);
        ageFolder=dir;
        ageFolder(~[ageFolder.isdir])=[];
        tf=ismember({ageFolder.name},{'.','..'});
        ageFolder(tf)=[];
        for ageNum=1:length(ageFolder)
            cd([ageFolder(ageNum).folder '\' ageFolder(ageNum).name]);
            animalFolder=dir;
            animalFolder(~[animalFolder.isdir])=[];
            tf=ismember({animalFolder.name},{'.','..'});
            animalFolder(tf)=[];
            for anNum=1:length(animalFolder)
                cd([animalFolder(anNum).folder '\' animalFolder(anNum).name]);
                
                runTime=tic;
                theDir=cd;
                ManualScore_Files=dir(fullfile(theDir,'**','*_TrainingData_003.mat'));
                ChunkData.ArousalStates=[];
                ChunkData.StateChanges=[];
                ChunkData.Hypnogram=[];
                %% Analyze each assigned arousal state file
                for filNum=1:size(ManualScore_Files,1)
                    dashFind=strfind(ManualScore_Files(filNum).name,'_');
                    an_Name=ManualScore_Files(filNum).name(1:(dashFind(2)-1));
                    an_Hem=ManualScore_Files(filNum).name((dashFind(2)+1):(dashFind(3)-1));
                    an_Date=ManualScore_Files(filNum).name((dashFind(3)+1):(dashFind(4)-1));
                    an_Time=ManualScore_Files(filNum).name((dashFind(4)+1):(dashFind(7)-1));
                    
                    load([an_Name '_' an_Hem '_' an_Date '_' an_Time '_SleepScoringData.mat'],'StimulusTriggers');
                    if isempty(StimulusTriggers.Sol.solenoidContralateral) && isempty(StimulusTriggers.Opto.OptoStim)
                        %% Load Data Files
                        load(ManualScore_Files(filNum).name);
                        theData=load([an_Name '_' an_Hem '_' an_Date '_' an_Time '_SleepScoringData.mat']);
                        load([an_Name '_' an_Hem '_' an_Date '_' an_Time '_rawdata.mat']);
                        
                        %% File Parameters
                        ChunkData.Params.PixelMap=theData.IOS.Pixelwise.PixelMap;
                        ChunkData.Params.dal_fr=theData.AcquisitionParams.StimParams.dal_fr;
                        ChunkData.Params.an_fs=theData.AcquisitionParams.StimParams.an_fs;
                        ChunkData.Params.arousalBin_width=5; % binWidth in seconds
                        ChunkData.Params.anName=an_Name;
                        ChunkData.Params.Date=an_Date;
                        ChunkData.Params.Time=an_Time;
                        ChunkData.Params.FilterParams.EMG.Freqz=[300 5000];
                        ChunkData.Params.FilterParams.LFP.Freqz=[1 150];
                        
                        %% Bandpass filter for Nuchal EMG
                        [z,p,k]=butter(3,ChunkData.Params.FilterParams.EMG.Freqz/(0.5*ChunkData.Params.an_fs),'bandpass');
                        [sos_EMG,g_EMG]=zp2sos(z,p,k);
                        emg_Kernel=normpdf((1:(2*ChunkData.Params.an_fs)),(ChunkData.Params.an_fs),(0.05*ChunkData.Params.an_fs));
                        %% Bandpass filter for broadband LFP
                        [z,p,k]=butter(3,ChunkData.Params.FilterParams.LFP.Freqz/(0.5*ChunkData.Params.an_fs),'bandpass');
                        [sos_lfp,g_lfp]=zp2sos(z,p,k);
                        %% smoothing filter for broadband LFP
                        [z,p,k]=butter(3,1/(0.5*ChunkData.Params.an_fs),'low');
                        [sos_smooth,g_smooth]=zp2sos(z,p,k);
                        %% Bessel filter for filtering and normalizing neural activity
                        [z,p,k] = besself(6,3,'low'); %0.5Hz lowpass bessel filter to eliminate phase distortion of fast neural events.
                        [zd,pd,kd] = bilinear(z,p,k,ChunkData.Params.dal_fr);
                        [sos_bessel,g_bessel]=zp2sos(zd,pd,kd);
                        
                        %% Filter Neural Data
                        tempDelta=filtfilt(sos_bessel,g_bessel,theData.Ephys.deltaBandPower);
                        tempTheta=filtfilt(sos_bessel,g_bessel,theData.Ephys.thetaBandPower);
                        tempSpindle=filtfilt(sos_bessel,g_bessel,theData.Ephys.spindlePower);
                        tempGamma=filtfilt(sos_bessel,g_bessel,theData.Ephys.gammaBandPower);
                        tempRipple=filtfilt(sos_bessel,g_bessel,theData.Ephys.ripplePower);
                        broadbandLFP=filtfilt(sos_smooth,g_smooth,filtfilt(sos_lfp,g_lfp,RawData.Neuro).^2); % lowpass (<1Hz) filtered broadband LFP power [1 150] Hz
                        theEMG=conv(filtfilt(sos_EMG,g_EMG,RawData.MUA).^2,emg_Kernel,'same');  % lowpass (<~10Hz) filtered nuchal EMG power [300 5000] Hz
                        
                        %% Bin Data based on 5s arousal state label
                        if filNum==1
                            QuiescentEvents=find(strcmpi(TrainingTable.behavState,'Quiescent Awake'));
                            if ~isempty(QuiescentEvents)
                                for eventNum=1:length(QuiescentEvents)
                                    EventsInd=[QuiescentEvents(eventNum)-1,QuiescentEvents(eventNum)];
                                    sampleInds=((EventsInd(1)*5*30)+1):(EventsInd(2)*5*30);
                                    normDelta(eventNum)=mean(tempDelta(sampleInds),2);
                                    normTheta(eventNum)=mean(tempTheta(sampleInds),2);
                                    normSpindle(eventNum)=mean(tempSpindle(sampleInds),2);
                                    normGamma(eventNum)=mean(tempGamma(sampleInds),2);
                                    normRipple(eventNum)=mean(tempRipple(sampleInds),2);
                                end
                                normDelta=mean(normDelta);
                                normTheta=mean(normTheta);
                                normSpindle=mean(normSpindle);
                                normGamma=mean(normGamma);
                                normRipple=mean(normRipple);
                            else
                                normDelta=mean(tempDelta);
                                normTheta=mean(tempTheta);
                                normSpindle=mean(tempSpindle);
                                normGamma=mean(tempGamma);
                                normRipple=mean(tempRipple);
                            end
                            
                        end
                        normalizedDeltaBand=((tempDelta-normDelta)./normDelta)*100;
                        normalizedThetaBand=((tempTheta-normTheta)./normTheta)*100;
                        normalizedSpindle=((tempSpindle-normSpindle)./normSpindle)*100;
                        normalizedGamma=((tempGamma-normGamma)./normGamma)*100;
                        normalizedRipple=((tempRipple-normRipple)./normRipple)*100;
                        
                        for binNum=2:(length(TrainingTable.behavState)-1)
                            binTime=[(ChunkData.Params.arousalBin_width*(binNum-1)),(ChunkData.Params.arousalBin_width*binNum)]; %Get time in seconds at start and end of bin
                            IOS_Inds=((binTime(1)*theData.AcquisitionParams.StimParams.dal_fr)+1:(binTime(2)*theData.AcquisitionParams.StimParams.dal_fr));
                            analog_Inds=((binTime(1)*theData.AcquisitionParams.StimParams.an_fs)+1:(binTime(2)*theData.AcquisitionParams.StimParams.an_fs));
                            specInds(1)=find(theData.Spectrograms.FiveSec.T5>=(binTime(1)),1,'first');
                            specInds(2)=find(theData.Spectrograms.FiveSec.T5>=(binTime(2)),1,'first')-1;
                            if ~isempty(TrainingTable.behavState{binNum})
                                binFlag=strrep(TrainingTable.behavState{binNum},' ','_');
                            else
                                TrainingTable.behavState{binNum}='Active Awake';
                                binFlag='Active_Awake';
                            end
                            %% Build file Hypnogram
                            if isempty(ChunkData.Hypnogram)
                                ChunkData.Hypnogram{1}=binFlag;
                            else
                                ChunkData.Hypnogram{length(ChunkData.Hypnogram)+1}=binFlag;
                            end
                            %% Generate Arousal state structures containing underlying EMG LFP IOS NO TIME DEPENDENCE
                            if ~isfield(ChunkData.ArousalStates,binFlag)
                                ChunkData.ArousalStates.(binFlag)=[];
                                binCount=1;
                            else
                                binCount=size(ChunkData.ArousalStates.(binFlag).LFP.normDeltaBandPower,1)+1;
                            end
                            
                            if isempty(theData.Opto)
                                ChunkData.ArousalStates.(binFlag).IOS.barrels.dHbT(binCount,:)=theData.IOS.barrels.dHbT(IOS_Inds);
                                ChunkData.ArousalStates.(binFlag).IOS.forepaw.dHbT(binCount,:)=theData.IOS.forepaw.dHbT(IOS_Inds);
                                ChunkData.ArousalStates.(binFlag).IOS.Optogenetics.dHbT(binCount,:)=theData.IOS.Optogenetics.dHbT(IOS_Inds);
                                
                            else
                                ChunkData.ArousalStates.(binFlag).IOS.barrels.dHbT(binCount,:)=theData.Opto.IOS.barrels.dHbT(IOS_Inds);
                                ChunkData.ArousalStates.(binFlag).IOS.forepaw.dHbT(binCount,:)=theData.Opto.IOS.forepaw.dHbT(IOS_Inds);
                                ChunkData.ArousalStates.(binFlag).IOS.Optogenetics.dHbT(binCount,:)=theData.Opto.IOS.Optogenetics.dHbT(IOS_Inds);
                            end
                            ChunkData.ArousalStates.(binFlag).IOS.BinInds(binCount,:)=IOS_Inds;
                            ChunkData.ArousalStates.(binFlag).IOS.fileName{binCount}=ManualScore_Files(filNum).name;
                            ChunkData.ArousalStates.(binFlag).LFP.normDeltaBandPower(binCount,:)=normalizedDeltaBand(IOS_Inds);
                            ChunkData.ArousalStates.(binFlag).LFP.normThetaBandPower(binCount,:)=normalizedThetaBand(IOS_Inds);
                            ChunkData.ArousalStates.(binFlag).LFP.normSpindleBandPower(binCount,:)=normalizedSpindle(IOS_Inds);
                            ChunkData.ArousalStates.(binFlag).LFP.normGammaBandPower(binCount,:)=normalizedGamma(IOS_Inds);
                            ChunkData.ArousalStates.(binFlag).LFP.normRippleBandPower(binCount,:)=normalizedRipple(IOS_Inds);
                            ChunkData.ArousalStates.(binFlag).LFP.broadbandLFP(binCount,:)=broadbandLFP(analog_Inds(1):analog_Inds(2));
                            
                            ChunkData.ArousalStates.(binFlag).Spectrograms.FiveSecSpec(:,:,binCount)=theData.Spectrograms.FiveSec.S5_Norm(:,(specInds(1):specInds(2)));
                            ChunkData.ArousalStates.(binFlag).Spectrograms.T5=theData.Spectrograms.FiveSec.T5;
                            ChunkData.ArousalStates.(binFlag).Spectrograms.F5=theData.Spectrograms.FiveSec.F5;
                            
                            ChunkData.ArousalStates.(binFlag).EMG.EMGPower(binCount,:)=theEMG(analog_Inds(1):analog_Inds(2));%theData.Ephys.downSampleEMG(IOS_Inds);
                        end
                        behaviorStates=unique(TrainingTable.behavState);
                        %% Get Start/End times of arousal states
                        for stateNum=1:length(behaviorStates)
                            stateFind=strcmpi(TrainingTable.behavState,behaviorStates{stateNum});
                            stateChange=diff(stateFind);
                            stateOff=find(stateChange==-1)+1;
                            stateOn=find(stateChange==1)+1;
                            if ~isempty(stateOn)
                                if isempty(stateOff)
                                    stateOff=length(TrainingTable.behavState)+1;
                                end
                                if stateOn(1)>stateOff(1)
                                    if length(stateOn)==length(stateOff)
                                        stateOff(end+1,1)=length(TrainingTable.behavState)+1;
                                    end
                                    eventLengths=(stateOff(2:end)-stateOn)*5;
                                else
                                    if length(stateOn)>length(stateOff)
                                        stateOff(end+1,1)=length(TrainingTable.behavState)+1;
                                    end
                                    eventLengths=(stateOff-stateOn)*5;
                                end
                                stateLabel=strrep(behaviorStates{stateNum},' ', '_');
                                if ~isfield(ChunkData.ArousalStates.(stateLabel),'eventLengths')
                                    ChunkData.ArousalStates.(stateLabel).eventLengths=eventLengths;
                                else
                                    ChunkData.ArousalStates.(stateLabel).eventLengths=[ChunkData.ArousalStates.(stateLabel).eventLengths;eventLengths];
                                end
                                
                                
                                %% Behavior State Change Triggered Analysis
                                for startNum=1:length(stateOn)
                                    if eventLengths(startNum)>=10
                                        if (stateOn(startNum)-2)>0
                                            if strcmpi(TrainingTable.behavState{stateOn(startNum)-1},TrainingTable.behavState{stateOn(startNum)-2})% Are the two bins preceeding the state change within the same state?
                                                startLabel=strrep(TrainingTable.behavState{stateOn(startNum)-1},' ', '_');
                                                endLabel=strrep(TrainingTable.behavState{stateOn(startNum)},' ', '_');
                                                catLabel=[startLabel '_to_' endLabel];
                                                eventBins=[stateOn(startNum)-3,stateOn(startNum)+1]; %This will generate indices +10s before and +10s after state change
                                                if eventBins(1)>0
                                                    if eventBins(2)<length(stateFind)
                                                        eventInds=(eventBins(1)*5*theData.AcquisitionParams.StimParams.dal_fr):(eventBins(2)*5*theData.AcquisitionParams.StimParams.dal_fr);
                                                        normInds=(eventBins(1)*5*theData.AcquisitionParams.StimParams.dal_fr):(eventBins(1)*5*theData.AcquisitionParams.StimParams.dal_fr+(5*theData.AcquisitionParams.StimParams.dal_fr));
                                                        anInds=(eventBins(1)*5*theData.AcquisitionParams.StimParams.an_fs):(eventBins(2)*5*theData.AcquisitionParams.StimParams.an_fs);
                                                        an_normInds=(eventBins(1)*5*theData.AcquisitionParams.StimParams.an_fs):(eventBins(1)*5*theData.AcquisitionParams.StimParams.an_fs+(5*theData.AcquisitionParams.StimParams.an_fs));
                                                        specInds(1)=find(theData.Spectrograms.FiveSec.T5>=(eventBins(1)*5),1,'first');
                                                        specInds(2)=find(theData.Spectrograms.FiveSec.T5>=(eventBins(2)*5),1,'first')-1;
                                                        normSpec(1)=find(theData.Spectrograms.FiveSec.T5>=(eventBins(1)*5),1,'first');
                                                        normSpec(2)=find(theData.Spectrograms.FiveSec.T5>=((eventBins(1)+1)*5),1,'first');
                                                        if ~isfield(ChunkData.StateChanges,catLabel)
                                                            ChunkData.StateChanges.(catLabel)=[];
                                                            eventCount=1;
                                                        else
                                                            eventCount=size(ChunkData.StateChanges.(catLabel).LFP.normDeltaBandPower,1)+1;
                                                        end
                                                        
                                                        if isempty(theData.Opto)
                                                            ChunkData.StateChanges.(catLabel).IOS.barrels.dHbT(eventCount,:)=theData.IOS.barrels.dHbT(eventInds)-mean(theData.IOS.barrels.dHbT(normInds),2);
                                                            ChunkData.StateChanges.(catLabel).IOS.forepaw.dHbT(eventCount,:)=theData.IOS.forepaw.dHbT(eventInds)-mean(theData.IOS.forepaw.dHbT(normInds),2);
                                                            ChunkData.StateChanges.(catLabel).IOS.Optogenetics.dHbT(eventCount,:)=theData.IOS.Optogenetics.dHbT(eventInds)-mean(theData.IOS.Optogenetics.dHbT(normInds),2);
                                                            ChunkData.StateChanges.(catLabel).IOS.Pixelwise.dHbT(:,:,eventCount)=theData.IOS.Pixelwise.dHbT(:,eventInds)-repmat(mean(theData.IOS.Pixelwise.dHbT(:,normInds),2),1,size(theData.IOS.Pixelwise.dHbT(:,eventInds),2));
                                                        else
                                                            ChunkData.StateChanges.(catLabel).IOS.barrels.dHbT(eventCount,:)=theData.Opto.IOS.barrels.dHbT(eventInds)-mean(theData.Opto.IOS.barrels.dHbT(normInds),2);
                                                            ChunkData.StateChanges.(catLabel).IOS.forepaw.dHbT(eventCount,:)=theData.Opto.IOS.forepaw.dHbT(eventInds)-mean(theData.Opto.IOS.forepaw.dHbT(normInds),2);
                                                            ChunkData.StateChanges.(catLabel).IOS.Optogenetics.dHbT(eventCount,:)=theData.Opto.IOS.Optogenetics.dHbT(eventInds)-mean(theData.Opto.IOS.Optogenetics.dHbT(normInds),2);
                                                        end
                                                        
                                                        ChunkData.StateChanges.(catLabel).LFP.normDeltaBandPower(eventCount,:)=normalizedDeltaBand(eventInds)-mean(normalizedDeltaBand(normInds),2);
                                                        ChunkData.StateChanges.(catLabel).LFP.normThetaBandPower(eventCount,:)=normalizedThetaBand(eventInds)-mean(normalizedThetaBand(normInds),2);
                                                        ChunkData.StateChanges.(catLabel).LFP.normSpindleBandPower(eventCount,:)=normalizedSpindle(eventInds)-mean(normalizedSpindle(normInds),2);
                                                        ChunkData.StateChanges.(catLabel).LFP.normGammaBandPower(eventCount,:)=normalizedGamma(eventInds)-mean(normalizedGamma(normInds),2);
                                                        ChunkData.StateChanges.(catLabel).LFP.normRippleBandPower(eventCount,:)=normalizedRipple(eventInds)-mean(normalizedRipple(normInds),2);
                                                        ChunkData.StateChanges.(catLabel).LFP.broadbandLFP(eventCount,:)=((broadbandLFP(anInds)-mean(broadbandLFP(an_normInds)))/mean(broadbandLFP(an_normInds)))*100;%((broadbandLFP(anInds).^2-mean(broadbandLFP(an_normInds).^2))/mean(broadbandLFP(an_normInds).^2))*100;
                                                        
                                                        ChunkData.StateChanges.(catLabel).EMG.EMGPower(eventCount,:)=log10(theEMG(anInds))-mean(log10(theEMG(an_normInds)));%theData.Ephys.downSampleEMG(eventInds)-mean(theData.Ephys.downSampleEMG(normInds),2);
                                                        
                                                        ChunkData.StateChanges.(catLabel).Spectrograms.FiveSecSpec(:,:,eventCount)=theData.Spectrograms.FiveSec.S5_Norm(:,(specInds(1):specInds(2)))...
                                                            -repmat(mean(theData.Spectrograms.FiveSec.S5_Norm(:,(normSpec(1):normSpec(2))),2),1,size(theData.Spectrograms.FiveSec.S5_Norm(:,(specInds(1):specInds(2))),2));
                                                        ChunkData.StateChanges.(catLabel).Spectrograms.F5=theData.Spectrograms.FiveSec.F5;
                                                        ChunkData.StateChanges.(catLabel).Spectrograms.T5=theData.Spectrograms.FiveSec.T5;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        %% Get data around myoclonic twitches/startle responses
                        if ~exist('Opto','var')
                            iosData=theData.IOS.forepaw.dHbT;
                        else
                            iosData=theData.Opto.IOS.forepaw.dHbT;
                        end
                        if filNum==1
                            ChunkData.Startle.evokedData.IOS=[];
                            ChunkData.Startle.evokedData.LFPpwr=[];
                            ChunkData.Startle.evokedData.LFPraw=[];
                            ChunkData.Startle.evokedData.EMG=[];
                            ChunkData.Startle.evokedData.Spectrograms=[];
                            ChunkData.Startle.baselineValues.IOS=[];
                            ChunkData.Startle.baselineValues.LFP=[];
                            ChunkData.Startle.baselineValues.EMG=[];
                            ChunkData.Startle.baselineValues.Spectrograms=[];
                            baselineHbT=0;
                        end
                        
                        [twitchChunk]=chunk_MyoclonicTwitch_Data_Neonate(iosData,RawData.Neuro,(theData.Spectrograms.OneSec.S1_Norm*100),RawData.MUA,TrainingTable.myoclonicTwitch.timeLoc,RawData.dal_fr,RawData.an_fs,theData.Spectrograms.OneSec.T1,baselineHbT);
                        ChunkData.Startle.evokedData.IOS=[ChunkData.Startle.evokedData.IOS;twitchChunk.evokedValues.IOS];
                        ChunkData.Startle.evokedData.LFPpwr=[ChunkData.Startle.evokedData.LFPpwr;twitchChunk.evokedValues.LFPpwr];
                        ChunkData.Startle.evokedData.LFPraw=[ChunkData.Startle.evokedData.LFPraw;twitchChunk.evokedValues.LFPraw];
                        ChunkData.Startle.evokedData.EMG=[ChunkData.Startle.evokedData.EMG;twitchChunk.evokedValues.EMG];
                        if isempty(ChunkData.Startle.evokedData.Spectrograms)
                            ChunkData.Startle.evokedData.Spectrograms=twitchChunk.evokedValues.Spectrogram;
                        else
                            ChunkData.Startle.evokedData.Spectrograms=cat(3,ChunkData.Startle.evokedData.Spectrograms,twitchChunk.evokedValues.Spectrogram);
                        end
                        ChunkData.Startle.baselineValues.IOS=[ChunkData.Startle.baselineValues.IOS,twitchChunk.baselineValues.IOS];
                        ChunkData.Startle.baselineValues.LFP=[ChunkData.Startle.baselineValues.LFP,twitchChunk.baselineValues.LFP];
                        ChunkData.Startle.baselineValues.EMG=[ChunkData.Startle.baselineValues.EMG,twitchChunk.baselineValues.EMG];
                        ChunkData.Startle.baselineValues.Spectrograms=[ChunkData.Startle.baselineValues.Spectrograms,twitchChunk.baselineValues.Spectrogram];
                        %                         else
                        %                             fprintf('Stimulus found in trial skipping\n')
                        %                         end
                        
                        
                    end
                end
                %% Trial behavior fractions
                if ~isempty(ChunkData.ArousalStates)
                    if isfield(ChunkData.ArousalStates,'Active_Awake')
                        awakeBins=size(ChunkData.ArousalStates.Active_Awake.IOS.barrels.dHbT,1);
                    else
                        awakeBins=0;
                    end
                    if isfield(ChunkData.ArousalStates,'Quiescent_Awake')
                        quiescentBins=size(ChunkData.ArousalStates.Quiescent_Awake.IOS.barrels.dHbT,1);
                    else
                        quiescentBins=0;
                    end
                    if isfield(ChunkData.ArousalStates,'Quiescent_Asleep')
                        NREMBins=size(ChunkData.ArousalStates.Quiescent_Asleep.IOS.barrels.dHbT,1);
                    else
                        NREMBins=0;
                    end
                    if isfield(ChunkData.ArousalStates,'Active_Asleep')
                        REMBins=size(ChunkData.ArousalStates.Active_Asleep.IOS.barrels.dHbT,1);
                    else
                        REMBins=0;
                    end
                    totBins=awakeBins+quiescentBins+NREMBins+REMBins;
                    ChunkData.BehaviorFractions.ActiveAwakePerc=awakeBins/totBins;
                    ChunkData.BehaviorFractions.QuiescentAwakePerc=quiescentBins/totBins;
                    ChunkData.BehaviorFractions.QuiescentAsleepPerc=NREMBins/totBins;
                    ChunkData.BehaviorFractions.ActiveAsleepPerc=REMBins/totBins;
                    
                    %% Find time in arousal state
%                     arousalNames=fieldnames(ChunkData.ArousalStates);
%                     for stateNum=1:size(arousalNames,1)
%                         uniqueFiles=unique(ChunkData.ArousalStates.(arousalNames{stateNum}).IOS.fileName);
%                         for filNum=1:size(uniqueFiles,2)
%                             if filNum==1
%                                 ChunkData.ArousalStates.(arousalNames{stateNum}).time_in_state=[];
%                             end
%                             filInds=strcmpi(ChunkData.ArousalStates.(arousalNames{stateNum}).IOS.fileName,uniqueFiles{filNum});
%                             startInds=ChunkData.ArousalStates.(arousalNames{stateNum}).IOS.BinInds(filInds,1);
%                             stopInds=ChunkData.ArousalStates.(arousalNames{stateNum}).IOS.BinInds(filInds,end);
%                             getGap=find(diff(startInds)>(5*ChunkData.Params.dal_fr));
%                             for evntNum=1:size(getGap,1)
%                                 if evntNum==1
%                                     theInds(evntNum,:)=[startInds(1),stopInds(getGap(evntNum))];
%                                 else
%                                     theInds(evntNum,:)=[startInds(getGap(evntNum-1)+1),stopInds(getGap(evntNum))];
%                                 end
%                                 eventDur(evntNum)=(theInds(evntNum,2)-theInds(evntNum,1))/ChunkData.Params.dal_fr ;
%                             end
%                             ChunkData.ArousalStates.(arousalNames{stateNum}).time_in_state=[ChunkData.ArousalStates.(arousalNames{stateNum}).time_in_state,eventDur];
%                         end
%                     end
                    
                    %% Save file to memory
                    tempDate=char(datetime('now'));
                    tempDate=strrep(tempDate,'-','_');
                    tempDate=strrep(tempDate,' ','_');
                    saveDate=strrep(tempDate,':','');
                    save([an_Name '_' an_Hem '_' an_Date '_ArousalStateChunkData_' saveDate '.mat'],'ChunkData', '-v7.3');
                end
                toc(runTime);
            end
        end
    end
end
