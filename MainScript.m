clear
clc
close all

load('ECoG_Handpose.mat')

fs = 1200; %sample frequency

%% Preprocessing
[yfilt, classes] = preprocessing(y, fs);

%% Trial extraction
% 1 second after 1 second of the stimulus
[n0,n1,n2,n3]=deal(0);
for i=2:length(classes)
    if classes(i)==0 && classes(i-1)~=0
        n0=n0+1;
        ecog0(n0,:,:) = yfilt(:,(i+fs):(i+2*fs)-1);
    elseif classes(i)==1 && classes(i-1)~=1
        n1=n1+1;
        ecog1(n1,:,:) = yfilt(:,(i+fs):(i+2*fs)-1);
    elseif classes(i)==2 && classes(i-1)~=2
        n2=n2+1;
        ecog2(n2,:,:) = yfilt(:,(i+fs):(i+2*fs)-1);
    elseif classes(i)==3 && classes(i-1)~=3
        n3=n3+1;
        ecog3(n3,:,:) = yfilt(:,(i+fs):(i+2*fs)-1);
    end
end
ecog = cat(1,ecog0,ecog1,ecog2,ecog3); %concatenate
ecog = permute(ecog,[3, 2, 1]);
Class = [zeros(1,n0) ones(1,n1) 2*ones(1,n2) 3*ones(1,n3)];

%% feature extraction
for i = 1:size(ecog,2)
    for j=1:size(ecog,3)       
        % Log Power band1, 2, 3
        band1pow(i,j) = log(bandpower(ecog(:,i,j), fs, [60 90]));
        band2pow(i,j) = log(bandpower(ecog(:,i,j), fs, [110 140]));
        band3pow(i,j) = log(bandpower(ecog(:,i,j), fs, [160 190]));
    end
end
data = [band1pow; band2pow; band3pow]; 
data = data';

%% Classification 1: rest vs hand movement
Class1 = [zeros(1,n0) ones(1,n1) ones(1,n2) ones(1,n3)];

% Cross-validation
k = 10;
[TrainInd, TestInd] = M_cross_validation(size(data,1),'Kfold',k);

%RF
Results1 = RF(data, Class1, TrainInd, TestInd, k);

%% Classification 2: fist vs peace vs open hand
Class2 = [zeros(1,n1) ones(1,n2) 2*ones(1,n3)];
data(1:n0,:)=[];

% Cross-validation
k = 10;
[TrainInd, TestInd] = M_cross_validation(size(data,1),'Kfold',k);

%RF
Results2 = RF(data, Class2, TrainInd, TestInd, k);

%% Results
disp('Classification Results')
Labels = ["rest vs hand movement" "fist vs peace vs open hand"];

[array2table(Labels') [struct2table(Results1); struct2table(Results2)]]