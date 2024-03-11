create or replace procedure p_test05
as
type t_type is table of scott.emp%rowtype;
v_type t_type;
v_total number(7,2);
v_table varchar2(100);
v_count int;
begin

--�ж��Ƿ������ʱ�� 
--������ʱ��
--��������Դ
--������Դ��ӵ���ʱ����
--��ѯ��ʱ��
--ɾ����ʱ��


--��ѯ���Ƿ���ڣ�count(1)��ֵ���� v_count
  v_table :='t_table';
  select count(1) into v_count from user_tables where table_name = upper(v_table); 
   --�����   ɾ����
  if v_count = 1 then
   --execute immediate 'truncate table t_table';--��ձ������� �����޷�drop table
   execute immediate 'drop table t_table';
 end if;
  commit;
    --������  
  execute immediate 'create table t_table'||'(EMPNO NUMBER(4,0), 
  ENAME VARCHAR2(10), 
  JOB VARCHAR2(9), 
  MGR NUMBER(4,0), 
  HIREDATE DATE, 
  SAL NUMBER(7,2), 
  COMM NUMBER(7,2), 
  DEPTNO NUMBER(2,0),
  total number(7,2))   ';

  select * bulk collect into v_type from scott.emp;
  for v_index in v_type.first ..v_type.last
    loop
      v_total :=v_type(v_index).SAL*12+nvl(v_type(v_index).COMM,0);
   
     execute immediate 'insert into t_table values(:1,:2,:3,:4,:5,:6,:7,:8,:9)'
    --using v_empno,v_ename,v_job,v_mgr,v_HIREDATE,v_sal,v_comm,v_deptno,v_total;
     using v_type(v_index).empno,v_type(v_index).ENAME,v_type(v_index).JOB,v_type(v_index).MGR,
     v_type(v_index).HIREDATE,v_type(v_index).SAL,v_type(v_index).COMM,v_type(v_index).DEPTNO,v_total;
    
   
  dbms_output.put_line(v_total);
 
    end loop;  
    commit;--�ύ
  -- execute immediate 'select * from t_table';
end;
