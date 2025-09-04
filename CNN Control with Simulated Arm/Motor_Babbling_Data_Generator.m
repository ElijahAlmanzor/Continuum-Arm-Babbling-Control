% MOTOR BABBLING SCRIPT TO GENERATE TRAINING DATA

%% Motor babbling variables
F_cur_initial = zeros(3, 4);        % Starting force
F_delta       = rand(1, 6) * 150;   % Generate a random trajectory to go to
last_t        = 0;                  % Switch to a new pose after every 5 seconds

counter = 1;

%% Variables for collecting the data
model_name = "upside_downCA_control_six_springs"; %Loads a version that generates motor babbling data
simOut     = sim(model_name);

angle  = simOut.yout{1}.Values.angle.data;
axis   = simOut.yout{1}.Values.axis.data;
x      = simOut.yout{1}.Values.x.data;
y      = simOut.yout{1}.Values.y.data;
z      = simOut.yout{1}.Values.z.data;
forces = simOut.yout{2}.Values.data;

%% Save training data as video
smwritevideo( ...
    'Motor_babbling', ...
    'x_s_training_data_video', ...
    'PlaybackSpeedRatio', 1.0, ...
    'FrameRate', 50, ...
    'VideoFormat', 'uncompressed avi' ...
);

%% Save forces as .mat file
save('x_s_training_data_forces');
