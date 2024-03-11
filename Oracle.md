1、Oracle数据库物理结构

​		XXX数据库

```plsql
参数文件.ORA ：用于记录Oracle配置参数信息。

数据文件1.DBF：用于记录在数据库中存放的应用数据。

数据文件N.DBF

控制文件.CTL：用于记录数据库所有文件的控制信息，如数据库的名称、建立日期、表空间信息、数据文件信息、
日志文件信息、当前日志序列号、检查点信息等。

日志文件1.LOG：用于记录数据库事务的日志文件。
```



2、Oracle数据库逻辑结构

表空间、段（表、索引、回滚等类型）、区、块



3、Oracle 数据类型

```plsql
字符：Char、NCHAR、Varchar、Text、Varchar2
整数：samllint、Interger
浮点数：Number(n,d),Float(n,d)
日期：Date、TIMESTAMP、 Datetime
货币：Money
```



4、创建表空间

```plsql
create tablespace ultraeos
logging
datafile 'D:\Oraclesoft\data\ultraeos.dbf'
size 100m
autoextend on 
next 32m maxsize 2048m
extent management local;

/*表空间转移*/
alter table 表名 move tablespace 新的表空间


SELECT *
FROM dba_tablespaces
WHERE tablespace_name IS NOT NULL;--查看所有命名空间

alter database default tablespace users;--指定数据库默认命名空间


---判断表是否存在---
declare 
i number;
begin
select count(*) into i from user_tables where table_name =upper('city');
if i=1 then
  execute immediate 'drop table city'    ;   
  commit;
else 
  DBMS_OUTPUT.PUT_LINE('没有此表');   
end if;
end;
```

5、创建用户并赋予权限

```plsql
create user cttsoft
Identified by Ccl123456
default tablespace ultraeos
temporary tablespace temp;
grant dba to cttsoft;

alter user cttsoft default tablespace users;
--用户操作
alter user [USER] account lock;--用户锁定
alter user [USER] account unlock;--用户解锁
alter user [USER] identified by 123456;--用户修改密码
select * from dba_users;--查看用户

drop user 用户名 cascade;--删除用户

```

8、创建表并对表进行操作

```
create table dt_eatery
(
eatery_id int primary key,
eatery_name varchar2(30),
eatery_number varchar2(30)
)tablespace USERS;


CREATE TABLE puConsumableHdr
(
uGUID  varchar2(200)  default sys_guid() primary key not null  ,
tCreateTime date  default sysdate NOT NULL  ,
sRemark varchar2(50)  NULL,
sBillNo varchar2(50) NULL,
iBillStatus number(2,0) NULL,
iNoteTypeId number(7,0) null,  
sConfirmMan varchar2(50)  NULL,
tConfirmTime date   NULL,
sAuditMan varchar2(50)  NULL,
tAuditTime date NULL,
sCreator varchar2(50)  NULL,
sUpdateMan varchar2(50)  NULL,
tUpdateTime date   default sysdate NULL
); 
##注意
1、表名首字符应该为字母
2、不能使用Oracle中保留字
3、不能超过30个字符
4、可以使用下划线、数字、字母，但不能使用空格和单引号
```

9、修改表名

```
alter table 旧表名 rename to 新表名
```

10、更改现有列的数据类型

```
alter table dt_eatery（表名） modify (eatery_name（列名） varchar(100)（数据类型）)
```

11、给已有的表加主键

```
alter table 表名 add constraint 主键名 primary key (列名)

表中添加列
alter table 表名 add （列名 类型）

删除表中列
alter table 表名 dorp (column 列名)

删除表中的所有数据而保留表结构
truncate table 表名

查看表结构

```

12、利用现有的表创建新表

