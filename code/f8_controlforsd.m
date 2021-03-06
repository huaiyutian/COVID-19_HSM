function dur=f8_controlforsd(sd,results2)

%% load data
load('Data_304_flowall_leveltime.mat'); %108obs-data
day=load('2019_month_day.mat'); %the number of day in specific month of 2019
load('Data_2019_cityflow.mat') %cityflow of 2019-12 months

%% parameter
theta=results2.mean;%results of f1.m
xdata=data.xdata;
simday=1000;%days of simulation
t=1:56; %period 1/11-3/6
n=304;  %the number of cities
gamma1(1:n)=theta(3); %infectious period from onset to removed of the asymptomatic
gamma=1./gamma1; 
gamma_s=1./(gamma1*theta(10));%removed rate of symptomatic infectivity
sigma_a=1/theta(1);%Mean latent period (days)
report=1/theta(2); %report rate
beta_b(1:n)=theta(4); % basic transmission rate

afa=0.5;%relative infectiousness of asymptomatic individuals [ref.Alberto,2020,nature human behavior]
beta_s=0.15;%proportion of presymptomatic transmission equals percent of infectioness [ref.Alberto,2020,nature human behavior]
sigma_pre=1/2;%latent period BUT presymptomatic [ref.Alberto,2020,nature human behavior]
sigma_s=1/(theta(1)-2);%latent period of symptomatic individuals
p=0.25;%proportion of asymptomatic

%% data
Pwuhan=10892900;%population of Wuhan
flowWH=xdata(ceil(t),2:(n+1));%flow from wuhan to other city
HRwuhan=xdata(ceil(t),1523);%wuhan report daily cases
HRwuhan(1:5)=theta(5);%the estimated reported cases of first 5 days in wuhan
pop=xdata(ceil(57),2:(n+1))*1000000;%population of other city
%because wuhan has been shutdown from 1.23,
%When Wuhan was completely free of cases, traffic resumed,so it won't
%import cases to other city,we then set flow from wuhan to other city and cases to be 0
flowWH(57:simday,:)=0;
HRwuhan(57:simday)=0;

%% model varible
HLa(1,1:n) = 0; %latent asymptomatic 
HIa(1,1:n) = 0; % infectious asymptomatic
HRa(1,1:n) = 0; %recovered asymptomatic
HLs(1,1:n) = 0; %latent symptomatic 
HLp(1,1:n) = 0; %presymptomatic
HS(1,1:n) = pop; %susceptible
HI(1,1:n) = 0; %infectious symptomatic 
HR(1,1:n) = 0; %removed symptomatic
I(1,1:n)=0; %daily reported cases
HN(1,1:n)=HS(1,1:n);%all population

%% results variable
res=cell(1,1);% save primary data of model
dur=zeros(20,20);%average duration of all cities
sumdur=dur;%duration of nation
avg_max_size=dur;%average max epidemic size of all cities
nation_max_size=dur;%max epidemic size of nation

