package probe

import "runtime"

// NewGoRoutineProbe checks for exceeding the amount of goroutines.
func NewGoRoutineProbe(num int) func() (string, bool) {
	return func() (string, bool) {
		if runtime.NumGoroutine() < num {
			return "ok", true
		} else {
			return "Number of Goroutines", false
		}
	}
}

func NewMemoryProbe(amount int) func() (string, bool) {
	return func() (string, bool) {
		m := &runtime.MemStats{}
		runtime.ReadMemStats(m)
		if m.TotalAlloc < uint64(amount) {
			return "ok", true
		} else {
			return "MemStat.TotalAlloc", false
		}
	}
}
