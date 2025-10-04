function tone_trigger_sfunc_oddball(block)

setup(block);

% ============================================================
function setup(block)

    % 输入端口
    block.NumInputPorts  = 0;
    % 输出端口（trigger, sampleCount）
    block.NumOutputPorts = 3;   
    
    block.SetPreCompPortInfoToDefaults;
    block.OutputPort(1).SamplingMode = 'Sample';
    block.OutputPort(2).SamplingMode = 'Sample';
    block.OutputPort(3).SamplingMode = 'Sample';

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
    block.NumDworks = 5;

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

    %  count - 500 hz
    block.Dwork(3).Name            = 'F500HzCount';
    block.Dwork(3).Dimensions      = 1;
    block.Dwork(3).DatatypeID      = 0;      % double
    block.Dwork(3).Complexity      = 'Real';
    block.Dwork(3).UsedAsDiscState = true;

    % count - 900 hz
    block.Dwork(4).Name            = 'F900HzCount';
    block.Dwork(4).Dimensions      = 1;
    block.Dwork(4).DatatypeID      = 0;      % double
    block.Dwork(4).Complexity      = 'Real';
    block.Dwork(4).UsedAsDiscState = true;

    % 0 - 500hz|1 - 900hz work for output
    block.Dwork(5).Name            = 'OutputFlag';
    block.Dwork(5).Dimensions      = 1;
    block.Dwork(5).DatatypeID      = 0;      
    block.Dwork(5).Complexity      = 'Real';
    block.Dwork(5).UsedAsDiscState = true;
end

% ============================================================
function InitConditions(block)
    block.Dwork(1).Data = 0;  % 重置sampleCount
    block.Dwork(2).Data = 0;  % 初始未播放
    block.Dwork(3).Data = 0;
    block.Dwork(4).Data = 0;
    block.Dwork(5).Data = 0;
end

% ============================================================
function Output(block)
    % output1：trigger 0-no audio 1-500hz 2-900hz
    if block.Dwork(2).Data == 1 && block.Dwork(5).Data == 0
        block.OutputPort(1).Data = 1;
    elseif block.Dwork(2).Data == 1 && block.Dwork(5).Data == 1
        block.OutputPort(1).Data = 2;
    else
        block.OutputPort(1).Data = 0;
    end
    
    block.OutputPort(2).Data = block.Dwork(3).Data;
    block.OutputPort(3).Data = block.Dwork(4).Data;
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
        if rand(1) < 0.85
            f = 500; % standard
            block.Dwork(3).Data = block.Dwork(3).Data + 1;
            block.Dwork(5).Data = 0;
        else
            f = 900; % deviant
            block.Dwork(4).Data = block.Dwork(4).Data + 1;
            block.Dwork(5).Data = 1;
        end
        block.Dwork(2).Data = 1;
        % 生成音频
        t = (0:samplesPerTone-1)/fs;
        y = sin(2*pi*f*t);
        sound(y, fs);   % 播放
        
    end
    
    % 超过音长则关闭trigger
    if mod(n, samplesPerInterval) > samplesPerTone
        block.Dwork(2).Data = 0;
    end
end
end