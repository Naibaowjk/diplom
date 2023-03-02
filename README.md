#  1. Improving Performance of Service Mesh for Cloud Native Applications- [Improving Performance of Service Mesh for Cloud Native Applications](#improving-performance-of-service-mesh-for-cloud-native-applications)
- [1. Improving Performance of Service Mesh for Cloud Native Applications- Improving Performance of Service Mesh for Cloud Native Applications](#1-improving-performance-of-service-mesh-for-cloud-native-applications--improving-performance-of-service-mesh-for-cloud-native-applications)
- [2. Description](#2-description)
- [3. Background Knowledge](#3-background-knowledge)
  - [3.1. MeshInsight](#31-meshinsight)
  - [3.2. Istio](#32-istio)
  - [DPDK](#dpdk)
  - [P4Lang](#p4lang)


# 2. Description
Unlike traditional monolithic applications, cloud-native applications are the 
collection of small and independent services, which are so-called microservices. As cloud-native 
applications have gained tremendous interest in recent years, many cloud vendors such as Google 
Cloud and Amazon Web Service already provided cloud platforms for cloud-native applications.
Service meshes have been considered as a de facto communication subtrate for cloud-native 
applications. Specifcially, each service in a cloud-native application communicate to each other 
via a software proxy, called sidecar. A sidecar intercepts cloud traffic reaching a service and thus 
provides various control functions such as security and traffic management. However, as each 
sidecar is co-located with each service, this design introduces overhead (e.g., increasing latency 
and lower throughput) for cloud-native applications, especially for applications that include a 
significant number of services. This work aims to improve the performance of service mesh for 
cloud-native applications.

# 3. Background Knowledge
## 3.1. MeshInsight
MeshInsight is a tool to systematically characterize the overhead of service meshes and to help developers quantify the latency and CPU overhead in deployment scenarios of interest. Read the paper for how MeshInsight works!

Note: MeshInsight currently only works on [`Istio`](#Istio). We plan to extend it to other service meshes (e.g., Cilium or Linkerd) in the future.

Follow this repo to get more: [Github: MeshInsight](https://github.com/UWNetworksLab/meshinsight)

I also change some setting in bash script. U can also check my origin branch [Github: Naibaowjk-Meshinsight](https://github.com/Naibaowjk/meshinsight)

## 3.2. Istio
Decoupling the control plane and data plane has been the goal of software development, application developers prefer to work in an ideal situation, that is, the network is stable, then the side car mode can handle the work of the data plane for application developers, the core content is to forward the application Inbound and Outbound data, so the data plane can be called Then the forwarding strategy is guided by the control plane.

Among the more popular solutions, the more popular is the control plane using Istio to manage, and Istio integrated data plane [Envoy](./doc/istio/Envoy.md) components.

Note: if your work machine has a limited number of CPU cores, creating istio example may fail due to CPU limitation. For example: 

```bash
# bookinfo
(diplom) lighthouse@VM-0-5-ubuntu:~/downloads/meshinsight$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
details-v1-6997d94bb9-8jl2h      2/2     Running   0          15m
productpage-v1-d4f8dfd97-5gs44   0/2     Pending   0          15m
ratings-v1-b8f8fcf49-bpskv       2/2     Running   0          15m
reviews-v1-5896f547f5-qpvr9      2/2     Running   0          15m
reviews-v2-5d99885bc9-hjjtk      0/2     Pending   0          15m
reviews-v3-589cb4d56c-qq84z      0/2     Pending   0          15m

# Error about cpu
$ kubectl describe pods productpage-v1-d4f8dfd97-5gs44 | grep cpu
kubernetes.io/limit-ranger: LimitRanger plugin set: cpu request for container productpage; cpu limit for container productpage
```
You should change the setting in `$(istio-DIR)/manifests/charts/istio-control/istio-discovery/values.yaml`
find this:
```yaml
  proxy:
    image: proxyv2

    # This controls the 'policy' in the sidecar injector.
```
change the cpu resources:
```yaml
    resources:
      requests:
        cpu: 10m # For example
        memory: 128Mi
```

## DPDK
Follow this link to install: [DPDK Official Website](http://doc.dpdk.org/guides/linux_gsg/build_dpdk.html)
Recommand install it in system folder.


## P4Lang
we offerd a script `p4lang/install.sh` to install p4 tutorial, which has been tested in Ubuntu 22.04
