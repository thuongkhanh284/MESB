
% function fast Non-maxima suppression
% input: window (:,3) <- ( start frame ,  end frame  , score) - olp :
% overlap rate threshold
% % output: top window
function [top ] = fast_nms (window , olp )
 if isempty(window)
     top = [];
     return;
 end 
 
 st = window(:,1);
 en = window(:,2);
 s = window(:,3); % SVM score
 
 pick = 0;
 counter = 1;
 
 
 len = (en - st + 1);
 [vals, I] = sort(s);
 while (~isempty(I)) 
     last = length(I);
     i = I(last);
     pick(counter) = i;
     counter = counter + 1;
     
     xx = max( st(i) , st( I(1:last-1)));
     yy = min( en(i) , en( I(1:last-1 )));
     
     len2 = max(0.0, yy-xx+1);

     o = len2 ./ len(I(1:last-1));
     I( [last ; find(o>= olp) ] ) = [];
 end
 pick= pick(1:(counter-1));
 top = window(pick,:);
 
end

