% Set up global variables used throughout the code

% setup svm mex for context rescoring (if it's installed)
if exist('./svm_mex601') > 0
  addpath svm_mex601/bin;
  addpath svm_mex601/matlab;
end

% dataset to use
if exist('setVOCyear') == 1
  VOCyear = setVOCyear;
  clear('setVOCyear');
else
  VOCyear = '2012';
end

% directory for caching models, intermediate data, and results
cachedir = '/tmp/yuxiang/Projects/data/';
resultdir = 'data/';

if exist(cachedir) == 0
  unix(['mkdir -p ' cachedir]);
end

if exist(resultdir) == 0
  unix(['mkdir -p ' resultdir]);
end

if exist([cachedir 'learnlog/']) == 0
    unix(['mkdir -p ' cachedir 'learnlog/']);
end

% directory for LARGE temporary files created during training
tmpdir = '/tmp/yuxiang/Projects/data/';

if exist(tmpdir) == 0
  unix(['mkdir -p ' tmpdir]);
end

% should the tmpdir be cleaned after training a model?
cleantmpdir = true;

% directory with PASCAL VOC development kit and dataset
VOCpaths = {'/net/acadia/workplace/yuxiang/Projects/PASCAL3D+_release1.1/PASCAL', ...
    '/home/yuxiang/Projects/Pose_Dataset/PASCAL3D+_release1.1/PASCAL', ...
    '/scratch/yuxiang/Projects/PASCAL3D+_release1.1/PASCAL', ...
    '/scail/scratch/u/yuxiang/PASCAL3D+_release1.1/PASCAL', ...
    '/afs/cs.stanford.edu/group/cvgl/rawdata/PASCAL3D+_release1.1/PASCAL'};
for i = 1:numel(VOCpaths)
    if exist(VOCpaths{i}, 'dir')
        PASCAL3Droot = [VOCpaths{i} '/../']; 
        VOCdevkit = [ VOCpaths{i} '/VOCdevkit/'];
        path_img_imagenet = [PASCAL3Droot '/Images/%s_imagenet'];
        path_cad = [PASCAL3Droot '/CAD/%s.mat'];
        break;
    end
end

% directory with KITTI development kit and dataset
KITTIpaths = {'/net/acadia/workplace/yuxiang/Projects/KITTI', ...
    '/home/yuxiang/Projects/KITTI_Dataset', ...
    '/scratch/yuxiang/Projects/KITTI_Dataset', ...
    '/scail/scratch/u/yuxiang/KITTI_Dataset', ...
    '/afs/cs.stanford.edu/group/cvgl/rawdata/KITTI_Dataset'};
for i = 1:numel(KITTIpaths)
    if exist(KITTIpaths{i}, 'dir')
        KITTIroot = [KITTIpaths{i} '/data_object_image_2'];
        KITTIdevkit = [KITTIpaths{i} '/devkit/matlab'];
        break;
    end
end
addpath(KITTIdevkit);