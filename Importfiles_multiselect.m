%% Import data
% Written by Keishi Okazaki @ Brown & Hiroshima Univ. 7/27/2013
% and making time vector with a lower sampling rate
% Updated on 11/02/2015, multiselect file (by Hamid Soleymani)
% Resent updated on 03/29/2016, update the load calibration for RIG II,

%% File import
M = []; % Make an empty matrix
ori = [];
t = [];

RigNo = menu('Rig No.','Rig 1','Rig 2','Rig 3');
openfile = uigetfile('.txt', 'Select files','MultiSelect','on'); % Rig I: ori = [load Pc Disp Temp];
[mm,nn] = size(openfile);
f = str2double(inputdlg('Sampling rate [s]')); % Sampling rate [s]

 for i= 1:nn
    M = dlmread(char(openfile(i)),',',22,3);
    ori = [ori;M];  
 end

t = 0:f:f*length(ori)-1; %t = 0:f:length(ori)-1;

switch RigNo
        case {1} % Load, Press, V, oC
           ori(:,3) = ori(:,3).*-5.393412; % Disp [mm]
           ori(:,1) = ori(:,1).*100 - 3; %Load [MPa]
           ori(:,2) = ori(:,2).*100 - 10; %Pc [MPa]
           dataset = [t' ori(:,3) ori(:,1) ori(:,2) ori(:,4)]; % Time, Disp [mm], Load [MPa], Press [MPa], Temp [oC]

        case {2} % Load, Press, V, oC
           ori(:,1) = ori(:,1)*-4.787-6.5467; % Disp [mm]
           ori(:,4) = ori(:,4)*100; %Load [MPa]  conversion F [kb]=5563.3*(V-1.42)/31.6692 is in vito
           ori(:,3) = (ori(:,3)+0.21)*100; %Pc [MPa]
           dataset = [t' ori(:,1) ori(:,4) ori(:,3) ori(:,2)]; % Time, Disp [mm], Load [MPa], Press [MPa], Temp [oC]

        case {3} % ori = [Temp Disp(V) Pc Load(mV)]
           ori(:,2) = -1.2423*ori(:,2) + 3; %Displacement [mm] 
           ori(:,4) = 225.227*ori(:,4)+162.1634; %Load [MPa]
           ori(:,3) = ori(:,3)*100; %Pc [MPa]
           dataset = [t' ori(:,2) ori(:,4) ori(:,3) ori(:,1)]; % Time, Disp [mm], Load [MPa], Press [MPa], Temp [oC]
            
        otherwise
        error('Error!! Select Rig No.')
end

figure;plot(dataset(:,1),dataset(:,3));
xlabel('time [s]');
ylabel('axial load [MPa]');
figure;plot(dataset(:,2),dataset(:,3));
xlabel('axial disp [mm]');
ylabel('axial load [MPa]');

disp('the data is saved in the current folder and workspace')
disp('dataset = [Time [s] Displacement [mm] Load [MPa] Press [MPa] Temperature [oC]')
%clear openfile f t ori

%% File export
str = {'Time [s]', 'Load point displacement [mm]', 'Axial load [MPa]', 'Pc [MPa]', 'Temperature [oC]'};
savefile= uiputfile('W19raw.csv', 'Save a File');
fid = fopen(savefile, 'wt');
csvFun = @(x)sprintf('%s,',x);
xchar = cellfun(csvFun, str, 'UniformOutput', false);
xchar = strcat(xchar{:});
xchar = strcat(xchar(1:end-1),'\n');
fprintf(fid,xchar);
dlmwrite(savefile, dataset, '-append','precision', 8); 

%% ‚¨‚í‚è