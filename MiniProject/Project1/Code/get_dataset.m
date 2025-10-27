function [X_train,Y_train,X_test,Y_test]=get_dataset(train_tuple,test_tuple,use_zscore)
   
    idxtrain_target = train_tuple{1};      
    idxtrain_non_target = train_tuple{2};  
    train_signal = train_tuple{3};         
    
    idxtest_target = test_tuple{1};
    idxtest_non_target = test_tuple{2};
    test_signal = test_tuple{3};

    [matrixX_train_target,matrixY_train_target] = get_data_matrix(idxtrain_target,train_signal,1,use_zscore);
    [matrixX_train_flash,matrixY_train_flash] = get_data_matrix(idxtrain_non_target,train_signal,0,use_zscore);

    [matrixX_test_target,matrixY_test_target] = get_data_matrix(idxtest_target,test_signal,1);
    [matrixX_test_flash,matrixY_test_flash] = get_data_matrix(idxtest_non_target,test_signal,0);

    X_train = [matrixX_train_target;matrixX_train_flash];
    Y_train = [matrixY_train_target;matrixY_train_flash];
    
    X_test  = [matrixX_test_target;matrixX_test_flash];
    Y_test  = [matrixY_test_target;matrixY_test_flash];
    
end
