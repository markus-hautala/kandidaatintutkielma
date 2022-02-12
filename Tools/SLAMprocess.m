classdef SLAMprocess
    % Suorittaa SLAM esikäsittelymenetelmät ja algoritmin

    properties
        eachFrame
        performPcDenoise
        downsamplemethod
        downsampleToPointAmount
        fov
        zLimits = [-0.5 1.5]

        pcSet
        pcSet_preprocessed
        lidarSet

        groundTruth

        optimizedPoses
        time_preprocess
        time_SLAM

        routeLengths
        distances
    end

    methods
        function obj = SLAMprocess(pcSet, groundTruth)
            % Alustetaan parametrit oletusarvoihin
            obj.eachFrame = 1;
            obj.performPcDenoise = true;
            obj.downsamplemethod = 'random';
            obj.downsampleToPointAmount = 6000;
            obj.fov = 60;
            obj.pcSet = pcSet;
            obj.groundTruth = groundTruth;
        end

        function obj = preprocess(obj)
            tic

            obj.pcSet_preprocessed = preprocess_param(obj.pcSet, ...
                obj.eachFrame, obj.performPcDenoise, obj.downsamplemethod, ...
                obj.downsampleToPointAmount, obj.fov/2);

            obj.lidarSet = pc2laser(obj.pcSet_preprocessed, obj.zLimits(1), obj.zLimits(2));

            obj.time_preprocess = toc;
        end

        function obj = SLAM(obj)
            tic
            obj.optimizedPoses = navigationTB_example(obj.lidarSet);
            obj.time_SLAM = toc;
        end

        function obj = runAll(obj)
            obj = preprocess(obj);
            obj = SLAM(obj);
            obj = results(obj);
        end

        function obj = results(obj)
            [obj.routeLengths, obj.distances] = getResults(obj.optimizedPoses, obj.groundTruth, obj.eachFrame);
            obj.routeLengths = [obj.routeLengths; mean(obj.routeLengths)];
            obj.distances = [obj.distances; mean(obj.distances)];
        end

    end
end