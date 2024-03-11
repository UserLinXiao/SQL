1、将表中数据复制到新表中

```mssql
SELECT * INTO CourseWillNum
FROM Course
WHERE WillNum>=40
```

2、约束

```mssql
数据完整性
域完整性：检查约束、默认约束、非空约束
实体完整性：主键约束(不可为空，唯一值)、唯一约束、标识列
引用完整性：外键约束
自定义完整性：触发器

（1）为Student表创建基于StuNo列名为PK_Student的主键约束
ALTER TABLE Student  ADD CONSTRAINT PK_Student PRIMARY KEY (StuNo)

（2）添加唯一约束
ALTER TABLE Course   ADD CONSTRAINT UN_CouName UNIQUE(CouName)

（3）检查约束
alter table Student  WITH NOCHECK  add CONSTRAINT ck_borndate check (borndate>'1980-01-01')

(4)默认约束
alter table student add ConSTRAINT  DF_address  default ('地址不详') for address

(5)外键约束
/*外键约束名为FK_StuCou_Student。StuCou表StuNo列值要参照Student 表StuNo列值。*/
ALTER TABLE StuCou ADD CONSTRAINT FK_StuCou_Student FOREIGN KEY (StuNo) REFERENCES Student (StuNo)


create table student(
studentNo in identity(1,1) primary key  not null,
inentitycard nvarchar(18)  uniqe not null,
borndate datetime check(borndate>'1980-01-01'),
address  nvarchar(50) null defaule('地址不详'),
gradeid int not null references grade(gradeid)
)

--删除约束 
ALTER TABLE Course DROP CONSTRAINT UN_CouName 
```

3、创建索引

```mssql
CREATE [UNIQUE|CLUSTERED] INDEX INDEX_NAME ON TABLE_NAME(列名)
UNIQUE：唯一索引

创建唯一非聚集索引
create unique nonclustered index IX_GoodsMade_Labour on GoodsMade_Labour(SID)

ALTER TABLE dbo.mmMaterial ADD CONSTRAINT un_sMaterialName UNIQUE(sMaterialName)

CREATE UNIQUE NONCLUSTERED INDEX IND_sMaterialName ON dbo.mmMaterial(sMaterialName)
```

4、事务

```mssql
DECLARE @myError INT =0
-- 全局变量 @@ERROR
--sql 语句执行成功  @@error=0    
--sql 语句执行失败  @@error>0    

BEGIN TRANSACTION 
--判断 
--语句

SET @myError=@myError+@@ERROR

IF @myError<>0
BEGIN
ROLLBACK TRANSACTION
PRINT ('业务办理失败!')
END 
ELSE 
BEGIN
COMMIT TRANSACTION
PRINT ('业务办理成功!')
END
```

5、存储过程OutPut和返回值

```mssql
ALTER   PROCEDURE testHR
(@s1 NVARCHAR(50) OUTPUT,
@s2 NVARCHAR(50) OUTPUT
)
AS 
BEGIN 
SELECT @s2=a.sEmployeeNameCN FROM dbo.hrEmployee A(NOLOCK) WHERE a.sEmployeeNo=@s1
RETURN 1
END 
GO

DECLARE @s1 NVARCHAR(50)='100564236', @s2 NVARCHAR(50);
DECLARE @i int
EXEC  @i=dbo.testHR @s1 = @s1 OUTPUT,   -- nvarchar(50)
                @s2 = @s2 OUTPUT    -- nvarchar(50)

SELECT @s1,@s2 ,@i

```

6、优化后查询语句

```mssql
alter PROCEDURE QuerySwipeCard
@dStart DATE,
@dEnd DATE,
@sOrderNo NVARCHAR(50),
@sStyleNo NVARCHAR(50),
@sEmployeeNameCN NVARCHAR(50)
AS
BEGIN 
SET NOCOUNT ON

SELECT a.sPackBarcode,a.sOrderNo,a.sContractNO,a.sStyleNo,a.sEmployeeNo,
a.sColorName,a.sSizeName,a.iPackageNo,a.sProcedureName,a.sEmployeeNameCN,a.iQty,a.iEmployeeCardID,
 CAST(a.dOutputDate AS DATE ) AS dOutputDate,a.iMaterialCardID INTO #tempoutput FROM RFIDOutput a (NOLOCK) 
 WHERE CAST(a.dOutputDate AS date)>=@dStart AND CAST(a.dOutputDate AS date)<=@dEnd
 AND (a.sOrderNo LIKE  +'%'+@sOrderNo+'%')
 AND (a.sStyleNo LIKE +'%'+ @sStyleNo +'%' )
 AND (a.sEmployeeNameCN LIKE +'%'+ @sEmployeeNameCN+'%')
order by a.dOutputDate DESC
OPTION (LOOP JOIN,HASH JOIN, MAXDOP 1,FORCE ORDER,ROBUST PLAN)

SELECT a.sPackBarcode,p.sBedOrder,a.sOrderNo,a.sContractNO,a.sStyleNo,p.sLotNo
,S.sStyleDesc,a.sColorName,a.sSizeName,a.iPackageNo,a.sProcedureName,p.sPartName, e.sDeptName AS sDeptFullName,a.sEmployeeNameCN,a.iQty
,a.dOutputDate,a.iMaterialCardID  FROM #tempoutput a 
 LEFT JOIN WTPMPackageBillDtl (nolock) T on t.sWorkTicketBarCode=a.sPackBarcode
 LEFT JOIN WTPMPackageBillMst p (nolock) ON t.iWTPMPackageBillMstId = p.iid
--LEFT JOIN KQA_hrEmployeeRelation er (NOLOCK) ON er.sCardNo=a.iEmployeeCardID
 LEFT JOIN hrEmployee e (NOLOCK) ON e.sEmployeeNo=a.sEmployeeNo
--LEFT JOIN hrDept d (NOLOCK) ON d.uGUID=e.uhrDeptGUID
 LEFT JOIN dbo.sdStyle S ON S.sStyleNo=A.sStyleNo

 order by a.dOutputDate desc
 OPTION ( MAXDOP 1)//OPTION(FAST 1000,MAXDOP 1)
DROP TABLE #tempoutput


SET NOCOUNT off
END 
GO

```

7、创建主键约束

```mssql
--为Department表创建基于DepartNo列名为PK_Department的主键约束

ALTER TABLE Department
ADD CONSTRAINT PK_Department PRIMARY KEY (DepartNo)


create table Department(
departno nvarchar(30),
departname nvarchar(30)
CONSTRANT PK_Department
PRIMARY KEY(departno)
)
```

8、like用法

```mssql
 ClassName LIKE '%'+@ClassName+'%'
```

9、程序集报错处理办法

```mssql
RECONFIGURE WITH OVERRIDE;
exec sp_configure 'show advanced options', '1';
go 
ALTER DATABASE HSGMTHYYM SET TRUSTWORTHY on;

```

10、纵转横

