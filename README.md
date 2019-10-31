# LIV Team

## Setup

First we need to install the tools for multi-agent programming, and then we can install the automated planner that our agents use.

### MAS

Download [Eclipse](https://www.eclipse.org/downloads/) if you don't have it yet. Any version should be fine, although newer versions are advised.

To enable syntax highlight for JaCaMo, install the Eclipse plugin using [this tutorial](http://jacamo.sourceforge.net/eclipseplugin/tutorial/) up to, and including, Step 10.

After restarting Eclipse, select the following menu option:
> File > Import > Git > Projects from Git > Clone URI

Copy https://github.com/autonomy-and-verification-uol/mapc2019-liv.git and paste it on the URI field.

Proceed until the "select a wizard to use for importing projects" screen, then pick Import existing Eclipse projects and click next and then finish.

### Planner

We used the Fast Downward (http://www.fast-downward.org/) planner. It should be possible to use another planner, as long as it supports the same subset of PDDL that FD does, but remember to modify the file `planner/run2.sh` accordingly with the command to run the new planner.

After installing FD (http://www.fast-downward.org/ObtainingAndRunningFastDownward), make sure the planner is working by itself by running it with a simple domain and problem file.

Finally, in the Eclipse project, navigate to `planner/run2.sh` and change the beginning of line 5 `/home/angelo/git/planner/./fast-downward.py` to the path where your `fast-downward.py` is installed.

## How to run
While testing, we use JUnit to run both the server and our JaCaMo code at the same time.

To run the sample map, right-click `test/liv/agentcontest2019/ScenarioRunSample.java` file, "Run as", "jUnit Test".
The server's output is shown on the Eclipse console. The JaCaMo output is loaded into a separate window. Press `enter` at the Eclipse console to start the simulation.

To run the sample map with two teams (team B only uses our exploration code), right-click `test/liv/agentcontest2019/ScenarioRunSampleTwoTeamsTeamB.java` file, "Run as", "jUnit Test". This will start only the code for team B.
Then, right-click `test/liv/agentcontest2019/ScenarioRunSampleTwoTeams.java` file, "Run as", "jUnit Test". This will start the server and team B. Press `enter` at the Eclipse console to start the simulation.

The files `ScenarioRunContest1.java` and `ScenarioRunContest2.java` run only our code (without the server) and were used to connect to the contest servers server1 and server2 respectively.

## How to watch the match live
Open [this link](http://localhost:8000/)

