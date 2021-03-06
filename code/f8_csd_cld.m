clear
%% load data
load('Data_304_flowall_leveltime.mat'); %108obs-data
day=load('2019_month_day.mat'); %the number of day in specific month of 2019
load('Data_2019_cityflow.mat') %cityflow of 2019-12 months
load('./res/matlab1002.mat') %parameter estimation of model

%% parameter
theta=results2.mean;%results of f1.m
xdata=data.xdata;
simday=1000;%days of simulation
t=1:56; %period 1/11-3/6
n=304;  %the number of cities
gamma1(1:n)=theta(3); %time period from onset to isolation
gamma=1./gamma1; 
gamma_s=1./(gamma1*theta(10));%removed rate of symptomatic infectivity
sigma_a=1/theta(1);%Incubation period 
report=1/theta(2); %report rate
beta_b(1:n)=theta(4); % basic transmission rate
c1(1:n)=theta(6);% control intensity

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
innercity=xdata(ceil(t),(n+2):(2*n+1));%inner intensity 1.11-3.6
max_before_fes_inner=max(innercity(1:14,:)); %1.11-1.24: index:1-13 
time1=xdata(ceil(t),1524:1827);%the time of 1-level response
time2=xdata(ceil(t),1828:2131); % the time of 2nd control
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
nationHI=dur;%national cases
%% model
 for perflow=[0.05:0.05:1] % control intensity of inter-city flow and intra-city flow
        percent_inter(1:simday)=perflow;
        percent_inter(1:13)=1;%control begin after 1.25 1-level response
        
    for perC=[0.05:0.05:1] % control intensity of social distancing 
       
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
            beta2=perC*perflow; %control for transmission between people  
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
            HSallcity=repmat(HS(i-1,:),304,1);   %matrix 304*304,suspecitble population of cities

            HLaallcity(HLaallcity<1)=0; %we assume that Less than one person does not have the ability to transmit virus
            HIaallcity(HIaallcity<1)=0; %we assume that Less than one person does not have the ability to transmit virus
            HLsallcity(HLsallcity<1)=0; %we assume that Less than one person does not have the ability to transmit virus
            HLpallcity(HLpallcity<1)=0; %we assume that Less than one person does not have the ability to transmit virus
            
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
            imcityout_s=sum(Fcity.*HSallcity./HNallcity,1);%suspectible population who flow out the city

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
%national cases
nationHI(iflow,iC)=sum(sumHI);
% peak size 
incidenci=ydot./HN;
Maxinci=max(incidenci);
nationI=sum(ydot,2);%national cases 
MaxnationI=max(nationI)/sum(pop); %national incidence
avg_max_size(iflow,iC)=mean(Maxinci);%average max peak size of cities
nation_max_size(iflow,iC)=MaxnationI;%national max peak size
    end
 end

%% plot the results
%set papaer size and figure size
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.4 2]);

%plot epidemic duration of nation
sumdur(find(sumdur>365))=370; %duration>1 year set to be 1 class
figure
subplot(2,2,1)
imagesc(sumdur);    %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('Epidemic duration (days)','Fontname', 'Arial','Fontsize',9)
    xlabel('Social distancing,CSD','Fontname', 'Arial','Fontsize',9)
    ylabel('Lockdown,CLD,{minner,mintra}','Fontname', 'Arial','Fontsize',9)

% plot average peak size
subplot(2,2,2)
imagesc(avg_max_size);            %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(0.005,0.035,4),'YTickLabel',sprintfc('%.2g',  linspace(0.005,0.035,4)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('Average peak size for cities (peak I/N)','Fontname', 'Arial','Fontsize',9)
    xlabel('Social distancing,CSD','Fontname', 'Arial','Fontsize',9)
    ylabel('Lockdown,CLD,{minner,mintra}','Fontname', 'Arial','Fontsize',9)

%Plot national cases
cld_csd=load('./res1009/cld_csd_nation.mat');
inter_csd=load('./res1009/inter_csd_nationHI.mat');
intra_csd=load('./res1009/intra_csd_nationHI.mat');

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [8.8 3]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 8.8 1.7]);
subplot(1,3,1)
imagesc(cld_csd.nationHI);    %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
c = colorbar;
%set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('National cases','Fontname', 'Arial','Fontsize',9)
    xlabel('Social distancing,CSD','Fontname', 'Arial','Fontsize',9)
    ylabel('Lockdown,C_{LD},{m_{inner},m_{intra}}','Fontname', 'Arial','Fontsize',9)

subplot(1,3,2)    
imagesc(intra_csd.nationHI);    %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
c = colorbar;
%set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('National cases','Fontname', 'Arial','Fontsize',9)
    xlabel('Social distancing,CSD','Fontname', 'Arial','Fontsize',9)
    ylabel('Lockdown,C_{LD},{m_{intra}}','Fontname', 'Arial','Fontsize',9)
    
subplot(1,3,3)   
imagesc(inter_csd.nationHI);    %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
c = colorbar;
%set(c, 'YTick', linspace(0.005,0.035,4),'YTickLabel',sprintfc('%.2g',  linspace(0.005,0.035,4)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('National cases','Fontname', 'Arial','Fontsize',9)
    xlabel('Social distancing,CSD','Fontname', 'Arial','Fontsize',9)
    ylabel('Lockdown,C_{LD},{m_{inter}}','Fontname', 'Arial','Fontsize',9)
 saveas(gca,'nationalI1.pdf')  