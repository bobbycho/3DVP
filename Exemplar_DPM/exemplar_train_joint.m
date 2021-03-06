function model = exemplar_train_joint(cls, name, data, centers, note, is_train, is_continue, is_pascal, overlap)

% model = kitti_train(cls, data, cid, note)
% Train a model with 1 component using the KITTI dataset.
% note allows you to save a note with the trained model
% example: note = 'testing FRHOG (FRobnicated HOG)

% At every "checkpoint" in the training process we reset the 
% RNG's seed to a fixed value so that experimental results are 
% reproducible.
initrand();

globals; 
if is_pascal
    [pos, neg, spos] = exemplar_pascal_data_joint(cls, name, data, centers, is_train, is_continue);
else
    [pos, neg, spos] = kitti_data_joint(cls, name, data, centers, is_train, is_continue);
end

cachesize = 24000;
maxneg = min(200, numel(neg));

% train root filter using warped positives & random negatives
filename = [cachedir cls '_' name '_root.mat'];
if is_continue && exist(filename, 'file')
  load(filename);
else
  initrand();
  for i = 1:numel(spos)
    models{i} = initmodel(cls, spos{i}, note, 'N');
    models{i}.symmetric = 0;
    models{i} = train([cls '_' name], models{i}, spos{i}, neg, i, 1, 1, 1, ...
                      cachesize, true, overlap, false, ['root_' num2str(i)]);
  end
                  
  save(filename, 'models');
end

% train root filter using latent detections & hard negatives
filename = [cachedir cls '_' name '_mix.mat'];
if is_continue && exist(filename, 'file')
  load(filename);
else
  initrand();
  model = mergemodels(models);
  model.overlap_neg = 0.2;
  model = train([cls '_' name], model, pos, neg(1:maxneg), 0, 0, 1, 5, ...
                cachesize, true, overlap, false, 'mix');
            
%   model = train(cls, model, pos, neg(1:maxneg), 0, 0, 8, 10, ...
%                 cachesize, true, 0.7, false, 'mix_1');
%   model = train(cls, model, pos, neg, 0, 0, 1, 5, ...
%                 cachesize, true, 0.7, true, 'mix_2');            
            
  save(filename, 'model');
end

% add parts and update model using latent detections & hard negatives.
filename = [cachedir cls '_' name '_parts.mat'];
if is_continue && exist(filename, 'file')
  load(filename);
else
  initrand();
  for i = 1:numel(spos)
      if min(model.filters(i).size) > 3
        model = model_addparts(model, model.start, i, i, 8, [6 6]);
      else
        model = model_addparts(model, model.start, i, i, 8, [3 3]);
      end
  end
  model = train([cls '_' name], model, pos, neg(1:maxneg), 0, 0, 8, 10, ...
                cachesize, true, overlap, false, 'parts_1');
  model = train([cls '_' name], model, pos, neg, 0, 0, 1, 5, ...
                cachesize, true, overlap, true, 'parts_2');
  save(filename, 'model');
end

model.centers = centers;
save([resultdir cls '_' name '_final.mat'], 'model');