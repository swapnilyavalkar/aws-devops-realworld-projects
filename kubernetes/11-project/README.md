# 11-Project - Jobs and CronJobs Example

- **Jobs**:
  - **What it is**: Manages one-time tasks that are expected to terminate after completion.
  - **Purpose**: Ensures that a task runs to completion even if a pod fails and restarts.
  - **Real-life Example**: It’s like setting a “one-time alarm” to wake you up in the morning.
  - **How to create**:

       ```yaml
       apiVersion: batch/v1
       kind: Job
       metadata:
         name: batch-job
       spec:
         template:
           spec:
             containers:
             - name: batch-task
               image: busybox
               command: ["echo", "Hello, World"]
             restartPolicy: OnFailure
       ```

- **CronJobs**:
  - **What it is**: A type of Job that runs on a schedule (like a cron in Linux).
  - **Purpose**: Schedules regular tasks, such as backups, reports, or maintenance.
  - **Real-life Example**: It’s like setting a “recurring alarm” that wakes you up every day at a specific time.
  - **How to create**:

       ```yaml
       apiVersion: batch/v1
       kind: CronJob
       metadata:
         name: cron-job
       spec:
         schedule: "*/5 * * * *"
         jobTemplate:
           spec:
             template:
               spec:
                 containers:
                 - name: cron-task
                   image: busybox
                   command: ["echo", "Scheduled Task"]
                 restartPolicy: OnFailure
       ```