```mssql

IF OBJECT_ID('tempdb..#t1') IS NOT NULL
DROP TABLE #t1

SELECT TOP  100 sStyleNo,sLotNo,sColorName,sSizeName,sEmployeeNameCN,iReWorkProcedureID,sReWorkProcedureName,iqty INTO #t1
FROM dbo.RFIDReWork ORDER BY tCreateTime DESC,iReWorkProcedureID asc

CREATE TABLE #t2(id int)
	EXEC dbo.sppbPivotEx
	    @sSqlText = N'SELECT * FROM #t1 ',  -- nvarchar(max)  数据源
	    @sFixedFields = N'sStyleNo,sLotNo,sColorName,sSizeName,sEmployeeNameCN,iReWorkProcedureID',                            -- nvarchar(4000) 固定列名
	    @sFixedRightFields = N'',                       -- nvarchar(4000)
	    @sNameField = N'sReWorkProcedureName',                              -- nvarchar(50) 动态列标题字段
	    @sValueField = N'iqty',                             -- nvarchar(50)   值列
	    @sGroupFunction = N'sum',                          -- nvarchar(50)   求和
	    @sOrderFields = N'iReWorkProcedureID ',                            -- nvarchar(500) 固定列排序
	    @sNameSQLText = N'	SELECT  sReWorkProcedureName FROM 
		(SELECT distinct sReWorkProcedureName,iReWorkProcedureID FROM #t1 )t order by iReWorkProcedureID ',   -- nvarchar(max) 获取动态列标题字段值
	    @sNameCaptionField = N'',                       -- nvarchar(max)
	    @sNullDefaultValue = N'',                       -- nvarchar(50)
	    @sNameFieldNullValue = N'',                     -- nvarchar(50)
	    @sTempTableName = N'#t2',                          -- nvarchar(50)  获取转化后的数据源表名字
	    @bPivotColumnEmptyReturnFixedColumnsData = 1 -- bit  默认为1 


	
		
		SELECT * FROM #t2

	IF OBJECT_ID('tempdb..#t2') IS NOT NULL
DROP TABLE #t2


--pivot函数用法
SELECT * FROM #rt AS p pivot(SUM(iReWorkQty) for sReWorkProcedureName in([耳袢 异常],                         
[浮线 外露线],                                       
[上亢下亢],                                          
[少压一道线])) AS v



select ts.studnet_name,
'C语言' as 科目,
ts.`C语言` as 成绩
from t_student1 ts
union all
select ts.studnet_name,
'数据结构' as 科目,
ts.`数据结构` as 成绩
from t_student1 ts
union all
select ts.studnet_name,
'操作系统' as 科目,
ts.`操作系统` as 成绩
from t_student1 ts
order by studnet_name,科目


```

11 删除列名

```mssql
ALTER  TABLE osContractMaterialDtl DROP COLUMN iIden ;
```

12、创建表

```mssql
CREATE TABLE puConsumableHdr
(
[uGUID] [uniqueidentifier] NOT NULL PRIMARY KEY ,
[tCreateTime] [datetime] NOT NULL ,
[sRemark] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[sBillNo] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[iBillStatus] [int] NULL,
[iNoteTypeId] [int] null,  
[sConfirmMan] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[tConfirmTime] [datetime] NULL,
[sAuditMan] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[tAuditTime] [datetime] NULL,
[sCreator] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[sUpdateMan] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[tUpdateTime] [datetime] NULL
CONSTRAINT puConsumableHdr_uGUID  UNIQUE(uGUID)
) 


  CREATE TABLE puConsumableDtl(
  uGUID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
  upuConsumableHdrGUID UNIQUEIDENTIFIER NOT NULL FOREIGN KEY(upuConsumableHdrGUID) REFERENCES dbo.puConsumableHdr(uGUID),
  sMaterialName NVARCHAR(50) NOT NULL ,
  sunit NVARCHAR(10),
  nQty DECIMAL(18,2),
  nPrice DECIMAL(18,2),
  nAmount DECIMAL(18,2),
  sProvider NVARCHAR(50),
  sConsumableDtlRemark NVARCHAR(80),
  uRefDtlGUID UNIQUEIDENTIFIER
  CONSTRAINT puConsumableDtl_uGUID  UNIQUE(uGUID)
  )


```

13、延迟执行

```mssql
WAITFOR TIME '16:29:00'   --等待16:29:00 之后执行


WAITFOR DELAY '00:01:30'  --等待1分30秒后执行

SELECT * 
FROM dbo.hrEmployee a(NOLOCK)
WHERE EXISTS (
SELECT sEmployeeNameCN 
FROM dbo.hrEmployee
WHERE sEmployeeNameCN=a.sEmployeeNameCN
GROUP BY sEmployeeNameCN 
HAVING COUNT(sEmployeeNameCN)>1
)
ORDER BY sEmployeeNameCN 
```

14、查看索引

```mssql
SELECT 
CASE
	WHEN t.[type] = 'U' THEN '表'
	WHEN t.[type] = 'V' THEN '视图'
END AS '类型',
SCHEMA_NAME(t.schema_id) + '.' + t.[name] AS '(表/视图)名称',
i.[name] AS 索引名称,
SUBSTRING(column_names, 1, LEN(column_names) - 1) AS '列名',
CASE
           WHEN i.[type] = 1 THEN
               '聚集索引'
           WHEN i.[type] = 2 THEN
               '非聚集索引'
           WHEN i.[type] = 3 THEN
               'XML索引'
           WHEN i.[type] = 4 THEN
               '空间索引'
           WHEN i.[type] = 5 THEN
               '聚簇列存储索引'
           WHEN i.[type] = 6 THEN
               '非聚集列存储索引'
           WHEN i.[type] = 7 THEN
               '非聚集哈希索引'
       END AS '索引类型',
       CASE
           WHEN i.is_unique = 1 THEN
               '唯一'
           ELSE
               '不唯一'
       END AS '索引是否唯一'
FROM sys.objects t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
CROSS APPLY
(
    SELECT col.[name] + ', '
    FROM sys.index_columns ic
    INNER JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
    WHERE ic.object_id = t.object_id AND ic.index_id = i.index_id
    ORDER BY col.column_id
    FOR XML PATH('')
) D(column_names)
WHERE t.is_ms_shipped <> 1
      AND index_id > 0
	  AND t.[name]='rfidoutput'
ORDER BY i.[name];


```

15、构建年月

```mssql
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
CREATE PROCEDURE QueryMonth
AS 
BEGIN
IF OBJECT_ID('tempdb..#ty') IS NOT NULL
DROP TABLE #ty
CREATE TABLE #ty(
tn NVARCHAR(30)
)
DECLARE @ji INT
SET @ji=0
WHILE @ji<=24
BEGIN
INSERT INTO #ty
SELECT FORMAT(DATEADD(MONTH,-@ji,GETDATE()) ,'yyyy-MM') 
SET @ji=@ji+1
end

SELECT * FROM #ty

DROP TABLE #ty
END 
GO
```

16、向上取整函数

```mssql
  SELECT CEILING(3.1)
  
  返回：4
```

17、时间

```mssql
SELECT  CONVERT(NVARCHAR(10),GETDATE()-DAY(GETDATE())+1,120)   --每月第一天
SELECT DATEADD(Day,-1,CONVERT(char(8),DATEADD(Month,1,GETDATE()),120)+'1')  --每月最后一天

SELECT CONVERT(VARCHAR(10),GETDATE(),121)  --当天

SELECT  DATEADD(MONTH,-12,GETDATE())   --去年的当天
```

