%load 304flow0flowallleveltime.mat 
load import304.mat %international imported
load .\res\matlab0926.mat;%results of f1.m

%rewrite f3,f4 as f3pred,f4pred; to calculate inter-city import、local、internatioanl import.
%im: data-international imported cases

% In order to use the |mcmcpred| function we need
% function |modelfun| with input arguments given as
% |modelfun(xdata,theta)|. We construct this as an anonymous function.
modelfun = @(d,th,im) f3pred(d(:,1),th,d,im);

%to predict local and import cases,the mcmc chain need to be reconstruct to be
%3*304 columns to give predictive range,respectively for local and imported cases;
s2chain4=s2chain2;
s2chain4(:,305:608)=s2chain4(:,1:304);
s2chain4(:,609:912)=s2chain4(:,1:304);

% We sample 1000 parameter realizations from |chain| and |s2chain|
% and calculate the predictive plots.
nsample = 100;
results2.sstype = 1;
out2 = mcmcpred(results2,chain2,s2chain4,data.xdata,modelfun,nsample,import304);
time=136;%time period 1.11-5.25(due to Subsequent importation of foreign cases)
m=304;%number of city 

%save data��local、import、reportI
for i =1:m

%all cases    
ohighfeng(1:time,i)=out2.obslims{1,1}{1,i}(3,1:time);
obsfeng(1:time,i)=out2.obslims{1,1}{1,i}(2,1:time);
olowfeng(1:time,i)=out2.obslims{1,1}{1,i}(1,1:time);
prehighfeng(1:time,i)=out2.predlims{1,1}{1,i}(3,1:time);
prefeng(1:time,i)=out2.predlims{1,1}{1,i}(2,1:time);
prelowfeng(1:time,i)=out2.predlims{1,1}{1,i}(1,1:time);

%local cases
localobs(1:time,i)=out2.obslims{1,1}{1,i+304}(2,1:time);
localobslow(1:time,i)=out2.obslims{1,1}{1,i+304}(1,1:time);
localobshigh(1:time,i)=out2.obslims{1,1}{1,i+304}(3,1:time);

%imported cases
importobs(1:time,i)=out2.obslims{1,1}{1,i+608}(2,1:time);
importobslow(1:time,i)=out2.obslims{1,1}{1,i+608}(1,1:time);
importobshigh(1:time,i)=out2.obslims{1,1}{1,i+608}(3,1:time);
importprehigh(1:time,i)=out2.predlims{1,1}{1,i+608}(3,1:time);
importpre(1:time,i)=out2.predlims{1,1}{1,i+608}(2,1:time);
importprelow(1:time,i)=out2.predlims{1,1}{1,i+608}(1,1:time);

end

%% national cases
%all cases
yobsfeng=sum(obsfeng,2);
yobsfenghigh=sum(ohighfeng,2);
yobsfenglow=sum(olowfeng,2);
yprefeng=sum(prefeng,2);
yprefenghigh=sum(prehighfeng,2);
yprefenglow=sum(prelowfeng,2);

%observed
yreal=sum(data.ydata(:,2:(m+1)),2);
%%%%%local
ylocalobs=sum(localobs,2);
ylocalobslow=sum(localobslow,2);
ylocalobshigh=sum(localobshigh,2);
%%%%%imported
yimportobs=sum(importobs,2);
yimportobslow=sum(importobslow,2);
yimportobshigh=sum(importobshigh,2);
yimportpre=sum(importpre,2);
yimportprelow=sum(importprelow,2);
yimportprehigh=sum(importprehigh,2);

%% plot local+import 
figure
fillyy(1:time,ylocalobshigh,ylocalobslow,[0.8 0.8 0.8]);
hold on 
fillyy(1:time,yimportobshigh,yimportobslow,[0.9 0.9 0.9]);
plot(ylocalobs);
plot(yimportobs,'b');
plot(yobsfeng);
legend('localobsCI','importobsCI','local','import','allI')
hold off


