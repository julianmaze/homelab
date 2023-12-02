# Update DNS records

Add record to file in [helm_values.yaml](helm_values.yaml), then run the following commands

```console
cd C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\coredns-external
helm upgrade coredns coredns/coredns -n coredns-external -f .\helm_values.yaml
```

Test the record by running a dig command

```console
> dig @10.50.25.200 network.local.julianmaze.com
```

We expect to see something like this

```console
jmaze@jmaze-desktop:/mnt/c/Users/jmmaz/OneDrive/Homelab/Projects$ dig @10.50.25.200 network.local.julianmaze.com

; <<>> DiG 9.18.12-0ubuntu0.22.04.3-Ubuntu <<>> @10.50.25.200 network.local.julianmaze.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 21656
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 8f74a9496d998ce6 (echoed)
;; QUESTION SECTION:
;network.local.julianmaze.com.  IN      A

;; ANSWER SECTION:
network.local.julianmaze.com. 5 IN      CNAME   ingress-nginx-controller.ingress-nginx.external.jmaze-k8s.local.
ingress-nginx-controller.ingress-nginx.external.jmaze-k8s.local. 5 IN A 10.50.25.192

;; Query time: 39 msec
;; SERVER: 10.50.25.200#53(10.50.25.200) (UDP)
;; WHEN: Thu Nov 16 19:05:32 PST 2023
;; MSG SIZE  rcvd: 253
```
