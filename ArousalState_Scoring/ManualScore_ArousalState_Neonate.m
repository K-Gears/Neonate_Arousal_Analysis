%% READ ME
%This script is used for the manual scoring of animal arousal state 
%Will generate figure with sliding, non overlapping bins for manual scoring
%Added manual selection of myoclonic twitches for movement based analysis
% Last updated 12-08-2021 KWG

%% pull list of raw data files from current directory
close all
clear all
scoringDataFileStruct = dir('*_SleepScoringData.mat');
rawDataFileStruct=dir('*_rawdata.mat');
trainingDataFiles=dir('*_TrainingData_002.mat');
if ~isempty(scoringDataFileStruct)
    if size(scoringDataFileStruct,1)~=size(trainingDataFiles,1)
        scoringDataFiles = {scoringDataFileStruct.name}';
        rawDataFiles={rawDataFileStruct.name}';
        scoringDataFileIDs = char(scoringDataFiles);
        rawDataFileIDs=char(rawDataFiles);
        finalFileID=scoringDataFileIDs(end,:);
        fileBreaks=strfind(finalFileID,'_');
        finalTrainingID=[finalFileID(1:(fileBreaks(end))) 'TrainingData_002.mat'];
        if ~exist(finalTrainingID,'file')
            %% Constants
            Fs=20000;
            emg_Kernel=normpdf((1:(2*Fs)),(Fs),(0.05*Fs));
            %Build filter for unit visualization of EMG signal
            
            lowcut=300;
            highcut=5000;
            [z,p,k]=butter(3,[lowcut highcut]/(0.5*Fs),'bandpass'); %filter for EMG 
            [sosEMG,gEMG]=zp2sos(z,p,k);
            % load each file and create a histogram of the EMG values
            
            [z,p,k]=butter(3,[1 150]/(0.5*Fs),'bandpass');
            [sos_LFP,g_LFP]=zp2sos(z,p,k);
            emgHold = [];
            velHold=[];
            
            [z,p,k]=butter(3,10/(0.5*Fs),'low');
            [sos_ball,g_ball]=zp2sos(z,p,k);
            maxvel=2*pi*0.06*10;
            maxVol=10; % maximum voltage output (read from USDigital device)
            rate=maxvel/maxVol;
            tic
            for a = 1:size(scoringDataFileIDs,1)
                disp(['Gathering EMG data for probability distribution: (' num2str(a) '/' num2str(size(scoringDataFileIDs,1)) ')']); disp(' ')
                scoringDataFileID = scoringDataFileIDs(a,:);
                dashInds=strfind(scoringDataFileID,'_');
                load(scoringDataFileID,'Ephys','Behavior')
                Ephys.downSampleEMG(Ephys.downSampleEMG<0)=0;
                unitEMG=(sqrt(Ephys.downSampleEMG)/10000)*1000000; %convert to uV
                EMG_Signal=unitEMG.^2;%Ephys.downSampleEMG;
%                 EMG_Signal(EMG_Signal<0)=0; % Negative EMG values are artifact of filtering, set to 0 for plotting purposes
                emgHold = cat(2,emgHold,log10(EMG_Signal)); % use natural log transform to visualize dynamic range of EMG signal
                velHold=cat(2,velHold,abs(Behavior.ballVelocity));
            end
            toc
            % plot histogram of EMG data to assist in identification of bimodal distribution values
            figure
            histogram(real(emgHold),500,'Normalization','probability')% visualize log transformed data as a histogram using 500 bins
            xlabel('EMG Power')
            ylabel('Probability')
            EMGThresh=0;%input('User Defined EMG Line?'); %Use to visualize population separation point on plots
            
            %plot ball velocity normalized to peak velocity of imaging trial
            velPeak=max(velHold);
            Time=(1:length(velHold))/30;
            
            figure;
            yyaxis left; plot(Time,emgHold,'-r');
            theAx=gca;
            theAx.YColor='black';
            ylabel('EMG power (log10 units)');
            yyaxis right; plot(Time,(velHold*rate*100),'-k');%/velPeak)*100);
            theAx=gca;
            theAx.YColor='black';
            ylabel('Ball velocity (cm/sec)');
            xlabel('Time (sec)');
            legend('EMG Power','Ball Velocity')
            % go through each file and create a list of manual scores
            for a = 1:size(scoringDataFileIDs,1)
                scoringDataFileID = scoringDataFileIDs(a,:);
                fileInfo=whos('-file',scoringDataFileID);
                dashInds=strfind(scoringDataFileID,'_');
                aviTag=scoringDataFileID((dashInds(3)+1):(dashInds(7)-1));
                aviName=[aviTag '_usb.avi'];
                RawDataName=[scoringDataFileID(1:(dashInds(7))) 'rawdata.mat'];
                disp(['Loading ' scoringDataFileID ' for manual sleep scoring: (' num2str(a) '/' num2str(size(scoringDataFileIDs,1)) ')' ]); disp(' ')
                strBreaks = strfind(scoringDataFileID,'_');
                trainingDataFileID = [scoringDataFileID(1:strBreaks(end)) 'TrainingData_003.mat'];
                TrainingTable.myoclonicTwitch.timeLoc=[];
                if ~exist(trainingDataFileID,'file')
                    if exist(aviName,'file')
