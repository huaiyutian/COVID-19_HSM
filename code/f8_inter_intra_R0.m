load('./res/matlab1002.mat')%results of f1.m
durR02= f8_controlforR0(2,results2);
durR03= f8_controlforR0(3,results2);
durR04= f8_controlforR0(4,results2);

%% plot 
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [8.8 3]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 8.8 1.5]);

%plot R0=2  Average epidemic duration for cities(days)
durR02(find(durR02>365))=370; %duration> 1yr set to be 1 class
subplot(1,3,1)
imagesc(durR02);            %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
str=sprintf('R_0=2 \n Average epidemic duration for cities(days)');
title(str,'Fontname', 'Arial','Fontsize',9)
xlabel('Social distancing,C_{SD}','Fontname', 'Arial','Fontsize',9)
ylabel('Lockdown,C_{LD},{m_{inner},m_{intra}}','Fontname', 'Arial','Fontsize',9)

%plot R0=3  Average epidemic duration for cities(days)
durR03(find(durR03>365))=370; %duration> 1yr set to be 1 class
subplot(1,3,2)
imagesc(durR03);            %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
str=sprintf('R_0=3 \n Average epidemic duration for cities(days)');
title(str,'Fontname', 'Arial','Fontsize',9)
xlabel('Social distancing,C_{SD}','Fontname', 'Arial','Fontsize',9)
ylabel('Lockdown,C_{LD},{m_{inner},m_{intra}}','Fontname', 'Arial','Fontsize',9)
    
%plot R0=4  Average epidemic duration for cities(days)
durR04(find(durR04>365))=370; %duration> 1yr set to be 1 class
subplot(1,3,3)
imagesc(durR04);            %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
str=sprintf('R_0=4 \n Average epidemic duration for cities(days)');
title(str,'Fontname', 'Arial','Fontsize',9)
xlabel('Social distancing,C_{SD}','Fontname', 'Arial','Fontsize',9)
ylabel('Lockdown,C_{LD},{m_{inner},m_{intra}}','Fontname', 'Arial','Fontsize',9)
 saveas(gca,'figr02_4_6_10.pdf') 