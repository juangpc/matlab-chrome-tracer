function actions
t__=Tracer(dbstack);
disp("starting actions")
c = cov(magic(5e3));
action1
pause(1)
action2
disp("ending actions")
end

function action1
t__=Tracer(dbstack);
disp("starting action1")
pause(2)
c = cov(magic(7e3));
disp("ending action1")
end

function action2
t__=Tracer(dbstack);
disp("starting action2")
c = cov(magic(1e4));
disp("ending action2")
action1
pause(1.5)
end

% Tracer.trackMemory(true);
% Tracer.enable
% actions
% Tracer.trackMemory(false);
% Tracer.disable