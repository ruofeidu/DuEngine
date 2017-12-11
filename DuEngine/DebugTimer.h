#pragma once
#include <map>
#include <string>
#include <chrono>
#include <iostream>
using namespace std;
using namespace chrono;
#define DEBUG_TIMER_ON

struct SingleTimePoint
{
	steady_clock::time_point startTime;
	int counter;
	double totalTime;
};

class DebugTimer
{
private:
	static const int AVERAGE_WINDOW_SIZE = 60 * 5;
	static map<string, steady_clock::time_point> Map;
	static map<string, SingleTimePoint> AverageWindowMap;

public:
	// Start a single timer 
	static void Start(string label = "-");
	// End a single timer
	static double End(string label = "-", bool silence = false);

	// Start a timer with average window of size AVERAGE_WINDOW_SIZE
	static void StartAverageWindow(string label = "-");
	// End a timer with average window of size AVERAGE_WINDOW_SIZE
	static double EndAverageWindow(string label = "-", bool silence = false);
};
