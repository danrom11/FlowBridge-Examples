//
//  Loader.hpp
//  FlowBridge-Example
//
//  Created by Daniil Arsentev on 20.09.2025.
//

#ifndef Loader_hpp
#define Loader_hpp

#include <memory>
#include <string>

class Loader {
public:
    Loader();
    ~Loader();

    // Start downloading from the URL. The file will be saved in Documents/destFileName
    void start(const char* url, const char* destFileName);

    // Cancel active download (if in progress)
    void cancel();

    // Signals (names for subscribing from Swift):
    // - "loader_progress": NSNumber (Double 0.0...1.0)
    // - "loader_finished": NSString (path to the saved file)
    // - "loader_error": NSString (error text)
    struct Signals {
        static constexpr const char* progress = "loader_progress";
        static constexpr const char* finished = "loader_finished";
        static constexpr const char* error    = "loader_error";
    };

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

#endif /* Loader_hpp */
