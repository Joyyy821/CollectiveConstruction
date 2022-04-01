classdef obstacle
    %OBSTACLE �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        Locations      (:, 2) double      % Obstacle locations [x, y]
        GlobalMap      map
        Size           (1, 1)  int32      % Number of obstacles
    end
    
    methods
        function obj = obstacle(locs, gmap)
            %OBSTACLE ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj.Locations = locs;
            obj.GlobalMap = gmap;
            [obj.Size, ~] = size(locs);
            for i=1:obj.Size
                obj.GlobalMap.obstacleMap(obj.Locations(i, 1), obj.Locations(i, 2)) = 1;
            end
        end
        
        function add(obj, newloc)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            obj.Locations = [obj.Locations; newloc];
            obj.Size = obj.Size + 1;
            obj.GlobalMap.obstacleMap(newloc(1), newloc(2)) = 1;
        end
    end
end

