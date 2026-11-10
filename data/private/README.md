# Participant data (not distributed)

`sim_RMPC_exp.m` and `sim_MPC_NDO_exp.m` (Sec. 6.3 of the paper) are driven by
wrist encoder recordings from a participant with essential tremor, collected
under Virginia Tech IRB protocols #23-769 and #24-1304. That recording is not
part of this repository.

If you have authorized access to it, place it here as `Data2_ET0220.mat`, or
pass a path before running:

```matlab
patientDataFile = '/path/to/Data2_ET0220.mat';
sim_RMPC_exp
```

Everything in this folder except this README is git-ignored.