```mssql
--筛选时间为周日

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

CREATE FUNCTION  dbo.spmGetWeek
(
 @st DATE,
 @et DATE
)
RETURNS @returntable TABLE
(
    CostTime DATE
)
AS 
BEGIN

DECLARE @t TABLE(date0 DATETIME);


WHILE @st<@et BEGIN
    INSERT INTO @t VALUES(@st);
    SELECT @st=DATEADD(DAY, 1, @st);
END;

INSERT @returntable(CostTime)
SELECT  date0
FROM @t
WHERE DATEPART(WEEKDAY, date0+@@DATEFIRST-1) IN (7) AND 
 (SELECT bset FROM  QCSet)=1


INSERT @returntable(CostTime)
SELECT dDate FROM pbCommonDateShield
WHERE (SELECT bset FROM  QCSet)=1




RETURN

END 



GO
```



18、触发器 

###### 触发器的定义

触发器其实就是一个特殊的存储过程,这个存储过程呢,不能调用罢了, 而是当数据发生变化的时候才触发了这个过程。

###### 触发器的分类

1）DDL触发器，针对数据库跟新的变化，主要以create、drop、alter开头的语句的触发。

2）DML触发器，

​	for/after 触发器（动作完成后触发）后置触发器  ||   instead of 就是执行某个操作之前    前置触发器

insert触发器

delete触发器

update触发器



3）登录触发器

触发器的格式

```

IF object_id('trigger','tr') is not null  --(trigger指触发器名称)
begin 
    drop trigger trigger
end
go
---判断触发器是否存在

CREATE TRIGGER trigger_name
 
ON table_name
 
[WITH ENCRYPTION]  --给触发器文本加密
 
FOR|after |instead of  [DELETE, INSERT, UPDATE]   ---多加一句after和for 是一个功能, 用一个就好了
 
AS
 
  T-SQL语句
 
GO
```

```mssql
-- 1、触发器创建 （DELETE 删除前的操作）
CREATE TRIGGER tri_deleteRFIDOutput 
ON dbo.RFIDOutput  FOR  DELETE
AS
DECLARE @i INT=0,@j BIGINT

SELECT @j=iID,@i=iqty FROM Deleted A
BEGIN TRANSACTION
IF @i>0
BEGIN
ROLLBACK TRANSACTION
PRINT ('删除失败')
END 
ELSE 
begin
DELETE FROM dbo.RFIDOutput WHERE iID=@j
COMMIT TRANSACTION
PRINT('删除成功')
END 

GO 


-- 2、触发器创建 （insert 添加前的操作）
-----------------------------------
CREATE TRIGGER tri_insertRFIDOutput 
ON dbo.RFIDOutput  FOR  INSERT 
AS
DECLARE @i INT=0,@j BIGINT,@s NVARCHAR(50)

SELECT @j=iID,@s=Inserted.sCreator FROM Inserted
BEGIN TRANSACTION
IF @s<>'cttsoft'
BEGIN
ROLLBACK TRANSACTION
PRINT ('添加失败')
END 
ELSE 
begin
COMMIT TRANSACTION
PRINT('添加成功')
END 

GO 


	 
--3	触发器创建 （update 触发器 ）


```

19、触发器的inserted和deleted表

| 修改操作         | inserted表 | deleted表 |
| ------------ | --------- | -------- |
| 增加（INSERT）记录 | 存放新增的记录   | --       |
| 删除（DELETE）记录 | --        | 存放被删除的记录 |
| 修改（UPDATE）记录 | 存放更新后的记录  | 存放跟新前的记录 |

​                                                                       inserted和deleted表存放的信息



20、sqlserver 日志

```mssql
--SQL2008清空删除日志:
USE [master]
GO
ALTER DATABASE AFMS SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER DATABASE AFMS SET RECOVERY SIMPLE
GO
USE AFMS
GO
DBCC SHRINKFILE (N'AFMS_Log' , 11, TRUNCATEONLY) 
GO
USE [master]
GO
ALTER DATABASE AFMS SET RECOVERY FULL WITH NO_WAIT
GO
ALTER DATABASE AFMS SET RECOVERY FULL
GO

---sqlserver2000压缩日志
DUMP TRANSACTION [jb51] WITH NO_LOG 
BACKUP LOG [jb51] WITH NO_LOG 
DBCC SHRINKDATABASE([jb51])
```

21、OPTION减少查询时间

```mssql
OPTION(MAXDOP 2048,FORCE ORDER,RECOMPILE,ORDER GROUP)  --jion
```

22、链接服务器操作

```mssql
两个表不在同一个数据库下且ip地址不同

查询两个表 就得用链接服务器操作
```

23、缺少*************对象

```mssql
1、就是缺少*******表
2、缺少*******字段
```



24、更改数据库可信状态(MS SQL)

在成功还原了数据库J_DB之后，进行查询时提示错误：

在尝试加载程序集 ID 65659 时 Microsoft .NET Framework 出错。
服务器可能资源不足，或者不信任该程序集，因为它的 PERMISSION_SET 设置为 EXTERNAL_ACCESS 或 UNSAFE。
请重新运行查询，或检查有关的文档了解如何解决程序集信任问题。
有关此错误的详细信息: System.IO.FileLoadException: 
未能加载文件或程序集“des, Version=0.0.0.0, Culture=neutral, PublicKeyToken=nu…………



在网上查找资料发现，原因应该是

在备份数据库的时候,在机器A,那么数据库的拥有者是A\Administrator(如果用windows登录创建),那么但是我们还原到服务器B,那么拥有者可能是B\Administrator,那么SQL CLR的安全性会认为该程序集不可靠.

按如下步骤操作即可：

(１).　exec sp_configure 'show advanced options', '1';

go
reconfigure;
go
exec sp_configure 'clr enabled', '1'
go
reconfigure;    --如果执行失败,就用这个RECONFIGURE WITH OVERRIDE;
exec sp_configure 'show advanced options', '1';
go 



(２).查SID在sys.databases 和sys.server_principals是否一致

```mssql
SELECT * FROM sys.server_principals;
```

SELECT * FROM sys.sysdatabases ;

(3).查看程序集是否存在

```mssql
SELECT * FROM sys.assemblies;SELECT * FROM sys.assembly_files;
```

1. 修改为ON
   ALTER DATABASE J_DB SET TRUSTWORTHY on;

(5).注意所有者

```mssql
exec sp_changedbowner 'sa'
```

25、截取字符串

```mssql
SELECT SUBSTRING(sDescription,CHARINDEX(',',sDescription,1)+1,LEN(sDescription)) FROM dbo.RFIDBoxScanCustEanData
```

26、查看语句执行

```mssql
SELECT TOP 100000
 (total_logical_reads + total_logical_writes) AS total_logical_io,
 (total_logical_reads / execution_count) AS avg_logical_reads,
(total_logical_writes / execution_count) AS avg_logical_writes,
(total_physical_reads / execution_count) AS avg_phys_reads,
substring (st.text,
(qs.statement_start_offset / 2) + 1,
((CASE qs.statement_end_offset WHEN -1
 THEN datalength (st.text)
ELSE qs.statement_end_offset END
 - qs.statement_start_offset)/ 2)+ 1)
 AS statement_text,

*

FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
ORDER BY total_logical_io DESC 
```

27、join

