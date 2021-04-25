classdef camera3d < handle
    properties
        %Intrinsics
        h(1,1)=512;
        w(1,1)=512;
        fx(1,1)=512; %1 meter length in 1 meter disatnce will apear as fx pixels
        fy(1,1)=512; %1 meter length in 1 meter disatnce will apear as fx pixels
        px(1,1)=512/2;
        py(1,1)=512/2;
        K(3,3);
        %Extrinsics
        position(3,1);
        targetVector(3,1);
        rollAngle(1,1)=0; %rad
        pose(4,4);
        %Intrinsics+Extrinsics
        ProjMat(3,4)
        %Misc
        cameraSize(1,1)=0.1;
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
            
            computeK(obj);
            computePose(obj);
            computeProjMat(obj)
        end
        function computePose(obj)
            %Systems: 0(world) -> 1(x->target) -> 2(roll)
            R2t1=eul2rotm([obj.rollAngle,0,0]);
            
            %R1t0 -
            %z1 is the target vector
            %upwards leanning. %will keep camera x-z plane parallel
            %to ground as much as possible in movement.
            %follows Camrea Conventions:
            %1) Z is forward
            %2) X is to the irhgt
            %3) Y is pointing down
            
            z1=obj.targetVector;
            
            z0=[0,0,1]';
            x1=-cross(z0,obj.targetVector); %size is not 1... cross=a*b*sin(theta)
            x1=x1/norm(x1);
            y1=cross(z1,x1);
            y1=y1/norm(y1);
            
            R1t0=[x1,y1,z1];
            R2t0=R1t0*R2t1;
            
            t=obj.position;
            obj.pose=[R2t0,t;...
                [0 0 0 1]];
        end
        function plot(obj)
            computePose(obj); %recompute pose in case that user changed properties
            plotpose=rigid3d(obj.pose');
            
            if isvalid(obj.graphicHandle) &&...
                    isa(obj.graphicHandle,'vision.graphics.Camera') %only update
                obj.graphicHandle.AbsolutePose=plotpose;
            else
                hold(obj.worldAxes,'on');
                obj.graphicHandle=plotCamera(...
                    'Parent',obj.worldAxes,...
                    'AbsolutePose',plotpose,...
                    'size',obj.cameraSize);
                hold(obj.worldAxes,'off');
            end
        end
        function image=getframe(obj,varargin)
            if isvalid(obj.imagePlaneFig) &&... %if imagePlane existed, clear it
                    isa(obj.imagePlaneFig,'matlab.ui.Figure')
                cla(obj.imagePlaneAxes);
            else %else.. create a new window
                obj.imagePlaneFig=figure('color',[1,1,1]); %open new figure
                obj.imagePlaneAxes=axes('parent',obj.imagePlaneFig,...
                    'view',[0 90],...
                    'XLim',[0,obj.w],...
                    'YLim',[0,obj.h]);
                axis(obj.imagePlaneAxes,'manual'); %mode - manual, style - image or not?
            end
            
            cla(obj.imagePlaneAxes);
            hold(obj.imagePlaneAxes,'on');
            for ii=1:length(varargin)
                [u,v]=ProjectOnImage(obj,varargin{ii});
                switch class(varargin{ii})
                    case 'plane3d'
                        patch(obj.imagePlaneAxes,'XData',u,'YData',v,...
                            'FaceColor',varargin{ii}.graphicHandle.FaceColor,...
                            'EdgeColor',varargin{ii}.graphicHandle.EdgeColor,...
                            'FaceAlpha',varargin{ii}.graphicHandle.FaceAlpha);
                    case 'line3d'
                        plot(obj.imagePlaneAxes,u,v,...
                            'Color',varargin{ii}.graphicHandle.Color,...
                            'LineWidth',varargin{ii}.graphicHandle.LineWidth,...
                            'LineStyle',varargin{ii}.graphicHandle.LineStyle);
                end
            end
            
            F = getframe(obj.imagePlaneFig);% Grab the rendered frame
            image=F.cdata;
        end
        function [u,v]=ProjectOnImage(obj,geo3d)
            P=geo3d.P;
            m=size(P,1); %number of points
            X=[P'; %transpose here so X is [x;y;z;1]
                ones(1,m)];
            x=obj.ProjMat*X;
            x=(x./(x(3,:)+eps));
            u=x(1,:);
            v=x(2,:);
            v=obj.h-v; %flip vertifcal axis of camera for image
        end
        function computeProjMat(obj)
            Rwtc=obj.pose(1:3,1:3)';
            O=obj.pose(1:3,4);
            obj.ProjMat=obj.K*[Rwtc,-Rwtc*O];
        end
        function delete(obj) %destructor
            delete(obj.graphicHandle);
        end
    end
end
%% Supporting Functions
function computeK(obj)
obj.K=[obj.fx,0,obj.px;
    0,obj.fy,obj.py;
    0,0,1];
end