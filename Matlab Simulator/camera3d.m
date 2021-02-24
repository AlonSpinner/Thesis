classdef camera3d < handle
    properties
        worldAxes
        size=0.1;
        position
        upVector
        targetVector
        focalLength=(512/2)/deg2rad(25/2);
        resolution=512;
        fieldOfView=deg2rad(25);
        figureHandle
        graphicHandle
    end
    methods
        function obj=camera3d(position,targetVector,upVector,worldAxes)
            if nargin<4 %worldAxes not provided
               worldAxes=gca; 
            end
            
            obj.worldAxes=worldAxes;
            obj.position=position;
            obj.upVector=upVector;
            obj.targetVector=targetVector;
        end   
        function plot(obj)
            R=eul2rotm([0,-pi/2,0]);
            t=obj.position;
            pose=rigid3d(R,t);
            
            delete(obj.graphicHandle);
            hold(obj.worldAxes,'on');
            obj.graphicHandle=plotCamera(...
                'Parent',obj.worldAxes,...
                'AbsolutePose',pose,...
                'size',obj.size);
            hold(obj.worldAxes,'off');
        end  
        function image=getframe(obj)
            if isempty(obj.figureHandle) || ~isvalid(obj.figureHandle)
               obj.figureHandle=figure('color',[1,1,1]); %open new figure
            end
            clf(obj.figureHandle);
            axesHandle=copyobj(obj.worldAxes,obj.figureHandle);

            set(axesHandle,...
                'Projection','perspective',...
                'CameraPosition',obj.position,...
                'CameraUpVector',obj.upVector,...
                'CameraTarget',obj.position+obj.targetVector,...
                'CameraViewAngle',obj.fieldOfView,...
                'Units', 'pixels',...
                'Xtick',[],'Ytick',[],'Ztick',[],...
                'Xlabel',[],'YLabel',[],'ZLabel',[],...
                'outerPosition',[1 1 obj.resolution obj.resolution]);
            
            F = getframe(obj.figureHandle);% Grab the rendered frame
            image=F.cdata;
        end
        function delete(obj) %destructor
            delete(obj.graphicHandle);
        end
    end
end
