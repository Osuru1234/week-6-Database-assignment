**# PostgreSQL Backup, Recovery \& Streaming Replication**



**## Project Overview**



**This project demonstrates PostgreSQL database backup, recovery, Point-in-Time Recovery (PITR), WAL archiving, and streaming replication using PostgreSQL 18 on Windows.**



**The practical work was completed using a primary PostgreSQL server and a separate standby server.**



**## Environment**



**- Database System: PostgreSQL 18.6**

**- Operating System: Windows**

**- Primary Server Port: 5432**

**- Standby Server Port: 5434**

**- Primary Database: `bootcamp`**

**- Replication User: `replicator`**



**## 1. Logical Backup**



**A PostgreSQL custom-format logical backup was created using `pg\_dump`.**



**```bash**

**pg\_dump -Fc -f \~/backups/bootcamp.dump bootcamp**

**```**



**The backup was inspected using `pg\_restore --list` and confirmed to contain the `students` table and its data.**



**The logical backup was successfully restored and verified with:**



**```sql**

**SELECT count(\*) AS student\_count FROM students;**

**```**



**Result:**



**```text**

**student\_count**

**-------------**

**5**

**```**



**## 2. WAL Archiving**



**WAL archiving was configured with:**



**```text**

**wal\_level = replica**

**archive\_mode = on**

**```**



**The Windows archive command was configured to copy WAL files to:**



**```text**

**C:\\Users\\KONZA-VDI\\backups\\wal**

**```**



**Multiple WAL segments were successfully archived.**



**## 3. Base Backup**



**A physical base backup was created using:**



**```bash**

**pg\_basebackup -U postgres -D "%USERPROFILE%\\backups\\base" -Ft -z -Xs -P**

**```**



**The base backup completed successfully at 100%.**



**## 4. Point-in-Time Recovery (PITR)**



**A separate PITR environment was created so that the original PostgreSQL data directory was not damaged.**



**The recovery target was set before the deletion of the `students` table.**



**The PITR server successfully recovered the database and returned:**



**```text**

**student\_count**

**-------------**

**5**

**```**



**This confirmed that the deleted table was recovered to the selected point in time.**



**## 5. Streaming Replication**



**A replication role was created:**



**```sql**

**CREATE ROLE replicator**

**WITH REPLICATION LOGIN PASSWORD 'reppass';**

**```**



**The primary server runs on:**



**```text**

**Port: 5432**

**```**



**The standby server runs on:**



**```text**

**Port: 5434**

**```**



**The standby was created using:**



**```bash**

**pg\_basebackup -h 127.0.0.1 -U replicator \\**

**-D "%USERPROFILE%\\standby" -R -P**

**```**



**The standby was successfully started and verified with:**



**```sql**

**SELECT pg\_is\_in\_recovery();**

**```**



**Result:**



**```text**

**t**

**```**



**This confirmed that the server was operating as a standby.**



**## 6. Replication Health**



**Replication status was checked on the primary using:**



**```sql**

**SELECT application\_name,**

&#x20;      **client\_addr,**

&#x20;      **state,**

&#x20;      **pg\_wal\_lsn\_diff(sent\_lsn, replay\_lsn) AS lag\_bytes**

**FROM pg\_stat\_replication;**

**```**



**Final result:**



**```text**

**application\_name | client\_addr | state     | lag\_bytes**

**-----------------+-------------+-----------+----------**

**walreceiver      | 127.0.0.1   | streaming | 0**

**```**



**This confirmed that the standby was connected and streaming with zero reported WAL lag at the time of the check.**



**## 7. Replication Test**



**A test table was created on the primary:**



**```sql**

**CREATE TABLE replication\_test (**

&#x20;   **id SERIAL PRIMARY KEY,**

&#x20;   **message TEXT**

**);**



**INSERT INTO replication\_test (message)**

**VALUES ('Streaming replication works');**

**```**



**The table and row were then queried from the standby server.**



**The replicated row was successfully visible on the standby, confirming that changes made on the primary were being replicated.**



**## 8. Skills Demonstrated**



**This practical exercise demonstrated:**



**- PostgreSQL logical backups**

**- PostgreSQL physical backups**

**- `pg\_dump`**

**- `pg\_restore`**

**- `pg\_basebackup`**

**- WAL archiving**

**- Point-in-Time Recovery**

**- Recovery using a separate PostgreSQL data directory**

**- PostgreSQL replication roles**

**- `pg\_hba.conf` configuration**

**- Streaming replication**

**- Standby server configuration**

**- Replication monitoring**

**- WAL lag monitoring**

**- Backup and recovery verification**



**## Conclusion**



**The PostgreSQL backup and disaster-recovery environment was successfully implemented and tested.**



**Logical backup and restore were verified, WAL archiving was configured, Point-in-Time Recovery successfully recovered deleted data, and streaming replication was successfully established between the primary and standby servers.**



**Final replication status showed:**



**```text**

**state: streaming**

**lag: 0 bytes**

**```**

