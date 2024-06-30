% Define data arrays
time = 1:24; % Time in hours
% Define updated data arrays for more realistic home usage 
load1 = [4, 3, 1, 1, 1, 0, 3, 4, 5, 6, 7, 5, 5, 4, 2, 0, 3, 2, 5, 4, 2, 2, 1, 2]; % Load profile for load 1 
load2 = [1, 2, 1, 2, 3, 4, 5, 3, 3, 0, 2, 2, 5, 6, 7, 8, 5, 2, 1, 1, 1, 1, 2, 5]; % Load profile for load 2 
load3 = [1, 3, 3, 5, 6, 4, 2, 2, 2, 0, 0, 0, 0, 3, 4, 4, 5, 8, 9, 7, 4, 2, 2, 0]; % Load profile for load 3
solar_power = [0, 0, 0, 0, 0, 0, 0, 7, 7, 8, 8, 6, 7, 6, 7, 7, 5, 4, 3, 1, 1, 2, 2, 3]; % Solar power generation profile
battery_capacity = 20; % Battery capacity in kWh
battery_charge_efficiency = 0.9; % Charging efficiency of the battery
battery_discharge_efficiency = 0.8; % Discharging efficiency of the battery

% Define load demand response parameters
demand_response_factor_peak = 0.7; % Load demand response factor during peak hours (70% of original load)
demand_response_factor_non_peak = 0.8; % Load demand response factor during non-peak hours (80% of original load)

% Initialize variables
total_energy_consumed = zeros(1, 24);
total_energy_generated = zeros(1, 24);
total_energy_deficit = zeros(1, 24);
total_energy_from_solar = zeros(1, 24);
total_energy_from_grid = zeros(1, 24);
total_energy_from_battery = zeros(1, 24);
battery_storage = 0;

% Energy management optimization
for i = 1:length(time)
    if ismember(i, [6, 7, 8, 9, 18, 19, 20])
        % Peak hours
        total_energy_consumed(i) = load1(i) * demand_response_factor_peak + load2(i) * demand_response_factor_peak + load3(i) * demand_response_factor_peak;
        
        % Peak hour energy management logic
        if solar_power(i) >= total_energy_consumed(i)
            total_energy_from_solar(i) = total_energy_consumed(i);
        elseif solar_power(i) + battery_storage >= total_energy_consumed(i)
            total_energy_from_solar(i) = solar_power(i);
            battery_storage = max(0, battery_storage + solar_power(i) - total_energy_consumed(i));
        else
            total_energy_from_solar(i) = solar_power(i) + min(total_energy_consumed(i) - solar_power(i), battery_storage / battery_discharge_efficiency);
            battery_storage = max(0, battery_storage - (total_energy_consumed(i) - solar_power(i)) * battery_charge_efficiency);
        end
        
        total_energy_generated(i) = total_energy_from_solar(i);
    else
       % Non-peak hours 
total_energy_consumed(i) = load1(i) * demand_response_factor_non_peak + load2(i) * demand_response_factor_non_peak + load3(i) * demand_response_factor_non_peak; 

% Non-peak hour energy management logic 
		if solar_power(i) >= total_energy_consumed(i) 
    			total_energy_from_solar(i) = total_energy_consumed(i); 
		else 
    			total_energy_from_solar(i) = solar_power(i); 
    			total_energy_from_grid(i) = max(0, total_energy_consumed(i) - solar_power(i)); 
		end 

			total_energy_generated(i) = total_energy_from_solar(i); 

		if total_energy_generated(i) < total_energy_consumed(i)
    			total_energy_deficit(i) = total_energy_consumed(i) - total_energy_generated(i);
		end
    end
end

    
    % Display results for each hour
    fprintf('Total Energy Consumed: %.2f kWh\n', total_energy_consumed(i));
    fprintf('Total Energy Generated: %.2f kWh\n', total_energy_generated(i));
    fprintf('Total Energy Deficit: %.2f kWh\n', total_energy_deficit(i));
    fprintf('Energy from Solar: %.2f kWh\n', total_energy_from_solar(i));
    fprintf('Energy from Grid: %.2f kWh\n\n', total_energy_from_grid(i));
   

% Plot the energy profiles as curves
figure;
plot(time, total_energy_consumed, 'b', 'LineWidth', 1.5);
hold on;
plot(time, total_energy_generated, 'g', 'LineWidth', 1.5);
plot(time, total_energy_deficit, 'r', 'LineWidth', 1.5);
plot(time, total_energy_from_solar, 'm', 'LineWidth', 1.5);
plot(time, total_energy_from_grid, 'c', 'LineWidth', 1.5);

xlabel('Time (hours)');
ylabel('Energy (kWh)');
legend('Total Energy Consumed', 'Total Energy Generated', 'Total Energy Deficit', 'Energy from Solar', 'Energy from Grid');
title('Energy Management Results');
grid on;