%                         if fileInfo(5).size(1)==0
%                             load(scoringDataFileID,'IOS');
%                             subfield=fieldnames(IOS.barrels);
%                             isHbT=ismember(subfield,'dHbT');
%                         else
%                             load(scoringDataFileID,'Opto');
%                             subfield=fieldnames(Opto.IOS.barrels);
%                             isHbT=ismember(subfield,'dHbT');
%                         end
                            isHbT=1;
                        if max(isHbT)==1
                            vidWin=implay(aviName,30);
                            if a==1
                                isok='n';
                                while strcmpi(isok,'n')
                                vidIntensities=input('Enter [min max] for video pixel intensity\n');
                                vidWin.Visual.ColorMap.UserRange=1;
                                vidWin.Visual.ColorMap.UserRangeMin=vidIntensities(1);
                                vidWin.Visual.ColorMap.UserRangeMax=vidIntensities(2);
                                isok=input('Is video intensity ok? y/n \n','s');
                                end
                            else
                                vidWin.Visual.ColorMap.UserRange=1;
                                vidWin.Visual.ColorMap.UserRangeMin=vidIntensities(1);
                                vidWin.Visual.ColorMap.UserRangeMax=vidIntensities(2);
                            end
                            load(RawDataName);
                            unitEMG=(filtfilt(sosEMG,gEMG,RawData.MUA)/10000)*1000000;% This is the spiking of the EMG signal
                            emgPower=log10(conv(((unitEMG/10000)*1000000).^2,emg_Kernel,'same'));
                            wideband_LFP=(filtfilt(sos_LFP,g_LFP,RawData.Neuro)/1000)*1000000; %This is the bandpass filtered signal from Hippocampus LFP
                            rawBall=filtfilt(sos_ball,g_ball,RawData.vBall);
                            velBall=rawBall*rate*100+0.155; % velocity in cm/sec
                            if fileInfo(5).size(1)==0
                                load(scoringDataFileID,'Behavior','AcquisitionParams','Spectrograms')
                                dHbT=RawData.IOS.forepaw.CBVrefl;
                            else
                                load(scoringDataFileID,'Behavior','AcquisitionParams','Spectrograms')
                                dHbT=RawData.IOS.forepaw.CBVrefl;
                            end
                            % need to add baseline structure or equivalent to figure function
                            [figHandle,ax1,ax2,ax4,ax5] = GenerateSingleFigures_Neonate(Fs,velBall,emgPower,dHbT,Spectrograms.FiveSec,EMGThresh,unitEMG,wideband_LFP);
                            rescale=input('do plot axes need rescaled? y/n','s');
                            if strcmpi(rescale,'y')
                               all_done='n';
                               while strcmpi(all_done,'n')
%                                    xLims=input('What are the x limits?');
%                                    xlim(xLims);
                                   yLims=input('What are the y limits?');
                                   ylim(yLims);
                                   all_done=input('All done rescaling plots? y/n','s');
                               end
                            end
                            ylim(ax1,'manual');
                            ylim([0 10]);
                            ylim(ax2,'manual');
                            ylim([-500 500])
                            ylim(ax4,'manual');
                            ylim(ax5,'manual');
                            %% Select myoclonic twitches within EMG plot
                            fprintf('Select myoclonic twitch events with left mouse click then press [ENTER]\n')
                            fprintf('If no twitch events in frame right mouse click then press [ENTER]\n')
                            [x_inds,y_inds,button]=ginput;
                            leftClicks=button==1;
                            TrainingTable.myoclonicTwitch.timeLoc=x_inds(leftClicks);
                            trialDuration = round(length(Behavior.ballVelocity)/AcquisitionParams.downSampled_Fs);
                            % determine number of 5 seconds bins
                            numBins = trialDuration/5;
                            twitchFrames=[1:6:numBins];
                            behavioralState = cell(numBins,1);
                            for b = 1:numBins
                                %                 global buttonState %#ok<TLEV>
                                %                 buttonState = 0;
