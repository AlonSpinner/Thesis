%%
fig=figure;
worldAxes=axes(fig);
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
%% Define Line
P0=[1,1,0];
P1=[1,0,0];
line1=line3d(P0,P1,worldAxes);
line1.plot('color',[1,0,0],'linewidth',2);
%% Define Camera
position=[0,0.5,0.5];
upVector=[0,0,1];
targetVector=[1,0,0];
camera=camera3d(position,targetVector,upVector,worldAxes);
camera.fieldOfView=deg2rad(0);
camera.plot;
Frame=camera.getframe;
%%
%project plane and line onto camera
R=eye(3); t=[0,0,0]';
f=100;
px=512/2; py=512/2;
K=[f 0 0
    0 f 0
    px py 1];
P=K*[R,t];

x=P*[plane1.P,ones(3,1)]';
u=(x./x(3,:))';
u=u(:,[1,2])
%add vanishing line and vanishing point

%extract feature set:
%rho - distance of VL from image center
%theta - slope of VL
%s - location of VL from shortest 
%d - length of line segment in the image
%p0 center point of the line segment in image