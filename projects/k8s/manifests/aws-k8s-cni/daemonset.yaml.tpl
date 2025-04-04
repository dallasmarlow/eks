---
"apiVersion": "apps/v1"
"kind": "DaemonSet"
"metadata":
  "labels":
    "k8s-app": "aws-node"
  "name": "aws-node"
  "namespace": "kube-system"
"spec":
  "selector":
    "matchLabels":
      "k8s-app": "aws-node"
  "template":
    "metadata":
      "labels":
        "k8s-app": "aws-node"
    "spec":
      "affinity":
        "nodeAffinity":
          "requiredDuringSchedulingIgnoredDuringExecution":
            "nodeSelectorTerms":
            - "matchExpressions":
              - "key": "kubernetes.io/os"
                "operator": "In"
                "values":
                - "linux"
              - "key": "kubernetes.io/arch"
                "operator": "In"
                "values":
                - "amd64"
                - "arm64"
              - "key": "eks.amazonaws.com/compute-type"
                "operator": "NotIn"
                "values":
                - "fargate"
      "containers":
      - "env":
        - "name": "ADDITIONAL_ENI_TAGS"
          "value": "{}"
        - "name": "AWS_VPC_CNI_NODE_PORT_SUPPORT"
          "value": "true"
        - "name": "AWS_VPC_ENI_MTU"
          "value": "9001"
        - "name": "AWS_VPC_K8S_CNI_CONFIGURE_RPFILTER"
          "value": "false"
        - "name": "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG"
          "value": "${CUSTOM_NETWORK_CFG}"
        - "name": "AWS_VPC_K8S_CNI_EXTERNALSNAT"
          "value": "false"
        - "name": "AWS_VPC_K8S_CNI_LOGLEVEL"
          "value": "DEBUG"
        - "name": "AWS_VPC_K8S_CNI_LOG_FILE"
          "value": "/host/var/log/aws-routed-eni/ipamd.log"
        - "name": "AWS_VPC_K8S_CNI_RANDOMIZESNAT"
          "value": "prng"
        - "name": "AWS_VPC_K8S_CNI_VETHPREFIX"
          "value": "eni"
        - "name": "AWS_VPC_K8S_PLUGIN_LOG_FILE"
          "value": "/var/log/aws-routed-eni/plugin.log"
        - "name": "AWS_VPC_K8S_PLUGIN_LOG_LEVEL"
          "value": "DEBUG"
        - "name": "DISABLE_INTROSPECTION"
          "value": "false"
        - "name": "DISABLE_METRICS"
          "value": "false"
        - "name": "ENABLE_POD_ENI"
          "value": "false"
        - "name": "ENI_CONFIG_LABEL_DEF"
          "value": "${ENI_CONFIG_LABEL}"
        - "name": "MY_NODE_NAME"
          "valueFrom":
            "fieldRef":
              "fieldPath": "spec.nodeName"
        - "name": "WARM_ENI_TARGET"
          "value": "1"
        "image": "${DOCKER_IMG}"
        "imagePullPolicy": "Always"
        "livenessProbe":
          "exec":
            "command":
            - "/app/grpc-health-probe"
            - "-addr=:50051"
          "initialDelaySeconds": 60
        "name": "aws-node"
        "ports":
        - "containerPort": 61678
          "name": "metrics"
        "readinessProbe":
          "exec":
            "command":
            - "/app/grpc-health-probe"
            - "-addr=:50051"
          "initialDelaySeconds": 1
        "resources":
          "requests":
            "cpu": "10m"
        "securityContext":
          "capabilities":
            "add":
            - "NET_ADMIN"
        "volumeMounts":
        - "mountPath": "/host/opt/cni/bin"
          "name": "cni-bin-dir"
        - "mountPath": "/host/etc/cni/net.d"
          "name": "cni-net-dir"
        - "mountPath": "/host/var/log/aws-routed-eni"
          "name": "log-dir"
        - "mountPath": "/var/run/aws-node"
          "name": "run-dir"
        - "mountPath": "/var/run/dockershim.sock"
          "name": "dockershim"
        - "mountPath": "/run/xtables.lock"
          "name": "xtables-lock"
      "hostNetwork": true
      "initContainers":
      - "env":
        - "name": "DISABLE_TCP_EARLY_DEMUX"
          "value": "false"
        "image": "${INIT_DOCKER_IMG}"
        "imagePullPolicy": "Always"
        "name": "aws-vpc-cni-init"
        "securityContext":
          "privileged": true
        "volumeMounts":
        - "mountPath": "/host/opt/cni/bin"
          "name": "cni-bin-dir"
      "priorityClassName": "system-node-critical"
      "serviceAccountName": "aws-node"
      "terminationGracePeriodSeconds": 10
      "tolerations":
      - "operator": "Exists"
      "volumes":
      - "hostPath":
          "path": "/opt/cni/bin"
        "name": "cni-bin-dir"
      - "hostPath":
          "path": "/etc/cni/net.d"
        "name": "cni-net-dir"
      - "hostPath":
          "path": "/var/run/dockershim.sock"
        "name": "dockershim"
      - "hostPath":
          "path": "/run/xtables.lock"
        "name": "xtables-lock"
      - "hostPath":
          "path": "/var/log/aws-routed-eni"
          "type": "DirectoryOrCreate"
        "name": "log-dir"
      - "hostPath":
          "path": "/var/run/aws-node"
          "type": "DirectoryOrCreate"
        "name": "run-dir"
  "updateStrategy":
    "rollingUpdate":
      "maxUnavailable": "10%"
    "type": "RollingUpdate"