%                                 if (b*5)<=30
%                                     xlim([0 30]);
% %                                 elseif b>=(numBins-3)
% %                                     xlim([((numBins-5)*5) (numBins*5)]);
%                                 else
%                                     lowInd=floor(b/6);
%                                     highInd=ceil(b/6);
%                                     if lowInd==highInd
%                                         xlim([(((lowInd-1)*6)*5) (((highInd)*6)*5)]);
%                                     else
%                                     xlim([((lowInd*6)*5) ((highInd*6)*5)]);
%                                     end
%                                 end
%                                 if max(b==twitchFrames)==1
%                                     fprintf('Select myoclonic twitch events with left mouse click then press [ENTER]\n')
%                                     fprintf('If no twitch events in frame right mouse click then press [ENTER]\n')
%                                    [x_inds,y_inds,button]=ginput;
%                                    leftClicks=button==1;
%                                    TrainingTable.myoclonicTwitch.timeLoc=[TrainingTable.myoclonicTwitch.timeLoc;x_inds(leftClicks)];
%                                 end
                                xStartVal = (b*5) - 5;
                                xEndVal = b*5;
                                xInds = xStartVal:1:xEndVal;
%                                 figHandle = gcf;
%                                 figure(figHandle); hold on
%                                 subplot(12,1,(1:2)); 
                                leftEdge1 = xline(ax1,xInds(1),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                rightEdge1 = xline(ax1,xInds(end),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                

%                                 subplot(12,1,(3:5));
                                leftEdge2 = xline(ax2,xInds(1),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                rightEdge2 = xline(ax2,xInds(end),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                %                 subplot(4,1,3)
                                %                 leftEdge3 = xline(xInds(1),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                %                 hold on
                                %                 rightEdge3 = xline(xInds(5),'color',colors_Neonate('electric purple'),'LineWidth',2);

%                                 subplot(12,1,(6:8));
                                leftEdge4 = xline(ax4,xInds(1),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                rightEdge4 = xline(ax4,xInds(end),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                % make decision
                                %[updatedGUI] = SelectBehavioralStateGUI_GT;

%                                 subplot(12,1,(9:12));
                                leftEdge5 = xline(ax5,xInds(1),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                rightEdge5 = xline(ax5,xInds(end),'color',colors_Neonate('electric purple'),'LineWidth',2);
                                if b==1
                                    app=Select_Arousal_State_GUI_Neonate;
                                end
                                uiwait(app.UIFigure);
                                if app.ActiveAwakeButton.Value==1
                                    behavioralState{b,1}='Active Awake';
                                    app.ActiveAwakeButton.Value=0; %Reset the button
                                elseif app.QuiescentAwakeButton.Value==1
                                    behavioralState{b,1}='Quiescent Awake';
                                    app.QuiescentAwakeButton.Value=0; %Reset the button
                                elseif app.QuiescentAsleepNREMButton.Value==1
                                    behavioralState{b,1}='Quiescent Asleep';
                                    app.QuiescentAsleepNREMButton.Value=0; %Reset the button
                                elseif app.ActiveAsleepREMButton.Value==1
                                    behavioralState{b,1}='Active Asleep';
                                    app.ActiveAsleepREMButton.Value=0; %Reset the button
                                end
                                %                             close(app.UIFigure);
                                %                 while buttonState == 0
                                %                     drawnow()
                                %                     if buttonState == 1
                                %                         guiResults = guidata(updatedGUI);
                                %                         if guiResults.togglebutton1.Value == true
                                %                             behavioralState{b,1} = 'Active Awake';
                                %                         elseif guiResults.togglebutton2.Value == true
                                %                             behavioralState{b,1} = 'Quiscent Awake';
                                %                         elseif guiResults.togglebutton3.Value == true
                                %                             behavioralState{b,1} = 'NREM Sleep';
                                %                         elseif guiResults.togglebutton4.Value == true
                                %                             behavioralState{b,1} = 'REM Sleep';
                                %                         else
                                %                             disp('No button pressed'); disp(' ')
                                %                             keyboard
                                %                         end
                                %                         close(updatedGUI)
                                %                         break;
                                %                     end
                                %                     ...
                                %                 end
                                delete(leftEdge1)
                                delete(leftEdge2)
                                %             delete(leftEdge3)
                                delete(leftEdge4)
                                delete(leftEdge5)
                                delete(rightEdge1)
                                delete(rightEdge2)
                                %             delete(rightEdge3)
                                delete(rightEdge4)
                                delete(rightEdge5)
                            end
                            close(figHandle)
                            close(app.UIFigure);
                            TrainingTable.behavState = behavioralState;
                            save(trainingDataFileID,'TrainingTable')
                            close(vidWin);
                        else
                            disp([trainingDataFileID ' missing dHbT data. Continuing...']); disp(' ')
                        end
                    else
                        disp('No avi file skipping analysis...'); disp(' ')
                    end
                else
                    disp([trainingDataFileID ' already exists. Continuing...']); disp(' ')
                end
            end
        end
    else
        disp('Sleep files already analyzed. Continuing...'); disp(' ')
    end
end
