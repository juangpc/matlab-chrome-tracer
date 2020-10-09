# matlab-chrome-tracer
A Matlab functionality to generate tracer json files compatible with Chrome-based browser.

## Usage

You need to have ```Tracer.m``` file in the path. This will allow you to configure and use the tracer.

### Enable the Tracer
Enable the tracing: ```Tracer.enable(fname)``` or also ```Tracer.start(fname)```. The variable ```fname``` is optional and contains the name of the json file where you want to store the traces. If you don't specify any value a file named ```default_tracer_file.json``` will be created in your current folder. 

```
Tracer.enable();
```
```
Tracer.enable(fname);
```
### Track Matlab's memory Usage (only windows)
You can track Matlabs memory usage. By default, memory usage will not be stored into the trace file. However you can use the command: 
```
Tracer.trackMemory(true);
```
To track its use. 
You can also modify the frequency with which the memory is sampled (defualt: 1s). ``Tracer.setTrackMemoryFreq(.2);```.

### Specify which functions to trace
Specify which functions you would like to trace. For this to hapen you just need to copy the following line ```t__ = Tracer(dbstack);``` at the begining of the function you want to trace. Sub-functions are compatible with Tracer.

An example of this could be the following Matlab code: 

```matlab
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
```
### Stop the tracing
The tracer is waiting for further events unless it is disabled or set to stop. ```Tracer.disable``` or ```Tracer.stop``` will stop the register of function calls and will save the final json file for an eventual review with Chrome web browser's tracing application.
```
Tracer.disable;
```

### See the trace of your code
Open a Chrome browser. Go to: ```chrome://tracing```. Then drag and drop the text file you have just created. And see the results. You can zoom in, measure times and in general see what is going on with your code. 

This is the trace (with memory usage) of the previous example ```function actions```;

![2020-10-09 14_54_26-chrome___tracing](https://user-images.githubusercontent.com/8955424/95626594-2fbc8200-0a40-11eb-9285-c377736b8011.png)
