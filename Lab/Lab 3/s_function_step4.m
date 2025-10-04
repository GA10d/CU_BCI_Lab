function s_function_template (block)
% Level-2 MATLAB file S-Function for times two demo.
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 

setup(block);
function setup(block)  
  %% Register number of input and output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
  block.InputPort(1).DirectFeedthrough = true;  
  %% Set block sample time to inherited
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';
 
  %% Register methods
  block.RegBlockMethod('Start',@Start);
  block.RegBlockMethod('Outputs',                 @Output);  
end

function Start(block)
  disp('Running...')
  global CurrentTime
  CurrentTime = 0;
end

function Output(block)
  global CurrentTime
  % get the input of s-function 
  input_data = block.InputPort(1).Data;

  % Use custom refresh rate
  if get(block, 'CurrentTime') - CurrentTime > 0.1
      CurrentTime = get(block, 'CurrentTime');
    
      % Do thing here
      bar(input_data);
      axis([0 2 0 10]);
      drawnow;
  end

end
end