```plsql
create table 新表名  as select 列名 from 老表名 where 条件 

---只会复制表数据和表结构，不会有任何约束
create table city2  as select * from city where 1<>1 /*空表*/

create table city2  as select * from city   


-----------------
create global temporary table tmp_session as select * from scott.emp ; --创建临时表结构

drop table tmp_session;--删除临时表

insert into tmp_session
select * from scott.emp;--从其他表添加数据

select * from tmp_session;--查询表

--临时表分类--
oracle临时表分为会话级临时表和事务级临时表；会话级的临时表只与当前会话相关，只要当前会话还存在，临时表中的数据就还存在，一旦退出当前会话，临时表中的数据也随之被丢弃；而且不同会话中临时表数据是不同的，当前会话只能对当前会话的数据进行操作，无法对别的会话的数据进行操作。而事务级临时表，只在当前事务有效，一旦进行commit事务提交之后，
临时表内的数据就会随着前一个事务的结束而删除。

-----------------
```

13、时间操作

```plsql
###每个月的第一天
select to_date(to_char(sysdate,'yyyy-mm')||'-01','yyyy-mm-dd') from dual
###一年的第一天
select to_date(to_char(sysdate,'yyyy')||'-01-01','yyyy-mm-dd') from dual
###上个月的最后一天
select trunc(last_day(add_months(sysdate,-1)))+1-1/24/60/60 from dual
###本年的最后一天
select trunc(last_day(to_date(to_char(sysdate,'yyyy')||'-12-01','yyyy-mm-dd')))+1-1/24/60/60  from dual
###本月的最后一天
select trunc(last_day(sysdate))+1-1/24/60/60  from dual
###显示日期，去掉时分秒
select trunc(sysdate)  from dual
###显示星期几
select to_char(sysdate,'Day') from dual

###显示年月日
 select to_date(sysdate),trunc(sysdate) from dual;
 
 TO_DATE()函数：用于将字符串转换为日期类型。可以指定日期的格式，例如'YYYY-MM-DD'。
 TRUNC()函数：用于截取日期的部分，例如年、月、日等。
 
 --日期比较和运用---
select a.username,
       a.user_id,
       a.created
from dba_users a
where  trunc(a.created)>=to_date('2022-01-01','YYYY-MM-DD')
and trunc(a.created)<=to_date('2023-11-15','YYYY-MM-DD')
order by       a.user_id;

```



14、

```plsql
create table example
(
id number(10) not null primary key ,
username varchar2(20),
phone varchar2(20),
address varchar2(50)
)  tablespace ultraeos;
---建立一个序列
create sequence emp_sequence
increment by 1 --每次加几
start with 1  --从1开始计数
nomaxvalue|maxvalue  --不设置最大值
nominvalue|minvalue
nocycle|cycle  --一直累加，不循环
nocache|cache  --不建缓冲区

comment on table  example --(4)
  is '测试表';
comment on column  example.username --(4)
  is '姓名';
  comment on column example.phone --(4)
  is '电话';
comment on column example.address --(4)
  is '地址';
  
  
--处：comment on table 是给表名进行注释。
--处：comment on column 是给表字段进行注释。

insert into example
select 2,id, username,phone,address from example 


----------
drop table city;
CREATE TABLE city (
city_id VARCHAR(50) NOT NULL,
city_name VARCHAR(50) NOT NULL,
country_id SMALLINT NOT NULL
);

begin
for i in 1 .. 10000 loop
insert into city values(i,'city'||i,ceil(i/1000));
end loop;
commit;
end;
----------


-- 查询你能管理的所有用户信息
select user_id, username, created from all_users;

-- 循环输出用户表信息
begin
  for cur_row in (select user_id, username, created from all_users) loop
    sys.dbms_output.put_line(cur_row.username);
  end loop;
end;
-- 当循环对象是比较长串的SQL时,建议提取游标,方便后续查看和维护

/*表名和字段名均为大写（暂不建议使用驼峰规则，仅限Oracle）*/
oracle 查询时字段列名从大写转换为驼峰大小写   实现不了
    原因：Oracle默认的存储格式都是大写，使用Oracle SQL Developer 建立表和字段时你写入大小写混用，但是显示的时候全部变成大写了，在卸表结构后，用字段名变换为变量的时候，就全部成了大写，如果C#代码中使用和字段对应的字段为大小写混排的驼峰规则时，反而容易出错。

```

