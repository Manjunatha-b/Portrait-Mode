function G = GraphConstruct(clusters,L,NumLabels)
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
end