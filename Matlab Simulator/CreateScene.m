%% This script creates the scene in the work place:
%defines world axes (and figure to view by)
%planes, lines and camera entties

worldfig=figure;
worldAxes=axes(worldfig,...
    'DataAspectRatioMode','manual');
%% Define box
lengths=[1,1,1];
center=[0.5,0.5,0.5];
box=hyperrectangle3d(lengths,center,worldAxes);
box.plot('facecolor','none');
view(3);
xlabel('x'); ylabel('y'); zlabel('z');
%% define plane 1
P=[1  1  0
   1  0  0
   1 0.5 1];
plane1=plane3d(P,worldAxes);
plane1.plot('facecolor',[0.5,0.5,0.5]);
%% define plane 2
P=[0  0  0
   1  0  0
   1  1  0
   0  1 0];
plane2=plane3d(P,worldAxes);
plane2.plot('facecolor',[0.5,0.8,0.5]);
%% Define Line 1
P0=[1,1,0];
P1=[1,0,0];
line1=line3d(P0,P1,worldAxes);
line1.plot('color',[1,0,0],'linewidth',2);

%% Define Line 2
P0=[1,1,0];
P1=[1,0.5,1];
line2=line3d(P0,P1,worldAxes);
line2.plot('color',[1,0,0],'linewidth',2);
%% Define Camera
position=[0,0.5,0.5];
rollAngle=0;
targetVector=[1,0,0];
camera=camera3d(position,targetVector,worldAxes);
camera.plot;