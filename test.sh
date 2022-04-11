go test -c -coverpkg='e6e/...' -tags testrunmain e6e
./e6e.test -test.coverprofile=bin/coverage.out
go tool cover -html coverage.out
