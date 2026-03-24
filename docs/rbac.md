# RBAC Requirements

The `kubeconfig` used by the plugin must have sufficient permissions to manage the Kubernetes and KubeVirt resources created during the build process.

Below is a minimal `Role` that grants the required permissions. Bind it to the service account or user referenced in your `kubeconfig` via a `RoleBinding` in the target namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: packer-kubevirt-builder
  namespace: <namespace>
rules:
  # VirtualMachine: create, get, update, delete
  - apiGroups: ["kubevirt.io"]
    resources: ["virtualmachines"]
    verbs: ["create", "get", "update", "delete"]

  # VirtualMachineInstance: get (status, IP, agent), VNC, port-forward
  - apiGroups: ["kubevirt.io"]
    resources: ["virtualmachineinstances"]
    verbs: ["get"]
  - apiGroups: ["subresources.kubevirt.io"]
    resources: ["virtualmachineinstances/vnc", "virtualmachineinstances/portforward"]
    verbs: ["get"]

  # DataVolume: get (validate ISO exists, wait for clone), create (clone root disk)
  - apiGroups: ["cdi.kubevirt.io"]
    resources: ["datavolumes"]
    verbs: ["get", "create"]

  # DataSource: create (bootable volume reference)
  - apiGroups: ["cdi.kubevirt.io"]
    resources: ["datasources"]
    verbs: ["create"]

  # ConfigMap: create, delete (media files / sysprep data)
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "delete"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: packer-kubevirt-builder
  namespace: <namespace>
subjects:
  - kind: ServiceAccount
    name: <service-account-name>
    namespace: <namespace>
roleRef:
  kind: Role
  name: packer-kubevirt-builder
  apiGroup: rbac.authorization.k8s.io
```

Replace `<namespace>` and `<service-account-name>` with your values.

> **Note:** If you use `ClusterInstanceType` or `ClusterPreference` resources, no additional RBAC is needed — KubeVirt resolves those references server-side when creating the VirtualMachine.
