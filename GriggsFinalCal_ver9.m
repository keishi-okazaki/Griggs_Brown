%% Final calculation for Griggs experiment
% Written by Keishi Okazaki @ Brown & Hiroshima Univ. 2014.05.10
% Need to run "hitpointcal_disp_2lines" before runing this script.
% Last update: 01/04/2018; use the boundary slip for area correction.

%% Sample dimensions 
Sl = 12.7; %Sample length for axial compression, mm
Sd = 6.35; %Sample diameter, mm
Pd = 6.35; %Sigma1 piston diameter, mm
Th0 = 1.182; %Initial sample gouge/wafer thickness for general shear, mm 1.097 for lawsonite
Thf = 0.634; %Final sample gouge/wafer thickness for general shear, mm 0.997
uB = 0; %Displacement between the sample and shear pistons, mm 
Theta = 45; %Precut angle, Degree
poisson = 0.5; %0.5 when assuming an inelastic constant volume deformation

%SamplRate = 1; % Sampling rate, s 
%Adr = 0.000183; %10^-5 gear, Axial displacement rate, mm/s
%Adr = 0.0000183; %10^-6 gear
Sa = Sd^2*pi/4; % Sample area, mm^2
Psa = Sd^2*pi/4/sin(Theta/180*pi); % Shear area, mm^2
Sap = Pd^2*pi/4; % Sigma1 piston area, mm^2
Stff = 118/Sa*1000; %Machine static stiffness (118kN/mm), MPa/mm, 35.6 kN/mm with spring
%Stff = 118; %Machine static stiffness, kN/mm
%Stff = 118/Pd*1000; %Machine static stiffness, MPa/mm
HitPoint = -(A(2,2)-A(1,2))/(A(2,1)-A(1,1));% Disp. at the hit point from hitpointcal.m
Pp = 0; 

%% Row data
M = dataset2; % Time [s], Load point disp [mm], Load [MPa], Pc [MPa], Temp [oC], Corrected load1 [MPa],Corrected load2 [MPa], Disp [mm]
Lm = length(dataset2);

%% Choose Data Reduction
DataReduction = menu('Data Reduction?','Yes','No','Yes, by decimate');
%'Yes';% Data reduction and averaging
%'No'; % Raw data
%'Decimate'; % Use dacimate function in Matlab

switch DataReduction
        case {1} % Moving average for data reduction, use below. 
           AmongX = inputdlg('data is reduced to 1/X, X =');

        case {2} % Using raw data 
            
        case {3} % Use decimate data resampling 
            AmongX = inputdlg('data is reduced to 1/X, X =');
            
        otherwise
        error('Error!! Select Data Reduction')
end


%% Correction the overlap of the shear piston 
ShearAreaCorr = menu ('Correction for general shear?','Thinning of sample','Thinning & area change','No','Constant volume');

%% Calculations
% M = [Time [s], Load point disp [mm], Load [MPa], Pc [MPa], Temp [oC], Corrected load1 [MPa], Corrected load2 [MPa], Axial disp [mm]];
% AAA = [Time [s], Load point displacement [mm], 'Axial displacement [mm], Axial strain, Shear displacement [mm],
%        Shear strain, Confinig pressure [MPa], Axial load [MPa], Differential stress [MPa], Effective normal stress [MPa],
%        Shear stress [MPa],Frictional coefficient, Temperature [oC]]

AAA = []; %empty matrix
AAA(:,1) = M(:,1); %Time
AAA(:,2) = M(:,2); % Load point disp
AAA(:,3) = M(:,2)-HitPoint-M(:,7)/Stff; % Axial disp
AAA(:,4) = AAA(:,3)/Sl; % Axial strain
AAA(:,5) = AAA(:,3)/(sin ((90-Theta)/180*pi)); % Shear displacement
AAA(:,6) = ((AAA(:,3))/(sin ((90-Theta)/180*pi)))/Th0; % Shear strain
AAA(:,7) = M(:,4); %Confining pressure
AAA(:,8) = M(:,3)*Sap/Sa; % Axial load
AAA(:,9) = M(:,7)*Sap/Sa; % Differential stress
%AAA(:,8) = M(:,3); % Axial load
%AAA(:,9) = M(:,7); % Differential stress
AAA(:,10) = AAA(:,9)*(sin (Theta/180*pi))^2 + M(:,4) - Pp; % Effective normal stress
AAA(:,11) = AAA(:,9)* sin (Theta/180*pi)*cos (Theta/180*pi); % Shear stress
AAA(:,12) = AAA(:,11)./AAA(:,10); % Nominal frictional coefficient 
AAA(:,13) = M(:,5); % Temperature
AAA(:,14) = Th0;

