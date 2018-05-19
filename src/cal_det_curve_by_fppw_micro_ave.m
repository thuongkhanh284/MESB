function detcurve = cal_det_curve_by_fppw_micro_ave(Res, params)

fiXLS = params.fiXLS;
XAxis = params.XAxis;

cross_number = length(Res.DEC);

miss_rates_of_crosses = [];
num_pos_array = [];

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
    
    seq_of_fppw_score = score_neg_sample(num_neg_sample -  num_fp_corr_xaxis + 1  );
    
    
    miss_rate_array = [];
    
    
    
    for j=1:length(seq_of_fppw_score) 
        curr_score_val = seq_of_fppw_score(j);
        num_fn = size( find (score_pos_sample < curr_score_val ) , 2 );
        num_tp = size( find (score_pos_sample >= curr_score_val ) , 2 );
        miss_rate_array = [miss_rate_array , num_fn];
    end
    if (length(miss_rates_of_crosses) < 1)
       miss_rates_of_crosses = zeros(1,length(miss_rate_array)); 
       num_pos_array = zeros(1,length(miss_rate_array));
    end
    miss_rates_of_crosses = miss_rates_of_crosses + miss_rate_array;
    num_pos_array = num_pos_array + num_pos_sample;
end
miss_rates_of_crosses
num_pos_array
detcurve.xaxis = params.XAxis;
detcurve.yaxis = double(miss_rates_of_crosses) ./ num_pos_array;
detcurve.ystd = [];


end