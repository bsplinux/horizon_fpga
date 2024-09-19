#include <iostream>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
// set system time 
int main() {
    struct timeval tv;
    struct tm newTime;

    // Set the desired time
    newTime.tm_year = 2024 - 1900;  // Year since 1900
    newTime.tm_mon = 8 - 1;         // Month 0-11
    newTime.tm_mday = 15;           // Day of the month
    newTime.tm_hour = 14;           // Hours 0-23
    newTime.tm_min = 30;            // Minutes 0-59
    newTime.tm_sec = 0;             // Seconds 0-59

    // Convert the new time to a time_t object
    time_t timeInSeconds = mktime(&newTime);

    // Set the timeval structure
    tv.tv_sec = timeInSeconds;
    tv.tv_usec = 0;

    // Set the system time
    if (settimeofday(&tv, NULL) < 0) {
        perror("Failed to set time");
        return 1;
    }

    std::cout << "System time updated successfully.\n";
    return 0;
}

get system time 
#include <iostream>
#include <sys/time.h>
#include <ctime>

int main() {
    struct timeval tv;
    struct tm *ptm;
    char time_string[40];
    long milliseconds;

    // Get the current time
    gettimeofday(&tv, NULL);

    // Convert the time to a human-readable format
    ptm = localtime(&tv.tv_sec);
    strftime(time_string, sizeof(time_string), "%Y-%m-%d %H:%M:%S", ptm);

    // Compute milliseconds
    milliseconds = tv.tv_usec / 1000;

    // Print the time with milliseconds
    std::cout << "Current time: " << time_string << "." << milliseconds << " milliseconds\n";

    return 0;
}

#include <iostream>
#include <chrono>
#include <ctime>

int main() {
    // Get the current time as a time_point
    auto current_time = std::chrono::system_clock::now();

    // Convert it to a time_t, which represents calendar time
    std::time_t time_now = std::chrono::system_clock::to_time_t(current_time);

    // Convert to a readable string
    std::cout << "Current time: " << std::ctime(&time_now);

    return 0;
}



