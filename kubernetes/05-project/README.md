# 05-Project - Persistent Volumes (PV) & Persistent Volume Claims (PVC) Example

- **What it is**:
  - **Persistent Volume (PV)**: A piece of storage provisioned by an admin.
  - **Persistent Volume Claim (PVC)**: A request for storage by a user.
- **Purpose**: Provides persistent storage to pods, retaining data even if a pod is deleted or rescheduled.
- **Why we use it**: Pods have ephemeral storage, meaning data is lost when a pod restarts. PV/PVC ensures data persists.
- **Real-life Example**:
  - PV: A “locker” (storage) available to all students (pods).
  - PVC: A student (pod) claiming a specific “locker” to keep their books safe.

## How to Configure and Use with Pods

- **Create a Persistent Volume (PV)**:

     ```yaml
     apiVersion: v1
     kind: PersistentVolume
     metadata:
       name: pv-example
     spec:
       capacity:
         storage: 1Gi
       accessModes:
         - ReadWriteOnce
       hostPath:
         path: /mnt/data
     ```

- **Create a Persistent Volume Claim (PVC)**:

     ```yaml
     apiVersion: v1
     kind: PersistentVolumeClaim
     metadata:
       name: pvc-example
     spec:
       accessModes:
         - ReadWriteOnce
       resources:
         requests:
           storage: 1Gi
     ```

- **Mount PVC in a Pod**:

     ```yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: nginx-pod
     spec:
       containers:
       - name: nginx
         image: nginx
         volumeMounts:
         - mountPath: "/usr/share/nginx/html"
           name: storage
       volumes:
       - name: storage
         persistentVolumeClaim:
           claimName: pvc-example
     ```
