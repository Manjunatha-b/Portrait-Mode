function endimg = ClusterVisualiser(clusters,l,h,L)
    endimg = zeros(h,l,3);
    for i=1:l
        for j=1:h
            endimg(j,i,1) = clusters(L(j,i),1);
            endimg(j,i,2) = clusters(L(j,i),2);
            endimg(j,i,3) = clusters(L(j,i),3);
        end
    end
end