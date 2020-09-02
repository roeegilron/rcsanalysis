params.vidFn  = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Vid_s1_adaptive/aDBS_RCS02  vids only.mp4';
params.vidOut = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Vid_s1_adaptive/aDBS_RCS02  vids only_blurred_face_v2.mp4';

vidCam = VideoReader(params.vidFn);
vidCam.CurrentTime = 0;
% set up video
v = VideoWriter(params.vidOut,'MPEG-4');
v.Quality = 100;
v.FrameRate = vidCam.FrameRate;
open(v);

% Get FaceDetector object.  Requires the Computer Vision Toolbox.
FaceDetector = vision.CascadeObjectDetector('FrontalFaceLBP');

while hasFrame(vidCam)
    try
        % read an image from the video camera
        rgbImage = readFrame(vidCam);
        % Use FaceDetector
        BBOX = step(FaceDetector, rgbImage);
        
        n = size (BBOX,1);
        fprintf('Number of detected faces = %d.\n', n);
        
        % select which option to run 
        run1 = 1;
        run2 = 0;
        
        if run1
            if n == 0
                rgbMaskedImage = A;
            else
                for bb = 1:size(BBOX,1)
                    % OPTION 1: blur just face
                    A = rgbImage;
                    x = BBOX(bb,1);
                    y = BBOX(bb,2);
                    w = BBOX(bb,3);
                    h = BBOX(bb,4);
                    face = A(y:y+h, x:x+w, :); %<--- this
                    sz = size(face, [1 2]);
                    face = imresize(imresize(face, sz/20), sz, 'Method', 'nearest');
                    A(y:y+h, x:x+w, :) = face; %<--- this
                end
                rgbMaskedImage  = A;
            end
        end
        %         imshow(A)
        
        if run2
            % OPTION 2: Create an image where the image is blurred within the face box area:
            % Create a blurry image
            % Resize the image to be the same size as the original.
            windowSize = 41;
            kernel = ones(windowSize) / windowSize ^ 2;
            rgbBlurredImage = imfilter(rgbImage, kernel); % Requires the Image Processing Toolbox.
            % Replace the pixels in the original image with the blurred image.
            row1 = BBOX(2);
            row2 = BBOX(2) + BBOX(4);
            col1 = BBOX(1);
            col2 = BBOX(1) + BBOX(3);
            rgbMaskedImage = rgbImage; % Initialize with a copy of the original image.
            % Replace only within the box.
            rgbMaskedImage(row1:row2, col1:col2, :) = rgbBlurredImage(row1:row2, col1:col2, :);
        end
        
        % write the video
        writeVideo(v,rgbMaskedImage);
    end
end
close(v);
delete(vidCam);
return;

% https://itectec.com/matlab/matlab-pixeling-only-detected-face/
% Locate the face in a color image using the vision.CascadeObjectDetector of the Computer Vision Toolbox
% and mask it in 2 ways: by blurring and pixelation.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fprintf('Beginning to run %s.m ...\n', mfilename);


fontSize = 18;

% Read image from the drive.
rgbImage = x;
imwrite(rgbImage, 'LenaColor.png');
[rows, columns, numberOfColorChannels] = size(rgbImage)
subplot(2, 3, 1);
imshow(rgbImage);
title('Original Image', 'FontSize', fontSize);
% Get FaceDetector object.  Requires the Computer Vision Toolbox.
FaceDetector = vision.CascadeObjectDetector();
% Use FaceDetector
BBOX = step(FaceDetector, rgbImage)
% Annotation of faces by putting boxes over them.
B = insertObjectAnnotation(rgbImage, 'rectangle', BBOX, 'Face');
subplot(2, 3, 2);
imshow(B);
title('Detected Face', 'FontSize', fontSize);
% Display box over it.


hold on;
rectangle('Position', BBOX, 'EdgeColor', 'b', 'LineWidth', 2);
% Display the number of detected faces.
n = size (BBOX,1);
fprintf('Number of detected faces = %d.\n', n);
%------------------------------------------------------------------------------------------------------------

