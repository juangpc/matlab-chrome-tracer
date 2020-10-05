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

### Specify which functions to trace
Specify which functions you would like to trace. For this to hapen you just need to copy the following line ```t__ = Tracer(dbstack);``` at the begining of the function you want to trace. Sub-functions are compatible with Tracer.

An example of this could be the following Matlab code: 

```matlab
function actions

t__ = Tracer(dbstack);

pause(2.5)

action1;

action2;

end

function action1
t__=Tracer(dbstack);

pause(1.5);

end

function action2
t__=Tracer(dbstack);

pause(2);

end
```
### Stop the tracing
The tracer is waiting for further events unless it is disabled or set to stop. ```Tracer.disable``` or ```Tracer.stop``` will stop the register of function calls and will save the final json file for an eventual review with Chrome web browser's tracing application.

### See the trace of your code
Open a Chrome browser. Go to: ```chrome://tracing```. Then drag and drop the text file you have just created. And see the results. You can zoom in, measure times and in general see what is going on with your code. 

See the trace for previous example:
![image](https://user-images.githubusercontent.com/8955424/94954723-231fb300-04af-11eb-867b-dd0f572fe40b.png)
