function s = GradientDescent(w_bgr,w_Ctr,w_smooth,NumLabels,iterations,alpha,G)
    % initialising saliency map to random values 
    s = rand(NumLabels,1);
    diff_loss = zeros(NumLabels,1);
    summation_arr = zeros(NumLabels,1);
    for i=1:iterations
        for j=1:NumLabels
            summation = double(0);
            na = neighbors(G,j);
            [len,waste] = size(na);
            for x = 1:len
                k = na(x);
                summation = summation + (2*w_smooth(j,k)*(s(j)-s(k)));
            end
            summation_arr(j) = summation;
            
            %%% this loss is different from the Original paper's loss.
            %%% I have tinkered around the weights since I have not used
            %%% face detection extra. These numbers seem to work fine.
            diff_loss(j) = (12*w_bgr(j)*(s(j))) + (2*w_Ctr(j)*(s(j)-1)); 
        end

        for j=1:NumLabels
            s(j) = s(j) - alpha*(diff_loss(j)+ summation_arr(j));
        end
        fprintf('Gradient Descent: %0.2f %%\n',(i/iterations)*100);
    end
    s = s/max(s);
end