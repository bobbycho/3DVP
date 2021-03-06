function [ap, bestf] = compute_aps(path, style)

filename = [path '/plot/car_detection.txt'];

data = load(filename);

recall = data(:,1);
precision_easy = data(:,2);
precision_moderate = data(:,3);
precision_hard = data(:,4);

hold on;
plot(recall, precision_easy, ['r' style], 'linewidth', 2);
plot(recall, precision_moderate, ['g' style], 'linewidth', 2);
plot(recall, precision_hard, ['b' style], 'linewidth', 2);
hold off;

ap(1) = VOCap(recall, precision_easy);
fprintf('AP_easy = %.4f\n', ap(1));

ap(2) = VOCap(recall, precision_moderate);
fprintf('AP_moderate = %.4f\n', ap(2));

ap(3) = VOCap(recall, precision_hard);
fprintf('AP_hard = %.4f\n', ap(3));

bestf(1) = max(2 .* (recall .* precision_easy) ./ (recall + precision_easy));
%fprintf('BF1_easy = %.4f\n', bestf(1));
bestf(2) = max(2 .* (recall .* precision_moderate) ./ (recall + precision_moderate));
%fprintf('BF1_moderate = %.4f\n', bestf(2));
bestf(3) = max(2 .* (recall .* precision_hard) ./ (recall + precision_hard));
%fprintf('BF1_hard = %.4f\n', bestf(3));

end
