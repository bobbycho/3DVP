function display_result_kitti

cls = 'car';
threshold = -0.9;

% read detection results
filename = sprintf('kitti_test/%s_test.mat', cls);
object = load(filename);
dets = object.dets;
fprintf('load detection done\n');

% read ids of validation images
object = load('kitti_ids.mat');
ids = object.ids_test;
N = numel(ids);

% KITTI path
globals;
root_dir = KITTIroot;
data_set = 'testing';
cam = 2;
image_dir = fullfile(root_dir, [data_set '/image_' num2str(cam)]);

figure;
ind_plot = 1;
for i = 1:N
    img_idx = ids(i);    
    det = dets{img_idx + 1};
    
    if isempty(det) == 1
        fprintf('no detection for image %d\n', img_idx);
        continue;
    end
    
    if max(det(:,6)) < threshold
        fprintf('maximum score %.2f is smaller than threshold\n', max(det(:,6)));
        continue;
    end
    num = size(det, 1);
    
    file_img = sprintf('%s/%06d.png',image_dir, img_idx);
    I = imread(file_img);
    
    subplot(4, 2, ind_plot);
    imshow(I);
    hold on;

    for k = 1:num
        if det(k,6) > threshold
            % get predicted bounding box
            bbox_pr = det(k,1:4);
            bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
            rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth', 2);
%             x = [bbox_pr(1) bbox_pr(3) bbox_pr(3) bbox_pr(1)];
%             y = [bbox_pr(2) bbox_pr(2) bbox_pr(4) bbox_pr(4)];
%             patch(x, y, 'g', 'FaceAlpha', 0.1, 'EdgeAlpha', 0);
            
%             text(bbox_pr(1), bbox_pr(2), num2str(k), 'FontSize', 16, 'BackgroundColor', 'r');
        end
    end
    subplot(4, 2, ind_plot);
    hold off;
    ind_plot = ind_plot + 1;
    if ind_plot > 8
        ind_plot = 1;
        pause;
    end
end