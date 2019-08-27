function gitUpdate(msg)
system('git add *.m');
system('git add *.md');
system('git add *.json');
system('git add *.csv');
system(sprintf('git commit -m "%s"',msg));
system('git push origin master'); 
end