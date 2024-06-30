matlab
% Define cost parameters
grid_price_peak = 11.25; % Grid electricity price during peak hours (Rs/kWh)
grid_price_non_peak = 7.50; % Grid electricity price during non-peak hours (Rs/kWh)
solar_price = 2.50; % Solar electricity price (Rs/kWh)
battery_cost = 1.50; % Battery charging cost (Rs/kWh)

% Define the maximum power values for solar, grid, and battery
max_solar_power = 100; % Maximum solar power available (kW)
max_grid_power = 200; % Maximum grid power available (kW)
max_battery_power = 50; % Maximum battery power available (kW)

% Define the demand response factors for peak and non-peak hours
demand_response_factor_peak = 0.8;
demand_response_factor_non_peak = 0.6;

% Initialize variables
time = 1:24;

load1 = [4, 3, 1, 1, 1, 0, 3, 4, 5, 6, 7, 5, 5, 4, 2, 0, 3, 2, 5, 4, 2, 2, 1, 2]; % Load profile for load 1 
load2 = [1, 2, 1, 2, 3, 4, 5, 3, 3, 0, 2, 2, 5, 6, 7, 8, 5, 2, 1, 1, 1, 1, 2, 5]; % Load profile for load 2 
load3 = [1, 3, 3, 5, 6, 4, 2, 2, 2, 0, 0, 0, 0, 3, 4, 4, 5, 8, 9, 7, 4, 2, 2, 0]; % Load profile for load 3
solar_power = [0, 0, 0, 0, 0, 0, 0, 7, 7, 8, 8, 6, 7, 6, 7, 7, 5, 4, 3, 1, 1, 2, 2, 3]; % Solar power generation profile

battery_discharge_efficiency = 0.9; % Efficiency of battery discharge

% Define the GA parameters
population_size = 50;
generations = 100;
mutation_rate = 0.02;

% Define the fitness function
fitness_function = @(x) energy_cost_function(x, solar_power, load1, load2, load3, grid_price_peak, grid_price_non_peak, solar_price, battery_cost);

% Initialize the population with random solutions
population = rand(population_size, 3) .* [max_solar_power, max_grid_power, max_battery_power];

% Main GA loop
for gen = 1:generations
    % Evaluate fitness of each individual in the population
    fitness = zeros(population_size, 1);
    for i = 1:population_size
        fitness(i) = fitness_function(population(i, :));
    end

    % Selection
    [~, idx] = sort(fitness);
    population = population(idx, :);

    % Crossover
    new_population = zeros(population_size, 3);
    for i = 1:2:population_size
        parent1 = population(mod(i, population_size) + 1, :);
        parent2 = population(mod(i + 1, population_size) + 1, :);
        crossover_point = randi([1, 2]);
        new_population(i, :) = [parent1(1:crossover_point), parent2(crossover_point + 1:end)];
        new_population(i + 1, :) = [parent2(1:crossover_point), parent1(crossover_point + 1:end)];
    end

    % Mutation
    for i = 1:population_size
        if rand < mutation_rate
            new_population(i, :) = new_population(i, :) + randn(1, 3) .* [max_solar_power, max_grid_power, max_battery_power] .* 0.1;
            new_population(i, :) = max(new_population(i, :), 0); % Ensure values do not go negative
        end
    end

    population = new_population;
end

% Find the best solution
best_solution = population(1, :);
best_cost = fitness_function(best_solution);

disp('Optimized Solution:');
disp(best_solution);
disp(['Optimized Cost: Rs', num2str(best_cost)]);


% Define the energy_cost_function
function total_cost = energy_cost_function(x, solar_power, load1, load2, load3, grid_price_peak, grid_price_non_peak, solar_price, battery_cost)
    % Extract decision variables
    solar_usage = x(1);
    grid_usage = x(2);
    battery_usage = x(3);

    % Calculate total energy consumed and cost
    total_energy_consumed = solar_usage + grid_usage + battery_usage;
    total_cost = max(0, solar_usage * solar_price + grid_usage * grid_price_peak + battery_usage * battery_cost); % Ensure cost is non-negative

    % Add constraints if needed

    % Return the total cost
