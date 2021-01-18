# eth2-validator-helm
Helm Chart for running ETH2 validator with OpenEthereum + Lighthouse on Kubernete cluster under MIT license.

## Donation

If you like my work, donations are welcome, my ETH address:

0x3a66eEcD83658154AeAD6fF900CC5C65Ab2f0890

## Disclaimer

Please be advised that you should be fully aware of the risks of running a ETH2 validator. It's also your sole responsibility to ensure adopting best security practices for your Kubernetes cluster and deployment. In other words, this is an open source software, the risk is on your on.

## Install

To install, you could run

```bash
helm repo add fangpen https://raw.githubusercontent.com/fangpenlin/helm-repo/master/
helm repo update
```

then

```bash
helm install eth2-validator fangpen/eth2-validator
```

