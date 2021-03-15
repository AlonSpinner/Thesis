%%
CreateScene;
%% Roll camera
roll=linspace(0,2*pi,10);
for ii=1:length(roll)
    camera.rollAngle=roll(ii);
    camera.plot;
    drawnow;
    pause(0.1);
end
%% Take Camera for a stroll
Q=[0,0.5,0.5
    1,0,1;
    1,1,1;
    0,0.5,0.5];
q=linspace(0,1,100);
p=EvalBezCrv_DeCasteljau(Q,q);

hold(worldAxes,'on');
h_track=plot3(worldAxes,p(:,1),p(:,2),p(:,3));
hold(worldAxes,'off');

target=[1,0.5,0.5]';
for ii=1:length(p)
    camera.position=p(ii,:);
    D=target-camera.position;
    camera.targetVector=D/vecnorm(D,2);
    camera.plot;
    drawnow;
    pause(0.01);
    
    camera.getframe(plane2,plane1);
end

delete(h_track);
%% Camera Project
camera.getframe(plane2,plane1);