%% model
 for perinter=[0.05:0.05:1] % control intensity of inter-city flow 
        percent_inter(1:simday)=perinter;
        percent_inter(1:13)=1;%control begin after 1.25 1-level response
        
    for perintra=[0.05:0.05:1]% control intensity of intra-city flow
        
        %% scene-setting
        for i = 2:simday
            
            %current month and days of month to load cityflow of month
            monthnow=mod(floor((i-11)/30)+2,12);
            if(monthnow==0)
                monthnow=12;
            end
            %daily inter city flow of current month
            Fcitybalcance=cityflow(:,((1+304*(monthnow-1)):304*(monthnow)))/day.day(monthnow);

             %transmission control between people
            beta=beta_b;%basic transmission  
            beta2=sd*perintra; %control for transmission between people  
            if(i>13)%1.25 1-level response
            beta=beta_b*beta2; %control begin from 1-level response
            end
        
         % Imported Infected cases from whuhan
            importI=HRwuhan(i-1)*flowWH(i-1,:)*report/Pwuhan*percent_inter(i-1); %; %exposed cases from wuhan to other cities

            % different class to calculate travel people proportion later 
            HLaallcity=repmat(HLa(i-1,:),304,1); %matrix 304*304,latent asymptomatic population of cities
            HIaallcity=repmat(HIa(i-1,:),304,1); %matrix 304*304,infectious asymptomatic population of cities
            HLsallcity=repmat(HLs(i-1,:),304,1); %matrix 304*304,latent symptomatic population of cities
            HLpallcity=repmat(HLp(i-1,:),304,1); %matrix 304*304,presymptomatic population of cities
            HNallcity=repmat(HN(i-1,:),304,1);   %matrix 304*304,infectious symptomatic population of cities
            HSallcity=repmat(HS(i-1,:),304,1);   %matrix 304*304,suspecitble population of citie
        
            % we assume the patient Less than one person does not have the ability to transmit
            HLaallcity(HLaallcity<1)=0;
            HIaallcity(HIaallcity<1)=0;
            HLsallcity(HLsallcity<1)=0;
            HLpallcity(HLpallcity<1)=0;
            
            % exposed population who travel between cities  
            Fcity=Fcitybalcance*percent_inter(i-1);

            imcity_la=sum(Fcity.*HLaallcity./HNallcity,2); %latent asymptomatic population who flow into the city
            imcityout_la=sum(Fcity.*HLaallcity./HNallcity,1); %latent asymptomatic population who flow out of the city
            imcity_ia=sum(Fcity.*HIaallcity./HNallcity,2); %infectious asymptomatic population who flow into the city
            imcityout_ia=sum(Fcity.*HIaallcity./HNallcity,1); %infectious asymptomatic population who flow out the city
            imcity_ls=sum(Fcity.*HLsallcity./HNallcity,2); %latent symptomatic population who flow into the city
            imcityout_ls=sum(Fcity.*HLsallcity./HNallcity,1); %latent symptomatic population who flow out the city
            imcity_lp=sum(Fcity.*HLpallcity./HNallcity,2); %presymptomatic population who flow into the city
            imcityout_lp=sum(Fcity.*HLpallcity./HNallcity,1); %presymptomatic population who flow out the city
            % suspectible travel population
            imcity_s=sum(Fcity.*HSallcity./HNallcity,2);%suspectible population who flow into the city
            imcityout_s=sum(Fcity.*HSallcity./HNallcity,1);%suspectible population who flow out 

            %% TSIR model
            %suspecitble population
            HS(i,:)=HS(i-1,:)-(afa*beta.*HIa(i-1,:)+beta.*HI(i-1,:)+beta_s*beta.*HLp(i-1,:)).*HS(i-1,:)./HN(i-1,:)+imcity_s'-imcityout_s;
            %asymptomatic population
            HLa(i,:)=HLa(i-1,:)+p*((afa*beta.*HIa(i-1,:)+beta.*HI(i-1,:)+beta_s*beta.*HLp(i-1,:)).*HS(i-1,:)./HN(i-1,:)+importI)-imcityout_la+imcity_la'-sigma_a*HLa(i-1,:); %latent
            HIa(i,:)=HIa(i-1,:)+sigma_a*HLa(i-1,:)-gamma.*HIa(i-1,:)-imcityout_ia+imcity_ia';%infectious
            %symptomatic population
            HLs(i,:)=HLs(i-1,:)+(1-p)*((afa*beta.*HIa(i-1,:)+beta.*HI(i-1,:)+beta_s*beta.*HLp(i-1,:)).*HS(i-1,:)./HN(i-1,:)+importI)-imcityout_ls+imcity_ls'-sigma_s*HLs(i-1,:);%latent
            HLp(i,:)=HLp(i-1,:)+sigma_s*HLs(i-1,:)-sigma_pre*HLp(i-1,:)-imcityout_lp+imcity_lp';%presymtomatic
            HI(i,:)=HI(i-1,:)+sigma_pre*HLp(i-1,:)-gamma_s.*HI(i-1,:); %infectious
            % removed population
            HR(i,:)=HR(i-1,:)+gamma_s.*HI(i-1,:)+gamma.*HIa(i-1,:);
            %all population
            HN(i,:)=HS(i,:)+HLa(i,:)+HIa(i,:)+HLs(i,:)+HLp(i,:)+HI(i,:)+HR(i,:); 
            %be confirmed cases
            I(i,:)=gamma_s.*HI(i-1,:);

        end

%% save simulation results 
ydot=[I(:,:)];%daily reported cases
%save matrix
iflow=find(perflow==[0.05:0.05:1] );
iC=find(perC==[0.05:0.05:1]);
res{1,1}{iflow,iC}=ydot;

% The number of cases is rounded as integer
yint=round(ydot); 
sumHI=sum(yint,2); % the number of cases of nation

% calculate duration 
[~,starind] = max((yint>=1),[],1); %the first day of epidemic 
[~,endind]=max((flipud(yint)>0),[],1);%the last day of epidemic,sort from the end of the data
fendind=size(yint,1)-endind+1;%the last day of epidemic,positive sequence
duration=fendind-starind+1;%duration
duration(find(sum(yint,1)==0))=0;%for city of no case,duration set to be 0;
dur(iflow,iC)=mean(duration);%average duration of cities 

% duration of nation 
[~,starindsum] = max((sumHI>=1),[],1);
[~,endindsum]=max((flipud(sumHI)>0),[],1);
fendindsum=size(sumHI,1)-endindsum+1;
sumdur(iflow,iC)=fendindsum-starindsum+1;

% peak size 
incidenci=ydot./HN;
Maxinci=max(incidenci);
nationI=sum(ydot,2);%national cases 
MaxnationI=max(nationI)/sum(pop); %national incidence
avg_max_size(iflow,iC)=mean(Maxinci);%average max peak size of cities
nation_max_size(iflow,iC)=MaxnationI;%national max peak size
    end
 end


end