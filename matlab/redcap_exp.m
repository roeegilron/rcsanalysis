function    [redcap_datetimes,redcap_painscores,varargout]  = redcap_exp()
% [redcap_datetimes,redcap_painscores]  = redcap_DL2(PATIENTID,dateANDTIME)
%
%  This will import redcap data for patient's CP1 - Cp4 using Prasad's
%  RedCap API Token for daily surveys
%
% Took forever to write.
% Prasad Shirvalkar Oct 9 2019
% Greg C Dec 4 2019 - Added CP1's Daily Pain for RCS, Added option to use
% it to get all the Pain Flucatuation Screening Data.
%
%
% If you want to get the pain fluctuation data, use 'FLUCT' as the
% PATIENTID. varargout will output the names of the individuals who filled
% out the painscores.

%% save dir 
params.savedir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/motor_diary_data/data/raw_data';
SERVICE = 'https://redcap.ucsf.edu/api/';
dat = importdata(fullfile(pwd,'redcap_token.txt'));
TOKEN = dat{1};
cnt = 1;
%%  RCS 01 All Motor Diaries V1
type{cnt} = 'motor_diary_no_med_v1';  % description modify
reportid{cnt} = '97093'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS01';
cnt = cnt + 1;
%%  RCS 02 All Motor Diaries V1
type{cnt} = 'motor_diary_no_med_v1';  % description modify
reportid{cnt} = '97092'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS02';
cnt = cnt + 1;
%%  RCS 05 All Motor Diaries V1
type{cnt} = 'motor_diary_no_med_v1';  % description modify
reportid{cnt} = '97094'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS05';
cnt = cnt + 1;
%%  RCS 06 All Motor Diaries V1
type{cnt} = 'motor_diary_no_med_v1';  % description modify
reportid{cnt} = '97095'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS06';
cnt = cnt + 1;
%%  RCS 07 All Motor Diaries V1
type{cnt} = 'motor_diary_no_med_v1';  % description modify
reportid{cnt} = '97096'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS07';
cnt = cnt + 1;
%%  RCS 08 All Motor Diaries V1
type{cnt} = 'motor_diary_no_med_v1';  % description modify
reportid{cnt} = '97097'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS08';
cnt = cnt + 1;
%%  RCS 11 All Motor Diaries V1
type{cnt} = 'motor_diary_no_med_v1';  % description modify
reportid{cnt} = '97098'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS11';
cnt = cnt + 1;
%%  RCS 12 All Motor Diaries V1
type{cnt} = 'motor_diary_no_med_v1';  % description modify
reportid{cnt} = '97099'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS12';
cnt = cnt + 1;

%%
%%  RCS 01 All Motor Diaries V2
type{cnt} = 'motor_diary_no_med_v2';  % description modify
reportid{cnt} = '97101'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS01';
cnt = cnt + 1;
%%  RCS 02 All Motor Diaries V2
type{cnt} = 'motor_diary_no_med_v2';  % description modify
reportid{cnt} = '97102'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS02';
cnt = cnt + 1;
%%  RCS 05 All Motor Diaries V2
type{cnt} = 'motor_diary_no_med_v2';  % description modify
reportid{cnt} = '97103'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS05';
cnt = cnt + 1;
%%  RCS 06 All Motor Diaries V2
type{cnt} = 'motor_diary_no_med_v2';  % description modify
reportid{cnt} = '97104'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS06';
cnt = cnt + 1;
%%  RCS 07 All Motor Diaries V2
type{cnt} = 'motor_diary_no_med_v2';  % description modify
reportid{cnt} = '97105'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS07';
cnt = cnt + 1;
%%  RCS 08 All Motor Diaries V2
type{cnt} = 'motor_diary_no_med_v2';  % description modify
reportid{cnt} = '97106'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS08';
cnt = cnt + 1;
%%  RCS 11 All Motor Diaries V2
type{cnt} = 'motor_diary_no_med_v2';  % description modify
reportid{cnt} = '97107'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS11';
cnt = cnt + 1;
%%  RCS 12 All Motor Diaries V2
type{cnt} = 'motor_diary_no_med_v2';  % description modify
reportid{cnt} = '97108'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS12';
cnt = cnt + 1;

