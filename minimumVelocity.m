function [minVelocity,bestAngle,clearance] = minimumVelocity(R_total,R_building,yA,yB,H,g,clearanceRequired)

% Initialising empty arrays to hold calculated values
validTheta = [];       % validTheta stores valid launch angles
validV = [];           % validV stores all valid velocities
validClearance = [];   % validClearance stores the margin by which each successful case cleared the building. 

% Defining range for angle theta for calculation of velocity
for theta = 1:0.1:89
    denominator = 2*(cosd(theta)^2) * (R_total*tand(theta) - (yB-yA));  % Derived from projectile equation

    if denominator <= 0
        continue
    end

    V_temp = sqrt((g*R_total^2)/denominator);  % Derived from projectile equation
    
    % Calculating projectile height at the building location 
    yBuilding = yA + R_building*tand(theta) - (g*R_building^2)/(2*V_temp^2*cosd(theta)^2); 

    % Clearance between projectile height and building height
    clearance_temp = yBuilding - H;
    
    % Allocating values to empty arrays
    if clearance_temp >= clearanceRequired
        validTheta(end+1) = theta;
        validV(end+1) = V_temp;
        validClearance(end+1) = clearance_temp;
    end

end

if isempty(validV)
    minVelocity = NaN;
    bestAngle = NaN;
    clearance = NaN;
    return
end

% Finds the smallest value in the array validV that cleared the building and satified the contraints
% Returns both the value and the position with the respective index so that the valid angle and the clearance can be returned.
[minVelocity,index] = min(validV);
bestAngle = validTheta(index);
clearance = validClearance(index);

end
