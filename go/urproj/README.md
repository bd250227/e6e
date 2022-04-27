# URPROJ

urproj represents the project being tested.  You can think of it as a placeholder for the project you wish to generate end-to-end (e2e) code coverage metrics for.  

## Try Me Out (Without Kubernetes)!

### Minimial Coverage Scenario
In a terminal, execute these commands (from this directory)
```bash
docker image build --target e2e -t urproj-e2e .
docker run --rm -p 8000:8000 -v ${PWD}/bin:/tmp urproj-e2e
# Wait a second or two
^C
```

The coverage output of this command should be 60%.  The output file should be available at `bin/coverage.out`

### Maximal Coverage Scenario
In a terminal, execute these commands
```bash
docker image build --target e2e -t urproj-e2e .
docker run --rm -p 8000:8000 -v ${PWD}/bin:/tmp urproj-e2e
```
In another terminal, run this command:
```bash
curl localhost:8000
```

Stop the test with ^C.  The coverage of this run should be 100% because cURL caused the handler to be exectued, unlike in the first case.

## Further Distillation: Test Binary Compilation
```bash
go test -c -coverpkg='urproj/...' -o bin/urproj.test -tags testrunmain urproj/cmd
./bin/e6e.test -test.coverprofile=bin/coverage.out
# Wait a second or two
^C
go tool cover -html coverage.out
```