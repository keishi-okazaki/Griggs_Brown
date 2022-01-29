f = 1; % Sampling rate [s]
openfile= uigetfile('.csv', 'Pick a File');
%ori = dlmread(openfile,',',1,3); % No Header
dataset = dlmread(openfile,',',1,0); % Including Single Header
%ori = dlmread(openfile,',',22,3); % Including Header

%dataset = [Time [s], Load point displacement [mm], 'Axial displacement [mm], Axial strain, 
%        Shear displacement [mm],Shear strain, Confinig pressure [MPa], Axial load [MPa], 
%        Differential stress [MPa], Effective normal stress [MPa],Shear stress [MPa],Frictional coefficient, 
%        Temperature [oC]]

QuickPlot = menu('Quick Plot','Differential stress','Shear stress');

switch QuickPlot
        case {1} %Axial stress 
          figure;plot(dataset(:,4),dataset(:,9));
          xlabel('Axial strain');
          ylabel('Differential stress [MPa]');
          
          figure;plot(dataset(:,3),dataset(:,9));
          xlabel('Axial displacement [mm]');
          ylabel('Differential stress [MPa]');
          
          figure;plot(dataset(:,1),dataset(:,9));
          xlabel('Time [s]');
          ylabel('Differential stress [MPa]');          
          
          
        case {2} % Shear stress 
           figure;plot(dataset(:,6),dataset(:,11));
           xlabel('Shear strain');
           ylabel('Shear stress [MPa]');
           
           figure;plot(dataset(:,5),dataset(:,9));
           xlabel('Shear displacement [mm]');
           ylabel('Equivalent stress [MPa]');
                     
           figure;plot(dataset(:,1),dataset(:,9));
           xlabel('Time [s]');
           ylabel('Equivalent stress [MPa]');
          
        otherwise
        error('Error!! Select plot data')
end

%figure;plot(dataset(:,1),dataset(:,3));
%xlabel('Time [s]');
%ylabel('Axial load [MPa]');