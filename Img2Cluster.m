function [clusters,L,NumLabels] = Img2Cluster(img,no_clusters)
    [h,l,waste] = size(img);
    conv = rgb2lab(img);

    % Superpixel segmentation
    [L,NumLabels] = superpixels(conv,no_clusters,'IsInputLab',true,'NumIterations',20);

    % Computing cluster regions
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
    
    % this variable clusters, is an array that holds each cluster's average
    % color, its center position x,y & the number of pixels assigned to it
    clusters(:,1) = clusters(:,1)./clusters(:,6);
    clusters(:,2) = clusters(:,2)./clusters(:,6);
    clusters(:,3) = clusters(:,3)./clusters(:,6);
    clusters(:,4) = clusters(:,4)./clusters(:,6);
    clusters(:,5) = clusters(:,5)./clusters(:,6);
end