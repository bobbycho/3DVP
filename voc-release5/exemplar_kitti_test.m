function exemplar_kitti_test(cls, cid, is_train, is_continue, is_pascal)

if is_pascal
    resultdir = 'PASCAL/';
else
    resultdir = 'KITTI/';
end

% load model
model_name = sprintf('%s/%s_%d_final.mat', resultdir, cls, cid);
object = load(model_name);
model = object.model;
model.thresh = min(-1, model.thresh);

% KITTI path
conf = voc_config;

if is_pascal
else
    root_dir = conf.kitti.root;
    if is_train == 1
        data_set = 'training';
    else
        data_set = 'testing';
    end

    % get sub-directories
    cam = 2; % 2 = left color camera
    image_dir = fullfile(root_dir, [data_set '/image_' num2str(cam)]); 

    % get test image ids
    object = load('kitti_ids.mat');
    if is_train == 1
        ids = object.ids_val;
    else
        ids = object.ids_test;
    end
end

filename = sprintf('%s/%s_%d_test.mat', resultdir, cls, cid);

% run detector in each image
if is_continue && exist(filename, 'file')
    load(filename);
else
    N = numel(ids);
    parfor i = 1:N
        fprintf('%s: center %d: %d/%d\n', cls, cid, i, N);
        img_idx = ids(i);
        file_img = sprintf('%s/%06d.png', image_dir, img_idx);
        im = imread(file_img);
        [dets, boxes] = imgdetect(im, model, model.thresh);
    
        if ~isempty(boxes)
            boxes = reduceboxes(model, boxes);
            [dets, boxes] = clipboxes(im, dets, boxes);
            % without non-maximum suppression
            boxes1{i} = dets(:, [1:4 end]);
            parts1{i} = boxes;
        else
            boxes1{i} = [];
            parts1{i} = [];
        end
    end  
    save(filename, 'boxes1', 'parts1');
end