# LIV Team

## Setup

Download [Eclipse](https://www.eclipse.org/downloads/) if you don't have it yet. Any version should be fine, although newer versions are advised.

To enable syntax highlight for JaCaMo, install the Eclipse plugin using [this tutorial](http://jacamo.sourceforge.net/eclipseplugin/tutorial/) up to, and including, Step 10.

After restarting Eclipse, select the following menu option:
> File > Import > Git > Projects from Git > Clone URI

Copy https://github.com/autonomy-and-verification-uol/mapc2019-liv.git and paste it on the URI field.

Proceed until the "select a wizard to use for importing projects" screen, then pick Import existing Eclipse projects and click next and then finish.

## How to run
We use JUnit to run both the server and our JaCaMo code at the same time.

At the moment there are two possible server configurations:   
To run a test map, right-click test/liv/agentcontest2019/ScenarioRunTest.java file, "Run as", "jUnit Test".   
To run the sample map, right-click test/liv/agentcontest2019/ScenarioRunSample.java file, "Run as", "jUnit Test".

The server's output is shown on the Eclipse console. The JaCaMo output is loaded into a separate window. Press `enter` at the Eclipse console to start the simulation.

## How to contribute
Make sure to always keep your version up-to-date with the live repository by constantly pulling from it.

To do so, right click the project (mapc2019-liv) > Team > Pull (not Pull...)

You can send your modifications directly to the master branch, or create another branch if it has an impact on the code.   
The code in the master branch should always be operational.   
If you haven't tested a new functionality or if it breaks the simulation, then create a branch for it.
