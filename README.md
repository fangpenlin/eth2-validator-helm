# eth2-validator-helm
Helm Chart for running [ETH2 validator](https://ethereum.org/en/eth2/staking/) with [OpenEthereum](https://openethereum.org/) + [Lighthouse](https://lighthouse.sigmaprime.io/) on Kubernete cluster under MIT license.

## Donation

If you like my work, donations are welcome, my ETH address:

**0x3a66eEcD83658154AeAD6fF900CC5C65Ab2f0890**

## Disclaimer

Please be advised that you should be fully aware of the risks of running a ETH2 validator. It's also your sole responsibility to ensure adopting best security practices for your Kubernetes cluster and deployment. In other words, this is an open source software, the risk is on your own.

## Install validator keystore and password

**WARNING: Please ensure proper access control is used for those Secrets, anyone who has access to these can get your private keypairs from the keystore and withdraw fund from your validators once it's available**

To run ETH2 validator in a Kubernete cluster with this Helm chart, you will need to install your keystore into the Kubernete cluster first. By default, two Secrets 

- `eth2-validator-keystore`
- `eth2-validator-password`

are used for keeping the secret data. For example, say you just created a keystore with eth2deposit cli command, and the file structure looks like this

```
+ validator_keys
   - keystore-m_12381_3600_0_0_01610836528.json
   - deposit_data-1610836529.json
```

You can run this command to create the keystore secret

```bash
kubectl create secret generic eth2-validator-keystore \
   --from-file=validator_keys/keystore-m_12381_3600_0_0_0-1610836528.json
```

If you have multiple keystores, you can repeat the `--from-file` argument to specify different files, like this

```bash
kubectl create secret generic eth2-validator-keystore \
  --from-file=validator_keys/keystore-00.json \
  --from-file=validator_keys/keystore-01.json
```

This will create a Kubernete Secret with content like

```
keystore-00.json: <keystore 00 json content>
keystore-01.json: <keystore 00 json content>
```

Since the keypairs in the keystore are encrypted, your validator will need the password to decrypt it, so you also need to install your keystore password. You need to first create the file with your keystore password as its content, and name the file exactly as the public key of your validator. For example, my validator's public key is `0xb8c7cdcaad73437a65125adfc3068bfc011122bac84edca77e9f41c6e6978f2c90579ff3e0170a434e80ba25a42b7e7a`, so I will create a file

```0xb8c7cdcaad73437a65125adfc3068bfc011122bac84edca77e9f41c6e6978f2c90579ff3e0170a434e80ba25a42b7e7a```

with the password as its content. Once you have this file, you can then run

```bash
kubectl create secret generic eth2-validator-password \
   --from-file=0xb8c7cdcaad73437a65125adfc3068bfc011122bac84edca77e9f41c6e6978f2c90579ff3e0170a434e80ba25a42b7e7a
```

This will create a Secret with key values like this:

```
0xb8c7cdcaad73437a65125adfc3068bfc011122bac84edca77e9f41c6e6978f2c90579ff3e0170a434e80ba25a42b7e7a: <password content>
```

Likewise, if you have more than one validator to run, you can apply `--from-file=` multiple times.

## Install

To install this Helm chart, you could run

```bash
helm repo add fangpen https://raw.githubusercontent.com/fangpenlin/helm-repo/master/
helm repo update
```

then

```bash
helm install eth2-validator fangpen/eth2-validator
```

Please notice that, by default the networks for ETH1 / ETH2 are `goerli` and `pyrmont`, if you want to run your validator against the main network, you can change the network configuration like this

```bash
helm install eth2-validator fangpen/eth2-validator \
   --set-string openethereum.network=mainnet \
   --set-string beacon.network=mainnet \
   --set-string validator.network=mainnet
```

## Networking and P2P connections

While making your P2P connection ports available to public internet is not a hard requirement, but it's usually a recommendation. With this Helm chart, we use Kubernete's `hostPort` feature for opening the port on the node where the pod is scheduled. You will need to add new firewall rules in your network environment to make those ports accessiable from internet. These ports are

- OpenEthereum: 9000 TCP/UDP
- Lighthouse Beacon: 30303 TCP/UDP

Please note that, `hostPort` is enabled by default and it comes with some drawbacks. By using `hostPort`, it means pods using the same host port can only be scheduled on different nodes. You can set `openethereum.hostPort.enabled=false` and `beacon.hostPort.enabled=false` to disable them if you don't want to open these ports on node or you wish to use other approach for opening the ports, such as an external LoadBalancer.

To avoid scheduling pods using the same public host port on the same machine, you can use `affinity` configuration like this:

```yaml
beacon:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/component
            operator: In
            values:
            - beacon
        topologyKey: kubernetes.io/hostname
```

In this case, beacon won't be schedule to machines where a beacon pod is already running there.

## Configurations

There are three components to be deployed with this Helm chart, they can be configured individually. Please check [values.yaml](values.yaml) for the default values.

### OpenEthereum

OpenEthereum provides the ETH1 service endpoint for Beacon. If you want to use a third-party ETH1 provider, you can probably disable it. The configuration of OpenEthereum component is all under `openethereum` key.

| Key                         | Usage                                               |
| --------------------------- | --------------------------------------------------- |
| **enabled**                 | Enable component or not                             |
| **defaultArgs**             | Default argument for running openethereum command   |
| **extraArgs**               | Extra argument for running openethereum command     |
| **persistent.enabled**      | Enable data persistent or not                       |
| **persistent.accessModes**  | Access mode for PersistentVolume                    |
| **persistent.size**         | Size of PersistentVolume                            |
| **persistent.storageClassName** | Storage class of of PersistentVolume, SSD is recommended |
| **replicaCount**            | Replica count                                       |
| **image.repository**        | Docker image repo                                   |
| **image.tag**               | Docker image tag                                    |
| **image.pullPolicy**        | Docker image polling policy                         |
| **network**                 | ETH network to connect to                           |
| **imagePullSecrets**        | Image polling secret                                |
| **serviceAccount.create**   | Create service account or not                       |
| **serviceAccount.name**     | Name of service account if not using default        |
| **podSecurityContext**      | Security group for pod                              |
| **securityContext**         | Security context                                    |
| **service.enabled**         | Enable Service or not                               |
| **hostPort.enabled**        | Expose P2P ports or not                             |
| **readinessProbe**          | Readiness probe                                     |
| **livenessProbe**           | Liveness probe                                      |
| **resources**               | Resource requirement and limitation                 |
| **nodeSelector**            | Node selector for pods                              |
| **tolerations**             | Tolerations for pods                                |
| **affinity**                | Affinity for pods                                   |

### Lighthouse Beacon

Lighthouse Beacon provides Beacon Chain service.

The configuration of OpenEthereum component is all under `beacon` key.

| Key                         | Usage                                               |
| --------------------------- | --------------------------------------------------- |
| **enabled**                 | Enable component or not                             |
| **defaultArgs**             | Default argument for running lighthouse command     |
| **extraArgs**               | Extra argument for running lighthouse command       |
| **persistent.enabled**      | Enable data persistent or not                       |
| **persistent.accessModes**  | Access mode for PersistentVolume                    |
| **persistent.size**         | Size of PersistentVolume                            |
| **persistent.storageClassName** | Storage class of of PersistentVolume, SSD is recommended |
| **replicaCount**            | Replica count                                       |
| **image.repository**        | Docker image repo                                   |
| **image.tag**               | Docker image tag                                    |
| **image.pullPolicy**        | Docker image polling policy                         |
| **network**                 | ETH network to connect to                           |
| **imagePullSecrets**        | Image polling secret                                |
| **serviceAccount.create**   | Create service account or not                       |
| **serviceAccount.name**     | Name of service account if not using default        |
| **podSecurityContext**      | Security group for pod                              |
| **securityContext**         | Security context                                    |
| **service.enabled**         | Enable Service or not                               |
| **hostPort.enabled**        | Expose P2P ports or not                             |
| **readinessProbe**          | Readiness probe                                     |
| **livenessProbe**           | Liveness probe                                      |
| **resources**               | Resource requirement and limitation                 |
| **nodeSelector**            | Node selector for pods                              |
| **tolerations**             | Tolerations for pods                                |
| **affinity**                | Affinity for pods                                   |

### Lighthouse Validator

Lighthouse Validator provides validator service.

The configuration of OpenEthereum component is all under `validator` key.

| Key                         | Usage                                               |
| --------------------------- | --------------------------------------------------- |
| **enabled**                 | Enable component or not                             |
| **defaultArgs**             | Default argument for running lighthouse command     |
| **extraArgs**               | Extra argument for running lighthouse command       |
| **persistent.enabled**      | Enable data persistent or not                       |
| **persistent.accessModes**  | Access mode for PersistentVolume                    |
| **persistent.size**         | Size of PersistentVolume                            |
| **persistent.storageClassName** | Storage class of of PersistentVolume, SSD is recommended |
| **image.repository**        | Docker image repo                                   |
| **image.tag**               | Docker image tag                                    |
| **image.pullPolicy**        | Docker image polling policy                         |
| **network**                 | ETH network to connect to                           |
| **imagePullSecrets**        | Image polling secret                                |
| **serviceAccount.create**   | Create service account or not                       |
| **serviceAccount.name**     | Name of service account if not using default        |
| **podSecurityContext**      | Security group for pod                              |
| **securityContext**         | Security context                                    |
| **service.enabled**         | Enable Service or not                               |
| **hostPort.enabled**        | Expose P2P ports or not                             |
| **readinessProbe**          | Readiness probe                                     |
| **livenessProbe**           | Liveness probe                                      |
| **resources**               | Resource requirement and limitation                 |
| **nodeSelector**            | Node selector for pods                              |
| **tolerations**             | Tolerations for pods                                |
| **affinity**                | Affinity for pods                                   |
