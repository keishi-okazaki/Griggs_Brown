%% Hit point
% Written by Keishi Okazaki @ Brown & Hiroshima University, 5/10/2013,
% Recent update  7/27/2015: added the other assumptioin for calculating the base line friction
clear

%% Making l1 and l2
%const0 = [30 200;250 -200]; %Initial values for LSF. You can change this value for each rig.
const0 = [50 250;500 1000]; %Initial values for Rig III?
f = 1; % Sampling rate [s]

%% Open file and fit
openfile= uigetfile('.csv', 'Pick a File');
%ori = dlmread(openfile,',',1,3); % No Header
dataset = dlmread(openfile,',',2,0); % Including Single Line Header
%ori = dlmread(openfile,',',22,3); % Including Header
%dataset = (Time [s],Load point displacement [mm],Axial load [MPa],Pc [MPa],Temperature [oC])
Sd = 6.35; %Sigma1 piston diameter, mm
Sa = Sd^2*pi/4; % Piston area, mm^2
Stff = 118/Sa*1000; % Static stiffness (118kN/mm), MPa/mm, 35.6 kN/mm with spring
Disp = dataset(:,2);

FrictionCorrection = menu('How to correct the baseline?','Linear fricition','Constant friction');
PressureSelect = menu('Pressure','Data','Constant pressure');

switch PressureSelect
    case {1} % use raw data
        Pressure = dataset(:,4);
    
    case {2} % use constant pressure
        Pressure = str2double(inputdlg('Pressure [MPa]'));
       
    otherwise
        error('Select pressure')

end

fig = figure;
fig.Name = 'Make variables l1 and l2, then restart';
plot(Disp, dataset(:,3)-Pressure);
xlabel('loadpoint disp [mm]');
ylabel('Sigma1-Sigma3 [MPa]');

pause;

%%
lines = [l1;l2]; % You MUST have two lines named "l1" and "l2" from your original data.
A = zeros(2,2); % make an empty matrix
[A B] = hitpointfit2(lines(:,1),lines(:,2),const0); 
%A:Fitted lines for the beseline and the elastic deformation of the sample
%B:Displacement at the hit point  

x = Disp;
y = dataset(:,3)-Pressure; %Sigma1-sigma3

%%
switch FrictionCorrection

% Assume linear friction during a whole running, for low T experiments?    
        case {1} %Linear fcition assuming
           yy = y - (A(1,1)*x+A(1,2)); % Mechanical data - base line
           baseline1 = A(1,1)*x+A(1,2); % Base line
           baseline2 = A(2,1)*x+A(2,2); % Slope of mechanical data
           C = (A(2,1).*x+A(2,2)) - (A(1,1).*x+A(1,2));
           yyy = yy;
           
           i = 1;
           while yyy(i) >= C(i)
               yyy(i) = C(i);
               i = i + 1;
           end
           
           for j=1:1:length(x);
               if yyy(j)<0
                  yyy(j) = 0;
               else
                   yyy(i) = yyy(i);
               end
           end
           
% Assume constant friction after the hit point, maybe for high T experiment?
        case {2} %Constant friction assuming
           baseline1 = A(1,1)*x+A(1,2); % Base line
           baseline2 = A(2,1)*x+A(2,2); % Slope of mechanical data
           baseline1(baseline1>B(2)) = B(2); % Make a constant friction after the hit point
           yy = y - baseline1; % Mechanical data - base line
           C = baseline2 - baseline1;
           yyy = yy;
           
           i = 1;
           while yyy(i) >= C(i)
               yyy(i) = C(i);
               i = i + 1;
           end
           
           for j=1:1:length(x);
               if yyy(j)<0
                  yyy(j) = 0;
               else
                   yyy(i) = yyy(i);
               end
           end
            
      
        otherwise
        error('Error!! Select the assumption for the friction.')
end


%%

plot(x,y,x,baseline1,x,baseline2,x,yy,x,C,x,yyy);
legend('raw data','base line1','base line2','data minused base line','the line used to slove hit point','final data');

HitPoint_disp = B(1)
Fitting_lines = A
 
dataset2 = horzcat(dataset,yy,yyy); % Time, Load point disp, Load, Press, oC, Corrected load1, Corrected load2