```mssql
1   CROSS JOIN  将A表的所有行分别与B表的所有行进行连接
select * from tableA cross join tableB;


2、 CROSS APPLY 仅返回外部表中通过表值函数生成结果集的行。
CREATE TABLE Personnel
(id VARCHAR(4) NOT NULL,
name VARCHAR(10) NOT NULL,
dept_id VARCHAR(2) NOT NULL,
age INTEGER,
gzsj DATE,
echnical_post VARCHAR(10),
salary INTEGER
)

SELECT p.id,p.name AS 姓名,p.dept_id FROM dbo.Personnel P
CROSS APPLY (SELECT * FROM dbo.Personnel A WHERE a.name IN ('张三','李4'))t 
WHERE t.dept_id=p.dept_id

OUTER APPLY 既返回生成结果集的行，也返回不生成结果集的行，其中表值函数生成的列中的值为 NULL。

3. UNION（隐式的DISTINCT）

UNION（隐式的DISTINCT）不但组合两个输入集合，而且还将消除重复的数据行。如果某一行出现在两个输入集合中，那么它在结果集合中仅出现一次。由于排除了重复的数据行，因此需要额外的系统开销。
　　
4、left join

5、inner join（join）

6、right join

7、full join
```

28、id转为uGUID

```mssql
 CONVERT(UNIQUEIDENTIFIER,CONVERT(BINARY(16),100))
```

29、创建全局临时表

```mssql
create table ##db_local_table  
(  
  id  int,  
  name varchar(50),  
  age int,  
  area int  
)  
```

30、创建含有计算字段的数据库表

```mssql
use db_sqlserver;  
go  
create table db_table8  
(  
  职工编号 int primary key,  
  职工号 varchar(50) unique,  
  仓库号 varchar(50),  
  基本工资 int check(基本工资>=800 and 基本工资<=2100),  
  加班工资 int,  
  奖金 int,  
  扣率 int,  
  应发工资 as (基本工资 + 加班工资 + 奖金 - 扣率)  
)  
```

31、sp_executesql用法 (动态)

```mssql
exec sp_executesql N'select * from HSGMT_ERP_SEDUNO..smSysRegInfo where "sIP"=@P2',N'@P2 nvarchar(4000)','192.168.1.2'

exec sp_executesql N'select * from HSGMT_ERP_SEDUNO..smSysRegInfo'


EXEC sys.sp_executesql N'update smSysRegInfo set "sWelcomeWord"=@p1 where "uGUID"=@P2',N'@P1 nvarchar(100),@P2 UNIQUEIDENTIFIER',          --注：英文双引号     
'Hello World','77F2D43E-8FD2-4B0A-A9EF-2D358D0EEAE5'


declare @max_title NVARCHAR(max)
EXECUTE sp_executesql @SQLString, @ParmDefinition, @level = @IntVariable, @max_titleOUT=@max_title OUTPUT;
SELECT @max_title;

第一个参数sqlstring 就是执行的sql字符串了
第二个参数@ParmDefinition是@sqlstring里边用到的参数在这里声明 输出的参数要加output  
最后的参数加output的参数是输出的参数（需要和外部的相对应的变量建立关联）
中间的参数就是@sqlstring 里边用到的参数（需要和外部的相对应的变量建立关联）
最后你可以 select 输出的参数 来查询(select @count)

--------以列名、表名、数据库名作为参数，须使用动态sql来执行-------
DECLARE @s_table NVARCHAR(500),@s_schma NVARCHAR(500),@s_fulltable NVARCHAR(500),
@sql  NVARCHAR(MAX)
SET @s_table='rt'
SET @s_schma='dbo'
SET @s_fulltable=@s_schma+'.'+@s_table
IF OBJECT_ID(@s_fulltable,'U') IS NOT NULL
BEGIN
	   SET @sql='drop table'+' '+@s_fulltable
       EXEC sp_executesql  @sql
	  
END

IF 1=1
BEGIN 
SET @sql='SELECT   TOP 1000 sEmployeeNameCN,sStyleNo,iqty INTO '+@s_table+' '+
'FROM dbo.RFIDOutput(NOLOCK) ORDER  BY tCreateTime DESC'
	EXEC  sp_executesql @sql;

```

32、更新列名

```mssql
EXEC sp_rename '表名.[原列名]', '新列名', 'COLUMN'
```

33、批量查询/删除  表

```mssql
SELECT TOP 10
'Name'          = o.name,
'Owner'         = user_name(ObjectProperty( object_id, 'ownerid')),
'Object_type'   = substring(v.name,5,31),
id=IDENTITY(INT,1,1)
INTO #tablename
from sys.all_objects o, master.dbo.spt_values v
where o.type = substring(v.name,1,2) collate catalog_default and v.type = 'O9T' AND substring(v.name,5,31)='user table'
order by [Owner] asc, Object_type desc, Name ASC

DECLARE @i INT=1,@icount int=(SELECT COUNT(id) FROM #tablename )
DECLARE @tablename NVARCHAR(100)
WHILE @i<=@icount
BEGIN
SELECT	@tablename=Owner+'.'+Name FROM #tablename WHERE id=@i

DECLARE @sql NVARCHAR(300)=N'SELECT top 10 * FROM '+@tablename
EXEC sp_executesql @sql  --,N'@tablename NVARCHAR(100)',@tablename
SET @i=@i+1
END

DROP TABLE #tablename
```

34、系统表

```mssql
SELECT * FROM sys.all_objects --所有对象表
WHERE type='U'  --3582080

SELECT * FROM sys.objects --对象表   关联字段 object_id,user_type_id,schema_id
SELECT * FROM sys.schemas  --模式    关联字段 schema_id
SELECT * FROM sys.columns  --列名表   关联字段 object_id
SELECT * FROM sys.types  --数据类型表  关联字段 user_type_id



CREATE VIEW dbo.dvColumns
WITH ENCRYPTION
AS
	SELECT iColumnId=A.colid,sColumnName=A.name,sTableName=B.name
		,sType=C.name,bIsNullable=CONVERT(Bit,A.isnullable)
		,nLength=CASE WHEN C.name in ('nchar','nvarchar') THEN A.Length/2 ELSE A.Length END
		,xPrec=A.xprec,xScale=A.xscale,bIsComputed=CONVERT(Bit,IsNull(A.IsComputed,0))
		--,bIsAutoValue=CONVERT(Bit,CASE IsNull(A.autoval,0) WHEN 0 THEN 0 ELSE 1 END)
		,bIsAutoValue=CONVERT(Bit,COLUMNPROPERTY(a.id,a.name,'IsIdentity'))
		,sInsertDefaultValue=dbo.fnpbGetExtendProperty(B.name+'.'+A.name,'sInsertDefaultValue')
		,sUpdateDefaultValue=dbo.fnpbGetExtendProperty(B.name+'.'+A.name,'sUpdateDefaultValue')
	FROM dbo.syscolumns A WITH(NOLOCK)
	INNER JOIN dbo.sysobjects B WITH(NOLOCK) ON B.id = A.id
	INNER JOIN dbo.systypes C WITH(NOLOCK) ON A.xUserType=C.xUserType
	WHERE b.xtype IN ('U','V')
GO

SELECT * FROM dbo.dvColumns
```

35、

```mssql
IIF(ISNUMERIC(ISNULL(A.weight,0))=1,CAST(a.weight AS NUMERIC),0) 
```



36、取出每个部门前5名产量最多的

