function BulkSleepScore_IOS_Neonate(~)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
DriveNames={'E:\','G:\',}; % hard drives containing sleep data'F:\',
for driveNum=1:numel(DriveNames)
    cd(DriveNames{driveNum});
    Folders=dir;
    Folders(~[Folders.isdir])=[];
    tf=ismember({Folders.name},{'.','..','$RECYCLE.BIN','System Volume Information'});
    Folders(tf)=[]; % eliminate house keeping directories
    for folderNum=1:size(Folders,1)
        if strcmpi(Folders(folderNum).name,'NeonateSleepIndividualAnimals')
            cd([Folders(folderNum).folder, Folders(folderNum).name]);
            dateFolders=dir;
            tf=ismember({dateFolders.name},{'.','..','$RECYCLE.BIN','System Volume Information'});
            dateFolders(tf)=[]; % eliminate house keeping directories
            for foldNum=1:size(dateFolders,1)
                if ~dateFolders(foldNum).isdir==1
                    tf(foldNum)=foldNum;
                end
            end
            tf(tf==0)=[];
            dateFolders(tf)=[];
            for dateNum=1:size(dateFolders,1)
                cd([dateFolders(dateNum).folder, '\' , dateFolders(dateNum).name]);
                ageFolders=dir;
                tf=ismember({ageFolders.name},{'.','..','$RECYCLE.BIN','System Volume Information'});
                ageFolders(tf)=[]; % eliminate house keeping directories
                for ageNum=1:size(ageFolders,1)
                    cd([ageFolders(ageNum).folder, '\' ageFolders(ageNum).name]);
                    animalFolders=dir;
                    tf=ismember({animalFolders.name},{'.','..','$RECYCLE.BIN','System Volume Information','Ignore'});
                    animalFolders(tf)=[]; % eliminate house keeping directories
                    for animalNum=1:size(animalFolders,1)
                        cd([animalFolders(animalNum).folder, '\' animalFolders(animalNum).name]);
                        ManualScore_ArousalState_Neonate;
                    end
                end
            end
        end
    end
end
end

