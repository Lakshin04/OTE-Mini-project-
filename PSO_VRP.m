clc; clear; close all;
%% Vehicle Routing Problem - Particle Swarm Optimization 
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
num_particles = 50;
iterations = 100;
% Initialize particles
particles = zeros(num_particles, n); 
pbest = particles;
pbest_cost = inf(num_particles,1); 
for i = 1:num_particles
    particles(i,:) = randperm(n); 
    pbest(i,:) = particles(i,:);
end
gbest = []; gbest_cost = inf; 
history = zeros(iterations,1);
for iter = 1:iterations
    for i = 1:num_particles 
        route = particles(i,:);
        c = compute_total_cost(route, dist, demand, capacity, ... 
            fuel_rate, delay_penalty, vehicle_cost, nv, n);
        if c < pbest_cost(i) 
            pbest(i,:) = route; 
            pbest_cost(i) = c;
        end
        if c < gbest_cost 
            gbest = route; 
            gbest_cost = c;
        end
    end
    % Update particles (swap-based movement) 
    for i = 1:num_particles
        % Move toward pbest 
        if rand < 0.5
            idx = randperm(n,2);
            [~,p1] = ismember(pbest(i,idx(1)), particles(i,:));
            [~,p2] = ismember(pbest(i,idx(2)), particles(i,:)); 
            if p1>0 && p2>0
                particles(i,[p1,p2]) = particles(i,[p2,p1]);
            end
        end
        % Move toward gbest 
        if rand < 0.3
            idx = randperm(n,2);
            particles(i,idx) = particles(i,fliplr(idx));
        end
    end
    history(iter) = gbest_cost;
end
fprintf('Best Total Cost (PSO): %.2f\n', gbest_cost); 
figure;
plot(history,'LineWidth',2,'Color','r'); 
title('PSO Convergence - Vehicle Routing');
xlabel('Iterations'); ylabel('Total Cost'); grid on; 
plot_vrp_routes(gbest, cx, cy, nv, demand, capacity, 'Best Routes (PSO)');

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