15、join

```

```

16、查看表空间名称及大小

```plsql
select a.tablespace_name,round(sum(bytes/(1024*1024)),0) as ts_size
from dba_tablespaces A ,dba_data_files B
where A.tablespace_name=b.tablespace_name
group by A.tablespace_name
```

17、查看表空间物理文件得名称及大小

```
select B.tablespace_name,round(bytes/(1024*1024),0) as ts_size
from dba_data_files B
order by B.tablespace_name
```

18、Oracle的伪列

```
Oracle的伪列是Oracle表在存储的过程中或查询的过程中，表会有一些附加列，称为伪列。伪列就像表中的字段一样，但是表中并不存储。伪列只能查询，不能增删改。Oracle的伪列有：rowid、rownum。
```

19、创建存储过程

```plsql
CREATE [OR REPLACE] PROCEDURE procedure_name  
    [ (parameter [,parameter]) ]  
IS/AS 
    [declaration_section]  
BEGIN  
    executable_section  
[EXCEPTION  
    exception_section]  
END [procedure_name];

/*
赋值给变量的方法：
1、使用“:=”直接赋值，语法“变量名:=值;”；
2、使用“select 表字段 into 变量 from 表”语句；
3、使用“execute immediate sql语句字符串 into 变量”语句。
*/


----------创建存储过程----------
create or replace procedure p_test04
/*无参*/
as
/*声明变量 var*/
v_username  varchar2(100);
v_time date;
v_id int;
v_msg varchar2(100);
begin
  select a.username,
         a.user_id,
         a.created 
  into v_username,v_id,v_time  
  from example01 A 
  where a.user_id=87 and rownum=1;--查询结果赋给变量
  
  v_msg :='执行成功';--变量赋值
  
dbms_output.put_line('name:'||v_username||',user_id:'||v_id||',time:'||v_time||',msginfo:'||v_msg);--输出结果
end  p_test04;
----------创建存储过程----------
----------执行存储过程----------
begin
  p_test04();
end;
----------执行存储过程----------



----------创建存储过程----------
create or replace procedure p_test05
/*传入参数*/
(
id in int
)
as
/*声明变量 var*/
v_username  varchar2(100);
v_time date;
v_id int;
v_msg varchar2(100);
begin
  select  a.username,
         a.user_id,
         a.created 
  into v_username,v_id,v_time  
  from example01 A 
  where a.user_id=id and rownum=1;--查询结果赋给变量
  
  v_msg :='执行成功';--变量赋值
  
dbms_output.put_line('name:'||v_username||',user_id:'||v_id||',time:'||v_time||',msginfo:'||v_msg);--输出结果
end  p_test05;
----------创建存储过程----------
----------执行存储过程----------
declare 
id int:=87;
begin
  p_test05(id);
end;
----------执行存储过程----------


----------创建存储过程----------
create or replace procedure p_test06
/*传入传出参数*/--参数列表中有in out参数  当既想携带值进来，又想携带值出去，可以用in out
(
id in  out int
)
as
/*声明变量 var*/
v_username  varchar2(100);
v_time date;
v_id int;
v_msg varchar2(100);
begin
  select  a.username,
         a.user_id,
         a.created 
  into v_username,v_id,v_time  
  from example01 A 
  where a.user_id=id and rownum=1;--查询结果赋给变量
  
  v_msg :='执行成功';--变量赋值
  id := 100;
  
dbms_output.put_line('name:'||v_username||',user_id:'||v_id||',time:'||v_time||',msginfo:'||v_msg);--输出结果
end  p_test06;
----------创建存储过程----------
----------执行存储过程----------
declare 
id int:=87;
begin
  p_test06(id);
  dbms_output.put_line(id);
end;
----------执行存储过程----------



----------创建存储过程----------
create or replace procedure p_test07
/*传入传出参数*/
(
id in  out int,
begintime in date,
endtime in  date
)
as
/*声明变量 var*/
v_username  varchar2(100);
v_time date;
v_id int;
v_msg varchar2(100);
begin
  select  a.username,
         a.user_id,
         a.created 
  into v_username,v_id,v_time  
  from example01 A 
  where to_date(a.created)>=to_date(begintime) and
  to_date(a.created)<=to_date(endtime) and rownum=1;--查询结果赋给变量
  
  v_msg :='执行成功';--变量赋值
  
dbms_output.put_line('name:'||v_username||',user_id:'||v_id||',time:'||v_time||',msginfo:'||v_msg);--输出结果
end  p_test07;
----------创建存储过程----------
----------执行存储过程----------
declare 
id int:=87;
begintime date ;
endtime date ;
begin
  select to_date(sysdate-20)   from dual;
  select to_date(sysdate-3) into endtime  from dual;
   dbms_output.put_line(begintime);
  p_test07(id,begintime,endtime);
  dbms_output.put_line(id);
end;
----------执行存储过程----------





```

