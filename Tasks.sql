-- �������� ������ ���������, � ������� ������� ���� ��������. ������� ��� ��������
select c.fullname
  from CLIENTS c
  where extract (day from c.bdate) = extract (day from sysdate)
    and extract (month from c.bdate) = extract (month from sysdate);

-- ��������� ���������� ���������, � ������� �� ������� ���� ��������
select count(*)
  from CLIENTS c
  where c.bdate is null;
  
-- ��������� ���������� ���������, � ������� �� ������� ���� ��������, �� ��������� �����-���� �������� ����������� (�������, �� �� ������������� WHERE, HAVING, CASE, IIF)
select count(c.pcode) - count(c.bdate)
  from CLIENTS c;
  
-- ��������� ������ ������������ ���� �������� � ������� ���������
select max(c.bdate)
  from CLIENTS c
  where c.bdate != (select max(bdate) from CLIENTS);
  
-- ��������� ������ ������������ ���� �������� � ������� ���������, �� ��������� ���������� ������� (�� ������� �� ����� ���� ��������� � ���������� ����� ��������)
with bdates as (select bdate
                      ,row_number() over (order by bdate desc) as rn
                  from CLIENTS
                  where bdate is not null)
select bdate
  from bdates
  where rn = 2;

-- ��������� ������ ������������ ���� �������� � ������� ���������, �� ��������� ���������� ������� (�� ������� ����� ���� �������� � ���������� ����� ��������)
with bdates as (select distinct bdate
                      ,row_number() over (order by bdate desc) as rn
                  from CLIENTS
                  where bdate is not null)
select bdate
  from bdates
  where rn = 2;
  
-- ������� ������ ������� ���������, ��� ������� ��� �� ������ �������
select *
  from CLIENTS c
  where c.pcode not in (select distinct pcode from TREAT);
  
-- ������� ������ ������� ��������� (CLIENTS.*), ��� ������� ���� ���� �� ���� �������
select *
  from CLIENTS c
  where c.pcode in (select distinct pcode from TREAT);
  
-- ������� ������ ������� ������� (TREAT.*), ��� ������� �����, ����������� �� ��������, (TREAT.AMOUNTCL) �������� ������������ � ������ ����� ��������
select *
  from TREAT t
  where t.amountcl = (select max(t1.amountcl)
                        from TREAT t1
                        where t1.pcode = t.pcode);
                        
-- ������� ������ ������ ������������� (���������� ��� � ���� ��������): ���, ���� ��������, ����������.
select c.*
      ,count(*) over (partition by c.fullname, c.bdate)
  from CLIENTS c
  where 1 < (select count(*)
               from CLIENTS c1
               where c1.fullname = c.fullname
                 and c1.bdate = c.bdate);

-- ��� ���� ������ ������� ������� ��������� ������: ��� �������, ���������� ������� �� �������, ���������� ������� �� �������, ��������� ������� ������ 10000.
select d.dname
      ,(select count(*)
          from TREAT t
          where t.dcode = d.dcode
            and t.treatdate = sysdate)
      ,(select count(*)
          from TREAT t
          where t.dcode = d.dcode
            and t.treatdate = sysdate
            and t.amountcl + t.amountjp > 10000) 
  from DOCTOR d;

-- ��� ���� ������ ������� ��������� ���������� ��������� ������� ��������� ��������� ����� (TREAT.AMOUNTCL) � 2019 ���� �� ��������� � 2018 ����. ������� ��� ������� � ��������� ����������
select d.dname
      ,nvl(avg(case when extract (year from t.treatdate) = 2019 then t.amountcl end)
           -
           avg(case when extract (year from t.treatdate) = 2018 then t.amountcl end)
           , 0) as change
  from DOCTOR d
    -- �������� ��� ������ �� ����� ����� �� ������ ����
    left join TREAT t
    on t.dcode = d.dcode
    and extract (year from t.treatdate) in (2018, 2019)
  group by d.dname;

-- ������� ������ ������������, ��� ������� ��������� �������� ������������ (CLHISTNUM.AMOUNTRUB) ������ �������� ��������� ���������� ��������� �� ����� ������������ ����� (TREAT.AMOUNTJP). ������� ��� ��������, ����� �������� (JPAGREEMENT.AGNUM), ����� ������ (CLHISTNUM.NSP), ������ ������������ (CLHISTNUM.BDATE,FDATE)
select cl.fullname
      ,j.agnum
      ,c.nsp
      ,to_char(c.bdate, 'dd.mm.yyyy') || '-' || to_char(c.fdate, 'dd.mm.yyyy') as period
  from CLHISTNUM   c
      ,CLIENTS     cl
      ,JPAGREEMENT j
  where cl.pcode = c.pcode
    and j.agrid  = c.agrid
    and c.amountrub < (select sum(t.amountcl + t.amountjp) / 2
                         from TREAT t
                         where t.histid = c.histid);
