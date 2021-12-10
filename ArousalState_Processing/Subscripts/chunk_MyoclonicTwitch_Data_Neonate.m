function [twitchChunk]=chunk_MyoclonicTwitch_Data_Neonate(IOS,LFP,Spec,EMG,twitchTimes,dal_fr,an_fs,specTimes,awakebaselineHbT)
%% Empty Structures for data
twitchChunk.evokedValues.IOS=[]; %store twitch evoked IOS data here
twitchChunk.evokedValues.LFPpwr=[]; %store twitch evoked LFP power data here
twitchChunk.evokedValues.LFPraw=[]; %store twitch evoked LFP power data here
twitchChunk.evokedValues.Spectrogram=[];%store twitch evoked LFP spectrograms here
twitchChunk.evokedValues.EMG=[];
twitchChunk.baselineValues.IOS=[];
twitchChunk.baselineValues.LFP=[];
twitchChunk.baselineValues.EMG=[];
twitchChunk.baselineValues.Spectrogram=[];
% twitchCount=1; %twitch counter

%% Build filters
[z,p,k]=butter(3,[1 150]/(0.5*an_fs),'bandpass');
[sos_LFP,g_LFP]=zp2sos(z,p,k); %bandpass filter for broadband LFP

[z,p,k]=butter(3,10/(0.5*an_fs),'low');
[sos_PWR,g_PWR]=zp2sos(z,p,k); % low pass filter for LFP power

[z,p,k]=butter(3,[0.1 1]/(0.5*dal_fr),'bandpass');
[sos_HbT,g_HbT]=zp2sos(z,p,k); %bandpass filter for HbT

[z,p,k]=butter(3,[300 5000]/(0.5*an_fs),'bandpass');
[sos_EMG,g_EMG]=zp2sos(z,p,k); %bandpass filter for EMG

emg_Kernel=normpdf((1:(2*an_fs)),an_fs,(0.05*an_fs));

%% Filter data
broadbandLFP=filtfilt(sos_LFP,g_LFP,LFP);
pwrLFP=filtfilt(sos_PWR,g_PWR,broadbandLFP.^2);
bandpassHbT=filtfilt(sos_HbT,g_HbT,IOS);
muaEMG=filtfilt(sos_EMG,g_EMG,EMG);
pwrEMG=conv((muaEMG.^2),emg_Kernel,'same');
shiftedHbT=IOS-awakebaselineHbT;
%% Constants
leadTime=10; %time in seconds before twitch
normTime=5; %time from leadtime to calculate pre twitch baseline
followTime=15; %time in seconds following twitch
specStep=round(1/(specTimes(2)-specTimes(1)),0); % bin step size of spectrograms

dal_lead=leadTime*dal_fr;
dal_norm=normTime*dal_fr;
dal_follow=followTime*dal_fr;

an_lead=leadTime*an_fs;
an_norm=normTime*an_fs;
an_follow=followTime*an_fs;

spec_lead=leadTime*specStep;
spec_norm=normTime*specStep;
spec_follow=followTime*specStep;

twitchSpacing=diff(twitchTimes); % find time in seconds between myoclonic twitches
twitchClear=find(twitchSpacing<(followTime))+1; % find indicies inside of the lead time of data windowing
twitchTimes(twitchClear)=[]; %clear twitches that violate rest periods

for twitchNum=1:size(twitchTimes,1) %cycle through myoclonic twitches
%% Twitch onset Indicies
    dal_start=round(twitchTimes(twitchNum)*dal_fr,0);
    an_start=round(twitchTimes(twitchNum)*an_fs,0);
    spec_start=find(specTimes>twitchTimes(twitchNum),1,'first')-1;
%% Twitch data collection Window
    dalInds=[(dal_start-dal_lead),(dal_start-dal_norm), (dal_start+dal_follow)];
    anInds=[(an_start-an_lead),(an_start-an_norm), (an_start+an_follow)];
    specInds=round([(spec_start-spec_lead),(spec_start-spec_norm),(spec_start+spec_follow)],0);
    if ~isempty(dalInds) && ~isempty(anInds) && ~isempty(specInds)
        if dalInds(1)>0 && anInds(1)>0 && specInds(1)>0
            if dalInds(3)<=length(IOS) && anInds(3)<=length(LFP) && specInds(3)<=length(specTimes)
                %% Calculate baseline constants
                baseIOS=mean(bandpassHbT(dalInds(1):dalInds(2)),2);
                baseLFP=mean(pwrLFP(anInds(1):anInds(2)),2);
                baseEMG=mean(muaEMG(anInds(1):anInds(2)),2);
                tempSpec=mean(Spec(:,(specInds(1):specInds(2))),2);
                baseSpec=repmat(tempSpec,1,size(Spec(:,(specInds(1):specInds(3))),2));
                
                %% Normalize to pre twitch baseline
                twitchCount=size(twitchChunk.evokedValues.IOS,1)+1;
                normHbT=bandpassHbT(dalInds(1):dalInds(3))-baseIOS;
                normLFP=((pwrLFP(anInds(1):anInds(3))-baseLFP)/baseLFP)*100;
                normEMG=muaEMG(anInds(1):anInds(3))-baseEMG;
                normSpec=Spec(:,(specInds(1):specInds(3)))-baseSpec;
                rawLFP=broadbandLFP(anInds(1):anInds(3));
                
                twitchChunk.baselineValues.IOS(twitchCount)=mean(shiftedHbT(dalInds(1):dalInds(2)),2);
                twitchChunk.baselineValues.LFP(twitchCount)=baseLFP;
                twitchChunk.baselineValues.EMG(twitchCount)=baseEMG;
                twitchChunk.baselineValues.Spectrogram(:,twitchCount)=tempSpec;
                
                twitchChunk.evokedValues.IOS(twitchCount,:)=normHbT;
                twitchChunk.evokedValues.LFPpwr(twitchCount,:)=normLFP;
                twitchChunk.evokedValues.LFPraw(twitchCount,:)=rawLFP;
                twitchChunk.evokedValues.EMG(twitchCount,:)=normEMG;
                twitchChunk.evokedValues.Spectrogram(:,:,twitchCount)=normSpec;
                
            end
        end
    end
end
            