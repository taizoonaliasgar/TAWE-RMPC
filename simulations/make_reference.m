function [refData, refdtData] = make_reference(scenario, tSpan1, hor)
%MAKE_REFERENCE  Joint reference [q_RUD; q_FE] and its time derivative.
%
%   'setpoint' - constant q_ref = [0.2; 0] rad (Sec. 5.3, task 1); also
%                used by the 'delay' and 'noise' scenarios (Sec. 6.1-6.2)
%   'sine'     - same set-point with a sinusoidal excursion between 3 s and
%                7 s (Sec. 5.3, task 2)
%   'exp'      - zero reference, used with patient-derived tremor (Sec. 6.3)

n = numel(tSpan1) + hor + 1;

switch lower(scenario)
    case 'exp'
        refData   = zeros(2, n);
        refdtData = zeros(2, n);
    case {'setpoint', 'sine', 'delay', 'noise'}
        refData   = repmat([0.2; 0], 1, n);
        refdtData = zeros(2, n);
        if strcmpi(scenario, 'sine')
            k = 151:351;                       % t = 3 s ... 7 s at 50 Hz
            t = tSpan1(k) - 3;
            refData(1, k)   = 0.2 - 0.2*sin(0.5*pi*t);
            refdtData(1, k) =      -0.2*0.5*pi*cos(0.5*pi*t);
            refData(2, k)   =       0.1*sin(0.5*pi*t);
            refdtData(2, k) =       0.1*0.5*pi*cos(0.5*pi*t);
        end
    otherwise
        error('make_reference:unknownScenario', ...
              'Unknown scenario "%s". Use ''setpoint'', ''sine'' or ''exp''.', scenario);
end
end