20、pl/sql developer中用execute调用存储过程弹出‘无效的sql语句’…该怎么解决

```
1、在sql的执行窗口中只能这样调用"call OUT_TIME(); "，这样执行就是把”call OUT_TIME(); “当成一个sql语句，而exec OUT_TIME();不是一个sql语句，是一个执行体，执行体调用必须在命令窗口，把这句话当成一个整体，也就是plsql块，但是要在sql窗口中之行也可以，这样调用：
begin
OUT_TIME();
end;
/

2、在命令窗口中两种方式都可以调用
exec OUT_TIME(); --这样，相当于执行一个plsql块，即把”OUT_TIME()“看成plsql块调用。
call OUT_TIME(); --这样，相当于，但用一个方法“OUT_TIME()”，把“OUT_TIME()”看成一个方法。
------解决方案--------------------
在PLSQL中，新建一个commond 窗口，再执行exec OUT_TIME(); 就可以了

文章知识点与官方知识档案匹配，可进一步学习相关知识
```

21、变量赋值

```plsql
declare
v_dd varchar2(100);
begin
  select sysdate into v_dd from dual; 
  select to_char(sysdate,'yyyy-mm-dd') into v_dd from dual; 
dbms_output.put_line(v_dd);
end;
```

22、约束

```

```

23、事务

```plsql
事务
	概念：作为单个逻辑工作单元执行的一系列操作
	四大特性：ACID
	
	Atomicity原子行:要么都成功，要么都失败。
	Consistency一致性：事务执行前后，总量保持一致。
	Isolation隔离性：各个事务并发执行时，彼此独立。
	Durability持久性：持久化操作。

事务的生命周期：
Oracle:手工提交
	事务的手动标识：第一条DML
				 事务的中间过程：各种DML操作
		结束：
			a. 提交
				i.显式提交：commit;
				ii.隐式：正常退出exit、DCL(grant ... to ...,revoke ...from)、DDL(create ...,drop ...)。
			b.回滚
				i.显式回滚：rollback.
				ii.隐式回滚：异常退出（宕机、断电）。
			
事务的隔离级别：
				多个事务会产生很多并发的问题：
					1、脏读：当一个事务正在访问数据，并对此数据进行了修改（1->2），但是这种修改【还没有提交到数据库（commit）】;此时另一个事务也在访问这个数据。本质：某个事务（客户端）读取到的数据是过失的。
					2、不可重复读：
					3、幻读：
				
 
 四种隔离级别的程度依次递进（解决并发的效果，越来越稳定），但是性能越来越低。并发性、可用性、本身就是矛盾的。
 Oracle只支持其中两种：Read Committed（默认）、Serializable
 
 切换隔离级别：
 		set transaction isolation level Serializable;
```

