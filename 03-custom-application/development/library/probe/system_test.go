package probe

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestNewGoRoutineProbe(t *testing.T) {
	_, ok := NewGoRoutineProbe(10)()
	assert.True(t, ok)

	_, nok := NewGoRoutineProbe(1)()
	assert.False(t, nok)
}

func TestNewMemoryProbe(t *testing.T) {
	_, ok := NewMemoryProbe(10000000)()
	assert.True(t, ok)

	_, nok := NewMemoryProbe(1)()
	assert.False(t, nok)
}
