function detcurve = cal_f1_curve_by_fppw_macro_ave(Res, params)

fiXLS = params.fiXLS;
XAxis = params.XAxis;

cross_number = length(Res.DEC);

precision_of_crosses = [];
recall_of_crosses = [];
for i=1:cross_number
    svm_score = Res.DEC{i}';

    
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
    
    precision_array = [];
    recall_array = [];
    
    
    for j=1:length(seq_of_fppw_score) 
        curr_score_val = seq_of_tppw_score(j);
        num_fn = size( find (score_pos_sample < curr_score_val ) , 2 );
        num_tp = size( find (score_pos_sample >= curr_score_val ) , 2 );
        num_fp = size( find (score_neg_sample >= curr_score_val ), 2);
        precision_array = [precision_array , (double(num_tp) / (num_fp + num_tp) )];
        recall_array = [recall_array  , (double(num_tp) / (num_fn + num_tp) )];
    end
    precision_of_crosses = [precision_of_crosses ; precision_array];
    recall_of_crosses = [ recall_of_crosses  ; recall_array  ];
    
end
F1_score_array = (2 * precision_of_crosses.* recall_of_crosses) ./ (precision_of_crosses + recall_of_crosses);

detcurve.xaxis = mean(recall_of_crosses);
detcurve.yaxis = mean(F1_score_array);
detcurve.ystd = std(F1_score_array);
detcurve.xstd = std(recall_of_crosses);

end