24、游标

```plsql
DECLARE
  CURSOR emp_cursor IS 
  SELECT empno,ename,job 
  FROM scott.emp;
  
  v_empno scott.emp.empno%TYPE;
  v_name scott.emp.ename%TYPE;
  v_job scott.emp.job%TYPE;
BEGIN
  OPEN emp_cursor;
  LOOP
    FETCH emp_cursor INTO v_empno,v_name,v_job;
    DBMS_OUTPUT.PUT_LINE('员工号为:'||v_empno||',姓名是'||v_name||',职位：'||v_job||'.');
    EXIT WHEN emp_cursor%NOTFOUND;
  END LOOP;
  CLOSE emp_cursor;
END;


/*for循环游标*/
declare
	-- 定义游标
	cursor c_job is  --cursor 声明游标
	select empno, ename, job, sal from SCOTT.EMP WHERE job='MANAGER';
	-- 定义游标变量，用来接收c_job中每一行的数据
	c_row c_job%rowtype;
BEGIN
	for c_row in c_job loop
dbms_output.put_line(c_row.empno||'--'||c_row.ename||'--'||c_row.job||'--'||c_row.sal);
end loop;
end;

------------------
/*fetch 游标 loop循环*/
declare
	-- 定义游标
	cursor c_job is 
	select empno, ename, job, sal from SCOTT.EMP WHERE job='MANAGER';
	-- 定义游标变量，用来接收c_job中每一行的数据
	c_row c_job%rowtype;
BEGIN
	open c_job; -- 打开游标
		loop
			--抓取游标中一行数据，赋值给c_row
			fetch c_job into c_row;
			exit when c_job%notfound; --c_job%notfound   fetch和exit中间不能插入其它语句 固定
			dbms_output.put_line(c_row.empno||'--'||c_row.ename||'--'||c_row.job||'--'||c_row.sal);--控制打印
		end loop;
	close c_job; -- 关闭游标
end;

--------------------
/*fetch 游标 while循环*/
declare
  cursor csr_dept is select dname from SCOTT.DEPT;
  row_dept csr_dept%rowtype;
begin
  open csr_dept;
    fetch csr_dept into row_dept;
      while csr_dept%found loop
        dbms_output.put_line('部门名称：'||row_dept.dname);
        fetch csr_dept into row_dept;
      end loop;
  close csr_dept;
end;



/*for循环游标加if判断*/
DECLARE
  cursor csr_update is select * from SCOTT.EMP1 FOR UPDATE OF SAL;
  empInfo csr_update%rowtype; --定义一个游标变量，该类型为游标csr_update中的一行数据
  salInfo SCOTT.EMP1.SAL%type;--salInfo 为EMP1表中的SAL列的类型
BEGIN
  FOR empInfo in csr_update loop
    if empInfo.sal<1500 then
      salInfo:=empInfo.sal*1.2;
    else if empInfo.sal<2000 THEN
      salInfo:=empInfo.sal*1.5;
    else if empInfo.sal<3000 THEN
      salInfo:=empInfo.sal*2;
    end if;
    end if;
    end if;
    update SCOTT.EMP1 SET SAL=salInfo WHERE CURRENT OF csr_update;
    --WHERE CURRENT OF是用来更新被锁住的记录的，执行游标遍历时的当前行就好像for(int i=0;i++;i<10){} where current of与“i”的功能相似。
  end loop;
end;


##############
begin
	if sql%isopen then
		dbms_output.put_line('sql游标已经打开');
	else
		dbms_output.put_line('sql游标未打开');
	end if;
end;
declare 
	e_count number;
begin
	select count(*) into e_count from SCOTT.EMP; 
	dbms_output.put_line('游标记录数：'||sql%rowcount);
end;
##############

```

25、从timestamp中获取年月日时分秒

