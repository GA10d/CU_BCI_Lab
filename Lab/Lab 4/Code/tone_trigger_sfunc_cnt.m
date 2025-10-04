function tone_trigger_sfunc_cnt(block)
% Level-2 MATLAB S-function
% 每0.7秒播放一个100ms、500Hz正弦音
% 输出1：trigger (0/1)
% 输出2：sampleCount (int32)

setup(block);

% ============================================================
function setup(block)

    % 输入端口
    block.NumInputPorts  = 0;
    % 输出端口（trigger, sampleCount）
    block.NumOutputPorts = 2;   
    
    block.SetPreCompPortInfoToDefaults;
    block.OutputPort(1).SamplingMode = 'Sample';
    block.OutputPort(2).SamplingMode = 'Sample';


    % 设定采样时间（基于音频采样率）
    fs = 44100;  % 音频采样率
    block.SampleTimes = [1/fs 0];  % sample period = 1/fs
    
    % 注册方法
    block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions', @InitConditions);
    block.RegBlockMethod('Outputs',              @Output); 
    block.RegBlockMethod('Update',               @Update); 
end

% ============================================================
function DoPostPropSetup(block)
    % 定义Dworks（状态变量）
    block.NumDworks = 3;

    % Sample计数器
    block.Dwork(1).Name            = 'sampleCount';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;      % double
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;

    % 是否正在播放音
    block.Dwork(2).Name            = 'playing';
    block.Dwork(2).Dimensions      = 1;
    block.Dwork(2).DatatypeID      = 0;
    block.Dwork(2).Complexity      = 'Real';
    block.Dwork(2).UsedAsDiscState = true;

    % Sample计数器
    block.Dwork(3).Name            = 'soundCount';
    block.Dwork(3).Dimensions      = 1;
    block.Dwork(3).DatatypeID      = 0;      % double
    block.Dwork(3).Complexity      = 'Real';
    block.Dwork(3).UsedAsDiscState = true;
end

% ============================================================
function InitConditions(block)
    block.Dwork(1).Data = 0;  % 重置sampleCount
    block.Dwork(2).Data = 0;  % 初始未播放
    block.Dwork(3).Data = 0;
end

% ============================================================
function Output(block)
    % 输出1：trigger
    if block.Dwork(2).Data == 1
        block.OutputPort(1).Data = 1;
    else
        block.OutputPort(1).Data = 0;
    end
    
    block.OutputPort(2).Data = block.Dwork(3).Data;
end

% ============================================================
function Update(block)
    fs = 44100;     % 采样率
    f = 500;        % 音频频率 Hz
    dur = 0.1;      % 音频时长 (s)
    interval = 0.7; % 间隔 (s)
    
    samplesPerTone = round(dur * fs);
    samplesPerInterval = round(interval * fs);

    % Sample计数器递增
    block.Dwork(1).Data = block.Dwork(1).Data + 1;
    n = block.Dwork(1).Data;

    % 是否开始播放新tone
    if mod(n, samplesPerInterval) == 1
        block.Dwork(2).Data = 1;
        % 生成音频
        t = (0:samplesPerTone-1)/fs;
        y = sin(2*pi*f*t);
        sound(y, fs);   % 播放
        block.Dwork(3).Data = block.Dwork(3).Data + 1;
    end
    
    % 超过音长则关闭trigger
    if mod(n, samplesPerInterval) > samplesPerTone
        block.Dwork(2).Data = 0;
    end
end
end