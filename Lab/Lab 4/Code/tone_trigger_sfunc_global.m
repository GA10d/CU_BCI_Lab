function tone_trigger_sfunc_global(block)
% 用 global 保存计数器和trigger

setup(block);

function setup(block)
    block.NumInputPorts  = 0;
    block.NumOutputPorts = 2;   % trigger + sampleCount
    
    block.SetPreCompPortInfoToDefaults;
    block.SampleTimes = [1/44100 0];  % 采样时间
    
    block.RegBlockMethod('Start',    @Start);
    block.RegBlockMethod('Outputs',  @Output);
    block.RegBlockMethod('Update',   @Update);

function Start(block)
    global sampleCount playing 
    global soundCount
    sampleCount = 0;
    soundCount = 0;
    playing = 0;

function Output(block)
    global sampleCount playing 
    global soundCount
    % 输出 trigger
    block.OutputPort(1).Data = playing;
    % 输出 sampleCount（保持 double 类型，避免报错）
    block.OutputPort(2).Data = soundCount;

function Update(block)
    global sampleCount playing soundCount
    fs = 44100; f = 500; dur = 0.1; interval = 0.7;
    samplesPerTone = round(dur*fs);
    samplesPerInterval = round(interval*fs);
    
    % 计数器 +1
    sampleCount = sampleCount + 1;

    % 播放条件
    if mod(sampleCount, samplesPerInterval) == 1
        playing = 1;
        t = (0:samplesPerTone-1)/fs;
        y = sin(2*pi*f*t);
        sound(y, fs);
        soundCount = soundCount +1;
    end

    % 超过tone长度，结束trigger
    if mod(sampleCount, samplesPerInterval) > samplesPerTone
        playing = 0;
    end
