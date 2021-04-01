        %%%%%%
        %
        % utility function add local time and frequency + power to data
        % tip of spectral image
        %
        %%%%%%
        %
        % all of the plotting function use datenum as the x axis
        % reason is that for plotting spectral data using imagesc (fastest
        % performance, compared to pcolor etc. which is slow in
        % largedatasets) you need a numeric axee.
        % This utility function allows one to see a human readable time on
        % mouseover as well as frequency and power value (logged)
        function addDataTipSpectral(varargin)
            % add data tip for human readable time if matlab
            % version allows this:
            %
            if ~verLessThan('matlab','9.6') % it only work on 9.6 and above...
                row = dataTipTextRow('local time',xTime);
                hplt.DataTipTemplate.DataTipRows(end+1) = row;
            end
        end
