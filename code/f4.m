function ydot = f4(t,y,theta,xdata)
t=1:56;
n=304;
gamma1(1:n)=theta(3); %time period from onset to isolation
gamma=1./gamma1;
sigma=1/theta(1);%Incubation period 

report=1/theta(2); %report rate
beta_b(1:n)=theta(4); % basic transmission rate

c1(1:n)=theta(6);% control intensity
%control classification by previous study (DOI: 10.1126/science.abb6105)
%C1_high: cities in Heilongjiang, Zhejiang, Hubei (exclude Wuhan); and Shanghai, Tianjin
%C1_medium: cities in Anhui, Fujian, Guangdong, Guangxi, Guizhou, Hunan, Jilin, Jiangsu, Jiangxi, Inner Mongolia, Shandong, Tibet; and Beijing
%C1_low: cities in Gansu, Hainan, Hebei, Henan, Liaoning, Ningxia,Qinghai,Shanxi, Shaanxi, Sichuan, Xinjiang, Yunnan; and Chongqing
mid=[1	25	26	27	28	29	30	31	32	33	34	35	50	51	52	53	54	55	56	57	72	73	74	75	76	77	78	79	80	81	82	83	84	96	97	98	99	100	101	102	103	104	105	106	107	108	109	110	111	112	113	114	115	116	117	118	119	120	121	122	123	124	125	126	127	128	129	130	131	132	133	134	135	136	137	138	139	140	141	142	143	144	145	146	176	177	178	179	180	181	182	183	184	185	186	187	188	189	190	191	192	193	194	195	196	197	198	199	200	201	202	203	204	205	206	207	208	209	210	211	212	213	214	215	216	217	218	219	220	221	222	247	248	249	250	251	252	253	254	255	270];
low=[3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	36	37	38	39	40	41	42	43	44	45	46	47	48	49	147	148	149	150	151	152	153	154	155	156	157	158	159	160	161	162	163	223	224	225	226	227	228	229	230	231	232	233	234	235	236	237	238	239	240	241	242	243	244	245	246	256	257	258	259	260	261	262	263	264	265	266	267	268	269	271	272	273	274	275	276	277	278	279	280	281	282	283	284	285	286	287	288	289	290	291	292	293	294	295	296	297	298	299	300	301	302	303	304];
c1(mid)=theta(7);
c1(low)=theta(8);
c2(1:n)=theta(9);% control intensity

% data
Pwuhan=10892900;%population of Wuhan
flow=xdata(ceil(t),2:(n+1));%flow from wuhan to other city
HRwuhan=xdata(ceil(t),1523);%wuhan report daily cases
HRwuhan(1:5)=theta(5);%the estimated reported cases of first 5 days in wuhan
pop=xdata(ceil(57),2:(n+1))*1000000;%population of other city
innercity=xdata(ceil(t),(n+2):(2*n+1));%inner intensity 1.11-3.6
max_before_fes_inner=max(innercity(1:14,:)); %1.11-1.24: index:1-13 
time1=xdata(ceil(t),1524:1827);%the time of 1st control
time2=xdata(ceil(t),1828:2131);% the time of 2nd control
HE(1,1:n) = 0; %
HI(1,1:n) = 0; %
HS(1,1:n) = pop-HE(1,:)-HI(1,:); %
HR(1,1:n) = 0; %
I(1,1:n)=0; %

%flow
Fcity=xdata(1:n,(2*n+3):(3*n+2))/31; %
%Fcity=Fcity-diag(diag(Fcity));%
Fcity2=xdata(1:n,(3*n+3):(4*n+2))/28;  %
%Fcity2=Fcity2-diag(diag(Fcity2));
Fcity3=xdata(1:n,(4*n+3):(5*n+2))/31;  %
%Fcity3=Fcity3-diag(diag(Fcity3));%
Allpop=repmat(pop,n,1); %
beta=beta_b;%

for i = 2:56

beta2=c1.*(innercity(i-1,:)./max_before_fes_inner); 
%1st control
beta(find(time1(i,:)==1))=beta_b(find(time1(i,:)==1)).*beta2(find(time1(i,:)==1));
%2nd control 
beta(find(time2(i,:)==1))=beta_b(find(time2(i,:)==1)).*beta2(find(time2(i,:)==1)).*c2(find(time2(i,:)==1));


%%%%%%%%%%%Imported Infected cases
importI=HRwuhan(i-1)*flow(i-1,:)*report/Pwuhan; 
HEallcity=repmat(HE(i-1,:),304,1);

 if(i>21 && i<51) 
            Fcity=Fcity2; 
 elseif i>50
            Fcity=Fcity3;
   
end
importallcity=Fcity.*HEallcity./Allpop;
imcity=sum(importallcity,2);
imcityout=sum(importallcity,1);
travelin=sum(Fcity,2);
travelout=sum(Fcity,1);
%%%%%%%%%%%%%%
HS(i,:)=HS(i-1,:)-beta.*HI(i-1,:).*HS(i-1,:)./pop+travelin'-travelout;%suspecitble population
HE(i,:)=HE(i-1,:)+beta.*HI(i-1,:).*HS(i-1,:)./pop+importI-imcityout+imcity'-sigma*HE(i-1,:);  %exposed population
HI(i,:)=HI(i-1,:)+sigma*HE(i-1,:)-gamma.*HI(i-1,:);%onset popuation      
HR(i,:)=HR(i-1,:)+gamma.*HI(i-1,:);% isolated population/confirmed population
I(i,:)=gamma.*HI(i-1,:);%be confirmed

end

ydot=[I(:,:)];
 