% Create a bar chart to visualize the results
figure;
bar(time, [total_energy_consumed; total_energy_generated; total_energy_deficit; total_energy_from_solar; total_energy_from_grid]', 'stacked');
xlabel('Time (hours)');
ylabel('Energy (kWh)');
legend('Total Energy Consumed', 'Total Energy Generated', 'Total Energy Deficit', 'Energy from Solar', 'Energy from Grid');
title('Energy Management Results');

% Define cost parameters
grid_price_peak = 11.25; % Grid electricity price during peak hours (Rs/kWh) 
grid_price_non_peak = 7.50; % Grid electricity price during non-peak hours (Rs/kWh) 
solar_price = 2.50; % Solar electricity price (Rs/kWh) 
battery_cost = 1.50; % Battery charging cost (Rs/kWh)

% Initialize cost variables
total_cost_grid = zeros(1, 24);
total_cost_solar = zeros(1, 24);
total_cost_battery = zeros(1, 24);

% Initialize variables
total_energy_consumed = zeros(1, 24);
total_energy_generated = zeros(1, 24);
total_energy_deficit = zeros(1, 24);
total_energy_from_solar = zeros(1, 24);
total_energy_from_grid = zeros(1, 24);
total_energy_from_battery = zeros(1, 24);
battery_storage = 0;

% Energy management optimization without cost-efficient savings
total_cost_no_optimization = zeros(1, 24);
for i = 1:length(time)
    total_energy_consumed(i) = load1(i) + load2(i) + load3(i);
    total_cost_no_optimization(i) = total_energy_consumed(i) * grid_price_peak;
end

% Energy management optimization with cost-efficient savings
total_cost_optimization = zeros(1, 24);
for i = 1:length(time)
    if ismember(i, [7, 8, 9, 18, 19, 20])
        % Peak hours
        total_energy_consumed(i) = load1(i) * demand_response_factor_peak + load2(i) * demand_response_factor_peak + load3(i) * demand_response_factor_peak;
        
        % Peak hour energy management logic for cost savings
        if solar_power(i) >= total_energy_consumed(i)
            total_energy_from_solar(i) = total_energy_consumed(i);
        else
            total_energy_from_solar(i) = min(solar_power(i), total_energy_consumed(i));
            total_energy_from_grid(i) = total_energy_consumed(i) - total_energy_from_solar(i);
        end
        
        % Battery usage for cost-efficient savings during peak hours
        battery_used = min(total_energy_consumed(i) - total_energy_from_solar(i), battery_storage);
        total_energy_from_battery(i) = battery_used * battery_discharge_efficiency;
        battery_storage = max(0, battery_storage - battery_used);
        
        % Calculate costs for optimization
        total_cost_solar = total_energy_from_solar(i) * solar_price;
        total_cost_grid = total_energy_from_grid(i) * grid_price_peak;
        total_cost_battery = battery_used * battery_cost;
        total_cost_optimization(i) = total_cost_solar + total_cost_grid + total_cost_battery;
    else
        % Non-peak hours
        total_energy_consumed(i) = load1(i) * demand_response_factor_non_peak + load2(i) * demand_response_factor_non_peak + load3(i) * demand_response_factor_non_peak;
        
        % Non-peak hour energy management logic for cost savings
        if solar_power(i) >= total_energy_consumed(i)
            total_energy_from_solar(i) = total_energy_consumed(i);
        else
            total_energy_from_solar(i) = solar_power(i);
            total_energy_from_grid(i) = total_energy_consumed(i) - solar_power(i);
        end
        
        % Calculate costs for optimization
        total_cost_solar = total_energy_from_solar(i) * solar_price;
        total_cost_grid = total_energy_from_grid(i) * grid_price_non_peak;
        total_cost_optimization(i) = total_cost_solar + total_cost_grid;
    end
end

% Calculate total costs for before and after optimization
total_costs_no_optimization = sum(total_cost_no_optimization);
total_costs_optimization = sum(total_cost_optimization);

% Display total costs for before and after optimization
fprintf('Total Cost without Energy Management: Rs%.2f\n', total_costs_no_optimization);
fprintf('Total Cost after Energy Management: Rs%.2f\n', total_costs_optimization);

% Plot the cost comparison
figure;
plot(time, total_cost_no_optimization, 'b--', 'LineWidth', 1.5);
hold on;
plot(time, total_cost_optimization, 'r', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Cost (Rs)');
legend('Cost without Energy Management', 'Cost after Energy Management');
title('Cost Comparison: Before and After Energy Management');
grid on;

% Plot the different load profiles 
figure; 
bar(time, [load1; load2; load3]', 'stacked');
xlabel('Time (hours)'); ylabel('Load (kW)'); 
legend('Load 1', 'Load 2', 'Load 3'); 
title('Different Load Profiles');


 figure; 
 plot(time, load1, 'b', 'LineWidth', 1.5); 
 hold on; plot(time, load2, 'g', 'LineWidth', 1.5); 
 plot(time, load3, 'r', 'LineWidth', 1.5); xlabel('Time (hours)'); 
 ylabel('Load (kW)'); legend('Load 1', 'Load 2', 'Load 3'); 
 title('Different Load Profiles'); 
 grid on;
 
 
 
 
 
 
 