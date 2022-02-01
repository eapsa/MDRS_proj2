function [sP nSP sP2 nSP2]= calculateAvailability(L,T,n)
    nFlows= size(T,1);
    nSP= zeros(1,nFlows);
    nSP2= zeros(1,nFlows);
    for i=1:nFlows
        tempL = L;
        [shortestPath, totalCost] = kShortestPath(L,T(i,1),T(i,2),n);
        sP{i}= shortestPath;
        c = shortestPath{1};
        before1 = 1;
        for k = 1:(length(c)-1)
            before1 = before1 * exp(-L(c(k),c(k+1)));
            tempL(c(k),c(k+1)) = inf;
            tempL(c(k+1),c(k)) = inf;
        end
        nSP(i)= before1;
        [shortestPath2, totalCost2] = kShortestPath(tempL,T(i,1),T(i,2),n);
        sP2{i}= shortestPath2;
        c = shortestPath2{1};
        before2 = 1;
        for k = 1:(length(c)-1)
            before2 = before2 * exp(-tempL(c(k),c(k+1)));
        end
        nSP2(i)= before2;
    end
end