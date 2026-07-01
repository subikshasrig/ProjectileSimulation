% 1. COLLECTING INPUT DATA FROM USER
disp('=== ENGG100 Projectile Simulation ===');
xA = input('Enter xA (m): ');
yA = input('Enter yA (m): ');
zA = input('Enter zA (m): ');
D  = input('Enter Building Distance D (m): ');
H  = input('Enter Building Height H (m): ');

g = 9.81;              % Gravity constant (m/s^2)
clearanceRequired = 2; % Required clearance (m)

% 2. SPATIAL GEOMETRY & TARGET DEFINITIONS
xBuilding = xA + D;    % x-coordinate of building position

% Target B absolute coordinates (Fixed by project specifications)
xB = xBuilding + 10;   % x- coordiate of Target B
yB = 5;                % y-coordinate of Target B
zB = 0;                % z-coordinate of Target B

% True horizontal distances across the ground plane
R_total = sqrt((xB - xA)^2 + (zB - zA)^2);           % Distance from Point A to Target B
R_building = sqrt((xBuilding - xA)^2 + (0 - zA)^2);  % Distance from Point A to Building

% Function to calculate minimum velocity required for the projectile to reach Target B with required clearance
[minVelocity,bestAngle,clearance] = minimumVelocity(R_total,R_building,yA,yB,H,g,clearanceRequired);

% Displays message if no velocity value has been obtained
if isnan(minVelocity)
    disp('No valid trajectory found that safely clears the building.');
    return
end

% Calculating maximum height of projectile
maxHeight = yA + (minVelocity*sind(bestAngle))^2/(2*g);

% Calculating total flight time of projectile
flightTime = (minVelocity*sind(bestAngle) + sqrt((minVelocity*sind(bestAngle))^2 + 2*g*(yA-yB)))/g;

% Displaying final results to the user
disp(' ');
disp('     MINIMUM VELOCITY SOLUTION      ');
disp(['Required Velocity (V) : ', num2str(minVelocity),' m/s']);
disp(['Required Angle (alpha): ', num2str(bestAngle),' degrees']);
disp(['Building Clearance    : ', num2str(clearance),' m']);
disp(['Maximum Height (Hmax) : ', num2str(maxHeight),' m']);

% Checking coordinates of projectile at a specified time 
disp(' ');
disp('=== Check Location of Projectile ===');
t_check = input(['Enter a specific flight time to check (0 to ', num2str(flightTime),' seconds): ']);

% Check that the requested time is within bounds
if t_check < 0 || t_check > flightTime
    disp('Error: The requested time falls outside the total flight path duration.');
else
    % Calculate horizontal distance traveled up to the chosen moment
    dist_horiz_check = minVelocity * cosd(bestAngle) * t_check;
    
    % Calculate the 3D coordinates matching the flight path vector model
    x_check = xA + (dist_horiz_check / R_total) * (xB - xA);
    z_check = zA + (dist_horiz_check / R_total) * (zB - zA);
    y_check = yA + minVelocity * sind(bestAngle) * t_check - 0.5 * g * t_check^2;
    
    % Display coordinates 
    disp(' ');
    disp(['At t = ', num2str(t_check), ' seconds, the projectile location is:']);
    disp(['X Coordinate : ', num2str(x_check), ' m']);
    disp(['Y Coordinate : ', num2str(y_check), ' m']);
    disp(['Z Coordinate : ', num2str(z_check), ' m']);
end
disp('====================================');

% Calling custom function to display plot
plotTrajectory(xA,yA,zA,xB,yB,zB,xBuilding,H,minVelocity,bestAngle,flightTime,R_total,g);