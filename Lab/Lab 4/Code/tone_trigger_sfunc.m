function tone_trigger_sfunc(block)
% Level-2 MATLAB S-function to play 500Hz, 100ms tone every 0.7s
% and generate a trigger signal

setup(block);

% ============================================================
function setup(block)

    % Register number of ports
    block.NumInputPorts  = 0;
    block.NumOutputPorts = 1;   % 1 output: trigger signal
    
    % Setup output port
    block.SetPreCompPortInfoToDefaults;
    block.OutputPort(1).SamplingMode = 'Sample';
    
    % Set block sample time (discrete)
    fs = 44100;  % audio sampling rate
    block.SampleTimes = [1/fs 0];  % sample period = 1/fs
    
    block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
    
    % Register block methods
    block.RegBlockMethod('InitializeConditions', @InitConditions);
    block.RegBlockMethod('Outputs',              @Output); 
    block.RegBlockMethod('Update',               @Update); 

% ============================================================
function DoPostPropSetup(block)
    % 定义 Dworks (状态变量)
    block.NumDworks = 2;

    % Counter for sample index
    block.Dwork(1).Name            = 'sampleCount';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;      % double
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;

    % Flag if currently playing tone
    block.Dwork(2).Name            = 'playing';
    block.Dwork(2).Dimensions      = 1;
    block.Dwork(2).DatatypeID      = 0;
    block.Dwork(2).Complexity      = 'Real';
    block.Dwork(2).UsedAsDiscState = true;

% ============================================================
function InitConditions(block)
    block.Dwork(1).Data = 0;  % reset counter
    block.Dwork(2).Data = 0;  % not playing initially

% ============================================================
function Output(block)
    % Output trigger
    if block.Dwork(2).Data == 1
        block.OutputPort(1).Data = 1;
    else
        block.OutputPort(1).Data = 0;
    end

% ============================================================
function Update(block)
    fs = 44100;     % sampling rate
    f = 500;        % frequency Hz
    dur = 0.1;      % tone duration (s)
    interval = 0.7; % repeat interval (s)
    
    samplesPerTone = round(dur * fs);
    samplesPerInterval = round(interval * fs);

    % Sample counter update
    block.Dwork(1).Data = block.Dwork(1).Data + 1;
    n = block.Dwork(1).Data;

    % Start new tone?
    if mod(n, samplesPerInterval) == 1
        block.Dwork(2).Data = 1;
        % Generate tone
        t = (0:samplesPerTone-1)/fs;
        y = sin(2*pi*f*t);
        sound(y, fs);   % play tone
    end
    
    % Stop trigger after tone finished
    if mod(n, samplesPerInterval) > samplesPerTone
        block.Dwork(2).Data = 0;
    end
