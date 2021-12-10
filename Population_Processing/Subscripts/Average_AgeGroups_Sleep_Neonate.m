function [PopulationData]=Average_AgeGroups_Sleep_Neonate(PopulationData)
%% READ ME
%This function averages subfields of each age group of neonatal sleep data

%% Get Age groups
ages=fieldnames(PopulationData);

for ageNum=1:(size(ages,1)-1)
    dataField=fieldnames(PopulationData.(ages{ageNum}));
    for dataNum=1:size(dataField,1)
        if ~strcmpi(dataField{dataNum},'BehaviorFractions') && ~strcmpi(dataField{dataNum},'Hypnogram') && ~strcmpi(dataField{dataNum},'Params')
            subfields=fieldnames(PopulationData.(ages{ageNum}).(dataField{dataNum}));
            for subNum=1:size(subfields,1)
                methodFields=fieldnames(PopulationData.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}));
                for methodNum=1:size(methodFields,1)
                    if ~strcmpi(methodFields{methodNum},'eventLengths')
                        nextField=fieldnames(PopulationData.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}));
                        for nextNum=1:size(nextField,1)
                            if isstruct(PopulationData.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum}))
                                finalField=fieldnames(PopulationData.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum}));
                                for finalNum=1:size(finalField,1)
                                    PopulationData.Averages.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum}).(finalField{finalNum})=...
                                        mean(PopulationData.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum}).(finalField{finalNum}),1);
                                end
                            else
                                
                                if size(PopulationData.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum}),3)==1
                                    PopulationData.Averages.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum})=...
                                        mean(PopulationData.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum}),1);
                                else
                                    PopulationData.Averages.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum})=...
                                        mean(PopulationData.(ages{ageNum}).(dataField{dataNum}).(subfields{subNum}).(methodFields{methodNum}).(nextField{nextNum}),3);
                                end
                            end
                        end
                    else
                    end
                end
            end
        else
        end
    end
end
                
            