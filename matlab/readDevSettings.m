function output = readDevSettings(fn)
<<<<<<< HEAD

%% assigns device settings to structure
data = load(fn);

%% Starting with first needs, i.e. fft sesttings
output.fft = struct(data.outRec.fftConfig);
switch output.fft.size
    case 0, output.fft.size = 64;
    case 1, output.fft.size = 256;
    case 2, output.fft.size = 1024;
end

switch output.fft.windowLoad
    case 0, output.fft.windowLoad = 25;
    case 1, output.fft.windowLoad = 50;
    case 2, output.fft.windowLoad = 100;
end

%% will have to continue here ...

end
=======
%% assigns device settings to structure
data = load(fn);
%% Starting with first needs, i.e. fft sesttings
output.fft = struct(data.outRec.fftConfig);
switch output.fft.size
  case 0, output.fft.size = 64;
  case 1, output.fft.size = 256;
  case 2, output.fft.size = 1024;
end
switch output.fft.windowLoad
  case 0, output.fft.windowLoad = 25;
  case 1, output.fft.windowLoad = 50;
  case 2, output.fft.windowLoad = 100;
end
%% will have to continue here ...
end

>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69
