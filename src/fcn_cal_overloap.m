function [overlap_val] = fcn_cal_overloap( x1,y1,x2,y2)
overlap_val=0;

% method 1: forcing integer by ceil function
x1 = ceil(x1);
x2 = ceil(x2);
y1 = ceil(y1);
y2 = ceil(y2);

% method 2: using two kinds of integer
% if (floor(x1) + 0.5 > x1)
%     x1= floor(x1);
% else
%     x1 = ceil(x1);
% end
% 
% if (floor(x2) + 0.5 > x2)
%     x2= floor(x2);
% else
%     x2 = ceil(x2);
% end
% 
% if (floor(y1) + 0.5 > y1)
%     y1= floor(y1);
% else
%     y1 = ceil(y1);
% end
% 
% if (floor(y2) + 0.5 > y2)
%     y2= floor(y2);
% else
%     y2 = ceil(y2);
% end

intersect_val = fcn_intersection(x1,y1,x2,y2);
if (length(intersect_val) == 0)
    overlap_val = 0;
else
    union_val = fcn_union(x1,y1,x2,y2);

    overlap_val = length(intersect_val) / length(union_val);
end



end

function [ insec] = fcn_intersection(x1,y1,x2,y2)
insec = [];

min_x = min(x1,x2);
max_y = max(y1,y2);

for i=min_x: max_y
    if ( i >= x1 && i <= y1 && i >= x2 && i <= y2 )
        insec = [insec , i];
    end
end

end

function [ uni ] = fcn_union(x1,y1,x2,y2)
uni = [];

for (i=floor(x1):floor(y1))
    if ( i >= x1 && i <= y1  )
        uni = [uni , i];
    end
end
for (i=floor(x2):floor(y2))
    if ( i >= x2 && i <= y2  )
        uni = [uni , i];
    end
end
uni = unique(uni);
end