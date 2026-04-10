# 🚚 Smart Logistics – Vehicle Routing Optimization

> A comparative study of **Genetic Algorithm (GA)**, **Particle Swarm Optimization (PSO)**, and **Ant Colony Optimization (ACO)** applied to the Capacitated Vehicle Routing Problem (CVRP), implemented in MATLAB.

---

## 📌 Overview

The **Vehicle Routing Problem (VRP)** is a classic NP-hard combinatorial optimization challenge in logistics — determining the most cost-efficient delivery routes for a fleet of capacity-constrained vehicles serving geographically dispersed customers from a central depot.

This project implements and compares three nature-inspired metaheuristic algorithms on a 20-customer, 3-vehicle CVRP instance. Each algorithm minimizes a composite cost function that accounts for:

- 📏 Travel distance
- ⛽ Fuel consumption
- ⏱️ Delay penalties
- 🚛 Fixed vehicle operating costs

---

## 📂 Repository Structure

```
smart-logistics-vrp/
│
├── GA_VRP.m          # Genetic Algorithm implementation
├── PSO_VRP.m         # Particle Swarm Optimization implementation
├── ACO_VRP.m         # Ant Colony Optimization implementation
└── README.md
```

---

## ⚙️ Problem Setup

| Parameter | Value |
|-----------|-------|
| Customers | 20, randomly located in a 100×100 grid |
| Depot | Fixed at (50, 50) |
| Vehicles | 3, each with capacity = 100 units |
| Customer Demand | Random ∈ [5, 20] units (seed: `rng(42)`) |
| Distance Metric | Euclidean |
| Cost Function | `d + 0.5·d + 2·max(0, d−200) + 50·vehicles_used` |

---

## 🧬 Algorithms

### 1. Genetic Algorithm (`GA_VRP.m`)
- **Encoding:** Permutation of customer indices; routes decoded by capacity
- **Selection:** Tournament selection
- **Mutation:** Swap mutation (rate = 0.3)
- **Population size:** 50 | **Iterations:** 100
- **Result:** Cost reduced from ~1,800 → ~1,400 (~22% improvement)

### 2. Particle Swarm Optimization (`PSO_VRP.m`)
- **Position:** Customer permutation decoded by capacity
- **Movement:** Swap-based velocity operators (cognitive prob = 0.5, social prob = 0.3)
- **Swarm size:** 50 | **Iterations:** 100
- **Result:** Cost reduced from ~1,700 → ~1,250 (~26% improvement) — **fastest convergence**

### 3. Ant Colony Optimization (`ACO_VRP.m`)
- **Pheromone:** α = 1, evaporation ρ = 0.5
- **Heuristic:** Inverse distance, β = 5
- **Ants:** 30 | **Iterations:** 100
- **Result:** Cost reduced from ~1,700 → ~1,200 (~29% improvement) — **best solution quality**

---

## 📊 Results Summary

| Algorithm | Initial Cost | Final Cost | Improvement | Convergence |
|-----------|-------------|------------|-------------|-------------|
| GA        | ~1,800      | ~1,400     | ~22%        | Gradual, steady |
| PSO       | ~1,700      | ~1,250     | ~26%        | Rapid early, plateaus ~iter 70 |
| ACO       | ~1,700      | ~1,200     | ~29%        | Consistent, no plateau |

**Winner: ACO** for solution quality. **PSO** for speed. **GA** for simplicity and robustness.

---

## 🚀 Getting Started

### Prerequisites
- MATLAB R2018b or later (no additional toolboxes required)

### Running the Code

Each file is fully self-contained. Simply open MATLAB and run:

```matlab
% For Genetic Algorithm
run('GA_VRP.m')

% For Particle Swarm Optimization
run('PSO_VRP.m')

% For Ant Colony Optimization
run('ACO_VRP.m')
```

Each script will:
1. Generate the customer/depot dataset (deterministic via `rng(42)`)
2. Run the optimization for 100 iterations
3. Print the best total cost to the console
4. Plot the **convergence curve** (cost vs. iterations)
5. Plot the **best routes** found across all 3 vehicles

---

## 📈 Sample Output

```
Best Total Cost (GA):  1397.43
Best Total Cost (PSO): 1248.71
Best Total Cost (ACO): 1201.56
```

---

## 👥 Authors

| Name | Roll Number |
|------|-------------|
| Lakshin SK | 2023BCSE07AED009 |
| Suriya SM | 2023BCSE07AED028 |
| Pavan M | 2023BCSE07AED123 |

**Course:** Optimization Techniques (6CS1026)  
**Department:** Computer Science & Engineering  
**Institution:** Alliance University, Bangalore  
**Batch:** AIML – A | April 2026

---

## 📚 References

- Dantzig & Ramser (1959) – The Truck Dispatching Problem
- Holland (1975) – Genetic Algorithms
- Dorigo (1992) – Ant Colony Optimization
- Kennedy & Eberhart (1995) – Particle Swarm Optimization
- Baker & Ayechew (2003) – GA for VRP
- Bullnheimer et al. (1999) – ACO for VRP

---

## 📄 License

This project was developed as part of an academic course. Feel free to use or reference it for educational purposes.
