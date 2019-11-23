%       Reading image
img = imread('prof2.jpg');
[h,l,waste] = size(img);

%       Converting to Lab space
conv = rgb2lab(img);

%       Superpixel segmentation
[L,NumLabels] = superpixels(conv,500,'IsInputLab',true,'NumIterations',20);

%       Computing cluster regions
clusters  = double(zeros(NumLabels,6));

for i=1:l
    for j=1:h
        clusters(L(j,i),1) = clusters(L(j,i),1) + conv(j,i,1);
        clusters(L(j,i),2) = clusters(L(j,i),2) + conv(j,i,2);
        clusters(L(j,i),3) = clusters(L(j,i),3) + conv(j,i,3);
        clusters(L(j,i),4) = clusters(L(j,i),4) + i;
        clusters(L(j,i),5) = clusters(L(j,i),5) + j;
        clusters(L(j,i),6) = clusters(L(j,i),6) + 1;
    end
end
 
clusters(:,1) = clusters(:,1)./clusters(:,6);
clusters(:,2) = clusters(:,2)./clusters(:,6);
clusters(:,3) = clusters(:,3)./clusters(:,6);
clusters(:,4) = clusters(:,4)./clusters(:,6);
clusters(:,5) = clusters(:,5)./clusters(:,6);

%       Calculating superpixeled image with cluster color (Not req);

endimg = zeros(h,l,3);
for i=1:l
    for j=1:h
        endimg(j,i,1) = clusters(L(j,i),1);
        endimg(j,i,2) = clusters(L(j,i),2);
        endimg(j,i,3) = clusters(L(j,i),3);
    end
end

%imshow(lab2rgb(endimg));
%       Creating adjacency matrix of superpixels , stored in neighbours

glcms = graycomatrix(L,'NumLevels',NumLabels,'GrayLimits',[1,NumLabels],'Offset',[0,1;1,0]);
glcms = sum(glcms,3);    % add together the two matrices
glcms = glcms + glcms.'; % add upper and lower triangles together, make it symmetric
glcms(1:NumLabels+1:end) = 0; 
[I,J] = find(glcms);     % returns coordinates of non-zero elements
neighbours = [J,I];



%       Creating Weight list of euclidian distances , stored in euclids

[no_edges , waste ] = size(neighbours);
euclids = zeros(no_edges,1);

for i=1:no_edges
    l_diff = clusters(neighbours(i,1),1) - clusters(neighbours(i,2),1);
    a_diff = clusters(neighbours(i,1),2) - clusters(neighbours(i,2),2);
    b_diff = clusters(neighbours(i,1),3) - clusters(neighbours(i,2),3);
    dist = sqrt(power(l_diff,2)+ power(a_diff,2) + power(b_diff,2));
    euclids(i) = dist;
end


%       Creating the graph 

G = graph(neighbours(:,1),neighbours(:,2),euclids);
G = simplify(G); % Removes redundant connections , formatting problem

%       Calculating shortest distance between graph

%[P,d] = (shortestpath(G,1,4));
%disp(P);
%disp(d);

%       Calculating Geodesic shiz
A = zeros(NumLabels,1);
BndCon = zeros(NumLabels,1);
Lens = zeros(NumLabels,1);
w_bgr = double(zeros(NumLabels,1));
sigmaG = 10;
w_Ctr = double(zeros(NumLabels,1));
Ctr = double(zeros(NumLabels,1));
        %       Finding clusters on image border
        
boundary_cluster_list = [];
boundary_cluster_list = [boundary_cluster_list;L(1,:)];
boundary_cluster_list = [boundary_cluster_list L(:,1).'];
boundary_cluster_list = [boundary_cluster_list L(h,:)];
boundary_cluster_list = [boundary_cluster_list L(:,l).'];
boundary_cluster_list = unique(boundary_cluster_list.','rows');
disp(size(boundary_cluster_list));
[boundary_cluster_len,fuk] = size(boundary_cluster_list);

%        Finding w_bgr values ( Background map )

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
end

%       Finding w_ctr values ( Contrast map / Foreground shiz )

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
end

w_Ctr = w_Ctr/(max(w_Ctr));
Ctr = Ctr/max(Ctr);

plot(G);

% Attempt to minimize the Saliency EQN 
% (w_bgr*s)^2 + (w_Ctr*(s-1))^2 + smoothness
% Think i'll try to randomly intialize saliency values and iterate loss

s = rand(NumLabels,1);
diff_loss = zeros(NumLabels,1);
summation_arr = zeros(NumLabels,1);
alpha = 0.05;
for i=1:299
    for j=1:NumLabels
        summation = double(0);
        na = neighbors(G,j);
        [len,waste] = size(na);
        for x = 1:len
            k = na(x);
            summation = summation + (2*w_smooth(j,k)*(s(j)-s(k)));
        end
        summation_arr(j) = summation;
        diff_loss(j) = (12*w_bgr(j)*(s(j))) + (2*w_Ctr(j)*(s(j)-1)); 
    end
    
    %summation_arr = summation_arr/max(summation_arr);
    %diff_loss = diff_loss/max(diff_loss);
    
    for j=1:NumLabels
        s(j) = s(j) - alpha*(diff_loss(j)+ summation_arr(j));
    end
end

s = s/max(s);
endimg = zeros(h,l,1);
for i=1:l
    for j=1:h
        
        if(s(L(j,i))>0.60)
            endimg(j,i)=1;
        else
            endimg(j,i)=0;
        end
        %endimg(j,i)=s(L(j,i));
    end
end


%imshow(uint8(255*endimg));
BW2 = bwareaopen(endimg,(10000));
BW2 = imgaussfilt((uint8(BW2)),8);
BW2=BW2>0.4;
imshow(BW2);


backgr = uint8(1-BW2).*img;
foregr = uint8(BW2).*img;
blurredbackgr = imgaussfilt(img,11).*uint8(1-BW2);
sharpenedfrgr = imsharpen(foregr).*uint8(BW2);

imshow(blurredbackgr+sharpenedfrgr);