```plsql
select 
 extract(year from systimestamp) year
,extract(month from systimestamp) month
,extract(day from systimestamp) day
,extract(minute from systimestamp) minute
,extract(second from systimestamp) second
,extract(timezone_hour from systimestamp) th
,extract(timezone_minute from systimestamp) tm
,extract(timezone_region from systimestamp) tr
,extract(timezone_abbr from systimestamp) ta
from dual
```

27、存在疑问

```plsql
create or replace package test_package1
is
type cursor_type is ref cursor;--声明游标类型变量
end test_package1;

create or replace procedure test_query_info(v_cur out test_package1.cursor_type)
is
begin
open v_cur for select * from city where city_id=7652;--返回指定列
end test_query_info;



---------------
create or replace procedure myprocedure(retval in out sys_refcursor) is
begin
  open retval for
    select city_id from city;
end myprocedure;

/*数据量多了 获取异常*/
 declare 
   myrefcur sys_refcursor;
   tablename  city.city_id%type;
 begin
  DBMS_OUTPUT.ENABLE(buffer_size => null;--设置缓冲区不受限制
   myprocedure(myrefcur);
   loop
     fetch myrefcur into tablename;
     
     exit when myrefcur%notfound;
     dbms_output.put_line(tablename);
   end loop;
   close myrefcur;
 end;
--------------------


------begin 能运行---------
create or replace procedure p_test08(p_cur out sys_refcursor)
as
begin
  open p_cur for 
select * from scott.emp;
end p_test08;


declare 
p_cur sys_refcursor;
i scott.emp%rowtype;
begin
  p_test08(p_cur);
  loop fetch p_cur into i;
       exit when p_cur%notfound;
       dbms_output.put_line(i.ename||'--'||i.deptno);
  end loop;
  
  close p_cur;
  
end;  
-------end-----------
```

28、Oracle日期格式

```
在Oracle数据库系统中，NLS_DATE_FORMAT的值是：
DD-MON-RR

假设想要将标准日期格式更改为YYYY-MM-DD，那么可以使用ALTER SESSION语句来更改NLS_DATE_FORMAT参数的值，如下所示：
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';



```

```plsql
 ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
 
create global  temporary table tmp_session as select * from scott.emp;
declare 
type c_type is ref cursor;
i tmp_session%rowtype;
cur c_type;
begin
  

  insert into tmp_session
  select * from scott.emp;
  open cur for select * from tmp_session;

  loop
   fetch cur into i;
   exit when cur%notfound;
   dbms_output.put_line(i.empno||','||i.ename||','||i.job||','||i.hiredate);
  end loop;

end;

select * from tmp_session;

```

29、动态sql

```plsql
--1、不传参不赋值

/*拷贝表*/
begin
  
execute immediate 'create table test2 as select * from scott.emp';
end ;
/*创建表*/

begin
  execute immediate 'create table tmp_table2'||'(id integer,name varchar2(20))';
end;


--2、将结果集存在变量中动态运行
declare 
sSql varchar2(100) :='create table test_tmp1 as select * from test2';
s varchar2(100) :='drop table test_tmp1';
begin
  execute immediate s;
  execute immediate sSql;
end;


--3、动态sql传参和赋值
/*
using 传参
into 赋值
参数格式 [:参数]
*/

declare
v_sal scott.emp.sal%type;
f_d  NUMBER(4,0):=7654;
begin 
  execute immediate 'select sal from scott.emp where empno=:i '/*7654*/
  into v_sal
  using f_d;
  dbms_output.put_line(v_sal);
end;


--4、动态sql只赋值不传参


declare
v_sal scott.emp.sal%type;

begin 
  execute immediate 'select sal from scott.emp where empno=7654 '/*7654*/
  into v_sal;
  dbms_output.put_line(v_sal);
end;


--5、动态sql与存储过程的的运用
/*案例1*/

create or replace procedure drop_table(tablename in varchar2)
as
sqls varchar2(1000);
begin
  sqls :='drop table '||tablename;
  execute immediate sqls;
end;


begin
  drop_table('test2');
end;

```

