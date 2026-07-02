classdef app3_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        RunSimulationButton        matlab.ui.control.Button
        Edit_BuildingClearance     matlab.ui.control.NumericEditField
        BuildingClearanceLabel     matlab.ui.control.Label
        Edit_MaxHeight             matlab.ui.control.NumericEditField
        MaxHeightLabel             matlab.ui.control.Label
        Edit_ReqAngle              matlab.ui.control.NumericEditField
        ReqAngleLabel              matlab.ui.control.Label
        Edit_ReqVelocity           matlab.ui.control.NumericEditField
        ReqVelocityEditFieldLabel  matlab.ui.control.Label
        Edit_H                     matlab.ui.control.NumericEditField
        HLabel                     matlab.ui.control.Label
        Edit_BuildingDistance      matlab.ui.control.NumericEditField
        BuildingDistanceLabel      matlab.ui.control.Label
        Edit_zA                    matlab.ui.control.NumericEditField
        zALabel                    matlab.ui.control.Label
        Edit_yA                    matlab.ui.control.NumericEditField
        yAEditFieldLabel           matlab.ui.control.Label
        Edit_xA                    matlab.ui.control.NumericEditField
        xALabel                    matlab.ui.control.Label
        UIAxes                     matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RunSimulationButton
        function RunSimulationButtonPushed(app, event)
  %% User Inputs from the GUI
    xA = app.Edit_xA.Value;   
    yA = app.Edit_yA.Value;   
    zA = app.Edit_zA.Value;
    
    distToBuilding = app.Edit_BuildingDistance.Value;
    H = app.Edit_H.Value;
    
    % Fixed targets and constants
    yf = 5;
    g = 9.81; 
    safety_margin = 2.0; 
    
    %% Physics Equations
    % Find where the building sits on the X-axis
    xBuilding = xA + distToBuilding;
    
    % Set the max height of the flight
    y_max = H + safety_margin; 
    
    % Simple kinematic equations to find peak time and launch velocities
    v_y0 = sqrt(2 * g * (y_max - yA)); % Upward velocity
    t_peak = v_y0 / g;                 % Time to go UP to the peak
    
    % Simple kinematic equation to find falling time to yf = 5
    t_fall = sqrt(2 * (y_max - yf) / g); % Time to go DOWN to target height
    
    % Total flight time is just up time plus down time
    flightTime = t_peak + t_fall; 
    
    % Horizontal velocity needed to reach the building right at its peak
    v_x_total = distToBuilding / t_peak; 
    
    % Final landing position xf
    xf = xA + v_x_total * flightTime; 
    
    % Vector math for total speed and angle
    velocity_req = sqrt(v_x_total^2 + v_y0^2);
    angle_req = atand(v_y0 / v_x_total);

    %% Vectors for Plotting
    t_vec = linspace(0, flightTime, 100); 
    
    x_vec = xA + v_x_total * t_vec;
    y_vec = yA + v_y0 * t_vec - 0.5 * g * t_vec.^2;
    z_vec = linspace(zA, 0, 100); % Straight line on Z from zA to 0

    %% Calculate Clearance & Create Message
    building_clearance = safety_margin; 
    
    status_message = ['SUCCESS! Object cleared building and reached destination at xf = ', num2str(xf)];
    status_color = [0, 0.6, 0]; % Using RGB for a nice clear green

    %% Send Results back to GUI Boxes
    app.Edit_ReqVelocity.Value = velocity_req;
    app.Edit_ReqAngle.Value = angle_req;
    app.Edit_MaxHeight.Value = y_max;
    app.Edit_BuildingClearance.Value = building_clearance;

    %% Plot the Graph
    cla(app.UIAxes);
    
    % 1. Plot the blue flight path line
    plot3(app.UIAxes, x_vec, z_vec, y_vec, 'b', 'LineWidth', 3);
    hold(app.UIAxes, 'on');
    grid(app.UIAxes, 'on');
    
    % 2. Draw the building as a simple 3D mesh sheet barrier
    zWidthRange = linspace(min(zA, 0) - 5, max(zA, 0) + 5, 10);
    yHeightRange = linspace(0, H, 10);
    [zMesh, yMesh] = meshgrid(zWidthRange, yHeightRange);
    xMesh = zeros(size(zMesh)) + xBuilding;
    
    mesh(app.UIAxes, xMesh, zMesh, yMesh, 'FaceColor', [0.6 0.6 0.6], ...
         'FaceAlpha', 0.6, 'EdgeColor', [0.3 0.3 0.3]);

    % 3. Plot Launch Point (Green circle) and Target Point (Red circle)
    plot3(app.UIAxes, xA, zA, yA, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
    plot3(app.UIAxes, xf, 0, yf, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

    % 4. Add clear Text Labels right next to the points on the graph
    text(app.UIAxes, xA + 1, zA, yA + 1, 'Start Point A', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'g');
    text(app.UIAxes, xf + 1, 0, yf + 1, 'Target Point B', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'r');

    % Labels and Title
    xlabel(app.UIAxes, 'X Distance (m)');
    ylabel(app.UIAxes, 'Z Distance (m)');
    zlabel(app.UIAxes, 'Y Height (m)');
    title(app.UIAxes, status_message, 'Color', status_color);
    
    view(app.UIAxes, 75, 20); 
    hold(app.UIAxes, 'off');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'ENGG100 Project - Team 47')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [170 131 463 303];

            % Create xALabel
            app.xALabel = uilabel(app.UIFigure);
            app.xALabel.HorizontalAlignment = 'right';
            app.xALabel.Position = [23 343 25 22];
            app.xALabel.Text = 'xA';

            % Create Edit_xA
            app.Edit_xA = uieditfield(app.UIFigure, 'numeric');
            app.Edit_xA.Position = [63 343 100 22];

            % Create yAEditFieldLabel
            app.yAEditFieldLabel = uilabel(app.UIFigure);
            app.yAEditFieldLabel.HorizontalAlignment = 'right';
            app.yAEditFieldLabel.Position = [23 307 25 22];
            app.yAEditFieldLabel.Text = 'yA';

            % Create Edit_yA
            app.Edit_yA = uieditfield(app.UIFigure, 'numeric');
            app.Edit_yA.Position = [63 307 100 22];

            % Create zALabel
            app.zALabel = uilabel(app.UIFigure);
            app.zALabel.HorizontalAlignment = 'right';
            app.zALabel.Position = [22 271 25 22];
            app.zALabel.Text = 'zA';

            % Create Edit_zA
            app.Edit_zA = uieditfield(app.UIFigure, 'numeric');
            app.Edit_zA.Position = [62 271 100 22];

            % Create BuildingDistanceLabel
            app.BuildingDistanceLabel = uilabel(app.UIFigure);
            app.BuildingDistanceLabel.HorizontalAlignment = 'right';
            app.BuildingDistanceLabel.Position = [23 230 94 22];
            app.BuildingDistanceLabel.Text = 'BuildingDistance';

            % Create Edit_BuildingDistance
            app.Edit_BuildingDistance = uieditfield(app.UIFigure, 'numeric');
            app.Edit_BuildingDistance.Position = [132 230 31 22];

            % Create HLabel
            app.HLabel = uilabel(app.UIFigure);
            app.HLabel.HorizontalAlignment = 'right';
            app.HLabel.Position = [23 197 25 22];
            app.HLabel.Text = 'H';

            % Create Edit_H
            app.Edit_H = uieditfield(app.UIFigure, 'numeric');
            app.Edit_H.Position = [63 197 100 22];

            % Create ReqVelocityEditFieldLabel
            app.ReqVelocityEditFieldLabel = uilabel(app.UIFigure);
            app.ReqVelocityEditFieldLabel.HorizontalAlignment = 'right';
            app.ReqVelocityEditFieldLabel.Position = [229 94 68 22];
            app.ReqVelocityEditFieldLabel.Text = 'ReqVelocity';

            % Create Edit_ReqVelocity
            app.Edit_ReqVelocity = uieditfield(app.UIFigure, 'numeric');
            app.Edit_ReqVelocity.Editable = 'off';
            app.Edit_ReqVelocity.Position = [312 94 100 22];

            % Create ReqAngleLabel
            app.ReqAngleLabel = uilabel(app.UIFigure);
            app.ReqAngleLabel.HorizontalAlignment = 'right';
            app.ReqAngleLabel.Position = [416 94 58 22];
            app.ReqAngleLabel.Text = 'ReqAngle';

            % Create Edit_ReqAngle
            app.Edit_ReqAngle = uieditfield(app.UIFigure, 'numeric');
            app.Edit_ReqAngle.Editable = 'off';
            app.Edit_ReqAngle.Position = [489 94 100 22];

            % Create MaxHeightLabel
            app.MaxHeightLabel = uilabel(app.UIFigure);
            app.MaxHeightLabel.HorizontalAlignment = 'right';
            app.MaxHeightLabel.Position = [235 73 62 22];
            app.MaxHeightLabel.Text = 'MaxHeight';

            % Create Edit_MaxHeight
            app.Edit_MaxHeight = uieditfield(app.UIFigure, 'numeric');
            app.Edit_MaxHeight.Editable = 'off';
            app.Edit_MaxHeight.Position = [312 73 100 22];

            % Create BuildingClearanceLabel
            app.BuildingClearanceLabel = uilabel(app.UIFigure);
            app.BuildingClearanceLabel.Position = [421 73 101 22];
            app.BuildingClearanceLabel.Text = 'BuildingClearance';

            % Create Edit_BuildingClearance
            app.Edit_BuildingClearance = uieditfield(app.UIFigure, 'numeric');
            app.Edit_BuildingClearance.AllowEmpty = 'on';
            app.Edit_BuildingClearance.Editable = 'off';
            app.Edit_BuildingClearance.Position = [530 73 59 22];

            % Create RunSimulationButton
            app.RunSimulationButton = uibutton(app.UIFigure, 'push');
            app.RunSimulationButton.ButtonPushedFcn = createCallbackFcn(app, @RunSimulationButtonPushed, true);
            app.RunSimulationButton.Position = [23 145 137 34];
            app.RunSimulationButton.Text = 'RunSimulation';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app3_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end