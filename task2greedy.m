clear all;
close all;
clc

Nodes= [30 70
       350 40
       550 180
       310 130
       100 170
       540 290
       120 240
       400 310
       220 370
       550 380];
   
Links= [1 2
        1 5
        2 3
        2 4
        3 4
        3 6
        3 8
        4 5
        4 8
        5 7
        6 8
        6 10
        7 8
        7 9
        8 9
        9 10];

T= [1  3  1.0 1.0
    1  4  0.7 0.5
    2  7  2.4 1.5
    3  4  2.4 2.1
    4  9  1.0 2.2
    5  6  1.2 1.5
    5  8  2.1 2.5
    5  9  1.6 1.9
    6 10  1.4 1.6];

nNodes= 10;

nLinks= size(Links,1);
nFlows= size(T,1);

B= 625;  %Average packet size in Bytes

co= Nodes(:,1)+j*Nodes(:,2);

L= inf(nNodes);    %Square matrix with arc lengths (in Km)
for i=1:nNodes
    L(i,i)= 0;
end
C= zeros(nNodes);  %Square matrix with arc capacities (in Gbps)
for i=1:nLinks
    C(Links(i,1),Links(i,2))= 10;  %Gbps
    C(Links(i,2),Links(i,1))= 10;  %Gbps
    d= abs(co(Links(i,1))-co(Links(i,2)));
    L(Links(i,1),Links(i,2))= d+5; %Km
    L(Links(i,2),Links(i,1))= d+5; %Km
end
L= round(L);  %Km

% Compute up to all paths for each flow:
n= inf;
[sP nSP]= calculatePaths(L,T,n);

%for i=1:nFlows
%    fprintf("[%d,%d] has %d diferente routing paths \n",T(i,1),T(i,2),nSP(i));
%end

%Compute the link loads using the first (shortest) path of each flow:
sol= ones(1,nFlows);
Loads= calculateLinkLoads(nNodes,Links,T,sP,sol);
maxLoad= max(max(Loads(:,3:4)));
%
%Optimization algorithm resorting to the greedy strategy:
fprintf("\nOptimization algorithm resorting to the greedy strategy\n")
%Using all possible routing paths.
t= tic;
bestEnergy= inf;
sol= zeros(1,nFlows);
allValues= [];
while toc(t)<10
    continuar= true;
    while continuar
        continuar= false;
        ax2= randperm(nFlows);
        sol= zeros(1,nFlows);
        for i= ax2
             k_best= 0;
             best= inf;
             for k= 1:nSP(i)
                  sol(i)= k;
                  Loads= calculateLinkLoads(nNodes,Links,T,sP,sol);
                  load= max(max(Loads(:,3:4)));
                  if load <= 10
                      energy = 0;
                      for a=1:nLinks
                          if(Loads(a,3)+Loads(a,4)>0)
                              energy = energy + L(Loads(a,1),Loads(a,2));
                          end
                      end
                  else
                      energy = inf;
                  end
                  if energy<best
                       k_best= k;
                       best= energy;
                  end
             end
             if k_best>0
                sol(i)= k_best;
             else
                continuar= true;
                break;
             end
        end
    end
    energy = best;
    allValues= [allValues energy];
    if energy<bestEnergy
        bestSol= sol;
        bestEnergy= energy;
    end
end
hold on
plot(sort(allValues));
fprintf("\nUsing all possible routing paths\n")
fprintf('   Best Energy = %.2f\n',bestEnergy);
fprintf('   No. of solutions = %d\n',length(allValues));
fprintf('   Av. quality of solutions = %.2f\n',mean(allValues));

%using the 10 shortest routing paths
t= tic;
bestEnergy= inf;
sol= zeros(1,nFlows);
allValues= [];
while toc(t)<10
    continuar= true;
    while continuar
        continuar= false;
        ax2= randperm(nFlows);
        sol= zeros(1,nFlows);
        for i= ax2
             k_best= 0;
             best= inf;
             n = min(10,nSP(i));
             for k= 1:n
                  sol(i)= k;
                  Loads= calculateLinkLoads(nNodes,Links,T,sP,sol);
                  load= max(max(Loads(:,3:4)));
                  if load <= 10
                      energy = 0;
                      for a=1:nLinks
                          if(Loads(a,3)+Loads(a,4)>0)
                              energy = energy + L(Loads(a,1),Loads(a,2));
                          end
                      end
                  else
                      energy = inf;
                  end
                  if energy<best
                       k_best= k;
                       best= energy;
                  end
             end
             if k_best>0
                sol(i)= k_best;
             else
                continuar= true;
                break;
             end
        end
    end
    energy = best;
    allValues= [allValues energy];
    if energy<bestEnergy
        bestSol= sol;
        bestEnergy= energy;
    end
end
hold on
plot(sort(allValues));
fprintf("\nUsing the 10 shortest routing paths\n")
fprintf('   Best Energy = %.2f\n',bestEnergy);
fprintf('   No. of solutions = %d\n',length(allValues));
fprintf('   Av. quality of solutions = %.2f\n',mean(allValues));

%using the 5 shortest routing paths
t= tic;
bestEnergy= inf;
sol= zeros(1,nFlows);
allValues= [];
while toc(t)<10
    continuar= true;
    while continuar
        continuar= false;
        ax2= randperm(nFlows);
        sol= zeros(1,nFlows);
        for i= ax2
             k_best= 0;
             best= inf;
             n = min(5,nSP(i));
             for k= 1:n
                  sol(i)= k;
                  Loads= calculateLinkLoads(nNodes,Links,T,sP,sol);
                  load= max(max(Loads(:,3:4)));
                  if load <= 10
                      energy = 0;
                      for a=1:nLinks
                          if(Loads(a,3)+Loads(a,4)>0)
                              energy = energy + L(Loads(a,1),Loads(a,2));
                          end
                      end
                  else
                      energy = inf;
                  end
                  if energy<best
                       k_best= k;
                       best= energy;
                  end
             end
             if k_best>0
                sol(i)= k_best;
             else
                continuar= true;
                break;
             end
        end
    end
    energy = best;
    allValues= [allValues energy];
    if energy<bestEnergy
        bestSol= sol;
        bestEnergy= energy;
    end
end
hold on
plot(sort(allValues));
legend("all","10 shortest","5 shortest");
fprintf("\nUsing the 5 shortest routing paths\n")
fprintf('   Best Energy = %.2f\n',bestEnergy);
fprintf('   No. of solutions = %d\n',length(allValues));
fprintf('   Av. quality of solutions = %.2f\n',mean(allValues));