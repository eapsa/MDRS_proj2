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

MTBF= (450*365*24)./L;
A= MTBF./(MTBF + 24);
A(isnan(A))= 0;

logA = -log(A);


% Compute up to all paths for each flow:
n= 10;
[sP1 nSP1 sP2 nSP2]= calculateAvailabilityN(logA,T,n);
tab = '\t'
for i=1:nFlows
    fprintf('\nFlow %d\n',i);
    for k=1:n
        nSP{i}(k) = 1-((1-nSP1{i}{k})*(1-nSP2{i}{k}));
        disp(['[' num2str(sP1{i}{k}(:).') '] [' num2str(sP2{i}{k}(:).') '] -> ' num2str(nSP{i}(k),'%f') ]);
    end
end

fprintf("\nOptimization algorithm resorting to the  multi start hill climbing algorithm\n")
%Using all possible routing paths.
t= tic;
bestLoad= inf;
sol= zeros(1,nFlows);
allValues= [];
while toc(t)<30
    ax2= randperm(nFlows);
    sol= zeros(1,nFlows);
    for i= ax2
         k_best= 0;
         best= inf;
         for k= 1:10
              sol(i)= k;
              Loads= calculateLinkLoads1to1Sol(nNodes,Links,T,sP1,sP2,sol);
              load= max(max(Loads(:,3:4)));
              if load<best
                   k_best= k;
                   best= load;
              end
         end
         sol(i)= k_best;
    end
    load = best;

    %HILL CLIMBING:
    continuar= true;
    while continuar
        i_best= 0;
        k_best= 0;
        best= load;
        for i= 1:nFlows
            for k= 1:10
                if k~=sol(i)
                    aux= sol(i);
                    sol(i)= k;
                    Loads= calculateLinkLoads1to1Sol(nNodes,Links,T,sP1,sP2,sol);
                    load1= max(max(Loads(:,3:4)));
                    if load1<best
                        i_best= i;
                        k_best= k;
                        best= load1;
                    end
                    sol(i)= aux;
                end
            end
        end
        if i_best>0
            sol(i_best)= k_best;
            load= best;
        else
            continuar= false;
        end
    end
    allValues= [allValues load];
    if load<bestLoad
        bestSol= sol;
        bestLoad= load;
    end
end

sumAvai = 0;
for i=1:nFlows
    nSP{i}(sol(i)) = 1-((1-nSP1{i}{sol(i)})*(1-nSP2{i}{sol(i)}));
    sumAvai = sumAvai + nSP{i}(k);
    disp(['[' num2str(sP1{i}{sol(i)}(:).') '] [' num2str(sP2{i}{sol(i)}(:).') '] -> ' num2str(nSP{i}(sol(i)),'%f') ]);
end
sumAvai= sumAvai/nFlows;
fprintf('\n Average service availability: %f\n\n',sumAvai);
fprintf('   Best load = %.2f\n',bestLoad);
