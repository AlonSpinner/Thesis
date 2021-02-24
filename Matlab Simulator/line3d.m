classdef line3d < handle 
    properties
        worldAxes
        P0
        P1
        direction
        length
        graphicHandle
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
            x=P(1,:); y=P(2,:);
            
            delete(obj.graphicHandle);
            hold(obj.worldAxes,'on');
            obj.graphicHandle=plot(x,y,...
                'Parent',obj.worldAxes,...
                varargin{:});
            hold(obj.worldAxes,'off');
        end
    end   
end