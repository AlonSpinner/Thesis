classdef camera3d < handle
    properties
        h(1,1)=512;
        w(1,1)=512;
        fx(1,1)=512; %1 meter length in 1 meter disatnce will apear as fx pixels
        fy(1,1)=512; %1 meter length in 1 meter disatnce will apear as fx pixels
        px(1,1)=512/2;
        py(1,1)=512/2;
        position(3,1);
        targetVector(3,1);
        rollAngle(1,1)=0; %rad
        pose(4,4);
        
        size(1,1)=0.1;
        worldAxes(1,1)=gobjects(1,1);
        imagePlaneFig(1,1)=gobjects(1,1);
        imagePlaneAxes(1,1)=gobjects(1,1);
        graphicHandle(1,1)=gobjects(1,1);
    end
    methods
        function obj=camera3d(position,targetVector,worldAxes)
            if nargin<4 %worldAxes not provided
                worldAxes=gca;
            end
            
            obj.worldAxes=worldAxes;
            obj.position=position;
            obj.targetVector=targetVector;
            
            computePose(obj);
        end
        function computePose(obj)
            %Systems: 0(world) -> 1(x->target) -> 2(roll)
            R2t1=eul2rotm([obj.rollAngle,0,0]);
            
            %R1t0
            z0=[0,0,1]';
            x1=obj.targetVector;
            y1=-cross(obj.targetVector,z0);
            z1=cross(x1,y1);
            R1t0=[x1,y1,z1];
            
            R2t0=R1t0*R2t1;
            
            t=obj.position;
            obj.pose=[R2t0,t;...
                [0 0 0 1]];
        end
        function plot(obj)
            computePose(obj); %recompute pose in case that user changed properties
            
            %we need to fix rotation for our notation where 0 rotation
            %means that the camera target vector is x, and up vector is z
            Rfix=eul2rotm([0,-pi/2,0]);
            R=obj.pose(1:3,1:3);
            t=obj.pose(1:3,4);
            plotpose=rigid3d(R*Rfix,t');
            
            if isvalid(obj.graphicHandle) &&...
                    isa(obj.graphicHandle,'vision.graphics.Camera') %only update
                obj.graphicHandle.AbsolutePose=plotpose;
            else
                hold(obj.worldAxes,'on');
                obj.graphicHandle=plotCamera(...
                    'Parent',obj.worldAxes,...
                    'AbsolutePose',plotpose,...
                    'size',obj.size);
                hold(obj.worldAxes,'off');
            end
        end
        function image=getframe(obj,varargin)
            if isvalid(obj.imagePlaneFig) &&...
                    isa(obj.graphicHandle,'vision.graphics.Figure')
                cla(obj.imagePlaneAxes);
            end
            obj.imagePlaneFig=figure('color',[1,1,1]); %open new figure
            obj.imagePlaneAxes=axes('parent',obj.imagePlaneFig); %open new figure
            
            K=obj.computeK;
            for ii=1:length(varargin)   
                P=varargin{ii};
                x=K*P';
                x=(x./x(3,:))';
                u=x(:,1);
                v=x(:,2);
                
                patch(obj.imagePlaneAxes,'XData',u,'YData',v,...
                    'FaceColor',varargin{ii}.graphicHandle.FaceColor,...
                    'EdgeColor',varargin{ii}.graphicHandle.EdgeColor,...
                    'FaceAlpha',varargin{ii}.graphicHandle.FaceAlpha);
            end
            
%             F = getframe(obj.figureHandle);% Grab the rendered frame
%             image=F.cdata;
        end
        function K=computeK(obj)
          K=[obj.fx,0,obj.px;
               0,obj.fy,obj.py;
               0,0,1];
        end
        function delete(obj) %destructor
            delete(obj.graphicHandle);
        end
    end
end
%% Unused Functions
function [camPts,camAxesPts]=getCamPts()
cu = 1;
ln = cu+cu;  % cam length

% back
camPts = [0  0   cu  cu 0;...
    0  cu  cu  0  0;...
    0  0   0   0  0];
% sides
camPts = [camPts, ...
    [0   0  0  0  cu cu cu cu cu cu 0; ...
    0   cu cu cu cu cu cu 0  0  0  0; ...
    ln  ln 0  ln ln 0  ln ln 0  ln ln]];

ro = cu/2;    % rim offset
rm = ln+2*ro; % rim z offset (extent)

% lens
camPts = [camPts, ...
    [ -ro  -ro     cu+ro   cu+ro  -ro; ...
    -ro   cu+ro  cu+ro  -ro     -ro; ...
    rm   rm     rm      rm      rm] ];

% rim around the lens
camPts = [camPts, ...
    [0   0  -ro    0  cu  cu+ro cu cu  cu+ro cu  0 ;...
    0   cu  cu+ro cu cu  cu+ro cu 0  -ro    0   0 ;...
    ln  ln  rm    ln ln  rm    ln ln  rm    ln  ln] ];

camPts = bsxfun(@minus, camPts, [cu/2; cu/2; cu]);
camPts = camPts';

camAxesPts = 2*([0 1 0 0 0 0;
    0 0 0 1 0 0;
    0 0 0 0 0 1]);
end
function transform=drawCamera(transformMatrix,ParentAxes)
[camPts,camAxesPts]=getCamPts();
transform=hgtransform('Matrix',transformMatrix,'Parent',ParentAxes);
alpha=0.8;
camColor=[0.7,0,0];

% cam 'lens'
lensPatch = struct('vertices', camPts, 'faces', 17:21);
h = patch(lensPatch,'Parent',transform);
set(h,'FaceColor', [0 0.8 1], 'FaceAlpha', alpha, ...
    'EdgeColor', camColor, 'HitTest', 'off');

% cam back
rimPatch = struct('vertices', camPts, 'faces', 1:5);
h = patch(rimPatch,'Parent',transform);
set(h,'FaceColor', camColor, 'FaceAlpha', alpha, ...
    'EdgeColor', camColor, 'HitTest', 'off');

% cam sides
sidePatch = struct('vertices', camPts, 'faces',...
    [5 6 7 8 5; 8 9 10 11 8; 11 12 13 14 11; 14 5 6 13 14]);
h = patch(sidePatch,'Parent',transform);
set(h,'FaceColor', camColor, 'FaceAlpha', alpha, ...
    'EdgeColor', camColor, 'HitTest', 'off');

% cam rim
rimPatch = struct('vertices', camPts, 'faces',...
    [21 22 23 24  21; 24 25 26  27 24;...
    27 28 29 30 27; 30 31 32 21 30]);

h = patch(rimPatch,'Parent',transform);
set(h,'FaceColor', camColor, 'FaceAlpha', alpha, ...
    'EdgeColor', camColor, 'HitTest', 'off');

plot3(camAxesPts(:,1),camAxesPts(:,2),camAxesPts(:,3),'k-',...
    'linewidth',1.5, 'HitTest', 'off','Parent',transform);
end