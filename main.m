% img_path = path of image for input
% no_clusters = roughly the number of superixels to be formed
% iterations = no.of steps of gradient descent to optimize the saliency map
% alpha = learning rate of the gradient descent algorithm

iterations = 300;
alpha=0.05;
img_path = 'test.jpg';
no_clusters = 500;

% 1. read image
% 2. gets dimensions of image
% 3. gets label of which superpixel each pixel belongs to
% 4. construct graph
% 5. create weights of backgr and foregr
% 6. implements gradient descent on weights to give final map
img = imread(img_path);
[h,l,waste] = size(img);
[clusters,L,NumLabels] = Img2Cluster(img,no_clusters);
Graph = GraphConstruct(clusters,L,NumLabels);
[w_bgr,w_ctr,ctr,w_smooth] = WeightGen(NumLabels,L,clusters,Graph,l,h);
saliency_map = GradientDescent(w_bgr,w_ctr,w_smooth,NumLabels,iterations,alpha,Graph);

% converting the weights to images for visualisisuperpixeled_img = ClusterVisualiser(clusters,l,h,L);ng
saliency_img = SaliencyVisualiser(saliency_map,l,h,L);
superpixeled_img = ClusterVisualiser(clusters,l,h,L);
w_bgr_img = WeightsVisualiser(w_bgr,l,h,L);
w_frg_img = WeightsVisualiser(w_ctr,l,h,L);

% shows final saliency map
imshow(saliency_img);

% to show weights of background uncomment below line
% imshow(w_bgr_img);
% to show weights of foreground uncomment below line
% imshow(w_frg_img);
% to show superpixled image uncomment below line
% imshow(superpixeled_img);