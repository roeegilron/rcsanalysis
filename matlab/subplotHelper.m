classdef subplotHelper < handle
    %subplotHelper Helps with organizing and referring to SUBPLOT axes.
    %   This simple class helps with using SUBPLOT(M, N, P) by showing the SUBPLOT grid
    %   that will be created. The user can interactively choose the grid tiles that should
    %   be used for each axes by brushing the displayed rectangles. The property 'p' then
    %   holds a two-column matrix where each row is the P-input to each axes in the
    %   SUBPLOT for the respective grid part.
    %
    %   Usage:
    %
    %       obj = subplotHelper(m, n);
    %       Mark each grid part in the created axes, then read out 'p':
    %       p = obj.p;
    %
    %       Or:
    %       p = subplotHelper(m, n).getP;
    %       Waits for the user to mark the grid parts and close the figure, then 'p' is
    %       directly returned.
    %
    %       Then SUBPLOT can be used conveniently by referring to p(j, :), where J is the
    %       Jth grid part that was selected.
    %
    %       for iP = 1:size(p, 1)
    %           ax = subplot(m, n, p(iP, :));
    %           plot(ax, x, sin(x)+randn(size(x)));
    %       end
    %
    %
    %   Note that this script permits the user to brush grid tiles multiple times. This
    %   will most probably corrupt the returned indices.
    %
    %
    %   Author: Frederick Zittrell
    %
    % See also subplot
    
    
    properties (SetAccess = private)
        p   % Two-column matrix holding the P-input for each chosen SUBPLOT axes in the respective row.
    end
    
    properties (Access = private)
        ax
    end
    
    
    methods
        function self = subplotHelper(m, n)
            % Constructor: subplotHelper(m, n)
            
            validInput = @(var) ...
                validateattributes(var, {'numeric'}, {'integer', 'scalar', 'positive'});
            validInput(m);
            validInput(n);
            
            
            ax = gca;
            self.ax = gca;
            
            % SUBPLOT index matrix
            pMat = reshape(1 : m*n, n, m)';
            
            p = [];
            self.p = p;
            
            clrs = lines(m * n); % color RGB matrix
            iClr = 1; % color iterator
            
            % scatter data representing the SUBPLOT grid
            [x,y] = meshgrid(1:n, 1:m);
            sc = scatter(ax, x(:),y(:), 600, 'filled', 'Marker', 'square');
            sc.CData = repmat([.5 .5 .5], size(x(:)));
            ax.YAxis.Direction = 'reverse';
            ax.XAxisLocation = 'top';
            
            % adjust axes
            axis(ax, 'equal');
            title(ax, 'm \times n subplot grid')
            ax.XLim = [0, n + 1];
            ax.XTick = 1 : n;
            ax.XLabel.String = 'n';
            ax.YLim = [0, m + 1];
            ax.YTick = 1 : m;
            ax.YLabel.String = 'm';
            
            % initialize brushing
            hBr = brush(ax.Parent);
            hBr.Color = clrs(iClr, :);
            hBr.ActionPostCallback = @postBrush;
            brush(ax.Parent, 'on');
            

            
            function postBrush(~, ~)
                % get brushed data points
                % source: https://www.mathworks.com/matlabcentral/answers/385226
                isBrushed = logical(sc.BrushData);
                yBr = sc.YData(isBrushed);
                xBr = sc.XData(isBrushed);
                
                % min/max row & column values are subscript indices of the PMAT corner
                % indices needed for SUBPLOT
                m_min = min(yBr);
                m_max = max(yBr);
                n_min = min(xBr);
                n_max = max(xBr);
                
                % add subplot indices to P
                self.p = [self.p; pMat(m_min,n_min), pMat(m_max, n_max)];
                
                % keep the color of brushed data
                sc.CData(isBrushed, :) = repmat(clrs(iClr, :), nnz(isBrushed), 1);
                
                % cycle colors
                iClr = mod(iClr, size(clrs, 1)) + 1;
                hBr.Color = clrs(iClr, :);
            end
        end

        
        function p = getP(self)
            % waits for the figure to be closed, then returns P
            waitfor(self.ax.Parent)
            p = self.p;
        end
    end
end