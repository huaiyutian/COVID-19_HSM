clear
load 304flow0flowallleveltime.mat 
load codename.mat %cityname
%%
% The model sum of squares in file <algaess.html |algaess.m|> is
% given in the model structure.
model.ssfun = @f2;

%%
% All parameters are constrained to be positive. The initial
% concentrations are also unknown and are treated as extra parameters.
params1 = {   
    
    %parameter
    %name,mean,min.max,mean,std
    {'sigma', 7.17,3,14,8,2}  %incubation period
    {'report', 0.002,0,1,0.003,0.003} %report rate
    {'gamma', 4, 2,15,5,1}%infection period
    {'beta', 1,0.01,5}  %transmission rate 
    {'Iw0', 5,1,11} %the estimated reported cases of first 5 days in wuhan
    {'c1high',0.9,0,1} %control level1-1
    {'c1mid',0.5,0,1} %control level1-2
    {'c1low',0.1,0,1} %control level1-3 
    {'c2nd',0.15, 0,1}%2nd control
    
    };

%%
% We assume having at least some prior information on the
% repeatability of the observation and assign rather non informational
% prior for the residual variances of the observed states. The default
% prior distribution is sigma2 ~ invchisq(S20,N0), the inverse chi
% squared distribution (see for example Gelman et al.). The 3
% components (_A_, _Z_, _P_) all have separate variances.

model.S20 = [4];
model.N0  = [1];

%%
% First generate an initial chain.
options.nsimu = 50000;
options.stats = 1;
[results, chain, s2chain]= mcmcrun(model,data,params1,options);


% % %%
options.nsimu = 200000;
options.stats = 1;
[results2, chain2, s2chain2] = mcmcrun(model,data,params1,options,results);

%%
% Chain plots should reveal that the chain has converged and we can
% % use the results for estimation and predictive inference.
  
figure
mcmcplot(chain2,[],results2,'denspanel',2);
figure
mcmcplot(chain2,[],results2); %,'pairs'

%%
% Function |chainstats| calculates mean ans std from the chain and
% estimates the Monte Carlfigure
% the integrated autocorrelation time and |geweke| is a simple test
% for a null hypothesis that the chain has converged.

results2.sstype = 1; % needed for mcmcpred and sqrt transformation

chainstats(chain2,results2)


%%
% In order to use the |mcmcpred| function we need
% function |modelfun| with input arguments given as
% |modelfun(xdata,theta)|. We construct this as an anonymous function.

modelfun = @(d,th) f3(d(:,1),th,th(end),d);


%%o
% We sample 1000 parameter realizations from |chain| and |s2chain|
% and calculate the predictive plots.
nsample = 500;
results2.sstype = 1;
out = mcmcpred(results2,chain2,s2chain2,data.xdata,modelfun,nsample);%data.ydata-->data

 %figure
% mcmcpredplot(out,out.data,data,C);

%save result data
time=56; %model period
m=304;  % the number of city
for i =1:m
    
prefeng(1:time,i)=out.predlims{1,1}{1,i}(2,:);
prehighfeng(1:time,i)=out.predlims{1,1}{1,i}(3,:);
prelowfeng(1:time,i)=out.predlims{1,1}{1,i}(1,:);
ohighfeng(1:time,i)=out.obslims{1,1}{1,i}(3,:);
obsfeng(1:time,i)=out.obslims{1,1}{1,i}(2,:);
olowfeng(1:time,i)=out.obslims{1,1}{1,i}(1,:);
tem=corrcoef(prefeng(:,i),data.ydata(:,(i+1)));
temr2=1-sum((data.ydata(:,i+1)-prefeng(:,i)).^2)/ sum((data.ydata(:,i+1)-mean(data.ydata(:,i+1))).^2);
cor(i)=tem(2,1);
r2(i)=temr2;
end
yfeng=sum(prefeng,2);%predict median
yfenghigh=sum(prehighfeng,2);%predict 95CI-high
yfenglow=sum(prelowfeng,2);%predict 95CI-low
yobsfeng=sum(obsfeng,2);%obs 95CI-median
yobsfenghigh=sum(ohighfeng,2);%obs 95CI-high
yobsfenglow=sum(olowfeng,2);%obs 95CI-low
yreal=sum(data.ydata(:,2:(m+1)),2); %observation
% 
figure
fillyy(1:56,yobsfenghigh,yobsfenglow,[0.8 0.8 0.8]);
hold on 
plot(yreal);
plot(yfeng);
plot(1:56,yobsfeng);