end


% Define cost parameters
grid_price_peak = 11.25; % Grid electricity price during peak hours (Rs/kWh)
grid_price_non_peak = 7.50; % Grid electricity price during non-peak hours (Rs/kWh)
solar_price = 2.50; % Solar electricity price (Rs/kWh)
battery_cost = 1.50; % Battery charging cost (Rs/kWh)

% Define the maximum power values for solar, grid, and battery
max_solar_power = 100; % Maximum solar power available (kW)
max_grid_power = 200; % Maximum grid power available (kW)
max_battery_power = 50; % Maximum battery power available (kW)

% Define the demand response factors for peak and non-peak hours
demand_response_factor_peak = 0.8;
demand_response_factor_non_peak = 0.6;

% Initialize variables
time = 1:24;

load1 = [4, 3, 1, 1, 1, 0, 3, 4, 5, 6, 7, 5, 5, 4, 2, 0, 3, 2, 5, 4, 2, 2, 1, 2]; % Load profile for load 1 
load2 = [1, 2, 1, 2, 3, 4, 5, 3, 3, 0, 2, 2, 5, 6, 7, 8, 5, 2, 1, 1, 1, 1, 2, 5]; % Load profile for load 2 
load3 = [1, 3, 3, 5, 6, 4, 2, 2, 2, 0, 0, 0, 0, 3, 4, 4, 5, 8, 9, 7, 4, 2, 2, 0]; % Load profile for load 3
solar_power = [0, 0, 0, 0, 0, 0, 0, 7, 7, 8, 8, 6, 7, 6, 7, 7, 5, 4, 3, 1, 1, 2, 2, 3]; % Solar power generation profile

battery_discharge_efficiency = 0.9; % Efficiency of battery discharge

% Calculate cost without optimization
total_cost_no_opt = sum(load1 * grid_price_peak + load2 * grid_price_peak + load3 * grid_price_peak); % Assuming all loads are powered by the grid

% Initialize battery SOC
initial_battery_SOC = 20; % Initial Battery State of Charge (kWh)
battery_SOC = initial_battery_SOC;

% Plot load and power sources
figure;
subplot(2,1,1);
plot(time, load1, 'r', 'LineWidth', 1.5);
hold on;
plot(time, load2, 'b', 'LineWidth', 1.5);
plot(time, load3, 'g', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power Consumption (kW)');
title('Load Consumption Profiles');
legend('Load 1', 'Load 2', 'Load 3');
grid on;
hold off;

subplot(2,1,2);
plot(time, solar_power, 'y', 'LineWidth', 1.5);
hold on;
plot(time, ones(size(time))*max_grid_power, 'b--', 'LineWidth', 1.5);
plot(time, ones(size(time))*max_battery_power, 'g--', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power Generation/Usage (kW)');
title('Power Source Generation/Usage Profiles');
legend('Solar Power', 'Max Grid Power', 'Max Battery Power');
grid on;
hold off;

disp('Cost without optimization:');
disp(['Total Cost: Rs', num2str(total_cost_no_opt)]);


matlab
% Define cost parameters, variables, and functions as before...

% Initialize arrays to store power source consumption during optimization
solar_consumption = zeros(1, 24);
grid_consumption = zeros(1, 24);
battery_consumption = zeros(1, 24);

% Main GA loop
for gen = 1:generations

    % Update power source consumption arrays
    best_solution = population(1, :);
    solar_consumption = solar_consumption + best_solution(1) * solar_power;
    grid_consumption = grid_consumption + best_solution(2) * ones(1, 24);
    battery_consumption = battery_consumption + best_solution(3) * ones(1, 24);
end

% Plot power source consumption during optimization
figure;
plot(time, solar_consumption, 'y', 'LineWidth', 1.5);
hold on;
plot(time, grid_consumption, 'b', 'LineWidth', 1.5);
plot(time, battery_consumption, 'g', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power Consumption (kW)');
title('Power Source Consumption Profiles during Optimization');
legend('Solar Power Consumption', 'Grid Power Consumption', 'Battery Power Consumption');
grid on;
hold off;