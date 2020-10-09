function actions
t__=Tracer(dbstack);
disp("starting actions")
pause(2.5)
action1
action2
disp("ending actions")
end

function action1
t__=Tracer(dbstack);
disp("starting action1")
pause(1.5)
disp("ending action1")
end

function action2
t__=Tracer(dbstack);
disp("starting action2")
pause(2)
disp("ending action2")
action1
end

