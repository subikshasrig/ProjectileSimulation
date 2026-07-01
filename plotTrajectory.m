function plotTrajectory(xA,yA,zA,xB,yB,zB,xBuilding,H,velocity,angle,flightTime,R_total,g)

% Generating 1000 equally space time points for smooth plotting
t_vec = linspace(0,flightTime,1000);

% Horizontal distance travelled
distance_horizontal = velocity*cosd(angle).*t_vec;

% Calculating projectile height
y_vec = yA + velocity*sind(angle).*t_vec - 0.5*g.*t_vec.^2;

% Converting to 3D coordinates
x_vec = xA + (distance_horizontal/R_total)*(xB-xA);
z_vec = zA + (distance_horizontal/R_total)*(zB-zA);

figure('Name','ENGG100 Projectile Simulation 3D View','NumberTitle','off');

% Plotting 3D trajectory
plot3(x_vec,z_vec,y_vec,'b-','LineWidth',3);
hold on  
grid on

% Setting range along y and z axis
zWidthRange = linspace(min(zA,zB)-5,max(zA,zB)+5,10);
yHeightRange = linspace(0,H,10);

% Creating building mesh
% Forces the entire building surface to have 1 fixed x-position and turns the mesh into a vertical wall.
[zMesh,yMesh] = meshgrid(zWidthRange,yHeightRange);
xMesh = zeros(size(zMesh)) + xBuilding;

% Drawing the building
% Creates a 3D grid surface using mesh plotting. 
% A wireframe surface with fill color of the building surface in light grey (FaceColor)
% FaceAlpha controls transparency to be semi-transparent so that the projectile path can be seen through the building. 
% EdgeColor sets the color of grid lines to be dark grey and define the building structure clearly.  
% A semi-transparent grey 3D building with visible edges, placed at the correct x-position, acting as the obstacle 
mesh(xMesh,zMesh,yMesh,'FaceColor',[0.6 0.6 0.6],'FaceAlpha',0.6,'EdgeColor',[0.3 0.3 0.3]);

% Plotting the Launch Point A
plot3(xA,zA,yA,'go','MarkerSize',11,'MarkerFaceColor','g');

% Plotting Target B
plot3(xB,zB,yB,'ro','MarkerSize',11,'MarkerFaceColor','r');

% Formatting graph
xlabel('X Coordinate - Downrange Distance (m)');
ylabel('Z Coordinate - Cross-Range (m)');
zlabel('Y Coordinate - Elevation Height (m)');
title('Unified 3D Projectile Flight Path Vector Model');
legend('3D Flight Path','Building','Launch Point A','Target Point B','Location','best');

% Sets the viewing direction using two angles. 
% The Azimuth is considered to be 65° around the vertical z axis
% Elevation is 30° up from the horizontal plane. 
view(65,30);
hold off

end