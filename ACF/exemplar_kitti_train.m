function detector = exemplar_kitti_train(cls, name, data, ind, cid, is_train, is_continue, is_pascal)

exemplar_globals;

if is_pascal
    [pos, neg] = exemplar_pascal_data(cls, data, cid, is_train, is_continue);
else
    [pos, neg] = exemplar_kitti_data(cls, data, cid, is_train, is_continue);
end

if is_pascal
    is_truncated = data.trunc_per(cid) > 0.1;    
else
    is_truncated = data.truncation(cid) > 0.1;
end

% set up opts for training detector (see acfTrain)
opts = exemplar_acf_train();
modelDs = compute_model_size(pos);
opts.modelDs = modelDs;
if is_truncated
    opts.modelDsPad = modelDs;
else
    opts.modelDsPad = round(1.2*modelDs);
end
opts.pos = pos;
opts.neg = neg;
opts.nWeak = [32 128 512 2048];
opts.pJitter = struct('flip', 0);
opts.pBoost.pTree.fracFtrs = 1/16;
opts.pLoad = {'squarify', {3,.41}};
opts.name = sprintf('%s%s_%d', cachedir, cls, cid);
opts.cascThr = -1;
opts.is_continue = is_continue;
if is_pascal
    opts.overlap_neg = max(0, 0.4 - data.trunc_per(cid));
else
    opts.overlap_neg = max(0, 0.6 - data.truncation(cid));
end
opts.is_truncated = is_truncated;
opts.is_hadoop = is_hadoop;

% train detector (see acfTrain)
detector = exemplar_acf_train( opts );

% save detector
filename = fullfile(resultdir, sprintf('%s_%s_%d_final.mat', cls, name, ind));
save(filename, 'detector');


function modelDs = compute_model_size(pos)

% pick mode of aspect ratios
h = [pos(:).y2]' - [pos(:).y1]' + 1;
w = [pos(:).x2]' - [pos(:).x1]' + 1;
xx = -2:.02:2;
filter = exp(-[-100:100].^2/400);
aspects = hist(log(h./w), xx);
aspects = convn(aspects, filter, 'same');
[~, I] = max(aspects);
aspect = exp(xx(I));

% pick 20 percentile area
areas = sort(h.*w);
area = areas(max(floor(length(areas) * 0.2), 1));
area = max(min(area, 10000), 500);

% pick dimensions
w = sqrt(area/aspect);
h = w*aspect;
modelDs = round([h w]);