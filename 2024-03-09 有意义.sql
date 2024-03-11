DECLARE @s_table NVARCHAR(500),@s_schma NVARCHAR(500),@s_fulltable NVARCHAR(500),
@sql  NVARCHAR(MAX),@out_sql NVARCHAR(max)
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

	SET  @sql='SELECT sEmployeeNameCN,
        sStyleNo,iqty FROM'+' ' + @s_table;


SET @sql=
'WITH cte(sEmployeeNameCN,sStyleNo,iqty)
AS 
('+@sql+'
   
),
 ctw(sEmployeeNameCN,sStyleNo,iqty)
AS 
(
SELECT  sEmployeeNameCN,sStyleNo,SUM(iqty) AS iqty   FROM cte
GROUP BY sEmployeeNameCN,sStyleNo
				)

SELECT ROW_NUMBER() OVER(ORDER BY h.cat_sStyleNo) AS id ,h.sEmployeeNameCN,
LEFT(h.cat_sStyleNo,LEN(h.cat_sStyleNo)-1) AS cat_sStyleNo,h.count_sStyleNo
FROM  
(
SELECT  DISTINCT a.sEmployeeNameCN, 

(SELECT COUNT(1) FROM ctw  
WHERE sEmployeeNameCN=a.sEmployeeNameCN  )  AS count_sStyleNo,

(SELECT sStyleNo+'+''':'''+'+ CAST(iqty AS NVARCHAR(1000))+'+''','''+' FROM ctw b 
WHERE b.sEmployeeNameCN=a.sEmployeeNameCN FOR  XML PATH('+''''''+') )  AS cat_sStyleNo

FROM ctw a )h
OPTION (MAXRECURSION 2)'+';'
EXEC  sp_executesql @sql;

END 






--9	ÁÎÐ¡Ø«	60243F049B:26,60243F080A-JP:169,F28M3300:45	3


