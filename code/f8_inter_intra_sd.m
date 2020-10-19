oad('./res/matlab1002.mat')%results of f1.m
dursd2= f8_controlforsd(0.2,results2);
dursd4= f8_controlforsd(0.4,results2);
dursd6= f8_controlforsd(0.6,results2);
dursd10= f8_controlforsd(1,results2);

%% plot the results
%set papaer size and figure size
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6.4 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.4 4]);

%plot average duration for cities,sd=0.2
dursd2(find(dursd2>365))=370; %duration> 1yr set to be 1 class
figure
subplot(2,2,1)
imagesc(dursd2);   %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;          %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('Average epidemic duration for cities(days) sd=0.2','Fontname', 'Arial','Fontsize',9)
    xlabel('Intra-city travel','Fontname', 'Arial','Fontsize',9)
    ylabel('Inter-city travel','Fontname', 'Arial','Fontsize',9)


%plot average duration for cities,sd=0.4
dursd4(find(dursd4>365))=370; %duration> 1yr set to be 1 class
subplot(2,2,2)
imagesc(dursd2);   %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;          %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('Average epidemic duration for cities(days) sd=0.4','Fontname', 'Arial','Fontsize',9)
    xlabel('Intra-city travel','Fontname', 'Arial','Fontsize',9)
    ylabel('Inter-city travel','Fontname', 'Arial','Fontsize',9)
    
%plot average duration for cities,sd=0.6
dursd6(find(dursd6>365))=370; %duration> 1yr set to be 1 class
subplot(2,2,3)
imagesc(dursd2);   %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;          %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('Average epidemic duration for cities(days) sd=0.6','Fontname', 'Arial','Fontsize',9)
    xlabel('Intra-city travel','Fontname', 'Arial','Fontsize',9)
    ylabel('Inter-city travel','Fontname', 'Arial','Fontsize',9)

    
%plot average duration for cities,sd=1    
dursd10(find(dursd10>365))=370; %duration> 1yr set to be 1 class
subplot(2,2,4)
imagesc(dursd2);   %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;          %#   black and lower values are white)
c = colorbar;
set(c, 'YTick', linspace(50,350,7),'YTickLabel',sprintfc('%g', linspace(50,350,7)),'Fontsize',8);
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0],'Fontsize',8);
    title('Average epidemic duration for cities(days) sd=1','Fontname', 'Arial','Fontsize',9)
    xlabel('Intra-city travel','Fontname', 'Arial','Fontsize',9)
    ylabel('Inter-city travel','Fontname', 'Arial','Fontsize',9)
    % saveas(gca,'figsd2_4_6_10.pdf') 