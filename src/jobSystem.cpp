#include <assert.h>
#include "jobSystem.h"


JobSystem::JobSystem()
{
	m_runningWorkers = 0;
}

int JobSystem::GetHardwareWorkerCount()
{
	int count = std::thread::hardware_concurrency();
	if ( 0 == count )
		count = 1;
	if (count > kMaxJSWorkers)
		count = kMaxJSWorkers;
	return count;
}

int	JobSystem::RunJobs(void* userContext, int itemCount, processingFunction func, completeFunction completeFunc, int maxWorkers)
{
	m_itemSucceedCount = 0;
	assert(0 == m_runningWorkers);
	if (0 == itemCount)
		return 0;

	int workersCount = std::thread::hardware_concurrency();
	if ( 0 == workersCount )
		workersCount = 1;

	if (workersCount > itemCount)
		workersCount = itemCount;
	if (workersCount > kMaxJSWorkers)
		workersCount = kMaxJSWorkers;

	if ((maxWorkers > 0) && (workersCount > maxWorkers))
		workersCount = maxWorkers;

	m_userContext = userContext;
	m_itemCount = itemCount;
	m_itemProceed = 0;
	m_itemIndex = 0;
	m_itemSucceedCount = 0;
	m_processingFunction = func;
	m_completeFunction = completeFunc;

	m_runningWorkers = workersCount;

	for (int t = 0; t < workersCount; t++)
		m_workers[t] = new std::thread([this,t] { Start(t); });

	return workersCount;
}

int JobSystem::WaitForCompletion()
{
	if (m_runningWorkers > 0)
	{
		// wait for all threads to finish
		for (int t = 0; t < m_runningWorkers; t++)
		{
			m_workers[t]->join();
			delete m_workers[t];
		}
		m_runningWorkers = 0;
	}
	return m_itemSucceedCount;
}

// Grab jobs as fast as possible
void JobSystem::Start(int workerId)
{
	for (;;)
	{
		const int id = m_itemIndex.fetch_add(1);
		if (id < m_itemCount)
		{
			if (m_processingFunction(m_userContext, id, workerId))
				m_itemSucceedCount.fetch_add(1);

			const int proceed = m_itemProceed.fetch_add(1) + 1;
			if ( m_itemCount == proceed)
			{
				// if it's very last one element, run the complete function
				if (m_completeFunction)
					m_completeFunction(m_userContext, workerId);
			}
		}
		else
			break;
	}
}