%%
fig=figure;
ax=axes;
%% camera pose
R=eye(3); t=[0,0,0];
tform = rigid3d(R,t);

%% Construct Plane + Line relative to camera

%project plane and line onto camera

%show image

%add vanishing line and vanishing point

%extract feature set:
%rho - distance of VL from image center
%theta - slope of VL
%s - location of VL from shortest 
%d - length of line segment in the image
%p0 center point of the line segment in image
