classdef Trial < handle
    %TRIAL �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        % Classes
        gmap               map
        tars               targetGroup
        ext                Extension
        robotGp            AssembleGroup
        floatGp            moduleGroup
        mods               module      % Only save the floating modules
        obstacles          obstacle
        display            display2D
        % Flags
        fetch_arrive       logical
        target_arrive      logical
        structure_arrive   logical
        finish             logical
        % params
        N_rob              int32
        N_mod              int32
        rob_dirs           int32
        % TODO: ��Ӧ�ô�robdir Ӧ����extension
        % class����֮��Ͱ��ĸ���ŵ�ģ����ԶԽ���Щ��������л�����group
        ci
    end
    
    methods
        function obj = Trial()
            %TRIAL ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            addpath('lib');
            addpath('lib/display'); addpath('lib/alg');
            
        end
        
        function execute(obj)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
                        
            % Walk the modules
            for i=1:length(obj.mods)
                obj.mods(i).walk();
            end
            % TODO: move the floating module groups
            
            % Move the robot groups (search or construct)
            for i=1:obj.N_rob
                obj.ci = i;
                if ~obj.fetch_arrive(i)
                    % ���ڻ���������ģ��Ĳ��֣������ɵ���assemblegroup����
                    % ��ɣ��÷���ʹ�������ڵ�ͼ��S���������趨�л��е��յ�Ϊ
                    % goal��ÿ��moveһ����A*�������ʵ�ͼ������ʱ��ͼ���ظ���ģ����Ϣ
                    % ��������module map������group map��ģ�飩��һ�����ָ���ģ�飬������
                    % goal����Ϊģ�鵱ǰλ�ã����Աߣ����巽����Ҫ��ģ��id��Ӧ
                    % ��target id�������Ա����ڵ��Խ��棬�����û������Լ���
                    % ignore pos����֮��׷��ģ��Ĺ�����ÿ��moveǰ���¡�����
                    % ��һ����Ҫ����extension�������ɣ���������֮��ÿһ��
                    % �ƶ�ǰ����ģ��λ�� �����¹滮�����ģ���뿪��Ұ�����
                    % ��ǰλ�ÿ�ʼ����S������������ɹ�����ģ����ϣ���
                    % assemblegroup�ķ����践��ģ��id���ڴ˷�����ͨ��ģ��id
                    % ��������ģ��index����ɵ�ǰrobotGp��ģ��Խӣ����fetch
                    
                    % ���ڸ���ignore pos�Ĳ��֣�robot updatemap����������
                    % ���Ըĳɣ�ignore posֻ�ǲ���pos�������ţ�������ֱ�Ӱ�
                    % ���pos��Ϊ��
                    id_m = obj.robotGp(i).search();
                    if ~isempty(id_m)
                        [float_m, m_idx] = obj.getModule(id_m);
                        obj.robotGp(i).updateGroup("add", float_m);
                        obj.mods(m_idx) = [];
                        obj.fetch_arrive(i) = true;
                        target = int32(evalin('base', 'Object_Current_Target'));
                        obj.robotGp(i).LeadRobot.Goal = ...
                            [target(id_m, :)+obj.robotGp(i).attachdir, 0];
                    end
                elseif ~obj.target_arrive(i)
                    obj.target_arrive(i) = obj.robotGp(i).move();
                elseif ~obj.structure_arrive(i)
                    
                elseif ~obj.finish(i)
                    
                else
                    disp("Construction task finished!");
                end
            end

            
            % update the display
            obj.display.updateMap("Robot", obj.getRobots(), ...
                "Module", obj.getAllMods());
        end
        
        function robs = getRobots(obj)
            robs = robot();
            for i=1:obj.N_rob
                robs(i) = obj.robotGp(i).LeadRobot;
            end
        end
        
        function setRobotGp(obj, locs)
            [l, ~] = size(locs);
            
            for i = 1:l
                rob = robot(i, [locs(i, :), 0], obj.gmap);
                obj.robotGp(i) = AssembleGroup(i, rob, obj.gmap);
                if ~isempty(obj.ext)
                    cl = length(obj.ext.GroupLayers);
                    obj.robotGp(i).cl = cl;
                end
                obj.robotGp(i).initSearch();
            end
            obj.fetch_arrive = false(l);
            obj.target_arrive = false(l);
            obj.structure_arrive = false(l);
            obj.finish = false(l);
            obj.rob_dirs = zeros(l, 2);
            obj.N_rob = l;
        end
        
        function [m, idx] = getModule(obj, id, l, r)
            if nargin == 2
                l = 1; r = length(obj.mods);
            end
            mid = int32((r-l)/2+l);
            if obj.mods(mid).ID == id
                m = obj.mods(mid);
                idx = mid;
                return
            elseif r-l == 1
                if obj.mods(r).ID == id
                    idx = r;
                elseif obj.mods(l).ID == id
                    idx = l;
                end
                m = obj.mods(idx);
                return
            elseif obj.mods(mid).ID > id
                r = mid;
            else
                l = mid;
            end
            [m, idx] = obj.getModule(id, l, r);
        end
        
        function ms = getAllMods(obj)
            ms = obj.mods;
            for i=1:obj.N_rob
                if ~isempty(obj.robotGp(i).attachModuleID)
                    ms = [ms, obj.robotGp(i).modules.ModuleList.'];
                end
            end
            for i=1:length(obj.floatGp)
                ms = [ms, obj.floatGp.ModuleList.'];
            end
        end
        
        function setModules(obj, locs)
            [obj.N_mod, ~] = size(locs);
            for i = 1:obj.N_mod
                obj.mods(i) = module(i, [locs(i, :), 0], obj.gmap);
            end
%             obj.N_mod = length(modules);
        end
        
        function setTargets(obj, w, l, c, ext_c, ext_l)
            % Input: width, length, coordinate of lower left corner,
            % extension center, extension length
            N = w*l;
            Tars = [];
            for i = 1:N
                m = ceil(i/l);
                n = i - (m-1) * l;
                Tars = [Tars; targetPoint(i, [m+c(1)-1, n+c(2)-1], obj.gmap)];
            end
            obj.tars = targetGroup(Tars);
            
            % Binary tree construction / extension
            obj.ext = Extension(obj.tars, obj.gmap);
            obj.ext.TargetToTree(ext_c, ext_l);
        end
        
        function setDisplay(obj)
            % Display
            robs = obj.getRobots();
            obj.display = display2D(obj.gmap.mapSize, ...
                                    "FinalTarget", obj.tars, ...
                                    "Robot", robs, ...
                                    "Module", obj.mods, ...
                                    "Obstacle", obj.obstacles.Locations);
            % Extension
            obj.ext.showExtension(obj.display);
        end
    end
end