switch ShearAreaCorr
    case {2} % Thinning & area
        dz1total=(Th0-Thf)/sin(Theta/180*pi); %total shortening
        proportion=dz1total/max(AAA(:,3)); %proportion of shortening to total virtical displacement
        dx1=proportion.*AAA(:,3);%virtical displacment resulting in shortening assuming constant rate
        dx2=AAA(:,3)-dx1;%virtical displacment resolved in simple shear
        Th=Th0-dx1.*sin(Theta/180*pi);%instantaneous thickness assuming constant shortening rate
        AAA(:,5) = dx2/(sin ((90-Theta)/180*pi)); % Shear displacement
        uuu = uB*dx2/max(dx2); %- Th/tan(Theta); %Shear disp for area correction        
        uuu(uuu<0)=0; %treat negative value as 0
        SapOverlap = 2^0.5*Sd*Sd/2*acos(uuu/(2^0.5*Sd))-Sd/2*uuu.*sin(acos(uuu/(2^0.5*Sd)));
        AAA(:,6) = AAA(:,5)./Th; % Shear strain
        AAA(:,10) = AAA(:,10).*Psa./SapOverlap; % Effective normal stress
        AAA(:,11) = AAA(:,11).*Psa./SapOverlap; % Shear stress
        AAA(:,9) = AAA(:,11)*3^0.5;  % Equivalent stress
        AAA(:,14) = Th;
        
    case {3} % No
        
    case {1} % Thinning of the sample layer
        dz1total=(Th0-Thf)/sin(Theta/180*pi); %total shortening
        proportion=dz1total/max(AAA(:,3)); %proportion of shortening to total virtical displacement
        dx1=proportion.*AAA(:,3); %vertical displacment resulting in shortening assuming constant rate
        dx2=AAA(:,3)-dx1; %vertical displacment resolved in simple shear
        Th=Th0-dx1.*sin(Theta/180*pi); %instantaneous thickness assuming constant shortening rate
        
        AAA(:,5) = dx2/(sin ((90-Theta)/180*pi)); % Shear displacement
        AAA(:,6) = AAA(:,5)./Th; % Shear strain
        AAA(:,10) = AAA(:,10); % Effective normal stress
        AAA(:,11) = AAA(:,11); % Shear stress
        AAA(:,9) = AAA(:,11)*3^0.5;  % Equivalent stress
        AAA(:,14) = Th;
        
    case {4} % constant volume
        AAA(:,9) = AAA(:,9)./((1 + poisson.*AAA(:,4)).^2); % Differential stress with area change assuming a const volume
        
    otherwise
        error('Error!! Select ShearAreaCorr')
end

%% Data Reduction
MMM = [];
switch DataReduction
        case {1} % Moving average for data reduction, use below. 
           MM = [];
           ReSumplRate = str2double(AmongX);
           a = ReSumplRate; %average among 'a' data
           b = ones(1,a);
           S = a; %data reduced to 1/S
           n = 1:S:Lm;
           MM = [];
           MM(:,1) = AAA(:,1);
           MM(:,2:14) = filter(b,a,AAA(:,2:14));
           MMM = MM(n,:);

        case {2} % Using raw data 
            MMM = AAA;
            
        case {3} % Use decimate data resampling 
            ReSumplRate = str2double(AmongX);
            S =  ReSumplRate;
            for i=1:length(AAA(1,:)); 
            MMM(:,i)=decimate(AAA(:,i),S); 
            end
            
        otherwise
        error('Error!! Select Data Reduction')
end

M = []; %empty matrix
MM = []; %empty matrix

%% Plot
QuickPlot = menu('Quick Plot','Differential stress','Shear stress','No plot');
switch QuickPlot
        case {1} %Axial stress 
           [AX, H1, H2] = plotyy(MMM(:,3), MMM(:,8),MMM(:,3), MMM(:,9)); 
           xlabel('Axial displacement [mm]')
           set(get(AX(1),'Ylabel'),'String','Axial stress [MPa]') 
           set(get(AX(2),'Ylabel'),'String','Differential stress [MPa]')
           legend([H1, H2], 'Axial stress [MPa]', 'Differential stress [MPa]')
           
        case {2} % Shear stress 
           [AX, H1, H2] = plotyy(MMM(:,3), MMM(:,8),MMM(:,3), MMM(:,11)); 
           xlabel('Axial displacement [mm]')
           set(get(AX(1),'Ylabel'),'String','Axial stress [MPa]') 
           set(get(AX(2),'Ylabel'),'String','Shear stress [MPa]')
           legend([H1, H2], 'Axial stress [MPa]', 'Shear stress [MPa]')
        
        case {3} % No plot 
 
        otherwise

end


%% File Export as .csv file
switch ShearAreaCorr
    case {1,2} % General shear
        str = {'Time [s]', 'Load point displacement [mm]', 'Axial displacement [mm]', 'Axial strain', 'Shear displacement [mm]',...
            'Shear strain', 'Confinig pressure [MPa]', 'Axial load [MPa]','Equivalent stress [MPa]', 'Effective normal stress [MPa]',...
            'Shear stress [MPa]','Friction coefficient', 'Temperature [oC]','Gouge/wafer thickness [mm]'};
        
    otherwise % Axial compression
        str = {'Time [s]', 'Load point displacement [mm]', 'Axial displacement [mm]', 'Axial strain', 'Shear displacement [mm]',...
            'Shear strain', 'Confinig pressure [MPa]', 'Axial load [MPa]','Differential stress [MPa]', 'Effective normal stress [MPa]',...
            'Shear stress [MPa]','Friction coefficient', 'Temperature [oC]','Gouge/wafer thickness [mm]'};
end

savefile= uiputfile('W21out01042018.csv', 'Save a File');
fid = fopen(savefile, 'wt');
csvFun = @(x)sprintf('%s,',x);
xchar = cellfun(csvFun, str, 'UniformOutput', false);
xchar = strcat(xchar{:});
xchar = strcat(xchar(1:end-1),'\n');
fprintf(fid,xchar);
dlmwrite(savefile, MMM, '-append','precision', 7); 
%% END