```mssql
SELECT TOP 20000 sDeptNo,sEmployeeNameCN,SUM(a.iQty) AS iqty
INTO #temp001
FROM dbo.RFIDOutput(NOLOCK)  A
WHERE sDeptNo IN ('1003','1004','1005','1006','1007','1008')
GROUP BY sDeptNo,sEmployeeNameCN

SELECT * FROM(
select *, 
      DENSE_RANK() over (partition by sDeptNo
                   order by iqty desc) as ranking
from #temp001) A
where ranking <=3



---------------------------------------------
----####从临时表temp01中，有多少组别不清楚，从每个组别中抽取20%的数据显示  
IF OBJECT_ID('tempdb..#temp01 ') IS NOT NULL
begin
DROP  TABLE #temp001
END

SELECT TOP 20000 sDeptNo,sEmployeeNameCN,SUM(a.iQty) AS iqty
INTO #temp001
FROM dbo.RFIDOutput(NOLOCK)  A
WHERE A.sDeptNo IS NOT NULL AND A.sDeptNo<>''
GROUP BY sDeptNo,sEmployeeNameCN

SELECT a.* 
FROM(
select *, 
      ROW_NUMBER() over (partition by sDeptNo
                   order by iqty desc) as ranking
from #temp001) A
,
(select sDeptNo,  FLOOR(COUNT(sEmployeeNameCN)*0.2)  AS i  
from #temp001
GROUP BY sDeptNo)b
WHERE  a.sDeptNo=b.sDeptNo AND   B.i>0 AND   A.ranking<=b.i 
-----------------------------------------------------------------

------####重点###----------
-----产量均分----------------------------------
/*实例描述  字段sEmployeeNameCN为：朱训汉,高玲风,金霞珠,陈琰，四人姓名串联，中间逗号相隔，产量为100，计算每个人的产量*/
CREATE TABLE er
( id INT IDENTITY(1,1) PRIMARY KEY,
iQty INT ,
sEmployeeNameCN NVARCHAR(1000),
sDiff01 NVARCHAR(100),
sDiff02 NVARCHAR(100)
)
--SELECT * FROM dbo.er
INSERT INTO dbo.er
(
    iQty, sEmployeeNameCN, sDiff01, sDiff02
)
VALUES (
           1000,   -- iQty - int
           N'朱训汉,高玲风,金霞珠,陈琰', -- sEmployeeNameCN - nvarchar(1000)
           N'', -- sDiff01 - nvarchar(100)
           N''  -- sDiff02 - nvarchar(100)
       )


SELECT A.id,
       CAST( (A.iQty/T.i) AS DECIMAL(18,2)) AS iQty,
       T.value AS sEmployeeNameCN
	   ,*
FROM dbo.er A(NOLOCK)
CROSS APPLY
(SELECT value ,f.i
FROM STRING_SPLIT(a.sEmployeeNameCN,',') 
CROSS APPLY (SELECT COUNT(*) AS i FROM STRING_SPLIT(a.sEmployeeNameCN,',')) f
)T
----产量均分------------------------------------------------------
```

37、查看执行的sql语句

```mssql
SELECT DISTINCT TOP 1000  cacheobjtype,objtype,usecounts,sql,bucketid
 from sys.syscacheobjects where sql not like'%cach%' and sql not like '%sys.%' 
 AND sql not LIKE '%update smMsgLog%' AND sql not like'%UPDATE A SET tLastRefreshTime%'
 ORDER BY bucketid DESC 
 
 
SELECT a.creation_time,a.last_execution_time,b.*
FROM sys.dm_exec_query_stats A
OUTER APPLY  sys.dm_exec_sql_text (a.plan_handle) B
ORDER BY a.last_execution_time DESC 
```

38、作业相关

```mssql
Use msdb
GO
sp_help_job
sp_start_job
sp_stop_job
```

39、创建用户名和密码

```mssql
USE [master]
GO
CREATE LOGIN [hyym]--用户名 
WITH 
PASSWORD=N'123456' --登录密码
MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO


USE [HSGMTHYYM]
GO
CREATE USER [hyym] FOR LOGIN [hyym]
GO

```

40、检查SQL Agent是否开启

```mssql
IF EXISTS (
SELECT TOP 1 1
FROM sys.sysprocesses
WHERE program_name = 'SQLAgent - Generic Refresher'
)
SELECT 'Running'
ELSE
SELECT 'Not Running'
```

41、查询某个数据库下的表数据占用磁盘容量最大的10张表 

```mssql
select top 10 a.tablename,a.SCHEMANAME,sum(a.TotalSpaceMB) TotalSpaceMB,sum(a.RowCounts) RowCounts 
FROM
( SELECT     t.NAME AS TableName,     s.Name AS SchemaName,     p.rows AS RowCounts,   
SUM(a.total_pages) * 8 AS TotalSpaceKB,     CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,  
SUM(a.used_pages) * 8 AS UsedSpaceKB,     CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,  
CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB 
FROM           sys.tables t 
INNER JOIN     sys.indexes i ON t.OBJECT_ID = i.object_id 
INNER JOIN     sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id 
INNER JOIN     sys.allocation_units a ON p.partition_id = a.container_id 
LEFT  JOIN     sys.schemas s ON t.schema_id = s.schema_id 
WHERE     t.NAME NOT LIKE 'dt%'     AND t.is_ms_shipped = 0     AND i.OBJECT_ID > 255 
GROUP BY     t.Name, s.Name, p.Rows
) a 
GROUP BY  a.tablename,a.SCHEMANAME 
ORDER by sum(a.TotalSpaceMB) desc 
```

42、监视日志空间

```mssql
DBCC SQLPERF (LOGSPACE)
```

43、先杀掉进程、数据库在脱机

```mssql
SELECT spid FROM sysprocesses WHERE dbid=18

KILL 72--  spid 


ALTER DATABASE HSTVBoard SET OFFLINE   --脱机

SELECT name, dbid, sid, mode, status, status2, crdate, reserved, category, cmptlevel, filename, version FROM sys.sysdatabases
```

44、日志收缩

```mssql
ALTER DATABASE HSFabricTrade_SDNNEW SET RECOVERY SIMPLE --将“恢复模式”设置为“简单”
GO
USE HSFabricTrade_SDNNEW
GO
DBCC SHRINKFILE (N'HSFabricTrade_Log' , 1)--收缩日志文件大小到1M
GO
USE HSFabricTrade_SDNNEW
GO
ALTER DATABASE HSFabricTrade_SDNNEW SET RECOVERY FULL WITH NO_WAIT ----将“恢复模式”设置为“完整”
GO
ALTER DATABASE HSFabricTrade_SDNNEW SET RECOVERY FULL
go
```

45、其他

```mssql
SELECT b.text ,MAX(execution_count),MAX(total_worker_time),MAX(total_logical_writes),MAX(total_logical_reads) 
FROM sys.dm_exec_query_stats A(NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) B
WHERE B.text IS NOT NULL
GROUP BY sql_handle ,b.text 
ORDER BY MAX(total_worker_time) DESC
OPTION(MAXDOP 1024,RECOMPILE)
```

46   

```
^  每行开头
$  每行结束
```

47、游标

