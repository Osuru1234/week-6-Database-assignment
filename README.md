 # PostgreSQL Backup, Recovery and Replication Assignment

## Project Overview

This project demonstrates practical PostgreSQL database administration techniques, including logical backups, WAL archiving, physical base backups, Point-in-Time Recovery (PITR), streaming replication, and replication monitoring.

## Environment

- PostgreSQL Version: 18.6
- Operating System: Windows
- Primary PostgreSQL Port: 5432
- Standby PostgreSQL Port: 5434
- Database: `bootcamp`

---

## Step 1 Solution: Logical Backup

- `pg_dump -Fc` creates a compressed, portable backup.
- `pg_restore --list` confirms the contents of the backup.
- Restoring into `bootcamp_check` verifies that the backup can be restored successfully.

### Verification

The restored `students` table contained:

```text
student_count
-------------
5
```

---

## Step 2 Solution: WAL Archiving

- `wal_level = replica` enables features required for replication and point-in-time recovery.
- WAL files are archived for later replay during recovery.
- A base backup provides the starting point for recovery.
- `pg_switch_wal()` was used to generate and archive WAL activity for testing.

---

## Step 3 Solution: Point-in-Time Recovery

- WAL replay restores database changes up to a specified timestamp.
- The deleted `students` table was recovered because recovery stopped before the deletion occurred.
- This demonstrates how PITR can recover data without restoring the entire database from scratch.

### Verification

After PITR, the recovered `students` table contained:

```text
student_count
-------------
5
```

---

## Step 4 Solution: Streaming Replication

- A dedicated replication role named `replicator` was configured.
- `pg_basebackup -R` was used to create and configure the standby.
- The standby continuously receives and replays WAL from the primary server.

### Standby Verification

```text
pg_is_in_recovery()
-------------------
t
```

The value `t` confirms that the server was operating as a standby/recovery server.

---

## Step 5 Solution: Replication Monitoring

Replication was monitored using `pg_stat_replication`.

The verified result was:

```text
application_name | client_addr | state     | lag_bytes
-----------------+-------------+-----------+----------
walreceiver      | 127.0.0.1   | streaming | 0
```

This confirmed that the standby was connected and streaming WAL from the primary with zero reported lag at the time of testing.

---

## Step 6 Solution: Replication Test

A test table was created on the primary:

```sql
CREATE TABLE replication_test (
    id SERIAL PRIMARY KEY,
    message TEXT
);
```

A test record was inserted:

```sql
INSERT INTO replication_test (message)
VALUES ('Streaming replication works');
```

The record was then checked on the standby server, confirming that the change had successfully replicated.

---

## Final Outcome

This assignment demonstrated practical PostgreSQL database administration skills, including:

- Creating and verifying database backups
- Performing logical restore
- Configuring WAL archiving
- Performing physical base backups
- Performing Point-in-Time Recovery
- Configuring streaming replication
- Monitoring replication health
- Verifying recovered and replicated data

These techniques are important for improving database availability, recovery, and data protection.

## Files Included

- `README.md` — Project documentation and results
- `commands.sql` — Main PostgreSQL commands and SQL used
- `evidence.txt` — Verified test results and evidence

## Conclusion

The project successfully demonstrated backup, recovery, and replication procedures using PostgreSQL 18.6 on Windows. The successful recovery of five student records and the verified streaming replication state demonstrate that the configured procedures worked during testing.
