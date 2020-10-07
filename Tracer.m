classdef Tracer < handle
    properties
        fileName
        functionName
    end
    methods
        function obj = Tracer(st)
            if(Tracer.getSetEnableState)
                if (nargin == 1)
                    obj.fileName = st.file;
                    obj.functionName = st.name;
                end
                obj = obj.saveBeginEvent();
            end
        end
        function delete(obj)
            if(Tracer.getSetEnableState)
                obj.saveEndEvent();
            end
        end
        function obj = saveBeginEvent(obj)
            str1 = ['{"name":"' obj.functionName '","cat":"' obj.fileName '",'];
            str2 = ['"ph":"B","ts":"' num2str(timeDiffNow(Tracer.getSetZeroTime),'%f') '",'];
            str3 = ['"pid":1,"tid":1,"args":{}}']; %#ok<NBRAK>
            str = [',\n' str1 str2 str3];
            writeToFile(str);
        end
        function obj = saveEndEvent(obj)
            str1 = ['{"name":"' obj.functionName '","cat":"' obj.fileName '",'];
            str2 = ['"ph":"E","ts":"' num2str(timeDiffNow(Tracer.getSetZeroTime),'%f') '",'];
            str3 = ['"pid":1,"tid":1,"args":{}}']; %#ok<NBRAK>
            str = [',\n' str1 str2 str3];
            writeToFile(str);
        end
    end
    methods(Static)
        function enable(fname)
            if(nargin > 0)
                Tracer.getSetFileName(fname);
            else
                Tracer.getSetFileName('default_tracer_file.json');
            end
            Tracer.getSetFileId(Tracer.getSetFileName);
            Tracer.getSetZeroTime(timeNow);
            Tracer.getSetEnableState(true);
            writeToFile('{"displayTimeUnit": "ms",\n"traceEvents":[\n');
        end
        function disable
            if(Tracer.getSetEnableState)
                fprintf(Tracer.getSetFileId, ']}');
                fclose(Tracer.getSetFileId);
                Tracer.getSetZeroTime(0);
                Tracer.getSetSomeoneIsWriting(false);
                Tracer.getSetEnableState(false);
                fixInitialCommaInJson(Tracer.getSetFileName);
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
        function fileNameOut = getSetFileName(fileNameIn)
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
        function outFid = getSetFileId(fname)
            persistent fid;
            if(nargin > 0)
                if (fid > 0)
                    fclose(fid);
                end
                fid = fopen(fname,'w');
                Tracer.getSetSomeoneIsWriting(false);
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
        
    end
end

function writeToFile(str)
if(Tracer.getSetSomeoneIsWriting)
    pause(0.01);
    writeToFile(str);
else
    Tracer.getSetSomeoneIsWriting(true);
    fprintf(Tracer.getSetFileId,str);
    Tracer.getSetSomeoneIsWriting(false);
end
end

function t = timeNow
t = datevec(datenum(datetime('now')));
end
function td = timeDiffNow(timeZero)
td = 1e6 * etime(timeNow, timeZero);
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