```mssql

SELECT c.* INTO #t1 FROM (
SELECT * FROM rfidin(NOLOCK) WHERE sEmployeeNameCN='程超林' AND iWorkSectionId=10) c


DECLARE cursor_jx CURSOR FAST_FORWARD READ_ONLY FOR --定义一个游标


SELECT sPackBarcode FROM #t1;   --定于游标的数据源
OPEN cursor_jx  --打开游标
 
DECLARE @THIS NVARCHAR(4000),@i  int   --定义两个变量，用来保存上一行和当前行的数据
FETCH NEXT FROM cursor_jx INTO @THIS --设置@this 为当前行的数据
 SET @i=1
WHILE @@FETCH_STATUS=0  --判断游标是否为读取失败，读取失败则为-1 代表最后一行
BEGIN
 --如果为空则更新当前行的数据为上一行
UPDATE rfidin SET iProcessFactoryId=@i WHERE sPackBarcode=@THIS  AND iWorkSectionId=10--更新数据，where 只更新当前游标所在行
--PRINT @LAST
SET @i=@i+1
 
FETCH NEXT FROM cursor_jx INTO @THIS 　　　　--继续读取下一行数据
 
END
 
CLOSE cursor_jx  --关闭游标
DEALLOCATE cursor_jx --释放游标
DROP TABLE #t1

-------------------------------------------------------
DECLARE @v_table NVARCHAR(max)

SET @v_table='ep_RollBase'
SELECT      a.name AS 表名, f.name AS 列名, CAST(c.value AS NVARCHAR(100)) AS 字段注释, g.name AS 类型, f.max_length AS 长度,
            f.precision, f.scale
INTO        #io
FROM        sys.tables a
LEFT JOIN   sys.extended_properties c ON c.major_id = a.object_id
JOIN        sys.all_objects d ON d.object_id = a.object_id
JOIN        sys.all_columns f ON f.object_id = a.object_id
                                 AND   f.column_id = c.minor_id
JOIN        sys.types g ON g.user_type_id = f.user_type_id
WHERE       d.name = @v_table;

CREATE TABLE #result
(
    sTable NVARCHAR(100),
    sColumn NVARCHAR(200),
    sMS_Description NVARCHAR(200),
    sType NVARCHAR(200),
    sLength NVARCHAR(200)
);
DECLARE @sTable NVARCHAR(100), @sColumn NVARCHAR(200), @sMS_Description NVARCHAR(200), @sType NVARCHAR(200),
        @iLength INT, @iPrecision INT, @iScale INT;

DECLARE CURSOR_ty CURSOR FAST_FORWARD READ_ONLY FOR(SELECT  * FROM  #io);
OPEN CURSOR_ty;

FETCH NEXT FROM CURSOR_ty
INTO @sTable, @sColumn, @sMS_Description, @sType, @iLength, @iPrecision, @iScale;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @sType IN ( 'date', 'time', 'datetime2', 'datetimeoffset', 'datetime', 'smalldatetime', 'timestamp', 'image',
                   'text', 'uniqueidentifier', 'money', 'bit', 'tinyint', 'smallint', 'int', 'bigint'
                 )
    BEGIN
        INSERT INTO #result
        (
            sTable, sColumn, sMS_Description, sType, sLength
        )
        SELECT  @sTable, @sColumn, @sMS_Description, '[' + @sType + ']', NULL;
    END;

    IF @sType IN ( 'varchar', 'CHAR', 'nvarchar', 'NCHAR' )
    BEGIN
        INSERT INTO #result
        (
            sTable, sColumn, sMS_Description, sType, sLength
        )
        SELECT  @sTable, @sColumn, @sMS_Description,
                CASE
                    WHEN @iLength = -1 THEN
                        '[' + @sType + ']' + '(max)'
                    ELSE
                        '[' + @sType + ']' + '(' + CAST(@iLength AS NVARCHAR(20)) + ')'
                END, NULL;
    END;
    IF @sType IN ( 'decimal', 'numeric' )
    BEGIN
        INSERT INTO #result
        (
            sTable, sColumn, sMS_Description, sType, sLength
        )
        SELECT  @sTable, @sColumn, @sMS_Description,
                '[' + @sType + ']' + '(' + CAST(@iPrecision AS NVARCHAR(20)) + ',' + CAST(@iScale AS NVARCHAR(20))
                + ')', NULL;
    END;
    FETCH NEXT FROM CURSOR_ty
    INTO @sTable, @sColumn, @sMS_Description, @sType, @iLength, @iPrecision, @iScale;
END;

CLOSE CURSOR_ty;
DEALLOCATE CURSOR_ty;
SELECT  sTable, '[' + sColumn + ']  ' + sType AS sColumn, sMS_Description
FROM    #result;
DROP TABLE #result;
DROP TABLE #io;
-------------------------------------------------------
```

48、**SQL Server 数据库中的三种类型的数据文件：**

```
主要数据文件（扩展名.mdf是 primary data file 的缩写）
主要数据文件包含数据库的启动信息，并指向数据库中的其他文件。用户数据和对象可存储在此文件中，也可以存储在次要数据文件中。每个数据库有一个主要数据文件。主要数据文件的建议文件扩展名是 .mdf。

SQL Server的每个数据库是以两个文件存放的，一个后缀名为mdf，是数据文件，另一个后缀名为ldf，为日志文件。因此只要定期复制这两个文件，就可以达到备份的效果。

次要 （扩展名.ndf是Secondary data files的缩写）
次要数据文件是可选的，由用户定义并存储用户数据。通过将每个文件放在不同的磁盘驱动器上，次要文件可用于将数据分散到多个磁盘上。另外，如果数据库超过了单个 Windows 文件的最大大小，可以使用次要数据文件，这样数据库就能继续增长。次要数据文件的建议文件扩展名是 .ndf。

事务日志 （扩展名.ldf是Log data files的缩写）
事务日志文件保存用于恢复数据库的日志信息。每个数据库必须至少有一个日志文件。事务日志的建议文件扩展名是 .ldf。
```

49、数据库还原

```mssql
USE [master]
USE master
 go
 DECLARE @Sql NVARCHAR(max)
 SET @Sql=''
 select @Sql=@Sql+'kill '+cast(spid as varchar(50))+';' from sys.sysprocesses where dbid=DB_ID('wch')
 EXEC(@Sql) 
RESTORE DATABASE [wch] FROM  DISK = N'D:\开源\20230310\20230310.bak' WITH  FILE = 1,  
MOVE N'mscrm' TO N'F:\sql\SQL2016\sql server\sql\MSSQL13.MSSQLSERVER\MSSQL\DATA\wch.mdf',  
MOVE N'mscrm_log' TO N'F:\sql\SQL2016\sql server\sql\MSSQL13.MSSQLSERVER\MSSQL\DATA\wch_log.ldf',  
NOUNLOAD,  REPLACE,  STATS = 5
GO
```

50、注释

