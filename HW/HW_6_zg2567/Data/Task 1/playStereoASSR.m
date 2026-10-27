function playStereoASSR(block)
% Looping Stereo ASSR playback with configurable duration
%
% - Waits 15 s before starting
% - Plays sound repeatedly during playDuration seconds
% - Output = 1 while playback is active, otherwise 0

    block.NumInputPorts  = 0;
    block.NumOutputPorts = 1;

    block.OutputPort(1).DatatypeID  = 0;
    block.OutputPort(1).Complexity  = 'Real';
    block.OutputPort(1).SamplingMode = 'Sample';

    block.SampleTimes = [1/8000 0];  % Run at audio-rate timing

    block.RegBlockMethod('Start',   @Start);
    block.RegBlockMethod('Outputs', @Outputs);
    block.RegBlockMethod('Terminate',@Terminate);
end


% ===============================================================
% START: Runs once at simulation start
% ===============================================================
function Start(block)
    persistent vars;
    S = load('StereoASSR_sound.mat');  % Must contain w (2-by-N)
    
    vars.w = S.w;
    vars.fs = 8000;
    vars.delayTime = 15;             % Start playback after 15 s
    vars.playDuration = 320;         % Configurable: seconds
    vars.startClock = tic;           % Real-world timer
    vars.isPlaying = false;
    vars.stage = -1;                 % 用来记录当前阶段

    assignin('base', 'assr_loop_vars', vars);
    disp('[INIT] ASSR looping S-function initialized.');
end


% ===============================================================
% OUTPUTS: Runs continuously
% ===============================================================
function Outputs(block)
    vars = evalin('base', 'assr_loop_vars');
    elapsed = toc(vars.startClock);
    flag = 0;

    % 阶段1：等待15秒
    if elapsed < vars.delayTime
        
        if vars.stage ~= 1
            fprintf(1, '[WAIT] t = %.2f s → Waiting before playback...\n', elapsed);

            vars.stage = 1;
            assignin('base', 'assr_loop_vars', vars);
        end
        
        flag = 0;

    % 阶段2：播放窗口内（循环播放）
    elseif elapsed < vars.delayTime + vars.playDuration
        
        if vars.stage ~= 2
            fprintf(1, '🎵 Sound (re)started at t = %.2f s\n', elapsed);
            vars.stage = 2;
            assignin('base', 'assr_loop_vars', vars);
        end

        flag = 1;

        % 如果当前没有在播放 → 立即播放
        if ~vars.isPlaying
            sound(vars.w', vars.fs);
            vars.isPlaying = true;
            assignin('base', 'assr_loop_vars', vars);
            disp(['  🎵 Sound (re)started at t = ', num2str(elapsed, '%.2f'), ' s']);
        end

    % 阶段3：播放结束，停止声音
    else
        
        if vars.stage ~= 3
            fprintf(1, '⏹️ Sound stopped at t = %.2f s\n', elapsed);

            vars.stage = 3;
            assignin('base', 'assr_loop_vars', vars);
        end

        if vars.isPlaying
            clear sound;
            vars.isPlaying = false;
            assignin('base', 'assr_loop_vars', vars);
            fprintf(1, '⏹️ Sound stopped at t = %.2f s\n', elapsed);
        end
        
        flag = 0;
    end

    % 输出 flag
    block.OutputPort(1).Data = flag;
end


% ===============================================================
% TERMINATE
% ===============================================================
function Terminate(block)
    clear sound;
    disp('[END] Simulation finished. Sound cleared.');
end
