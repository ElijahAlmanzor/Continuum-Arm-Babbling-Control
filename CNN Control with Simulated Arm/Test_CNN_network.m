%VARIABLES TO GET TESTING STARTED
counter = 1;

%Initialise with zero forces
q_i = zeros(1,6);

%For the low pass filter
last_error = zeros(1,6);


%Initialise the goal
I_i_1 = load('train_data_input\1.mat','cur_input_bin');
I_i_1 = I_i_1.cur_input_bin;
I_i_1 = I_i_1(:,:,3,11); %Pick a random target


%RUN THE SIMULATION TO ACTUALLY GET RESULTS
model_name = "CNN_CA_control_six_springs";
simOut = sim(model_name);
angle = simOut.yout{1}.Values.angle.data;
axis = simOut.yout{1}.Values.axis.data;
x = simOut.yout{1}.Values.x.data;
y = simOut.yout{1}.Values.y.data;
z = simOut.yout{1}.Values.z.data;
forces = simOut.yout{2}.Values.data;