%%
%%  RCS 01 All Adaptive Logs
type{cnt} = 'adaptive_log';  % description modify
reportid{cnt} = '97109'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS01';
cnt = cnt + 1;
%%  RCS 02 All Adaptive Logs
type{cnt} = 'adaptive_log';  % description modify
reportid{cnt} = '97110'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS02';
cnt = cnt + 1;
%%  RCS 05 All Adaptive Logs
type{cnt} = 'adaptive_log';  % description modify
reportid{cnt} = '97111'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS05';
cnt = cnt + 1;
%%  RCS 06 All Adaptive Logs
type{cnt} = 'adaptive_log';  % description modify
reportid{cnt} = '97112'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS06';
cnt = cnt + 1;
%%  RCS 07 All Adaptive Logs
type{cnt} = 'adaptive_log';  % description modify
reportid{cnt} = '97113'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS07';
cnt = cnt + 1;
%%  RCS 08 All Adaptive Logs
type{cnt} = 'adaptive_log';  % description modify
reportid{cnt} = '97114'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS08';
cnt = cnt + 1;
%%  RCS 11 All Adaptive Logs
type{cnt} = 'adaptive_log';  % description modify
reportid{cnt} = '97115'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS11';
cnt = cnt + 1;
%%  RCS 12 All Adaptive Logs
type{cnt} = 'adaptive_log';  % description modify
reportid{cnt} = '97116'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS12';
cnt = cnt + 1;

%%
%%  RCS 01 All Adaptive Patient Reports
type{cnt} = 'adaptive_patient_report';  % description modify
reportid{cnt} = '97117'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS01';
cnt = cnt + 1;
%%  RCS 02 All Adaptive Patient Reports
type{cnt} = 'adaptive_patient_report';  % description modify
reportid{cnt} = '97118'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS02';
cnt = cnt + 1;
%%  RCS 05 All Adaptive Patient Reports
type{cnt} = 'adaptive_patient_report';  % description modify
reportid{cnt} = '97119'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS05';
cnt = cnt + 1;
%%  RCS 06 All Adaptive Patient Reports
type{cnt} = 'adaptive_patient_report';  % description modify
reportid{cnt} = '97120'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS06';
cnt = cnt + 1;
%%  RCS 07 All Adaptive Patient Reports
type{cnt} = 'adaptive_patient_report';  % description modify
reportid{cnt} = '97121'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS07';
cnt = cnt + 1;
%%  RCS 08 All Adaptive Patient Reports
type{cnt} = 'adaptive_patient_report';  % description modify
reportid{cnt} = '97122'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS08';
cnt = cnt + 1;
%%  RCS 11 All Adaptive Patient Reports
type{cnt} = 'adaptive_patient_report';  % description modify
reportid{cnt} = '97123'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS11';
cnt = cnt + 1;
%%  RCS 12 All Adaptive Patient Reports
type{cnt} = 'adaptive_patient_report';  % description modify
reportid{cnt} = '97124'; % Report ID determines which report set to load from. (Daily, Weekly, or Monthly) - This should be updated from REDCAP ID
PATIENT_ARM{cnt} = 'arm_1';
PATIENTID{cnt} = 'RCS12';
cnt = cnt + 1;
%%
%%
for i = 1:length(type)
    try 
    disp('************************');
    disp('Download a file from a subject record');
    disp('************************');
    data = webwrite(...
        SERVICE,...
        'token', TOKEN, ...
        'content', 'report',...
        'report_id',reportid{i}, ...
        'format', 'csv',...
        'type','flat',...
        'rawOrLabelHeaders','raw',...
        'raw_or_label_headers','label',...
        'exportCheckboxLabel','false',...
        'exportSurveyFields','true',...
        'returnformat','csv');
        fprintf('\n');
        fprintf('\n');
        fprintf('-----------------%%%%%%%%%%%----------- \n');
        fprintf('\n');
        fprintf('report pulled without errors:\n'); 
        fprintf('size data\t = %d\n',size(data,1)); 
        fprintf('report id\t = %s\n',reportid{i}); 
        fprintf('patient arm\t = %s\n',PATIENT_ARM{i})
        fprintf('patient id\t = %s\n',PATIENTID{i})
        fprintf('\n');
        fprintf('-----------------%%%%%%%%%%%----------- \n');
        fprintf('\n');
        fprintf('\n\n\n\n\n'); 
        fnsave = sprintf('%s_%s_%s_%s.mat',PATIENTID{i},PATIENT_ARM{i},'report-id',reportid{i});
        fullfilesave = fullfile(params.savedir, fnsave); 
        patient = PATIENTID{i};
        study_arm = PATIENT_ARM{i};
        report_id = reportid{i};
        type_data = type{i}; 
        save(fullfilesave,'data','patient','study_arm','report_id','type_data');
    catch
        fprintf('\n');
        fprintf('-----------------%%%%%%%%%%%----------- \n');
        fprintf('\n');
        fprintf('report ERROR:\n'); 
        fprintf('size data\t = %d\n',size(data,1)); 
        fprintf('report id\t = %s\n',reportid{i}); 
        fprintf('patient arm\t = %s\n',PATIENT_ARM{i})
        fprintf('patient id\t = %s\n',PATIENTID{i})
        fprintf('\n');
        fprintf('-----------------%%%%%%%%%%%----------- \n');
        fprintf('\n');
        fprintf('\n\n\n\n\n'); 
    end
end
%%
end