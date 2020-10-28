function pinAtAffordance(hThis, affNum)
% Pin a scribe object at the given affordance

%   Copyright 2006 The MathWorks, Inc.

% Updated by Todd A. Baxter
%   2017-06-25: works even when axes is embedded in uipanel hierarchy

% First, unpin any pins at a given affordance:
hThis.unpinAtAffordance(affNum);

% First, convert the affordance position into pixels representing a the
% point in the figure
hAff = hThis.Srect(affNum);
point = [get(hAff,'XData') get(hAff,'YData')];
hFig = ancestor(hThis,'Figure');
point = hgconvertunits(hFig,[point 0 0],'Normalized','Pixels',hFig);
point = point(1:2);

% Before we create a pin, make sure we are over a pinnable object
% First check for a valid axes:
axlist = findobj(hFig,'type','axes');
pinax = [];
for i=1:length(axlist)
    if pointinaxes(axlist(i),point) && ~isappdata(axlist(i),'NonDataObject')
        pinax = axlist(i);
    end
end

% If there is no axes that the annotation can be pinned to, return early
% and don't even create a pin.
if isempty(pinax)
    return;
end

pinobj = [];
% Turn off the hittest property of this group to find out if we are over an
% object
hitState = get(hThis,'HitTest');
set(hThis,'HitTest','off');
obj = handle(hittest(hFig,point));
set(hThis,'HitTest',hitState);

if ~isempty(obj) && ~isa(obj,'scribe.scribeobject') && ...
        ~strcmpi(get(obj,'tag'),'DataTipMarker')
    type = get(obj,'type');
    if strcmpi(type,'surface')||strcmpi(type,'patch')||strcmpi(type,'line')
        pinobj = obj;
    end
end

% Create the pin
hPin = scribe.scribepin('Parent',hThis.Parent,'Target',hThis,'DataAxes',pinax,'Affordance',affNum);
% Create the correspondence between the axes and the pin
repin(hPin(end),point,pinax,pinobj);
set(hPin,'Enable','on');

% Link the pin to the scribe object
hThis.Pin(end+1) = hPin;

%-----------------------------------------------------------------------%
function isin = pointinaxes(ax,p)
pos = getpixelposition(ax,true);
isin = false;
if p(1)>=pos(1) && p(2)>=pos(2) && ...
        p(1)<=(pos(1)+pos(3)) && p(2)<=(pos(2)+pos(4))
    isin = true;
end