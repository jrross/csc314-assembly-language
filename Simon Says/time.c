#include <time.h>
#include <stdio.h>

struct timespec timer_start()
{
	struct timespec start_time = {0};
	clock_gettime(CLOCK_MONOTONIC, &start_time);
	return start_time;

}

unsigned long timer_end_nano(struct timespec start_time)
{
	struct timespec end_time = {0};
	clock_gettime(CLOCK_MONOTONIC, &end_time);
	unsigned long diff = end_time.tv_nsec - start_time.tv_nsec;
	return diff;
}

time_t timer_end_sec(struct timespec start_time)
{
	struct timespec end_time = {0};
	clock_gettime(CLOCK_MONOTONIC, &end_time);
	time_t diff = end_time.tv_sec - start_time.tv_sec;
	return diff;

}
