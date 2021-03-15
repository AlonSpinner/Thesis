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
            
            computePose(obj);
        end
        function computePose(obj)
            %Systems: 0(world) -> 1(x->target) -> 2(roll)
            R2t1=eul2rotm([obj.rollAngle,0,0]);
            
            %R1t0 - 
            %z1 is the target vector
            %upwards leanning. %will keep camera x-z plane parallel
            %to ground as much as possible in movement.
            
            z1=obj.targetVector;
            
            z0=[0,0,1]';
            x1=cross(z0,obj.targetVector); %size is not 1... cross=a*b*sin(theta)
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
            axis(obj.imagePlaneAxes,'manual'); %mode - manual, style - image
            end
            
            K=obj.computeK; %Method
            Rwtc=obj.pose(1:3,1:3)';
            O=obj.pose(1:3,4);
            for ii=1:length(varargin)          
                P=varargin{ii}.P;
                m=size(P,1); %number of points
                X=[P'; %transpose here so X is [x;y;z;1]
                    ones(1,m)];
                x=K*[Rwtc,-Rwtc*O]*X;
                x=(x./(x(3,:)+eps));
                u=x(1,:);
                v=x(2,:);
                
%                 ind=convhull(u,v);
%                 u=u(ind);
%                 v=v(ind);
                
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