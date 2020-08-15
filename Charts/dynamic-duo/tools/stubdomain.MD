# Setup consul dns inside kubernetes, setting up a stubdomain and kubedns/coredns configmap modification

In order to set this up please read the following documentation below.
For the lazy sysadmins, feel free to do step one and then run the script which will take care of setting up the configmap with the stubdomain for kube-dns
`./test/setup-stubdomain.sh`

1) find the consul-dns service or the one tagged with *-consul-dns, it might be using the release name.
    ```
    $ kubectl get svc
    vk-consul-dns                      ClusterIP      10.103.29.139    <none>                  53/TCP,53/UDP    
    ```

* if you want to skip the next two steps you can run the following script. `./test/setup-stubdomain.sh`

2) run the following command in order to set this Ip address as the variable we will need for use  in our `consul-stub-domain.yaml` file
    ```
    export CONSUL_DNS_IP=10.35.240.78
    ```

3) run the command to install the consul-stub-domain configmap.
    ```
    cat << EOF | kubectl apply -f -
    apiVersion: v1
    kind: ConfigMap
    metadata:
      labels:
        addonmanager.kubernetes.io/mode: EnsureExists
    name: kube-dns
    namespace: kube-system
    data:
      stubDomains: |
        {"consul": ["$CONSUL_DNS_IP"]}
    EOF
    ```

4) Edit the coredns configmap on the kubernetes cluster

    ```
    kubectl edit configmap coredns -n kube-system
    ```

   and append it with
   ```
   consul {
     errors
     cache 30
     forward . <consul-dns-service-cluster-ip>
   }
   ```

   * the consul proxy can only point to a static ip address, if the cluster-ip address of the consul-dns service changes then the ip address in the consul-stub-domain configmap must be changed to this new address otherwise connectivity will break.

5) The coredns edit should look similar to this once done
    ```
    apiVersion: v1
    data:
    Corefile: |
        .:53 {
            errors
            health
            ready
            kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
            }
            prometheus :9153
            forward . /etc/resolv.conf
            cache 30
            loop
            reload
            loadbalance
        }
        consul {
        errors
        cache 30
        forward . 10.103.29.139
        }
    kind: ConfigMap
    metadata:
      name: coredns
    ```
    * note that I have prometheus running on my cluster hence the prometheus stub that is located here referencing that, your cluster might be similar however you should just add in the consul block.

6) The dns test pod is located in the tests folder 'test-stubdomain.yaml', run the following command below to create the pod/job on your cluster

    ```
    $ k get pods

    NAME                                                             READY   STATUS             RESTARTS   AGE
    dns-zn8d9                                                        0/1     Completed          0          2m3s
    ```

    It should give you similar output to below..

    ```
    k logs dns-zn8d9
    ; <<>> DiG 9.11.2-P1 <<>> consul.service.consul
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56614
    ;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
    ;; WARNING: recursion requested but not available

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;consul.service.consul.         IN      A

    ;; ANSWER SECTION:
    consul.service.consul.  5       IN      A       172.17.0.15

    ;; Query time: 831 msec
    ;; SERVER: 10.96.0.10#53(10.96.0.10)
    ;; WHEN: Sat Aug 15 17:19:48 UTC 2020
    ;; MSG SIZE  rcvd: 87
    ```