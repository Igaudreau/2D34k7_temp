#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=1-00:00
#SBATCH --account=def-bmaxwell
#SBATCH --output=postout

# Run unified python analyzer
python3 - << 'PY'
import os
import re
import numpy as np

# --- 1. Parse Parameters from runsim.sh ---
loop_end = None
mg_timestep = None

if os.path.exists('runsim.sh'):
    with open('runsim.sh', 'r') as f:
        for line in f:
            if 'LOOP_END=' in line and not line.strip().startswith('#'):
                match = re.search(r'LOOP_END=\s*(\d+)', line)
                if match:
                    loop_end = int(match.group(1))
            if 'mg_timestep=' in line and not line.strip().startswith('#'):
                match = re.search(r'mg_timestep=\s*([0-9.eE+-]+)', line)
                if match:
                    mg_timestep = float(match.group(1))

# Fallbacks if parsing fails
loop_start = 0
loop_end = (loop_end + 1) if loop_end is not None else 201
mg_timestep = mg_timestep if mg_timestep is not None else 1.0e-8
threshold = 0.2E23

# --- 2. Extract Shock History ---
for j in ['bot', 'top']:
    history = []
    
    for i in range(loop_start, loop_end + 1):
        filename = f'./xq/pg_{j}.{i:04d}.xq'
        time = i * mg_timestep
        
        if not os.path.exists(filename):
            continue
            
        try:
            # Load x and pressure columns (skip header)
            a = np.loadtxt(filename, skiprows=3)
            if a.ndim < 2 or a.shape[0] == 0:
                continue
                
            x_vals = a[:, 0]
            p_vals = a[:, 1]
            
            # Find elements exceeding threshold
            indices = np.where(p_vals > threshold)[0]
            
            # Bounds check before indexing
            if len(indices) >= 6:
                shocki = indices[-6]
                pos_index = min(shocki + 3, len(x_vals) - 1)
                
                xshock = x_vals[pos_index]
                pshock = p_vals[shocki]
                history.append([xshock, pshock, time])
                
        except Exception as e:
            print(f"Warning: Failed processing {filename}: {e}")

    if not history:
        print(f"No shock data found for {j}")
        continue

    history = np.array(history)
    
    # Save shock position history
    np.savetxt(f'./shockhist_{j}.txt', history, fmt='%.8e')

    # --- 3. Compute Shock Speed D = dx/dt ---
    if len(history) >= 3:
        x = history[:, 0]
        t = history[:, 2]

        # Central difference via np.gradient
        D = np.gradient(x, t)

        # Truncate endpoints to match central differencing behavior
        speed_data = np.column_stack((D[1:-1], x[1:-1]))
        np.savetxt(f'./shockspeed_{j}.txt', speed_data, fmt='%.8e')

PY

# --- 4. Plot Results ---
gnuplot Dspeed.plt
