Create Table #DiskInformation
(DISK_Drive nvarchar(100),DISK_num_of_reads  decimal(18,2), DISK_io_stall_read_ms  decimal(18,2),  DISK_num_of_writes decimal(18,2) , DISK_io_stall_write_ms decimal(18,2) , DISK_num_of_bytes_read decimal(18,2), 
DISK_num_of_bytes_written  decimal(18,2), DISK_io_stall decimal(18,2))
 
insert into #DiskInformation
(DISK_Drive ,DISK_num_of_reads  , DISK_io_stall_read_ms  ,  DISK_num_of_writes  , DISK_io_stall_write_ms  , DISK_num_of_bytes_read ,DISK_num_of_bytes_written  , DISK_io_stall)
  
SELECT LEFT(UPPER(mf.physical_name), 2) AS DISK_Drive, 
SUM(num_of_reads) AS DISK_num_of_reads,
SUM(io_stall_read_ms) AS DISK_io_stall_read_ms, 
SUM(num_of_writes) AS DISK_num_of_writes,
SUM(io_stall_write_ms) AS DISK_io_stall_write_ms, 
SUM(num_of_bytes_read) AS DISK_num_of_bytes_read,
	         SUM(num_of_bytes_written) AS DISK_num_of_bytes_written, SUM(io_stall) AS io_stall
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
      GROUP BY LEFT(UPPER(mf.physical_name), 2)
 
SELECT DISK_Drive AS [Ime diska],

ROUND(CAST(
	CASE 
		WHEN DISK_num_of_reads = 0 THEN 0 
		ELSE (DISK_io_stall_read_ms/DISK_num_of_reads) 
	END as decimal (18,2)),2,1) AS  [Latencija čitanja],
	
	ROUND(CAST(
	CASE
		WHEN DISK_io_stall_write_ms = 0 THEN 0 
		ELSE (DISK_io_stall_write_ms/DISK_num_of_writes) 
	END AS decimal (18,2)),2,1) [Latencija pisanja],


	ROUND(CAST(
	CASE 
		WHEN (DISK_num_of_reads = 0 AND DISK_num_of_writes = 0) THEN 0 
		ELSE (DISK_io_stall/(DISK_num_of_reads + DISK_num_of_writes)) 
	END AS decimal (18,2)),2,1) [Ukupna latencija],

	ROUND(CAST(
	CASE 
		WHEN DISK_num_of_reads = 0 THEN 0 
		ELSE (DISK_num_of_bytes_read/DISK_num_of_reads) 
	END AS decimal (18,2)),2,1) [Prosjek Bytes/Čitanje],

	ROUND(CAST(
	CASE 
		WHEN DISK_io_stall_write_ms = 0 THEN 0 
		ELSE (DISK_num_of_bytes_written/DISK_num_of_writes) 
	END AS decimal (18,2)),2,1) [Prosjek Bytes/Pisanje],

	ROUND(CAST(
	CASE 
		WHEN (DISK_num_of_reads = 0 AND DISK_num_of_writes = 0) THEN 0 
		ELSE ((DISK_num_of_bytes_read + DISK_num_of_bytes_written)/(DISK_num_of_reads + DISK_num_of_writes)) 
	END AS decimal (18,2)),2,1) [Prosjek Bytes/Transfer]
from #DiskInformation
ORDER BY [Ukupna latencija] OPTION (RECOMPILE);
Drop table #DiskInformation