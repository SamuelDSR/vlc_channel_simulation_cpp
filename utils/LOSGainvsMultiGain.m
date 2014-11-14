HLos = zeros(1,total_receivers);
HMulti = zeros(1,total_receivers);
for j = 1:total_sources
    for k = minbounce:maxbounce
        tmp = cell2mat(p(k+1,j));
        for i = 1:total_receivers
            if k == 0
                HLos(i) = HLos(i)+tmp(i);
            else
                HMulti(i) = HMulti(i)+tmp(i);
            end
        end
    end
end
            