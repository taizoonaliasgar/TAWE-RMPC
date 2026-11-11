# TAWE-RMPC

MATLAB code for the paper

> T. Chunawala, S. Janakaraj, J. Decker, M. Ahmad, S. Vijayan, O. Barry, K. Akbari Hamed,
> **"Robust Model Predictive Control of a Tremor-Suppression Exoskeleton under Tremor-Induced Disturbances,"**
> *ASME Journal of Dynamic Systems, Measurement, and Control* (accepted).

The repository contains the 9-DoF constrained arm–exoskeleton model of the
Tremor Alleviating Wrist Exoskeleton (TAWE), the proposed robust MPC (RMPC)
with state-dependent vertex weighting, the three baselines (nominal MPC,
nonlinear MPC, MPC with a nonlinear disturbance observer), and the scripts
and saved results behind the simulation figures and tables in the paper.

## Status

This repository is an archival record of the code and results used for the
paper.

- `results/paper/` contains the original simulation runs behind the published
  figures and tables. `run_all` recomputes the RMSE tables and redraws the
  figures from these runs. This has been checked against the paper; see
  *Reproducibility notes*.
- The simulation scripts are the ones used for the paper, reorganized for
  sharing: relative paths, one script per scenario, explicit configuration,
  and a fixed random seed. Full reruns from scratch (`rerunSimulations = true`)
  have not been re-verified in this layout and may differ slightly from the
  saved runs (see notes below).

## Requirements

