//
//  Timer.hpp
//  FlowBridge-Example
//
//  Created by Daniil Arsentev on 18.09.2025.
//

#ifndef Timer_hpp
#define Timer_hpp

#include <functional>
#include <thread>
#include <atomic>
#include <chrono>

#include "FlowBridge.hpp"

FLOW_SIGNAL(tick_score);

class Timer {
public:
    Timer(int intervalMs);
    ~Timer();
    static Timer& getInstance(int intervalMs);
    
    void start();
    void stop();
    

private:
    int _interval;
    std::atomic<bool> _running;
    std::thread _thread;
    
};

#endif /* Timer_hpp */
