warning('off','all');
warning;

% Load the image data
input  = fileDatastore('train_data_input',  'ReadFcn', @load, 'FileExtensions', '.mat');
output = fileDatastore('train_data_output', 'ReadFcn', @load, 'FileExtensions', '.mat');
input_t  = transform(input,  @(data) rearrange_datastore_input(data));
output_t = transform(output, @(data) rearrange_datastore_output(data));

train = combine(input_t, output_t);


layers = [ ...
    imageInputLayer([128 128 3], 'Normalization', 'rescale-zero-one')
    convolution2dLayer(2, 256, 'Padding', 'same', 'Stride', 1, 'Name', 'conv1')
    reluLayer('Name', 'relu1')
    maxPooling2dLayer(2, 'Stride', 1, 'Name', 'convfe2')
    convolution2dLayer(2, 128, 'Stride', 1, 'Name', 'conv2')
    reluLayer('Name', 'relu2')
    maxPooling2dLayer(2, 'Stride', 1, 'Name', 'conerfe2')
    convolution2dLayer(2, 64,  'Stride', 1, 'Name', 'conv2a')
    reluLayer('Name', 'relu3')
    % dropoutLayer
    convolution2dLayer(2, 64,  'Stride', 1, 'Name', 'coenv2a')
    reluLayer('Name', 'relu3t')
    % maxPooling2dLayer(2, 'Stride', 2)
    convolution2dLayer(2, 32,  'Stride', 1, 'Name', 'conv4')
    reluLayer('Name', 'relu5')
    convolution2dLayer(2, 32,  'Stride', 1, 'Name', 'co4nv4')
    reluLayer('Name', 'rel455')
    % dropoutLayer
    fullyConnectedLayer(6)
    regressionLayer ...
];

miniBatchSize = 256;
options = trainingOptions('adam', ...
    'MiniBatchSize', miniBatchSize, ...
    'MaxEpochs', 5000, ...
    'InitialLearnRate', 0.1*1e-3, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.99, ...
    'LearnRateDropPeriod', 7, ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu', ...
    'Verbose', true ...
);

[net, info] = trainNetwork(train, layers, options);


%Data Augmentation Functions Below
function image = rearrange_datastore_input(data)
    image = data.cur_input_bin;
    asd = size(image);

    % random speckled noise
    image(:,:,1,:) = image(:,:,1,:) + randi(110, 128, 128, 1, asd(4));
    image(:,:,3,:) = image(:,:,3,:) + randi(110, 128, 128, 1, asd(4));

    % affine transforms on current state
    val  = rand;
    val2 = rand;

    if val > 0.75
        tx = randn*20; ty = randn*20;
        A = [1 0 tx; 0 1 ty; 0 0 1];
        tform = affinetform2d(A);
        image(:,:,1,:) = imwarp(image(:,:,1,:), tform, 'OutputView', imref2d(size(image(:,:,1,:))));
    elseif val > 0.5
        tx = 0; ty = 0;
        A = [1 tx 0; ty 1 0; 0 0 1];
        cx = randi([40, 60]); cy = randi([40, 60]);
        sx = randi([10, 40]); sy = randi([10, 40]);
        op = rand;
        for i = 1:asd(4)
            t_im = insertShape(image(:,:,1,i), "filled-rectangle", [cx cy sx sy], Opacity = op, Color = "black");
            image(:,:,1,i) = t_im(:,:,1);
        end
    elseif val > 0.25
        tx = 0; ty = 0;
        A = [1 tx 0; ty 1 0; 0 0 1];
        tform = affinetform2d(A);
        image(:,:,1,:) = imwarp(image(:,:,1,:), tform, 'OutputView', imref2d(size(image(:,:,1,:))));
    else
        tx = rand/2 * randsample([-1, 1], true);
        A = [cos(tx) -sin(tx) 0; sin(tx) cos(tx) 0; 0 0 1];
        tform = affinetform2d(A);
        image(:,:,1,:) = imwarp(image(:,:,1,:), tform, 'OutputView', imref2d(size(image(:,:,1,:))));
    end

    % transforms on target state
    if val2 > 0.67
        tx = randn*20; ty = randn*20;
        A = [1 0 tx; 0 1 ty; 0 0 1];
        tform = affinetform2d(A);
        image(:,:,3,:) = imwarp(image(:,:,3,:), tform, 'OutputView', imref2d(size(image(:,:,3,:))));
    elseif val2 > 0.33
        x3 = randi([90, 96]);  y3 = randi([115, 117]);
        x4 = randi([27, 39]);  y4 = randi([113, 117]);
        for i = 1:asd(4)
            cur_im = image(:,:,3,i);
            [row, col] = find(cur_im < 80);
            col = sort(col);
            x1 = randi([26, 58]);
            y1 = randi([col(1), col(1) + 5]);
            x2 = randi([84, 100]);
            y2 = randi([col(1), col(1) + 5]);
            t_im = insertShape(image(:,:,3,i), "filledpolygon", [x1 y1 x2 y2 x3 y3 x4 y4], Opacity = 1, Color = [255 255 255]);
            image(:,:,3,i) = t_im(:,:,1);
        end
    else
        tx = 0; ty = 0;
        A = [1 tx 0; ty 1 0; 0 0 1];
        tform = affinetform2d(A);
        image(:,:,3,:) = imwarp(image(:,:,3,:), tform, 'OutputView', imref2d(size(image(:,:,3,:))));
    end

    image = num2cell(image, 1:3);
    image = image(:);
end

function labels = rearrange_datastore_output(data)
    labels = data.cur_output_bin;
    labels = num2cell(labels, 1);
    labels = labels(:);
end