| Dependency | Used for | Notes |
|---|---|---|
| MATLAB (R2020b or newer recommended) | everything | `exportgraphics` needs R2020a+ |
| [qpSWIFT](https://github.com/qpSWIFT/qpSWIFT) | QP solver for MPC, MPC-NDO and RMPC | GPL-3.0; **bundled** in `external/qpSWIFT/` with prebuilt MEX files for Linux, Windows and Intel macOS. On other platforms, build it from upstream |
| [CasADi](https://web.casadi.org/get/) 3.6.x | NMPC baseline only | LGPL-3.0; not bundled. Developed with 3.6.4 |
| Symbolic Math Toolbox | model re-derivation only (`model/derivation/`) | not needed to run simulations |

## Quick start

```matlab
cd TAWE-RMPC
setup_paths

% Recompute Tables 2-4 and redraw Figs. 6-11 from the shipped results (seconds)
run_all

% Or rerun a single simulation (results go to results/rerun/)
scenario = 'setpoint';   % or 'sine'
sim_RMPC
compute_rmse_tables('rerun')
```

To regenerate every result from scratch, set `rerunSimulations = true;` before
`run_all`. That takes a while (NMPC is by far the slowest), and it hasn't been
re-verified in this layout; see *Status*.

## Repository layout

```
model/            TAWE parameters, dynamics/kinematics, linearization terms
  derivation/     symbolic model and CasADi code generation (as used; see notes)
  nmpc/           CasADi dynamics function for the NMPC (gzipped, unpacked on first use)
lib/ANDY/         multibody modeling library by Jiamin Wang (VT RML)
controllers/      mpc_RMPC2n (RMPC QP), compute_vertex_weights (state-dependent weighting),
                  mpc_no_BMFLC (nominal MPC QP), NDO_estimator (Eq. 20), mpc_Casadi_full (NMPC)
uncertainty/      uncertainty_vertices (the vertex set W), build_uncertainty_set, polygon fitting
simulations/      one script per controller and scenario
plotting/         one function per paper figure, plus compute_rmse_tables
data/             simulated tremor torques (simTAWERef.mat), alternative vertex set
results/paper/    saved runs behind the published figures and tables
results/rerun/    where your reruns are written (git-ignored)
external/qpSWIFT/ bundled QP solver (GPL-3.0)
```

## Paper ↔ code map

| Paper | Simulation script(s) | Plot / table |
|---|---|---|
| Sec. 3, Eqs. (1)–(10): constrained, reduced dynamics | `model/` (`System_TAWE`, `Flow_TAWE`, `TAWE_Lin_Files/`) | – |
| Sec. 4.2, Eq. (16): RMPC QP | `controllers/mpc_RMPC2n.m` | – |
| Sec. 4.3: state-dependent vertex weighting | `controllers/compute_vertex_weights.m` | – |
| Sec. 5.1, Fig. 6: uncertainty set | `uncertainty/build_uncertainty_set.m`, `uncertainty_vertices.m` | `plot_fig6_uncertainty` |
| Fig. 7a / 7b, Table 2 | `sim_MPC`, `sim_NMPC`, `sim_MPC_NDO`, `sim_RMPC` with `scenario = 'setpoint'` / `'sine'` | `plot_fig7_tracking`, `compute_rmse_tables` |
| Fig. 8 | `sim_MPC_NDO`, `sim_RMPC` (set-point) | `plot_fig8_ndo` |
| Table 3 (n_W sensitivity) | `sim_RMPC` with a 5- or 6-vertex set (see notes) | `compute_rmse_tables` |
| Sec. 6.1, Fig. 9a, Table 4 | `sim_MPC_NDO_delay`, `sim_RMPC_delay` | `plot_fig9_delay_noise` |
| Sec. 6.2, Fig. 9b, Table 4 | `sim_MPC_NDO_noise`, `sim_RMPC_noise` | `plot_fig9_delay_noise` |
| Sec. 6.3, Figs. 10–11, Table 4 | `sim_MPC_NDO_exp`, `sim_RMPC_exp` (need participant data) | `plot_fig10_11_experimental` |

Each simulation script accepts optional workspace variables set before it
runs: `scenario`, `seed` (default `0`), and for RMPC `vertexSet`
(`'paper'` or `'minRn2'`).

## Data availability

The experimental-tremor runs (Sec. 6.3) are driven by wrist encoder data from a
participant with essential tremor, recorded under Virginia Tech IRB protocols
#23-769 and #24-1304. That recording is **not** distributed here. The resulting
simulated joint trajectories and control inputs are included in
`results/paper/`, so Figs. 10(b) and 11 and the Table 4 experimental column can
be reproduced. The disturbance torque in Fig. 10(a) is derived directly from
the recording and is therefore omitted. See `data/private/README.md`.

## Reproducibility notes

The results in `results/paper/` were matched to the paper by recomputing RMSE
from each saved run (`compute_rmse_tables`):

| Paper entry | Shipped run vs. paper (rad) |
|---|---|
| Table 2 (all controllers) | within ±0.001 |
| Table 3, n_W = 4 and 5 | within ±0.001 |
| Table 3, n_W = 6 | 0.070 / 0.041 (to be updated in the published version) |
| Table 4, experimental | within ±0.001 |
| Table 4, delay | within ±0.002 (see *Randomness*) |
| Table 4, noise | within ±0.006 (see *Randomness*) |

Things to know when rerunning:

- **Uncertainty vertices.** `uncertainty_vertices('paper')` regenerates the
  vertices from the values in Sec. 5.1, so reruns are close to, but not
  bit-identical with, the published numbers. For Table 3,
  `build_uncertainty_set(nW)` regenerates the 5- and 6-vertex sets in the same
  way.
- **Randomness.** The delay and noise studies use random realizations, which
  accounts for the small Table 4 differences. All scripts call `rng(seed)`
  (default `0`), so reruns are repeatable but use different realizations from
  the published runs.
- **Fig. 10.** Figs. 10–11 are redrawn from the runs reported in Table 4, so
  small visual differences from the printed figures are possible.
- **Vertex weighting.** The normalized weights from `compute_vertex_weights`
  are multiplied by a constant gain before entering the QP (3.5 for the
  simulated-tremor studies, 1.5 for the patient-derived profile). See the
  function for implementation details.
- **Model derivation.** `model/derivation/` holds the scripts that produced the
  symbolic model, `TAWE_Lin_Files/`, and the CasADi NMPC function. They are
  included as they were used and have not been re-run in this repository
  layout. The generated outputs they produce are already in `model/`.

## Acknowledgements

This material is based upon work supported by the National Science Foundation
under Grant No. 2306984. The multibody modeling library in `lib/ANDY/` and the
original TAWE model were developed by Jiamin Wang and Oumar Barry
(Robotics & Mechatronics Lab, Virginia Tech), introduced in:

> J. Wang and O. R. Barry, "Multibody Analysis and Control of a Full-Wrist
> Exoskeleton for Tremor Alleviation," *Journal of Biomechanical Engineering*,
> vol. 142, no. 12, 121008, 2020. [doi:10.1115/1.4047424](https://doi.org/10.1115/1.4047424)

## Citation

See `CITATION.cff`. The DOI will be added once the paper is published.

## License

MIT; see `LICENSE`. The bundled qpSWIFT solver in `external/qpSWIFT/` is
GPL-3.0 and keeps its own license; CasADi (not bundled) is LGPL-3.0.