% OPTION 1: Create an image where the image is pixelated within the face box area:
% Extract the individual red, green, and blue color channels.
redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);
blockSize = [16, 16]; % 16 pixel by 16 pixel window that jumps along in steps of 16.
% Block process the image to replace every pixel in the
% 16 pixel by 16 pixel block by the mean of the pixels in the block.
% The image is 512 pixels across which will give 512/16 = 32 blocks.
% The image is 480 pixels tall which will give 480/16 = 30 blocks.
outputMagnificationRatio1 = 1;
meanFilterFunction1 = @(theBlockStructure) mean2(theBlockStructure.data(:));
% Next process the image and each 64x64 block is an array of 64 x 64 pixels.
% So it will be the same size as the original image.
% Now,here we actually to the actual filtering.
blockyImageR = blockproc(redChannel, blockSize, meanFilterFunction1);
blockyImageG = blockproc(greenChannel, blockSize, meanFilterFunction1);
blockyImageB = blockproc(blueChannel, blockSize, meanFilterFunction1);
% Recombine separate color channels into a single, true color RGB image.
rgbBlockyImage = cat(3, blockyImageR, blockyImageG, blockyImageB);
% rgbBlockyImage is a double image (because we took the mean) and would display as white unless we cast to uint8, so let's do that.
rgbBlockyImage = cast(rgbBlockyImage, 'like', rgbImage);
[blockRows, blockColumns, numberOfColorChannels2] = size(rgbBlockyImage)
% Display the block mean image.
subplot(2, 3, 3);
imshow(rgbBlockyImage, []);
axis('on', 'image');
caption = sprintf('Block mean image with block size = %d\nOutput image size = %d rows by %d columns', ...
    blockSize(1), blockRows, blockColumns);
title(caption, 'FontSize', fontSize);
% Create a pixelated image
% Resize the image to be the same size as the original.

rgbPixelatedImage = imresize(rgbBlockyImage, [rows, columns], 'nearest'); % Use 'nearest' to pixelate.
% Display the blurry image.

subplot(2, 3, 4);
imshow(rgbPixelatedImage);
axis('on', 'image');
title('Resized, Pixelated Image', 'FontSize', fontSize);
% Display box over it.
hold on;
rectangle('Position', BBOX, 'EdgeColor', 'b', 'LineWidth', 2);
% Replace the pixels in the original image with the pixelated image.
row1 = BBOX(2);
row2 = BBOX(2) + BBOX(4);
col1 = BBOX(1);
col2 = BBOX(1) + BBOX(3);
rgbMaskedImage = rgbImage; % Initialize with a copy of the original image.

% Replace only within the box.

rgbMaskedImage(row1:row2, col1:col2, :) = rgbPixelatedImage(row1:row2, col1:col2, :);
% Display the masked, pixelated image.

subplot(2, 3, 5);
imshow(rgbMaskedImage, []);
axis('on', 'image');
title('Final Masked, Pixelated Image', 'FontSize', fontSize);
% Maximize the figure window.
g = gcf;
g.WindowState = 'maximized';
g.Name = 'Masked, Pixelated Image';
%------------------------------------------------------------------------------------------------------------
% OPTION 2: Create an image where the image is blurred within the face box area:
% Create a blurry image
% Resize the image to be the same size as the original.
windowSize = 41;
kernel = ones(windowSize) / windowSize ^ 2;
rgbBlurredImage = imfilter(rgbImage, kernel); % Requires the Image Processing Toolbox.
% Display the blurry image.
hFig2 = figure;
subplot(1, 2, 1);
imshow(rgbBlurredImage);
axis('on', 'image');
title('Resized, Blurred Image', 'FontSize', fontSize);
% Display box over it.
hold on;
rectangle('Position', BBOX, 'EdgeColor', 'b', 'LineWidth', 2, 'LineWidth', 2);
% Replace the pixels in the original image with the blurred image.
row1 = BBOX(2);
row2 = BBOX(2) + BBOX(4);
col1 = BBOX(1);
col2 = BBOX(1) + BBOX(3);
rgbMaskedImage = rgbImage; % Initialize with a copy of the original image.
% Replace only within the box.
rgbMaskedImage(row1:row2, col1:col2, :) = rgbBlurredImage(row1:row2, col1:col2, :);
% Display the masked, pixelated image.
subplot(1, 2, 2);
imshow(rgbMaskedImage, []);
axis('on', 'image');
title('Final Masked, Blurred Image', 'FontSize', fontSize);
% Enlarge the figure window.
hFig2.Units = 'normalized';
hFig2.Position = [0.3, 0.3, 0.4, 0.4];
hFig2.Name = 'Masked, Blurred Image'