function actions

p = Tracer(dbstack); cleanup = onCleanup(@()p.delete);

pause(2.5)

action1

action2

end

function action1
p = Tracer(dbstack); cleanup = onCleanup(@()p.delete);

pause(1.5)

end

function action2
p = Tracer(dbstack); cleanup = onCleanup(@()p.delete);

pause(2)

end

