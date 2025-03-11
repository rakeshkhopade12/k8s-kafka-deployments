#!/bin/bash

# Define storage class and base path for local storage
STORAGE_CLASS="standard"
BASE_PATH="/mnt/disks/kafka-storage"  # Change if needed
PV_SIZE="20Gi"

# Define nodes (adjust this list based on your Kafka nodes)
NODES=("e2e-118-193" "e2e-118-194" "e2e-118-195")

# Loop through nodes and create PVs
for i in "${!NODES[@]}"; do
  NODE_NAME="${NODES[$i]}"
  PV_NAME="pv-kafka-storage-$((i+1))"
  STORAGE_PATH="${BASE_PATH}-$((i+1))"

  cat <<EOF > ${PV_NAME}.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${PV_NAME}
spec:
  capacity:
    storage: ${PV_SIZE}
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ${STORAGE_CLASS}
  local:
    path: ${STORAGE_PATH}
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - ${NODE_NAME}
EOF

  echo "Applying PV: ${PV_NAME} for node: ${NODE_NAME}"
  kubectl apply -f ${PV_NAME}.yaml
done

echo "✅ All PVs created successfully!"
