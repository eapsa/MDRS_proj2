function [sP nSP sP2 nSP2]= calculateAvailabilityN(L,T,n)
    nFlows= size(T,1);
    for i=1:nFlows
        [shortestPath, totalCost] = kShortestPath(L,T(i,1),T(i,2),n);
        sP{i}= shortestPath;
        for j=1:n
            tempL = L;
            c = shortestPath{j};
            before1 = 1;
            for k = 1:(length(c)-1)
                before1 = before1 * exp(-L(c(k),c(k+1)));
                tempL(c(k),c(k+1)) = inf;
                tempL(c(k+1),c(k)) = inf;
            end
            nSP{i}{j}= before1;
            [shortestPath2, totalCost2] = kShortestPath(tempL,T(i,1),T(i,2),1);
            if length(shortestPath2)>0
                sP2{i}(j)= shortestPath2;
                c = shortestPath2{1};
            else
                sP2{i}(j)= {[]};
            end
            before2 = 1;
            for k = 1:(length(c)-1)
                before2 = before2 * exp(-tempL(c(k),c(k+1)));
            end
            nSP2{i}{j}= before2;
        end
    end
end