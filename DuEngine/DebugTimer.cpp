#include "stdafx.h"
#include "DebugTimer.h"
map<string, steady_clock::time_point> DebugTimer::Map;
map<string, SingleTimePoint> DebugTimer::AverageWindowMap;

void DebugTimer::Start(string label) {
#ifdef DEBUG_TIMER_ON
	Map[label] = chrono::steady_clock::now();
#endif // DEBUG_TIMER_ON
}

double DebugTimer::End(string label, bool silence) {
#ifdef DEBUG_TIMER_ON
	auto end = steady_clock::now();
	auto diff = end - Map[label];
	double duration = chrono::duration <double, milli>(diff).count();
	if (!silence) {
		printf("[%s]\t%.4f %s\r\n", label.c_str(), (duration > 1000) ? duration / 1000 : duration, (duration > 1000) ? "s" : "ms");
	}
	return duration;
#endif // DEBUG_TIMER_ON
}

void DebugTimer::StartAverageWindow(string label) {
#ifdef DEBUG_TIMER_ON
	AverageWindowMap[label].startTime = chrono::steady_clock::now();
#endif // DEBUG_TIMER_ON
}
double DebugTimer::EndAverageWindow(string label, bool silence) {
#ifdef DEBUG_TIMER_ON
	SingleTimePoint* t = &AverageWindowMap[label];
	auto end = chrono::steady_clock::now();
	auto diff = end - t->startTime;
	t->totalTime += chrono::duration <double, milli>(diff).count();
	//printf("[%s]\t%d\r\n", label.c_str(), t->counter);

	if (t->counter >= AVERAGE_WINDOW_SIZE - 1) {
		double duration = t->totalTime / AVERAGE_WINDOW_SIZE;
		if (!silence) {
			printf("[%s]\t%.4f %s\r\n", label.c_str(), (duration > 1000) ? duration / 1000 : duration, (duration > 1000) ? "s" : "ms");
		}
		t->counter = 0;
		t->totalTime = 0;
		return duration;
	} else {
		t->counter++;
		return -1; 
	}
#endif // DEBUG_TIMER_ON
}
