You will need the screencapture toolbox to get this to work! 
https://uk.mathworks.com/matlabcentral/fileexchange/24323-screencapture-screenshot-of-component-figure-or-screen?status=SUCCESS
1. Run: Motor_Babbling_Generator.m to generate data (I've also provided a 60 second pre-generated dataset)
2. Run:Save_Video_and_Force_Data.m to process data in a suitable manner for training
3. Run:Train_CNN_Controller.m to train on the data
4. Run:Test_CNN_network.m to test one of the pre-trained networks

Additional notes:
To get the image state feedback, MATLAB/SIMULINK takes a screenshot of your screen - so you will need to manually 
align the Simulink display to the box (either by moving the window or the image capture position). 

Sorry, this is very tricky, but it was only way I could find that allows to get the image feedback from MATLAB.
 
Make sure to change the background of the simulator to white too!