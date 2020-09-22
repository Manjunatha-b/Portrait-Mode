function [w_bgr,w_Ctr,Ctr,w_smooth] = WeightGen(NumLabels,L,clusters,G,l,h)
    
    % Calculating Geodesic shiz
    A = zeros(NumLabels,1);
    BndCon = zeros(NumLabels,1);
    Lens = zeros(NumLabels,1);
    sigmaG = 10;
    w_bgr = double(zeros(NumLabels,1));
    w_Ctr = double(zeros(NumLabels,1));
    Ctr = double(zeros(NumLabels,1));
    
    % Finding clusters on image border
    
    boundary_cluster_list = [];
    boundary_cluster_list = [boundary_cluster_list;L(1,:)];
    boundary_cluster_list = [boundary_cluster_list L(:,1).'];
    boundary_cluster_list = [boundary_cluster_list L(h,:)];
    boundary_cluster_list = [boundary_cluster_list L(:,l).'];
    boundary_cluster_list = unique(boundary_cluster_list.','rows');
    [boundary_cluster_len,waste] = size(boundary_cluster_list);

    % Finding w_bgr values ( Background map )

    for i=1:NumLabels
        area=double(0);
        len = 0;
        S_array = zeros(NumLabels,1);
        temp = double(0);
        for j=1:NumLabels
            if(i==j)
                area = area+1;
                continue;
            end
            [waste,Dg] = shortestpath(G,i,j);
            coeff = (-power(Dg,2))/(2*power(sigmaG,2)); 
            S = exp(coeff);
            area = area+S;
            S_array(j) = S;
        end
        for j=1:boundary_cluster_len
            len = len + S_array(boundary_cluster_list(j));
        end
        A(i) = area;
        Lens(i) = len;
        BndCon(i) = len/sqrt(area);
        w_bgr(i) = 1 - (exp(-(power(BndCon(i),2)/2)));
        fprintf('Calculating background weights: %0.2f %%\n',(i/NumLabels)*100);
    end

    % Finding w_ctr values ( Contrast map / Foreground shiz )

    w_smooth = zeros(NumLabels,NumLabels);

    for i=1:NumLabels
        temp = double(0);
        temp_ctronly = double(0);
        for j=1:NumLabels
            if(i==j)
                continue;
            end
            l_diff = clusters(i,1) - clusters(j,1);
            a_diff = clusters(i,2) - clusters(j,2);
            b_diff = clusters(i,3) - clusters(j,3);
            dist_colspace = sqrt(power(l_diff,2)+ power(a_diff,2) + power(b_diff,2));
            dist_spat = sqrt(power((clusters(i,4)-clusters(j,4))/l,2) + power((clusters(i,5)-clusters(j,5))/h,2));
            coeff = (-power(dist_spat,2))/(2*(0.25*0.25)); 
            w_spa = exp(coeff);
            temp = temp + dist_colspace*w_spa*w_bgr(j);
            temp_ctronly = temp_ctronly + dist_colspace*w_spa;
            w_smooth(j,i) = exp(-power(dist_colspace,2)/(2*85)) + 0.2; % Smoothness matrix 
        end
        w_Ctr(i) = temp;
        Ctr(i) = temp_ctronly;
        fprintf('Calculating foreground, smoothness weights : %0.2f %%\n',(i/NumLabels)*100);
    end

    w_Ctr = w_Ctr/(max(w_Ctr));
    Ctr = Ctr/max(Ctr);
end