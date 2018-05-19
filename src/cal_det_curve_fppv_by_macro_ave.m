function detcurve = cal_det_curve_fppv_by_macro_ave(Res, param)

%type = param.type; % 1 - Normal test , 2 - subject independent test
% get the config FFPV {0.1 , 0.5 , 1  ,  10 }
%detcurve.xaxis = param.XAxis; 
fiXLS = param.fiXLS;

% initialize the output 
detcurve.yaxis = [];
detcurve.ystd = [];
detcurve.debug = {};

% the configuration
scale_list = [1 , 0.75, 0.5];
DEC = Res.DEC; 
num_cross = length(DEC);
 % index of video in test set

 % calculating number of FP
 
num_test_video = size(Res.test_index,2);
% HERE: The number of FP vector.
%method 1
num_fp_array = [1:(num_test_video), num_test_video*5 , num_test_video*10 ];
 %method 2 : number of each FP vector
% num_fp_array = [floor(0.1*num_test_video),  , floor(0.5*num_test_video) ];
 
win_list = {};
top_list = {};
vid_list = [];
TP_list = {};
FP_list = {};
MissRate_Arr = [];
FP_video = {};
fpvid = 1;

monitor_arr = {}; % this variable is used to debug
tp_thr = []; % debug vars
tic
for (cross_id = 1: num_cross)
    

    %test_index = Res.test_index(cross_id , :); % video index of test set
    scale_array = Res.test_scale{cross_id}; % vector
    score_array = Res.DEC{cross_id}'; % score vector of each cross validation
    test_label = Res.LabelTest{cross_id}; % label vector of test sample (-1, 1)
    test_video = Res.testVideo{cross_id}; % video index vector of each sample
    test_window_position = Res.testID{cross_id}; % 
    % the ground truth label
    
    % sort the score vector 
    [sorted_score_array , id] = sort(score_array);
    sorted_scale = scale_array(id);
    sorted_label = test_label(id);
    sorted_video = test_video(id);
    sorted_winpos = test_window_position(id);
    
%     idpos = find(sorted_label > 0);
%     idneg = find(sorted_label <= 0);
%     pos_sorted_scale = sorted_scale(idpos);
%     pos_sorted_video = sorted_video(idpos);
%     pos_sorted_winpos = sorted_winpos(idpos);
%     pos_sorted_score = sorted_score_array(idpos);
%     
%     neg_sorted_scale = sorted_scale(idneg);
%     neg_sorted_video = sorted_video(idneg);
%     neg_sorted_winpos = sorted_winpos(idneg);
%     neg_sorted_score = sorted_score_array(idneg);
    
    list_video = sort(unique(test_video)); 
    %INITIALIZE MissRate
    MissRate = zeros(1,length(num_fp_array)) - 1;
    % calculate the number of Postiive Sample

    num_POS_ME = sum(fiXLS(list_video,14));% number of Positive Ground Truth
    num_video = length(list_video); % number of video in test set
    
    %num_fp_array = floor (param.XAxis * num_video);
    

    num_window = length(sorted_score_array); % number of test sample
    %num_neg_window = length(neg_sorted_score);
    tp_thr = [];
    for ( i= num_window:-1:1)
    %for ( i= num_window:-1:1 )
        threshold_val = sorted_score_array(i);
        
