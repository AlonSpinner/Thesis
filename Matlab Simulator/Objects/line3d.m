classdef line3d < handle
    properties
        P0(3,1);
        P1(3,1);
        direction(3,1);
        length(1,1);
        
        worldAxes(1,1)=gobjects(1,1);
        graphicHandle(1,1)=gobjects(1,1);
    end
    methods
        function obj=line3d(P0,P1,worldAxes) %constructor
            if nargin<3 %worldAxes not provided
                worldAxes=gca;
            end
            
            P0=P0(:); P1=P1(:);
            D=P1-P0;
            L=vecnorm(D,2);
            t=D/L;
            
            obj.P0=P0;
            obj.P1=P1;
            obj.direction=t;
            obj.length=L;
            obj.worldAxes=worldAxes;
        end
        function delete(obj) %destructor
            delete(obj.graphicHandle);
        end
        function plot(obj,varargin)
            P=[obj.P0,obj.P1];
            x=P(1,:); y=P(2,:); z=P(3,:);
            if isvalid(obj.graphicHandle) &&...
                    isa(obj.graphicHandle,'matlab.graphics.Line') %only update
                set(obj.graphicHandle,...
                    'XData',x,...
                    'YData',y,...
                    'ZData',z,...
                    varargin{:});
            else
                hold(obj.worldAxes,'on');
                obj.graphicHandle=plot3(x,y,z,...
                    'Parent',obj.worldAxes,...
                    varargin{:});
                hold(obj.worldAxes,'off');
            end
            
        end
    end
end