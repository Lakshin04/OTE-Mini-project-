clc; clear; close all;
%% Vehicle Routing Problem - Genetic Algorithm
% Dataset: 20 customers, 1 depot, 3 vehicles 
rng(42);
n = 20; % number of customers 
nv = 3; % number of vehicles
capacity = 100; % vehicle capacity
% Generate customer locations (depot at index 1) 
depot = [50, 50];
cx = [depot(1); randi([5,95],n,1)];
cy = [depot(2); randi([5,95],n,1)];
demand = [0; randi([5,20],n,1)];
% Distance matrix 
N = n+1;
dist = zeros(N,N); 
for i=1:N
    for j=1:N
        dist(i,j) = sqrt((cx(i)-cx(j))^2 + (cy(i)-cy(j))^2);
    end
end
% Cost parameters
fuel_rate = 0.5;      % cost per unit distance 
delay_penalty = 2.0;  % penalty per unit delay 
vehicle_cost = 50;    % fixed cost per vehicle used
% Fitness function
calc_cost = @(routes) compute_total_cost(routes, dist, demand, ... 
    capacity, fuel_rate, delay_penalty, vehicle_cost, nv, n);
% GA parameters 
pop_size = 50;
iterations = 100;
mutation_rate = 0.3;
% Initialize population (permutation encoding) 
population = zeros(pop_size, n);
for i = 1:pop_size
    population(i,:) = randperm(n);
end
best_cost = inf; 
best_route = [];
best_history = zeros(iterations,1);
% GA loop
for iter = 1:iterations
    costs = zeros(pop_size,1); 
    for i = 1:pop_size
        costs(i) = calc_cost(population(i,:)); 
        if costs(i) < best_cost
            best_cost = costs(i); 
            best_route = population(i,:);
        end
    end
    best_history(iter) = best_cost;
    % Tournament selection and crossover 
    new_pop = population;
    for i = 1:pop_size
        % Tournament selection
        p1 = population(randi(pop_size),:); 
        p2 = population(randi(pop_size),:); 
        if calc_cost(p1) < calc_cost(p2)
            parent = p1;
        else
            parent = p2;
        end
        child = parent;
        % Mutation: swap two customers 
        if rand < mutation_rate
            idx = randperm(n,2); 
            child(idx(1)) = parent(idx(2));
            child(idx(2)) = parent(idx(1));
        end
        new_pop(i,:) = child;
    end
    population = new_pop;
end
fprintf('Best Total Cost (GA): %.2f\n', best_cost);
% Plot convergence 
figure;
plot(best_history,'LineWidth',2); 
xlabel('Iterations'); ylabel('Total Cost'); 
title('GA Convergence - Vehicle Routing'); grid on;
% Plot routes
plot_vrp_routes(best_route, cx, cy, nv, demand, capacity, 'Best Routes (GA)');

%% Helper functions
function cost = compute_total_cost(route, dist, demand, cap, fr, dp, vc, nv, n) 
    cost = 0;
    vehicles_used = 0;
    idx = 1;
    while idx <= n
        vehicles_used = vehicles_used + 1; 
        load = 0; d = 0; prev = 1;
        while idx <= n
            cust = route(idx) + 1;
            if load + demand(cust) > cap 
                break;
            end
            d = d + dist(prev, cust);
            load = load + demand(cust); 
            prev = cust;
            idx = idx + 1;
        end
        d = d + dist(prev, 1);
        cost = cost + d + fr*d + dp*max(0, d-200);
    end
    cost = cost + vc * vehicles_used;
end

function plot_vrp_routes(route, cx, cy, nv, demand, cap, ttl) 
    figure; hold on;
    plot(cx(1), cy(1), 'ks', 'MarkerSize', 12, 'MarkerFaceColor', 'k');
    plot(cx(2:end), cy(2:end), 'ro', 'MarkerSize', 6);
    colors = ['b','r','g','m','c']; 
    idx = 1; n = length(route); v = 0; 
    while idx <= n
        v = v+1; load = 0;
        rx = cx(1); ry = cy(1); 
        while idx <= n
            cust = route(idx)+1;
            if load + demand(cust) > cap, break; end 
            rx = [rx; cx(cust)]; ry = [ry; cy(cust)]; 
            load = load + demand(cust);
            idx = idx+1;
        end
        rx = [rx; cx(1)]; ry = [ry; cy(1)];
        plot(rx, ry, [colors(mod(v-1,5)+1) '-'], 'LineWidth', 1.5);
    end
    title(ttl); legend('Depot','Customers'); grid on;
end
