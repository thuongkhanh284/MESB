function detcurve = cal_f1_curve_by_fppw_micro_ave(Res, params)

fiXLS = params.fiXLS;
XAxis = params.XAxis;

cross_number = length(Res.DEC);

num_fn_of_crosses = [];
num_tp_of_crosses = [];
num_fp_of_crosses = [];
for i=1:cross_number
    svm_score = Res.DEC{i};
    
    sample_label = Res.LabelTest{1,i};
    
    % get the IDX of positive and negative samples
    idx_pos = find(sample_label == 1);
    idx_neg = find(sample_label == -1);
    
    % score of positive sample and negative sample
    score_pos_sample = svm_score(idx_pos);
    score_neg_sample = svm_score(idx_neg);
    
    % sort ascending
    score_pos_sample = sort(score_pos_sample);
    score_neg_sample = sort(score_neg_sample);
    
    
    num_sample = length(svm_score);
    num_neg_sample = length(score_neg_sample);
    num_pos_sample = num_sample - num_neg_sample;
    
    num_fp_corr_xaxis = ceil (XAxis * num_neg_sample);
    num_tp_corr_xaxis = ceil (XAxis * num_pos_sample);
    
    seq_of_fppw_score = score_neg_sample(num_neg_sample -  num_fp_corr_xaxis + 1  );
    seq_of_tppw_score = score_pos_sample(num_pos_sample -  num_tp_corr_xaxis + 1) ;
    
    
    fn_array = [];
    fp_array = [];
    tp_array = [];
    
    for j=1:length(seq_of_tppw_score) 
        curr_score_val = seq_of_tppw_score(j);
        num_fn = size( find (score_pos_sample < curr_score_val ) , 2 );
        num_tp = size( find (score_pos_sample >= curr_score_val ) , 2 );
        num_fp = size( find (score_neg_sample >= curr_score_val ), 2);
        fn_array = [fn_array , num_fn];
        fp_array = [fp_array , num_fp];
        tp_array = [tp_array , num_tp];
    end
    if (length(num_fn_of_crosses) < 1)
        num_fn_of_crosses = zeros(1,length(fn_array));
        num_tp_of_crosses = zeros(1,length(fn_array));
        num_fp_of_crosses = zeros(1,length(fn_array));
    end
    num_fn_of_crosses = num_fn_of_crosses + fn_array;
    num_tp_of_crosses = num_tp_of_crosses + tp_array;
    num_fp_of_crosses = num_fp_of_crosses + fp_array;
end
Precision_array = num_tp_of_crosses ./ (num_tp_of_crosses + num_fp_of_crosses)
Recall_array = num_tp_of_crosses ./ (num_tp_of_crosses + num_fn_of_crosses )
detcurve.xaxis = Recall_array;
detcurve.yaxis = (2 * Precision_array.* Recall_array) ./ (Precision_array + Recall_array);
detcurve.ystd = [];


end