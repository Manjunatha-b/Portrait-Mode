function endimg = SaliencyVisualiser(s,l,h,L)
    endimg = zeros(h,l,1);
    for i=1:l
        for j=1:h
            endimg(j,i)=s(L(j,i));
        end
    end
end