% MAKE SURE TO LOAD THE corresponding .mat file containing the forces
% Load the video training data
v = VideoReader('60_s_training_data.avi');
k = 50;                                % Sampling step

bin_size    = 50;                      % Adjust later for larger set
num_of_bins = ceil(v.NumFrames/(k*bin_size))
bin_counter = 1;
counter     = 1;
cur_input_bin  = [];
cur_output_bin = [];

% Ensure output folders exist
in_dir  = 'train_data_input';
out_dir = 'train_data_output';
if ~exist(in_dir, 'dir');  mkdir(in_dir);  end
if ~exist(out_dir, 'dir'); mkdir(out_dir); end

for i = 1:k:v.NumFrames
    % Save a bin when full, or if at the last bin near the end of frames
    if mod(counter, bin_size+1) == 0 | and(bin_counter >= num_of_bins, i + k >= v.NumFrames)
        save(fullfile(in_dir,  string(bin_counter) + ".mat"), "cur_input_bin")
        save(fullfile(out_dir, string(bin_counter) + ".mat"), "cur_output_bin")

        cur_input_bin  = [];
        cur_output_bin = [];
        counter        = 1;
        bin_counter    = bin_counter + 1;
    end

    if i + k >= v.NumFrames
        break
    end

    % Inputs
    I_i = read(v, i);
    I_i = imresize(I_i, [128 128]);
    I_i = im2gray(I_i);

    I_i_plus_1 = read(v, i + k);
    I_i_plus_1 = imresize(I_i_plus_1, [128 128]);
    I_i_plus_1 = im2gray(I_i_plus_1);

    % Force image (normalise to 0–255 and make 128x128)
    force_as_image = repmat(forces(:, :, i), 43, 32);
    force_as_image = force_as_image(1:128, 1:128);
    force_as_image = uint8((force_as_image ./ 150) .* 255);

    input_i = uint8(cat(3, I_i, force_as_image, I_i_plus_1));
    cur_input_bin(:, :, :, counter) = input_i;

    imshow(input_i)

    % Outputs
    output_i_plus_1 = [ ...
        forces(1, 1, i + k)
        forces(1, 3, i + k)
        forces(2, 1, i + k)
        forces(2, 3, i + k)
        forces(3, 1, i + k)
        forces(3, 3, i + k) ]';
    cur_output_bin(:, counter) = output_i_plus_1;

    counter
    counter = counter + 1;
end
