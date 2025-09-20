//
//  Timer.cpp
//  FlowBridge-Example
//
//  Created by Daniil Arsentev on 18.09.2025.
//

#include "Timer.hpp"

Timer::Timer(int intervalMs)
: _interval(intervalMs), _running(false) {
    FlowBridge::registerSignal(tick_score);
}

Timer::~Timer() { stop(); }

Timer& Timer::getInstance(int intervalMs) {
    static Timer instance(intervalMs);
    return instance;
}

void Timer::start() {
    if (_running) return;
    _running = true;
    _thread = std::thread([this] {
        int tick = 0;
        while (_running) {
            std::this_thread::sleep_for(std::chrono::milliseconds(_interval));
            if (!_running) break;
            tick++;
            printf("Tick: %d\n", tick);
            FlowBridge::emit(tick_score, std::to_string(tick));
        }
    });
}

void Timer::stop() {
    _running = false;
    if (_thread.joinable()) {
        _thread.join();
    }
}
