clc; clear; close all;
%% Vehicle Routing Problem - Ant Colony Optimization 
rng(42);
n = 20; nv = 3; capacity = 100;
depot = [50, 50];
cx = [depot(1); randi([5,95],n,1)];
cy = [depot(2); randi([5,95],n,1)];
demand = [0; randi([5,20],n,1)];
N = n+1;
dist = zeros(N,N); 
for i=1:N
    for j=1:N
        dist(i,j) = sqrt((cx(i)-cx(j))^2 + (cy(i)-cy(j))^2);
    end
end
fuel_rate = 0.5; delay_penalty = 2.0; vehicle_cost = 50;
% ACO parameters 
num_ants = 30;
iterations = 100;
alpha = 1; beta = 5;
evaporation = 0.5; 
pheromone = ones(N,N);
best_cost = inf; 
best_route = [];
best_history = zeros(iterations,1);
for iter = 1:iterations 
    for ant = 1:num_ants
        visited = false(1,n); 
        route = zeros(1,n);
        pos = 0;      % index in route 
        current = 1;  % start at depot 
        load = 0;
        vehicles_used = 1;
        for i = 1:n
            % Calculate probabilities 
            prob = zeros(1,n);
            for j = 1:n
                if ~visited(j) 
                    cust = j+1;
                    if load + demand(cust) <= capacity
                        prob(j) = (pheromone(current,cust)^alpha) * ... 
                            ((1/dist(current,cust))^beta);
                    end
                end
            end
            if sum(prob) == 0
                % Return to depot, start new vehicle 
                current = 1;
                load = 0;
                vehicles_used = vehicles_used + 1;
                % Recalculate probabilities 
                for j = 1:n
                    if ~visited(j) 
                        cust = j+1;
                        if load + demand(cust) <= capacity
                            prob(j) = (pheromone(current,cust)^alpha) ...
                                * ((1/dist(current,cust))^beta);
                        end
                    end
                end
            end
            prob = prob / sum(prob);
            next = find(rand <= cumsum(prob), 1); 
            route(i) = next;
            visited(next) = true; 
            current = next + 1;
            load = load + demand(current);
            % Evaluate
            c = compute_total_cost(route, dist, demand, capacity, ... 
                fuel_rate, delay_penalty, vehicle_cost, nv, n);
            if c < best_cost 
                best_cost = c; 
                best_route = route;
            end
        end
    end
    % Pheromone update
    pheromone = (1-evaporation) * pheromone; 
    prev = 1;
    for i = 1:n
        cust = best_route(i)+1;
        pheromone(prev,cust) = pheromone(prev,cust) + 1/best_cost; 
        prev = cust;
    end
    best_history(iter) = best_cost;
end
fprintf('Best Total Cost (ACO): %.2f\n', best_cost); 
figure;
plot(best_history,'LineWidth',2,'Color',[0 0.6 0]); 
xlabel('Iterations'); ylabel('Total Cost'); 
title('ACO Convergence - Vehicle Routing'); grid on;
plot_vrp_routes(best_route, cx, cy, nv, demand, capacity, 'Best Routes (ACO)');

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
