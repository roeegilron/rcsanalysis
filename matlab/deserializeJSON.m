function data = deserializeJSON(filename)
addpath(genpath(fullfile(pwd ,'toolboxes', 'turtle_json','src')));
start = tic;
try
    data = json.load(filename);
    fprintf('file loaded in %.2f seconds\n',toc(start));
catch
    % try to fix the file 
    dat = fileread(filename); 
    if strcmp(dat(end),'}')  % it's missing the end closing brackets 
        x =2 ;
        fileID = fopen(filename,'a');
        fprintf(fileID,'%s',']}]'); 
        fclose(fileID); 
        try 
            data = json.load(filename);
        catch
            fprintf('file failed to load problem with json\n');
            data = [];
        end
    end
end


% eventLog = jsondecode(fixMalformedJson(fileread(fn),'EventLog'));

end