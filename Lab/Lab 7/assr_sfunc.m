function assr_sfunc(block)
% ===============================================================
% Simple self-timed S-function for ASSR experiment
% - Wait 15s (flag=0)
% - Play sound file for 600s (flag=1)
% - Stop playback (flag=0)
% ===============================================================

setup(block);

end

function setup(block)
    block.NumInputPorts  = 0;
    block.NumOutputPorts = 1;

    block.OutputPort(1).Dimensions   = 1;
    block.OutputPort(1).SamplingMode = 'Sample';
    block.OutputPort(1).DataTypeId   = 0; % double

    block.SampleTimes = [0.001 0];  % 每1ms执行一次

    % 注册回调
    block.RegBlockMethod('Start',    @Start);
    block.RegBlockMethod('Outputs',  @Outputs);
    block.RegBlockMethod('Terminate',@Terminate);
end


% ===============================================================
% START：初始化，只执行一次
% ===============================================================
function Start(block)
    persistent y fs startTime delayTime playDuration isPlaying;
    [y, fs] = audioread('am_tone_40Hz.wav');  % 声音文件
    startTime = tic;      % 启动计时器
    delayTime = 15;       % 延迟15秒
    playDuration = 600;   % 播放600秒
    isPlaying = false;

    % 把变量存到 base workspace（便于 Outputs 使用）
    assignin('base', 'assr_vars', struct('y', y, 'fs', fs, ...
        'startTime', startTime, 'delayTime', delayTime, ...
        'playDuration', playDuration, 'isPlaying', isPlaying));

    disp('✅ Simple ASSR S-function initialized.');
end



function Outputs(block)
    % 取出状态变量
    vars = evalin('base', 'assr_vars');
    elapsed = toc(vars.startTime);
    flag = 0;

    % 阶段1：等待阶段
    if elapsed < vars.delayTime
        flag = 0;

    % 阶段2：播放阶段
    elseif elapsed < vars.delayTime + vars.playDuration
        if ~vars.isPlaying
            sound(vars.y, vars.fs);
            vars.isPlaying = true;
            assignin('base', 'assr_vars', vars);
            disp(['🎵 Sound started at t = ', num2str(elapsed, '%.2f'), ' s']);
        end
        flag = 1;

    else
        if vars.isPlaying
            clear sound;
            vars.isPlaying = false;
            assignin('base', 'assr_vars', vars);
            disp(['⏹️ Sound stopped at t = ', num2str(elapsed, '%.2f'), ' s']);
        end
        flag = 0;
    end

    % 输出flag
    block.OutputPort(1).Data = flag;
end


% ===============================================================
% TERMINATE：结束清理
% ===============================================================
function Terminate(block)
    clear sound;
    disp('Simulation finished. Sound cleared.');
end
