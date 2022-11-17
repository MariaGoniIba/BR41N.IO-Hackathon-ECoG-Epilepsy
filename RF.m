function Results = RF(data, Class, TrainInd, TestInd, k)

    classpredict=[]; classreal=[]; Score=[]; weights=[]; opttrees=[]; %optimal number of trees
    for i = 1:k
        RFmodel = TreeBagger(100,data(TrainInd{i},:),Class(TrainInd{i}),'OOBPrediction','off');
        [classp, score] = RFmodel.predict(data(TestInd{i},:));
        classpredict = [classpredict classp'];
        Score=[Score; score(:,2)];
        classreal=[classreal Class(TestInd{i})];
    
        clear RFmodel classp score
    end
    
    classpredict = str2double(classpredict);
    
    Results.Acc = length(find(classreal == classpredict)); %corregir!
    Results.TP = length(find(classreal==1 & classpredict==1));
    Results.TN = length(find(classreal==0 & classpredict==0));
    Results.FP = length(find(classreal==0 & classpredict==1));
    Results.FN = length(find(classreal==1 & classpredict==0));
    Results.Sens=Results.TP/(Results.TP+Results.FN);
    Results.Spec=Results.TN/(Results.TN+Results.FP);
    Results.BalAcc=(Results.Sens+Results.Spec)/2;
    Results.Precision=Results.TP/(Results.TP+Results.FP);
    Results.Recall=Results.TP/(Results.TP+Results.FN);
    Results.F1Score=2*((Results.Recall*Results.Precision)/(Results.Recall+Results.Precision));