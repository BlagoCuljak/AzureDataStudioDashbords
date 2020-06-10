with fs
as
(
    select database_id, type, size * 8.0 / 1024 size
    from sys.master_files
)
select top 10
    name,
    (select sum(size) from fs where type = 0 and fs.database_id = db.database_id) [Veličina podataka],
    (select sum(size) from fs where type = 1 and fs.database_id = db.database_id) [Veličina loga]
from sys.databases db
where database_id > 4
order by [Veličina podataka] desc