%         threshold_val = neg_sorted_score(i);
%         id_tmp = find(sorted_score_array == threshold_val);
        index_thr = i:num_window;

        TP = 0;
        FP = 0;
        FN = 0;
        
        % obtain the scores, video , scale , lable, position from i to
        % num_window
        score_one_threshold = sorted_score_array(index_thr);
        video_one_theshold = sorted_video(index_thr);
        scale_one_threshold = sorted_scale(index_thr);
        label_one_threshold = sorted_label(index_thr);
        position_one_threshold = sorted_winpos(index_thr);
        
        %list video index used in test set
        video_list_one_threshold = sort(unique(video_one_theshold));
        
        num_fp_one_video = [];
        for (j=1:length(video_list_one_threshold))
            % process with one video 
            vid_index = video_list_one_threshold(j);
            idv = find(video_one_theshold == vid_index); % get the indexs of sample belonged to vid_index 
            
            score_one_video = score_one_threshold(idv);
            scale_one_video = scale_one_threshold(idv);
            label_one_video = label_one_threshold(idv);
            position_one_video = position_one_threshold(idv);
            
            window_one_video = [];
            
            % window_one_video vector = [first position , last position of
            % samples, SVM score];
            window_one_video = [ position_one_video ./ scale_one_video , (position_one_video+8)./ scale_one_video,  score_one_video  ];
            % using Non Maxima Suppression      
            % 
            %option 1
            top_window = fast_nms(window_one_video , 0.5) ;
            % option 2
            %top_window = fast_nms2(window_one_video , 0.5) ;
            
            % get the number of ME in one video
            vid_ind = vid_index;
            numME = fiXLS(vid_ind,14);
            % obtain ground truth for each video
            ground_truth_window = [];
            FP_onevideo = 0;
            TP_onevideo = 0;
            FN_onevideo = 0;
            ME_Pos = 5;
            for (t=1:numME)
                if (t==2)
                    ME_Pos = 7;
                end
                % get the Onset and Offset
                OnsetX  = fiXLS(vid_ind,ME_Pos) - fiXLS(vid_ind,10) + 1 ;
                OffsetX = fiXLS(vid_ind,ME_Pos + 1 ) - fiXLS(vid_ind,10) + 1 ;
                ground_truth_window = [ ground_truth_window;  OnsetX , OffsetX];
                
                save_win = [];
                for (tw = 1 : size(top_window,1) )
                    st = top_window(tw,1);
                    en = top_window(tw,2);
                    sc = top_window(tw,3);
                    % calculating the overloap between ground truth and
                    % detector
                    olp = fcn_cal_overloap(st,en,OnsetX,OffsetX);
                    
                    % obtain the matching windows
                    if (olp >= 0.5)
                        save_win = [save_win ; tw];
                    end
                
                end
                
                % if matching window >= 1: there one TP
                if (length(save_win) >= 1)
                    TP_onevideo = TP_onevideo + 1;
                    
                end
                % if matching window == 0: there one FN
                if (length(save_win) == 0)
                    FN_onevideo = FN_onevideo + 1;
                end
                
            end
            
            % calcualte TP = TP + TP_inOneVideo
            TP = TP + TP_onevideo;
            % minus the total detected window with TP_Onevideo to obtain FP
            FP = FP + size(top_window,1) - TP_onevideo;
            FN = FN + FN_onevideo;
           
        end
        
        % after all video in one threshold: mapping the MissRate to the
        % corresponded position of FP quantity.
        
        
        if (any(num_fp_array == FP) == 1)
            id_fp = find(FP == num_fp_array );
            
            MissRate(id_fp) = 1 - (TP/ num_POS_ME); % MissRate = 1 - True Positive Rate
            
        end
        
        % this code is used to debug
%         if (FP==230)
%             tp_thr = [tp_thr ; threshold_val , TP];
%         end
        
        % too heuristics to stop the calculation: if FP > 10*numvideo + 100,
        % we only care the FP 1 -> numvideo and numvideo*10
        if (FP> num_video * 10 + 20)
            break;
        end
        
    end
    % debugging vars
    %monitor_arr{cross_id} = tp_thr;
    
    % one vector of Miss Rate from (0,1) - 1 and 10^1
    
    MissRate_Arr = [MissRate_Arr ; MissRate];
    
end

toc
detcurve.xaxis = num_fp_array / num_test_video;
% there are -1 in some cross: remove calculate -1 in each 
for (i=1:size(MissRate_Arr,2))
    miss_rate_one_fp = MissRate_Arr(:,i);
    miss_rate_one_fp_no_0 = miss_rate_one_fp(miss_rate_one_fp~=-1);
    detcurve.yaxis = [ detcurve.yaxis , mean(miss_rate_one_fp_no_0)];
    detcurve.ystd = [detcurve.ystd , std(miss_rate_one_fp_no_0)];
    
end

detcurve.num_video = num_test_video;



end