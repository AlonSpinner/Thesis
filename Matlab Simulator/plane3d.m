classdef plane3d < handle  
    properties
        worldAxes
        P
        n
        t1
        t2
        graphicHandle
    end
    methods
        function obj=plane3d(P,worldAxes) %constructor
            if nargin<2 %worldAxes not provided
                worldAxes=gca;
            end
            
            %P - arranged point list [x,y,z] of three or more points
            Pcg=mean(P,1);
            V=P-Pcg;
            n=null(V); %normal vec
            v_heuristic=[1,0,0]';
            t1=cross(n,v_heuristic);
            t2=cross(n,t1);
            
            obj.P=P;
            obj.n=n;
            obj.t1=t1;
            obj.t2=t2;    
            obj.worldAxes=worldAxes;
        end
        function delete(obj) %destructor
            delete(obj.graphicHandle);
        end
        function plot(obj,varargin)
            
            delete(obj.graphicHandle);
            hold(obj.worldAxes,'on');
            obj.graphicHandle=patch(...
                'XData',obj.P(:,1),...
                'YData',obj.P(:,2),...
                'ZData',obj.P(:,3),...
                'Parent',obj.worldAxes,...
                varargin{:});
            hold(obj.worldAxes,'off');
        end
    end
end