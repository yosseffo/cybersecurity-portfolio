# Automated Incident Timeline & Event Logger

## Problem
After noticing moments of latency disruption during live broadcast in the NBA, the challenge was investigating the precise moment when these disruption took place. The TechOps team used to manually log game quarters just to keep record. Not only was it Tedious, but it also was inaccurate at times due to human error. Due to these flaws, I built a tool to completely automate this process in order to provide consistent and accurate timeframes of the games. 

## Solution
This designed tool listens to live WebSocket data and pushes accurate milestone alerts directly to a Slack channel. By doing so, whenever there are data disruptions that occur, we are able to outline the exact moment in the game timeline that these events have occurred, leading to a more efficient process of identifying the root cause. 

## Tech Stack
- Powershell
- .NET WebSockets
- Slack Webhooks
- JSON Data Parsing

  ## Security and Engineering Notes
  - **In Memory Execution**: By utilizing Powershell Runspaces and native.NET classes, I was able to bypass standard execution blocks upheld by Corporate IT policies in order to run the entire tool in memory
  - **API Reverse Engineering**: When first studying the JSON payloads, it was crucial to notice the undocumented and incomprehensible text stream of the streaming API. I was able to analyze raw JSON payloads and outline definitive markers in the stream instead of utilizing broad API broadcasts. This lead to guaranteed triggers to fire perfectly at identical time of data input.

 ## Setup and Usage
1. Repository cloning
2. Setting webhook URL to local system environment variable
3. Running script via PowerShell ISE to avoid local file execution blocks

## Lessons Learned
- During this project I was able to learn a lot in regards to reading JSON payloads and utilizing webhooks as well as web sockets. I also learned that automating the incident timeline helped to mitigate human error significantly while also allowing the team to focus entirely on other tasks that require human interaction processes. 