```mssql
----对表、字段添加注释
EXEC sp_addextendedproperty N'MS_Description', N'布卷', 'SCHEMA', N'dbo', 'TABLE', N'ep_RollBase', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'布卷', 'SCHEMA', N'dbo', 'TABLE', N'ep_RollBase', 'COLUMN', N'ep_RollId'
GO
EXEC sp_addextendedproperty N'MS_Description', N'创建时间', 'SCHEMA', N'dbo', 'TABLE', N'ep_RollBase', 'COLUMN', N'CreatedOn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'创建者', 'SCHEMA', N'dbo', 'TABLE', N'ep_RollBase', 'COLUMN', N'CreatedBy'
GO

-----查看注释
SELECT a.name AS 表名 ,f.name AS 列名,c.value AS 含义,g.name AS 类型
from sys.tables a 
LEFT join sys.extended_properties c on c.major_id = a.object_id
JOIN sys.all_objects d ON d.object_id=a.object_id
JOIN sys.all_columns f ON f.object_id=a.object_id AND f.column_id=c.minor_id
JOIN sys.types g ON g.user_type_id=f.user_type_id
WHERE d.name='ep_RollBase'

--ep_Quantity
SELECT * FROM sys.all_columns WHERE object_id='1845334084'
```

51、九九乘法口诀表

```mssql
-----------九九乘法口诀表---------------
CREATE TABLE #yu
(id INT,
sStr NVARCHAR(1000)
)
DECLARE @i INT=1,@j INT =1 ,@str NVARCHAR(1000)=0x,@sum INT 
WHILE @i<=10
BEGIN
WHILE  @j<=@i
BEGIN
SET @sum=@i*@j
SET @str=@str+CAST(@j AS NVARCHAR(200))+'*'+CAST(@i AS NVARCHAR(200))+'='+CAST(@sum AS NVARCHAR(200))+','
SET @j=@j+1
END
INSERT INTO #yu
SELECT @i, LEFT(@str,LEN(@str)-1)
SET @i=@i+1
SET @j=1
SET @str=''
END
SELECT * FROM #yu --FOR XML PATH
DROP TABLE #yu
-----------九九乘法口诀表---------------
```

52、事务

```
事务
	概念：作为单个逻辑工作单元执行的一系列操作
	四大特性：ACID
	
	Atomicity原子行:要么都成功，要么都失败。
	Consistency一致性：事务执行前后，总量保持一致。
	Isolation隔离性：各个事务并发执行时，彼此独立。
	Durability持久性：持久化操作。

事务的生命周期：

```

```mssql
use	wangchunhua 
EXEC sys.sp_helpfile
```

53、

```mssql
DECLARE @sp_sql nvarchar(300),@i INT ,@len INT ,@j INT
DECLARE @count INT 
SET @i=0
SET @sp_sql='郭书飞,陈斌,秦强,吴寅锋'
SET @len=LEN(@sp_sql)
CREATE TABLE #PU(id int)
WHILE @i<=@len
BEGIN
SET @j=(SELECT CHARINDEX(',',@sp_sql,@i))
SET @i=@j+1
IF @j=0
BEGIN
SET @i=10000
END 
ELSE
begin
INSERT INTO #PU(id) VALUES(@j)
end
END

--SELECT SUBSTRING(@sp_sql,1,4-1)
--SELECT SUBSTRING(@sp_sql,4+1,7-4-1)
--SELECT SUBSTRING(@sp_sql,7+1,10-7-1)
--SELECT SUBSTRING(@sp_sql,11,@len)
SELECT * FROM #PU

DROP TABLE #PU
```

54、函数

```mssql
--表值函数
/****** Object:  UserDefinedFunction [dbo].[SplitToTable]    Script Date: 2023-06-05 08:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		汪进
-- Create date: 2014-07-04
-- Description:	表值函数实现Split方法,实现结果同C#
-- 调用示例:select * FROM [dbo].[SplitToTable] ('ABC,EFG,123',',')
-- =============================================
 ALTER FUNCTION [dbo].[SplitToTable]
 (
     @SplitString nvarchar(max),
     @Separator nvarchar(10)=','
 )
RETURNS @SplitStringsTable TABLE
(
	[id] int identity(1,1),
	[value] nvarchar(max)
)
AS
BEGIN
	DECLARE @CurrentIndex int;
	DECLARE @NextIndex int;
	DECLARE @ReturnText nvarchar(max);
	DECLARE @SepaLen int;
	IF(@Separator IS NULL OR LEN(@Separator)=0)
	BEGIN
		SET @Separator=',';
	END
	SELECT @CurrentIndex=1,@SepaLen=len(@Separator);
	IF(LEN(@SplitString)=0)
	BEGIN
		INSERT INTO @SplitStringsTable([value]) VALUES('');
		RETURN;
	END
	IF (charindex(@Separator,@SplitString,1)=0)
	BEGIN
		INSERT INTO @SplitStringsTable([value]) VALUES(@SplitString);
		RETURN;
	END
	WHILE(@CurrentIndex<=len(@SplitString))
	BEGIN
		SELECT @NextIndex=charindex(@Separator,@SplitString,@CurrentIndex);
		IF(@NextIndex=0 OR @NextIndex IS NULL)
		BEGIN
            SELECT @NextIndex=len(@SplitString)+1;	
		END	
		SELECT @ReturnText=substring(@SplitString,@CurrentIndex,@NextIndex-@CurrentIndex);
		INSERT INTO @SplitStringsTable([value]) VALUES(@ReturnText);
		SELECT @CurrentIndex=@NextIndex+@SepaLen;
		IF(@NextIndex=len(@SplitString)-@SepaLen+1)
		BEGIN
			INSERT INTO @SplitStringsTable([value]) VALUES('');
		END	
	END
	RETURN;
END




--表量值函数
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--提取字符串中部分字符（数字、字母、非数字）

create FUNCTION [dbo].[fnpbStringGetNum]  
( @Str NVARCHAR(MAX) ) 
RETURNS NVARCHAR(MAX)   
AS   
BEGIN   
    WHILE PATINDEX('%[^0-9]%',@Str)>0   
    BEGIN   
        SET @Str=STUFF(@Str,PATINDEX('%[^0-9]%',@Str),1,'') --删掉非数字的字符
    END   
    RETURN @Str 
END 



###########
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--提取字符串中部分字符（数字、字母、非数字）

alter FUNCTION [dbo].[fnpbStringGetLetter]  
( @Str NVARCHAR(MAX) ) 
RETURNS NVARCHAR(MAX)   
AS   
BEGIN   
    WHILE PATINDEX('%[^a-zA-Z]%',@Str)>0 
    BEGIN   
        SET @Str=STUFF(@Str,PATINDEX('%[^a-zA-Z]%',@Str),1,'') --删掉非字母的字符
		print @Str
    END   
    RETURN @Str 
END 
###########

--聚合函数


```

55、序列使用

```mssql
CREATE SEQUENCE [schema_name . ] sequence_name  
    [ AS [ built_in_integer_type | user-defined_integer_type ] ]  --类型
    [ START WITH <constant> ]  --开始值
    [ INCREMENT BY <constant> ]  --增量
    [ { MINVALUE [ <constant> ] } | { NO MINVALUE } ]  --最大
    [ { MAXVALUE [ <constant> ] } | { NO MAXVALUE } ]  --最小
    [ CYCLE | { NO CYCLE } ]  --是否循环
    [ { CACHE [ <constant> ] } | { NO CACHE } ]   --缓存到内存
    [ ; ]
```



```mssql
SELECT NEXT VALUE FOR dbo.SO_currentcasenumber
```

56、分页

