## Problem
After noticing several data disruptions during live games that we identified after live games for the NBA, I recognized a significant blind spot that needed more transparency especially while the games are live.

## Solution
The designed monitor functions to actively watch data stream coming from remote laptops located on NBA Arena courts across the United States. It extracts local clock timestamps recorded from the JSON payload of the streaming API, considering varying time zones, and compares them to exact moment the data hits the central server located in the main NBA office. If there is a spike or sync issue, the monitor alerts the time delay and characterizes it as minor/major drop depending on frequency of delay.

## Tech Stack
- Powershell
- WebSocket APIs
-  Data Telemetry

## Security Notes
- Proactivity: The tool has helped to adjust our posture from reactive to proactive functionality. Not only does it help to answer tickets regarding data drops at set periods of time, but the live monitoring helps for the team to take active measures to identify the cause of latency disruptions during live games.
-  Telemetry Analysis: I was able to engineer a way to extract and compare remote laptop clock times with the reception time at the central server. This helped to expose network latency and synchronization failures while mitigating false positives 

## Lessons Learned 
I learned to lean on common concepts instead of trying to figure the most technical approach to solving problems; for example approaching the latency calculation through comparing remote timestamps against central server. This approach not only saved a lot of time and unnecessary complication, but also allows for a very reliable way to spot network degradation. Building this has taught me that transparency requires looking at details of data in order to understand what can be portrayed as informative or not depending on the purpose of the objective. 
