classdef Tracer < handle
    properties
        fileName
        functionName
    end
    methods
        function obj = Tracer(st)
            if(getSetEnableState)
                if (nargin == 1)
                    obj.fileName = st.file;
                    obj.functionName = st.name;
                end
                obj = obj.saveBeginEvent();
            end
        end
        function delete(obj)
            if(getSetEnableState)
                obj.saveEndEvent();
            end
        end
        function obj = saveBeginEvent(obj)
            str1 = ['{"name":"' obj.functionName '","cat":"' obj.fileName '",'];
            str2 = ['"ph":"B","ts":' num2str(timeDiffNow(getSetZeroTime),'%d') ','];
            str3 = ['"pid":1,"tid":1,"args":{}}']; %#ok<NBRAK>
            str = [',\n' str1 str2 str3];
            writeToFile(str);
        end
        function obj = saveEndEvent(obj)
            str1 = ['{"name":"' obj.functionName '","cat":"' obj.fileName '",'];
            str2 = ['"ph":"E","ts":' num2str(timeDiffNow(getSetZeroTime),'%d') ','];
            str3 = ['"pid":1,"tid":1,"args":{}}']; %#ok<NBRAK>
            str = [',\n' str1 str2 str3];
            writeToFile(str);
        end
    end
    methods(Static)
        function enable(varargin)
            initFile(varargin{:})
            getSetZeroTime(timeNow);
            getSetEnableState(true);
            t = initTimer;
            if(getSetTrackMemoryUsage)
                t.start;
            end
        end
        function disable
            if(getSetEnableState)
                deleteMemoryTimer;
                finishFile;
                getSetZeroTime(0);
                getSetEnableState(false);
            end
        end
        function start(fname)
            if(nargin > 0)
                Tracer.enable(fname);
            else
                Tracer.enable;
            end
        end
        function stop
            Tracer.disable
        end
        function out = trackMemory(t)
            if( (nargin == 1) && islogical(t) )
                getSetTrackMemoryUsage(t);
                if(getSetEnableState)
                    t = getMemoryTimer;
                    if(getSetTrackMemoryUsage)
                        if(~strcmp(t.Running,'on'))
                            t.start;
                        end
                    else
                        if(strcmp(t.Running,'on'))
                            t.stop;
                        end
                    end
                end
            else
                error('Trace.trackMemory accepts only one logical input. Try: Trace.trackMemory(true)');
            end
            out = getSetTrackMemoryUsage;
        end
        function setTrackMemoryFreq(f)
           t = getMemoryTimer;
           timerState = t.Running;
           if(timerState)
               t.stop;
           end
           t.Period = f;
           if(timerState)
               t.start;
           end
        end
    end
end

function initFile(fname)
if( nargin > 0)
    getSetFileName(fname);
else
    getSetFileName('default_tracer_file.json');
end
getSetFileId(getSetFileName);
writeFileHeader;
end

function finishFile
writeFileFooter;
fclose(getSetFileId);
getSetSomeoneIsWriting(false);
getSetFileId(0);
fixInitialCommaInJson(getSetFileName);
end

function outTrackMemUsageState = getSetTrackMemoryUsage(t)
persistent trackMemoryUsageState;
if(nargin > 0)
    trackMemoryUsageState = t;
end
outTrackMemUsageState = trackMemoryUsageState;
end

function outTimer = getMemoryTimer
outTimer = deleteAllMemoryTimersBut(1);
end

function outTimer = deleteAllMemoryTimersBut(pos)
if (nargin == 0)
    pos = 0;
end
memoryTimerList = timerfind(timerfindall,'Name','Tracer.MemoryTimer');
if (~isempty(memoryTimerList))
    for i = 1 : length(memoryTimerList)-pos
        memoryTimerList(i).stop;
        delete(memoryTimerList(i));
    end
    outTimer = memoryTimerList(end);
else
    outTimer = [];
end
end

function outTimer = initTimer
deleteAllMemoryTimersBut;
outTimer = timer('Name','Tracer.MemoryTimer', ...
    'ObjectVisibility','off',...
    'BusyMode','drop',...
    'ExecutionMode','fixedRate',...
    'Period',1,...
    'StartDelay',0,...
    'TimerFcn',@(~,~)saveMemoryUsage);
end

function deleteMemoryTimer
t = getMemoryTimer;
t.stop;
delete(t);
end

function fileNameOut = getSetFileName(fileNameIn) %#ok<*DEFNU>
persistent fileName;
if(nargin > 0)
    fileName = fileNameIn;
end
if(isempty(fileName))
    fileName = '';
end
fileNameOut = fileName;
end

function outState = getSetEnableState(state)
persistent enableState;
if(nargin > 0)
    enableState = state;
end
if(isempty(enableState))
    enableState = false;
end
outState = enableState;
end

function outSomeoneIsWriting = getSetSomeoneIsWriting(state)
persistent someoneIsWriting;
if(nargin > 0)
    someoneIsWriting = state;
end
if (isempty(someoneIsWriting))
    someoneIsWriting = false;
end
outSomeoneIsWriting = someoneIsWriting;
end

function outFid = getSetFileId(fname)
persistent fid;
if(nargin > 0)
    if (fname == 0)
        fid = 0;
    else
        fid = fopen(fname,'w');
        getSetSomeoneIsWriting(false);
    end
end
outFid = fid;
end

function outZeroTime = getSetZeroTime(t)
persistent zeroTime;
if(nargin > 0)
    zeroTime = t;
end
if( isempty(zeroTime))
    zeroTime = timeNow;
end
outZeroTime = zeroTime;
end

function saveMemoryUsage
if(getSetEnableState())
    str1 = '{"name":"memory","ph":"C","ts":';
    str2 = [num2str(timeDiffNow(getSetZeroTime),'%d') ',"pid":1,"tid":1'];
    str3 = [',"args":{"memory[MB]":' num2str(getMatlabMemoryUsage(),'%d') '}}'];
    str = [',\n' str1 str2 str3];
    writeToFile(str);
end
end

function writeFileHeader
writeToFile('{"displayTimeUnit": "ms",\n"traceEvents":[\n');
end

function writeFileFooter
fprintf(getSetFileId, ']}');
end

function writeToFile(str)
if(getSetSomeoneIsWriting)
    pause(0.01);
    writeToFile(str);
else
    getSetSomeoneIsWriting(true);
    fprintf(getSetFileId,str);
    getSetSomeoneIsWriting(false);
end
end

function t = timeNow
t = datevec(datenum(datetime('now')));
end

function td = timeDiffNow(timeZero)
td = round(1e6 * etime(timeNow, timeZero));
end

function fixInitialCommaInJson(fname)
fid = fopen(fname,'r+');
searchForFirstBracket(fid);
searchForFollowingComma(fid);
fclose(fid);
end

function searchForFirstBracket(fid)
fseek(fid,0,'bof');
while( ~feof(fid) )
    c = fread(fid,1,'uint8');
    if( c ~= double('['))
        continue;
    end
    break;
end
end

function searchForFollowingComma(fid)
while( ~feof(fid))
    c = fread(fid,1,'uint8');
    if ( (c == 9) || (c == 10) || (c == 13) || (c == 32) )
        continue;
    end
    if ( c == double(','))
        fseek(fid,-1,'cof');
        fwrite(fid,double(' '),'uint8');
    end
    break;
end
end

function memUsage = getMatlabMemoryUsage()
if ispc
    m = memory;
    memUsage = 1e-6 * m.MemUsedMATLAB;
else
    memUsage = 0;
end
end