```mssql
SELECT * 
FROM dbo.RFIDOutput A(NOLOCK)
ORDER BY A.tCreateTime DESC
OFFSET 100 ROWS
FETCH NEXT 5 ROWS ONLY 


/**/
SELECT * FROM OPENROWSET(
BULK 'D:\1.txt',--文件路径
SINGLE_CLOB
) as test



--提前下载AccessDatabaseEngine_X64.exe并安装
--开启导入功能
exec sp_configure 'show advanced options',1
reconfigure
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure

--允许在进程中使用ACE.OLEDB.12
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
reconfigure
----允许动态参数
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
reconfigure

SELECT *
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
               'Excel 12.0;Database=C:\Users\ASUS\Desktop\22.xlsx;',
               'SELECT * FROM [Sheet1$]')   --读取excel文件

--关闭导入功能
exec sp_configure 'Ad Hoc Distributed Queries',0
reconfigure
exec sp_configure 'show advanced options',0
reconfigure

```

57、merge用法

```mssql
MERGE INTO dbo.hrEmployee_bak AS T  --目标表
USING dbo.hrEmployee AS S   --源表
ON S.uGUID=T.uGUID
WHEN MATCHED
THEN UPDATE SET T.sRemark=s.sRemark   --匹配上更新目标表的值
WHEN NOT MATCHED            --目标表没有uGUID，在源表中有，则添加到目标表
THEN INSERT VALUES(s.uGUID,s.sEmployeeNo,s.sEmployeeNameCN )
WHEN NOT MATCHED BY SOURCE  -- 目标表有uGUID，在源表中没有，则删除目标表信息
THEN DELETE 
OUTPUT $action AS action,Inserted.uGUID ,Deleted.uGUID;--对变动的数据进行输出
```

58、DBCC

```mssql
DBCC可以执行一系列的数据库检查和修复操作，包括但不限于以下操作：

DBCC CHECKDB：检查数据库的一致性，查找并修复潜在的逻辑和物理错误。
DBCC CHECKFILEGROUP：检查文件组的一致性，查找并修复潜在的逻辑和物理错误。
DBCC CHECKALLOC：检查分配的一致性，查找并修复潜在的逻辑和物理错误。
DBCC CHECKTABLE：检查表的一致性，查找并修复潜在的逻辑和物理错误。
DBCC CLEANTABLE：清除表中的无效行。
DBCC FREEPROCCACHE：释放进程缓存中的所有对象。
DBCC FLUSHPROCINDB：刷新当前数据库中的所有存储过程缓存。
```

59、查询错误 日志

```
EXEC xp_readerrorlog 0,1,NULL,NULL,'2016-04-28','2023-10-30','DESC'
```

60、聚合函数string_agg 去重合并  适用于2017版本

```mssql
输入：
Activities 表：
+------------+-------------+
| sell_date  | product     |
+------------+-------------+
| 2020-05-30 | Headphone   |
| 2020-06-01 | Pencil      |
| 2020-06-02 | Mask        |
| 2020-05-30 | Basketball  |
| 2020-06-01 | Bible       |
| 2020-06-02 | Mask        |
| 2020-05-30 | T-Shirt     |
+------------+-------------+
输出：
+------------+----------+------------------------------+
| sell_date  | num_sold | products                     |
+------------+----------+------------------------------+
| 2020-05-30 | 3        | Basketball,Headphone,T-shirt |
| 2020-06-01 | 2        | Bible,Pencil                 |
| 2020-06-02 | 1        | Mask                         |
+------------+----------+------------------------------+
解释：
对于2020-05-30，出售的物品是 (Headphone, Basketball, T-shirt)，按词典序排列，并用逗号 ',' 分隔。
对于2020-06-01，出售的物品是 (Pencil, Bible)，按词典序排列，并用逗号分隔。
对于2020-06-02，出售的物品是 (Mask)，只需返回该物品名。

解法1：
SELECT sell_date,COUNT(DISTINCT product) AS num_sold ,string_agg(product,',') AS products from(
select distinct *
from Activities
) AS t GROUP BY sell_date ORDER BY sell_date

解法2：
SELECT f.sell_date,f.num_sold,LEFT(f.products,LEN(f.products)-1) AS products
FROM 
(select m.sell_date,COUNT(DISTINCT m.product) AS num_sold,
            (select  a.product+','
            from (select distinct sell_date,product from Activities)a 
            where a.sell_date=m.sell_date
            order by a.product asc
            for xml path('')
             ) as products
  from  Activities m 
  group by m.sell_date 
)f 

```

61、删除

```mssql
1、删除行： DELETE FROM table_name WHERE condition;
2、多表关联删除
delete A  from table_name a 
join table_name_other  b on condition
where condition;
3、级联删除
---示例----
---假设我们有两个表：Customers 和 Orders。Customers 表包含客户信息，Orders 表包含订单信息，其中 Customers 表的主键是 -----CustomerID，Orders 表的外键是 CustomerID。现在，我们希望设置级联删除，以便在删除客户记录时，同时删除相关的订单记录。
--首先，我们需要创建这两个表：
IF OBJECT_ID('dbo.Orders','U') IS NOT NULL
DROP TABLE dbo.Orders

IF OBJECT_ID('dbo.Addr','U') IS NOT NULL
DROP TABLE dbo.Addr

IF OBJECT_ID('dbo.Customers','U') IS NOT NULL
DROP TABLE dbo.Customers


CREATE TABLE Customers (
CustomerID INT PRIMARY KEY,
CustomerName VARCHAR(255)
);

CREATE TABLE Orders (
OrderID INT PRIMARY KEY,
OrderDate DATE,
CustomerID INT,
FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE
);

CREATE TABLE Addr(
AddressID INT PRIMARY KEY,
Address NVARCHAR(100),
CustomerID INT,
FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

---ON DELETE CASCADE 子句表示删除父表中的记录时，将会自动删除相关的子表记录。-------


INSERT INTO Customers (CustomerID, CustomerName) VALUES (1, 'Alice')
INSERT INTO Customers (CustomerID, CustomerName) VALUES (2, 'Bob')

INSERT INTO Orders(OrderID,OrderDate,CustomerID) VALUES(1,'2021-01-01',1)
INSERT INTO Orders (OrderID, OrderDate, CustomerID) VALUES (2, '2021-02-01', 1)
INSERT INTO Orders (OrderID, OrderDate, CustomerID) VALUES (3, '2021-03-01', 2)

INSERT INTO dbo.Addr(AddressID, Address, CustomerID) VALUES (1,  N'湖北', 1 )
INSERT INTO dbo.Addr(AddressID, Address, CustomerID) VALUES (2,  N'新疆', 1 )
INSERT INTO dbo.Addr(AddressID, Address, CustomerID) VALUES (3,  N'西藏', 1 )
INSERT INTO dbo.Addr(AddressID, Address, CustomerID) VALUES (4,  N'河北', 2)
INSERT INTO dbo.Addr(AddressID, Address, CustomerID) VALUES (5,  N'山东', 2 )

SELECT * FROM Customers
SELECT * FROM Orders
SELECT * FROM dbo.Addr


DELETE FROM Customers WHERE CustomerID = 1



SELECT * FROM Customers
SELECT * FROM Orders

```

**结论：通过设置级联删除，我们可以在删除父表记录时，自动删除相关的子表记录，从而确保数据的一致性和完整性。在 SQL Server 数据库中，我们可以使用外键约束来实现。**
