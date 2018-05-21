

dir_result_path = '..//result//';
dir_result_obj =  dir(dir_result_path);

Miss_Rate_Array = [];
Miss_Rate_STD = [];

L=9;
fiXLS = xlsread('SMIC-VIS-E-Norm.xlsx');
XAxis = [0.05 , 0.1 , 0.5 , 1, 5, 10 ];
param.L = L;
param.fiXLS = fiXLS;
param.XAxis = XAxis;
det_data = {};
test_type = 'norm';
nObj = length(dir_result_obj);
norm_index = 1;
tic
for dir_index = 3: 3

 
 file_name = dir_result_obj(dir_index).name;
 data_path = {};
%  if length(strfind (file_name , test_type)) == 0
% %      param.type = 2; % 2 is Subject independent test
% %      dat = load(data_path{1});
% %     Res = dat.Res;
% %   
% %     % process the the function to calculate FPPV
% %     detcurve = fcn_cal_fppv(Res, param);
% %     det_data(dir_index-2) = detcurve;
%  end
 if (length(strfind (file_name , test_type)) == 1 && length(test_type) == 4)
    
    data_path{1} = [dir_result_path , file_name];
    dat = load(data_path{1});
    Res = dat.Res;
    Res = Res{3}; % set this for normal test : 30/70 - 50/50 - 70/30
    param.type = 1;
    % process the the function to calculate FPPV
    detcurve = cal_f1_curve_fppv_by_micro_ave(Res, param);
    detcurve.yaxis;
    detcurve.dataname = file_name
    
    det_data{norm_index} = detcurve;
    norm_index = norm_index + 1;
 end
  if (length(strfind (file_name , test_type)) == 1 && length(test_type) == 3)
    
    data_path{1} = [dir_result_path , file_name];
    dat = load(data_path{1});
    Res = dat.Res;
    
    param.type = 2;
    file_name
    % process the the function to calculate FPPV
    %detcurve = cal_fppv_sub(Res, param);
    detcurve = cal_fppv_leave_one(Res,param);
    detcurve.dataname = file_name;
    
    det_data{norm_index} = detcurve;
    norm_index = norm_index + 1;
  end
 
end
toc