30、函数

31、ORACLE中record、varray、table的使用详解

```plsql
1、record
一、什么是记录(Record)由单行多列的标量构成的复合结构。可以看做是一种用户自定义数据类型。组成类似于多维数组。将一个或多个标量封装成一个对象进行操作。是一种临时复合对象类型。

记录可以直接赋值。RECORD1 :=RECORD2;
记录不可以整体比较。
记录不可以整体判断为空。

二、%ROWTYPE和记录(Record)请区别%ROWTYPE和记录(Record)类型。%ROWTYPE可以说是Record的升级简化版。

区别在与前者结构为表结构，后者为自定义结构。二者在使用上没有很大区别。前者方便，后者灵活。在实际中根据情况来具体决定使用。Record + PL/SQL表可以进行数据的多行多列存储。

--使用
declare 
type r_type is record
(
e_no scott.emp.empno%type,
e_name scott.emp.ename%type,
e_job scott.emp.job%type,
e_mgr scott.emp.mgr%type,
e_date scott.emp.hiredate%type,
e_sal scott.emp.sal%type,
e_comm scott.emp.comm%type,
e_deptno scott.emp.deptno%type,
e_dt scott.emp.dt%type
);
v_re r_type;
begin
  select * into v_re from scott.emp where empno=7369;
  dbms_output.put_line(v_re.e_no||' '||v_re.e_sal);
end;


/*ORACLE中record、varray、table的使用详解*/


--组织机构结构表
CREATE TABLE SF_ORG
(
ORG_ID INT NOT NULL, --组织机构主键ID
ORG_NAME VARCHAR2(50),--组织机构名称
PARENT_ID INT--组织机构的父级
);
--一级组织机构
INSERT INTO SF_ORG(ORG_ID, ORG_NAME, PARENT_ID) VALUES(1, '一级部门1',0);
--二级部门
INSERT INTO SF_ORG(ORG_ID, ORG_NAME, PARENT_ID) VALUES(2, '二级部门2',1);
INSERT INTO SF_ORG(ORG_ID, ORG_NAME, PARENT_ID) VALUES(3, '二级部门3',1);
INSERT INTO SF_ORG(ORG_ID, ORG_NAME, PARENT_ID) VALUES(4, '二级部门4',1);

commit;
select * from sf_org;

/*
2.3 VARRAY的使用举例

先定义一个能保存5个VARCHAR2(25)数据类型的成员的VARRAY数据类型ORG_VARRAY_TYPE，
然后声明一个该数据类型的VARRAY变量V_ORG_VARRAY，
最后用与ORG_VARRAY_TYPE数据类型同名的构造函数语法给V_ORG_VARRAY变量赋予初值并显示赋值结果。
注意，在引用数组中的成员时．需要在一对括号中使用顺序下标，下标从1开始而不是从0开始。
*/
declare
type org_varray_type is varray(5) of varchar2(25);
v_arr_set org_varray_type;
begin
v_arr_set := org_varray_type('1','2','3','4','5');
dbms_output.put_line('输出1：' || v_arr_set(1) || '、'|| v_arr_set(2) || '、'|| v_arr_set(3) || '、'|| v_arr_set(4));
dbms_output.put_line('输出2：' || v_arr_set(5));
v_arr_set(5) := '5001';
dbms_output.put_line('输出3：' || v_arr_set(5));
end;

--type 数组名 varray(size) of 元素类型 [not null];
--size : 数组长度，必填项。

DECLARE 
         TYPE type_var IS VARRAY(4) OF VARCHAR2(30);
         v_arr type_var;
  BEGIN
         v_arr := type_var('a','b','c','d');
         dbms_output.put_line('输出第一个：'||v_arr(3));
         v_arr(3) := 'dd';    -- 下标3，必须已存在值，否则报错。
         dbms_output.put_line('输出第三个：'||v_arr(3));
         
           FOR v_index IN v_arr.first .. v_arr.last 
           LOOP 
               -- 循环遍历数组
               dbms_output.put_line(v_arr(v_index));
           END LOOP;
            dbms_output.put_line('输出第三个：'||v_arr(10));
EXCEPTION WHEN OTHERS THEN
          dbms_output.put_line(sqlerrm);
    END;




/*
2.4 TABLE使用举例
2.4.1 存储单列多行
这个和VARRAY类似。但是赋值方式稍微有点不同，不能使用同名的构造函数进行赋值。具体的如下：
*/
-- 存储单列多行
declare
type org_table_type is table of varchar2(25)
index by binary_integer;
v_org_table org_table_type;
begin
v_org_table(1) := '1';
v_org_table(2) := '2';
v_org_table(3) := '3';
v_org_table(4) := '4';
v_org_table(5) := '5';
dbms_output.put_line('输出1：' || v_org_table(1) || '、'
|| v_org_table(2) || '、'|| v_org_table(3) || '、'|| v_org_table(4)||'、'|| v_org_table(5));
end;



/*
2.4.2 存储多列多行和ROWTYPE结合使用
采用bulkcollect可以将查询结果一次性地加载到collections中。
而不是通过cursor一条一条地处理。
*/

declare 
type t_type is table of sf_org%rowtype;
v_type t_type;
begin
  select * bulk collect into v_type from  sf_org;
  for v_index in v_type.first .. v_type.last
    loop
      dbms_output.put_line(v_type(v_index).org_id ||' '
      || v_type(v_index).org_name ||' '|| v_type(v_index).parent_id );
    end loop;  
end;

```

