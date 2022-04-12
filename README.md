# Try Me Out!

## Minimial Coverage Scenario
In a terminal, execute these commands
```bash
docker image build --target e2e -t local/jarvis-e2e .
docker run --rm -p 8000:8000 -v ${PWD}/bin:/tmp jarvis-e2e
# Wait a second or two
^C
```

The coverage output of this command should be 33%.  The output file should be available at `bin/coverage.out`

## Maximal Coverage Scenario
In a terminal, execute these commands
```bash
docker image build --target e2e -t local/jarvis-e2e .
docker run --rm -p 8000:8000 -v ${PWD}/bin:/tmp jarvis-e2e
```
In another terminal, run this command:
```bash
curl localhost:8000
```

Stop the test with ^C.  The coverage of this run should be 100% because cURL caused the handler to be exectued, unlike in the first case.