#pragma once
#include <thread>
#include <atomic>


class JobSystem
{
public:
	JobSystem();

	typedef bool (*processingFunction)(void* userContext, int index, int workerId);
	typedef bool (*completeFunction)(void* userContext, int workerId);
	int	RunJobs(void* userContext,
					int itemCount,
					processingFunction jobFunc,
					completeFunction completeFunc = nullptr,
					int maxWorkers = 0);

	int WaitForCompletion();

	static int GetHardwareWorkerCount();

private:
	static const int	kMaxJSWorkers = 64;
	void	Start(int workerId);
	int m_runningWorkers;
	std::thread* m_workers[kMaxJSWorkers];

	void* m_userContext;
	int m_itemCount;
	std::atomic<int> m_itemIndex;
	std::atomic<int> m_itemSucceedCount;
	std::atomic<int> m_itemProceed;
	processingFunction m_processingFunction;
	completeFunction m_completeFunction;
};
