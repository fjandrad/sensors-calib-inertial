function plotJointTrajectories(data,modelParams,figuresHandler)

% compute time series
time = data.ac.tInit + data.ac.parsedParams.time(:);

%% Plot joint trajectories
figH = figure('Name','chain joint positions q','WindowStyle', 'docked');

figuresHandler.addFigure(figH,'jointTraject'); % Add figure to the figure handler

% If the figure is not docked, use the below command to display it full
% screen.
%set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
title('chain joint positions q','Fontsize',16,'FontWeight','bold');
hold on
myColors = {'b','g','r','c','m','y'};
colorIdx = 1;
eval(['qsRad = data.bc.parsedParams.qsRad_' modelParams.jointMeasedParts{1} '_state;']); qsRad = qsRad';
for qIdx = 1:size(qsRad,2)
    plot(time,qsRad(:,qIdx)*180/pi,myColors{colorIdx},'lineWidth',2.0);
    colorIdx = colorIdx+1;
end
hold off
grid ON;
xlabel('Time (sec)','Fontsize',12);
ylabel('Joints positions (degrees)','Fontsize',12);
legend('Location','BestOutside',modelParams.jointsToCalibrate.ctrledJoints{1});
set(gca,'FontSize',12);

