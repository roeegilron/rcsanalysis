function data = deserializeJSON(filename)
addpath(genpath(fullfile(pwd ,'toolboxes', 'turtle_json','src')));
start = tic;
try
    data = json.load(filename);
    fprintf('file loaded in %.2f seconds\n',toc(start));
catch
    fprintf('file failed to load problem with json\n');
    data = [];
end


% eventLog = jsondecode(fixMalformedJson(fileread(fn),'EventLog'));

end