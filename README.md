# eth2-validator-helm
Helm Chart for running ETH2 validator with OpenEthereum + Lighthouse on Kubernete cluster under MIT license.

## Donation

If you like my work, donations are welcome, my ETH address:

0x3a66eEcD83658154AeAD6fF900CC5C65Ab2f0890

## Disclaimer

Please be advised that you should be fully aware of the risks of running a ETH2 validator. It's also your sole responsibility to ensure adopting best security practices for your Kubernetes cluster and deployment. In other words, this is an open source software, the risk is on your on.

## Install validator keystore and password

To run ETH2 validator in a Kubernete cluster with this Helm chart, you will need to install your keystore into the Kubernete cluster first. By default, two Secrets `eth2-validator-keystore` and `eth2-validator-password` are used for keeping the secret data. For example, say you just created a keystore with eth2deposit cli command, and the file structure looks like this

```
+ validator_keys
   - keystore-m_12381_3600_0_0_01610836528.json
   - deposit_data-1610836529.json
```

You can run this command to create the keystore secret

```bash
kubectl create secret generic eth2-validator-keystore --from-file=validator_keys/keystore-m_12381_3600_0_0_0-1610836528.json
```

If you have multiple keystores, you can repeat the `--from-file` argument to specify different files, like this

```bash
kubectl create secret generic eth2-validator-keystore \
  --from-file=validator_keys/keystore-00.json \
  --from-file=validator_keys/keystore-01.json
```

Since the keypairs in the keystore are encrypted, your validator will need the password to decrypt it, so you also need to install your keystore password.

**Please ensure there are proper access control to these secrets, anyone who has access to these can get your private keypairs from the keystore and withdraw fund from your validator once it's available**

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

## Configurations

There are three components to be deployed with this Helm chart, they can be configured individually.

### OpenEthereum

OpenEthereum provides the ETH1 service endpoint for Beacon. If you want to use a third-party ETH1 provider, you can probably disable it.

TODO: config here

### Lighthouse Beacon

Lighthouse Beacon provides Beacon Chain service.

TODO: config here

### Lighthouse Validator

Lighthouse Validator provides validator service.

TODO: config here.