```


```

32、包头、包体

33、Oracle大纲

```
课程大纲
第一门课，Oracle Database 11g:SQL Fundamentals I 学习内容：
1．掌握关系数据库数据模型；
2．熟练在Linux平台上部署数据库系统；
3．根据业务需求定制各种类型的数据库；
4．掌握数据库中数据结构、数据类型的存储原理
5．熟练运用SQL语句检索、操纵、管理数据库中的数据；
6．MEGER、USING、ROLLUP、CUBE、集合运算符、和分层提取等高级方法来提取数据；
7． 编写SQL脚本文件，从而生成类似报告的输出结果；
8．运用开发工具编写过程、函数、包、触发器等程序块；
9. 学会查看数据字典
第二门课，Oracle Database 11g:Administrator I 学习内容：
了解Oracle核心组件Instance结构 掌握Oracle 数据库逻辑与物理存储结构 3管理ORACLE的实例、日志文件、控制文件、表空间、用户、权限、角色、表、索引、回滚段
4 Oracle Net Services网络配置,通过网络配置实现数据库的故障转移和负载均衡
4 配置应用程序数据库
5 使用基本监视过程
6 实施备份和恢复策略
7 在数据库和文件之间移动数据
第三门课，Oracle Database 11g:Administrator II学习内容：
1 创建一个能正常运行的数据库，以及如何以有效和高效的方式来正确管理各种不同的结构，从而构造出一个设计良好、高效率运行的数据库
2 如何实施数据库安全
3 使用资源管理器管理资源、作业调度、安全性和全球化问题
4 根据业务需求，制定与完善数据库的备份、恢复、和RECOVER等策略
5 执行数据库备份、恢复策略的计划与实施等关键任务，以及如何进行正确性的验证
6 根据实际数据库的十几种不同的损坏原因，采用不同的恢复方式
7 熟练掌握Recovery Manager工具来执行备份、恢复、执行块修复
8 使用脚本在内存、性能和存储方面，进行数据库监视操作
9 进行操作系统级调优
10 进行SQL语句调优
11 通过使用多种不同的工具，确认、分析、和解决Oracle 数据库在运行过程中所存在的瓶颈
```

