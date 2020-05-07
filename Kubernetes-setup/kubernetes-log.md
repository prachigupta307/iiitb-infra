# Log of Kubernetes setup.

### Resources referred
> There are multiple resources available to understand kubernetes, we have provided the resources which we thought would be necessary and useful with respect to mosip deployment.
###### Kubernetes Basics
1. https://medium.com/jorgeacetozi/kubernetes-master-components-etcd-api-server-controller-manager-and-scheduler-3a0179fc8186
2. https://medium.com/jorgeacetozi/kubernetes-node-components-service-proxy-kubelet-and-cadvisor-dcc6928ef58c
3. https://medium.com/better-programming/a-closer-look-at-etcd-the-brain-of-a-kubernetes-cluster-788c8ea759a5
###### Understanding Pods
1. https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/
2. https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/
3. https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
###### Understanding Deployments
1. https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
2. https://blog.container-solutions.com/kubernetes-deployment-strategies 
    > The above link might be little old, but one of the best blogs to understand the deployment conceptually.
###### Understanding Service
1. https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/
2. https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/
###### Kubernetes High Availability
1. https://medium.com/@dominik.tornow/kubernetes-high-availability-d2c9cbbdd864
2. https://thenewstack.io/kubernetes-high-availability-no-single-point-of-failure/
###### Creating single control plane cluster using Kubeadm
1. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
###### Creating Multi control plane cluster using Kubeadm
1. http://dockerlabs.collabnix.com/kubernetes/beginners/Install-and-configure-a-multi-master-Kubernetes-cluster-with-kubeadm.html
   > The above link is little outdated, but we have followed this link to build the multi control plane cluster using kubeadm. The changes that we made to this link are explained below. 
######
