---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: ${AZ}
spec:
  subnet: ${SUBNET}
  securityGroups:
    - ${SECURITY_GROUP}