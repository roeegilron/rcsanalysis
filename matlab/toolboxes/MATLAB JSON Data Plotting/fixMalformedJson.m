%--------------------------------------------------------------------------
% Copyright (c) Medtronic, Inc. 2017
%
% MEDTRONIC CONFIDENTIAL -- This document is the property of Medtronic
% PLC, and must be accounted for. Information herein is confidential trade
% secret information. Do not reproduce it, reveal it to unauthorized 
% persons, or send it outside Medtronic without proper authorization.
%--------------------------------------------------------------------------
%
% File Name: fixMalformedJson.m
% Autor: Ben Johnson (johnsb68)
%
% Description: This file contains the MATLAB function to fix a malformed 
% Summit JSON File due to improperly closing the SummitSystem session.
%
% -------------------------------------------------------------------------
%% Check and Apply Appropriate Fixes*************************************************
function [ jsonStringOut ] = fixMalformedJson( jsonString, type )

jsonString = strrep(jsonString,'INF','Inf'); % change inproper infinite labels

numOpenSqua = size(find(jsonString=='['),2);
numOpenCurl = size(find(jsonString=='{'),2);
numCloseCurl = size(find(jsonString=='}'),2);
numCloseSqua = size(find(jsonString==']'),2);

%Perform JSON formating fix depending on the file type.
if numOpenSqua~=numCloseSqua && (contains(type,'Log') || contains(type,'Settings'))
    jsonStringOut = strcat(jsonString,']'); % add missing bracket to the end
    disp('Your .json file appears to be malformed, a fix was attempted in order to proceed with processing')
elseif numOpenSqua~=numCloseSqua || numOpenCurl~=numCloseCurl
    %Put Fix here for adding in missing brackets at the end of the file.  Assume I want all curls, then all squares, and always end with }]
    jsonStringfix = strcat(repmat('}',1,(numOpenCurl-numCloseCurl-1)),repmat(']',1,(numOpenSqua-numCloseSqua-1)),'}]');
    jsonStringOut = strcat(jsonString,jsonStringfix);
    disp('Your .json file appears to be malformed, a fix was attempted in order to proceed with processing') 
else
    jsonStringOut = jsonString;
end