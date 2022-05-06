package fstrsfr_test

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
	"time"

	"ftr/pkg/fstrsfr"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func Test_WatchAndTransfer(t *testing.T) {
	// arrange
	tmpDir, err := os.MkdirTemp("", t.Name())
	require.Nil(t, err)
	t.Logf("temp dir: %s", tmpDir)

	go func() {
		time.Sleep(1 * time.Second)
		err := ioutil.WriteFile(filepath.Join(tmpDir, "coverage.out"), []byte("test data"), 0666)
		if err != nil {
			t.Logf("failed to create file: %s", err)
		}
		t.Log("file created")
	}()

	// act
	waitAndTransferErr := fstrsfr.WaitAndTransfer(tmpDir)

	// assert
	assert.Nil(t, waitAndTransferErr)

	// cleanup
	os.RemoveAll(tmpDir)
}
