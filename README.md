# E6E

E6E is a proof-of-concept for the generation of code coverage metrics in end-to-end (e2e) tests of a production-like Kubernetes installation.  Here are some of its features:
* Instruments a production-like binary
* Kubernetes-compatible
* Granular coverage metrics (per test attribution is possible)
* Flexible reporting (can sync report over the network)

## What's with the Name?
End-to-end testing is often abbreviated as `e2e`.  Since E6E instruments a binary, and `6` is both a number and kind of looks like a `b`, the `2` in e2e gets replaced with a `6`.

## How Does it Work?
For a given golang project `proj`, there will be a production-ready Docker image that is used in production Kubernetes deployments.  That Docker image is minimal for both size and security considerations, as is the `proj` binary that it holds. Traditional end-to-end (e2e) tests that exercise `proj` would target the production binary inside that Docker image.  

E6E wraps the production binary in test-tooling to create a test binary that achieves the optimal combination of tooling power and fidelity to production.  The CI workflow for a project that wishes to follow this concept will generate two separate Docker images: a production-ready image `proj` and one that is strictly used for e2e tests, `proj-e2e`.  

A side-car container is required to enable e2e code coverage metrics: a file detection/transfer tool, `ftr`.  Kubernetes deployments for e2e will bundle the `proj-e2e` and `ftr` containers into a pod.  These two containers share a volume to communicate the results of the code coverage.  `ftr` listens to `inotify` events from the filesystem to detect when the test tooling has finished writing the coverage report to the shared volume.    

The granularity of these metrics is arbitrary because the completion of a coverage report is triggered by the shutdown of the pod.  Transmission of `SIGINT` AND `SIGTERM` OS signals can therefore be used for arbitrary segmentation of the coverage report. This enables the tester to have per-test attribution of code coverage.

## Try it Out
This application has only been verified on a Linux host (Manjaro) using Microk8s.  The most important dependency is the use of the Microk8s local container registry, avaiable at localhost:32000.  `If you do not have this running the demo will NOT WORK`.  If you don't have this dependency, you can use E6E without k8s by following the README in [e6e](go/e6e/README.md)

Terminal 1:
```bash
make e2e
kubectl logs -f <pod-name> -c ftr > go/e6e/bin/coverage.out
```
Terminal 2:
```bash
# optional: exercise the test
kubectl expose e6e-e2e-deployment --type=LoadBalancer
curl <svc-ip>:8001
# ===========================

kubectl scale --replicas 0 deployment e6e-e2e-deployment
```

Terminal 3:
```bash
cd go/e6e
go tool cover -html bin/coverage.out
```

After the `scale` command completes, the `logs` command should also exit with the contents of the coverage file.  If redirection of STDOUT was used this content should now be in a `coverage.out` file inside  e6e's bin folder.  

The `go tool cover` command should open up a web browser that displays the code coverage.  Repeat these steps, making sure to scale the deployment back up to 1 replica, and exercise the test suite through cURL (or not if you did so the first time).  You should now have two tabs open in your web browser, each representing a different run of the test suite.  A difference in output coverage should be visible when the binary is and is not exercised.