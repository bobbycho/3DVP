function compute_recall_precision_kitti_cpp

globals;
pascal_init;

command = './evaluate_object results_kitti_train';
system(command);

filename = 'results_kitti_train/plot/car_detection.txt';
data = load(filename);

recall = data(:,1);
precision_easy = data(:,2);
precision_moderate = data(:,3);
precision_hard = data(:,4);

ap_easy = VOCap(recall, precision_easy);
fprintf('AP_easy = %.4f\n', ap_easy);

ap_moderate = VOCap(recall, precision_moderate);
fprintf('AP_moderate = %.4f\n', ap_moderate);

ap = VOCap(recall, precision_hard);
fprintf('AP_hard = %.4f\n', ap);

% draw recall-precision and accuracy curve
figure(1);
hold on;
plot(recall, precision_easy, 'g', 'LineWidth',3);
plot(recall, precision_moderate, 'b', 'LineWidth',3);
plot(recall, precision_hard, 'r', 'LineWidth',3);
h = xlabel('Recall');
set(h, 'FontSize', 12);
h = ylabel('Precision');
set(h, 'FontSize', 12);
tit = sprintf('Car APs');
h = title(tit);
set(h, 'FontSize', 12);
hold off;