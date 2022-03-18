classdef AssembleGroup < handle
    %ASSEMBLEGROUP �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        LeadRobot          robot
        modules            moduleGroup
        attachModuleID     int32
        GlobalMap          map       % "pointer" to a global map object
        dockFlag           logical
    end
    
    methods
        function obj = AssembleGroup(rob, gmap)
            %ASSEMBLEGROUP ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            if nargin == 1
                obj.LeadRobot = rob;
            end
            if nargin == 2
                obj.GlobalMap = gmap;
            end
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

