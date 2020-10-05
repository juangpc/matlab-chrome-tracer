function actions

t__=Tracer(dbstack); %#ok<NASGU>

pause(2.5)

action1

action2

end

function action1
t__=Tracer(dbstack); %#ok<NASGU>

pause(1.5)

end

function action2
t__=Tracer(dbstack); %#ok<NASGU>

pause(2)

end



