package msg_test

import (
	"testing"
	"urproj/pkg/msg"

	"github.com/stretchr/testify/assert"
)

func Test_Msg_Correct_Output(t *testing.T) {
	assert.Equal(t, msg.Msg(), "hello world")
}
