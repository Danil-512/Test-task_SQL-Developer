-- Отобрать список пациентов, у которых сегодня день рождения. Вывести ФИО пациента
select c.fullname
  from CLIENTS c
  where extract (day from c.bdate) = extract (day from sysdate)
    and extract (month from c.bdate) = extract (month from sysdate);

-- Вычислить количество пациентов, у которых не указана дата рождения
select count(*)
  from CLIENTS c
  where c.bdate is null;
  
-- Вычислить количество пациентов, у которых не указана дата рождения, не используя какие-либо условные конструкции (включая, но не ограничиваясь WHERE, HAVING, CASE, IIF)
select count(c.pcode) - count(c.bdate)
  from CLIENTS c;
  
-- Вычислить вторую максимальную дату рождения в таблице пациентов
select max(c.bdate)
  from CLIENTS c
  where c.bdate != (select max(bdate) from CLIENTS);
  
-- Вычислить вторую максимальную дату рождения в таблице пациентов, не используя агрегатных функций (по условию не может быть пациентов с одинаковой датой рождения)
with bdates as (select bdate
                      ,row_number() over (order by bdate desc) as rn
                  from CLIENTS
                  where bdate is not null)
select bdate
  from bdates
  where rn = 2;

-- Вычислить вторую максимальную дату рождения в таблице пациентов, не используя агрегатных функций (по условию могут быть пациенты с одинаковой датой рождения)
with bdates as (select distinct bdate
                      ,row_number() over (order by bdate desc) as rn
                  from CLIENTS
                  where bdate is not null)
select bdate
  from bdates
  where rn = 2;
  
-- Вывести строки таблицы пациентов, для которых нет ни одного лечения
select *
  from CLIENTS c
  where c.pcode not in (select distinct pcode from TREAT);
  
-- Вывести строки таблицы пациентов (CLIENTS.*), для которых есть хотя бы одно лечение
select *
  from CLIENTS c
  where c.pcode in (select distinct pcode from TREAT);
  
-- Вывести строки таблицы лечений (TREAT.*), для которых сумма, начисленная на пациента, (TREAT.AMOUNTCL) является максимальной в рамках этого пациента
select *
  from TREAT t
  where t.amountcl = (select max(t1.amountcl)
                        from TREAT t1
                        where t1.pcode = t.pcode);
                        
-- Вывести список полных однофамильцев (совпадение ФИО и даты рождения): ФИО, дата рождения, количество.
select c.*
      ,count(*) over (partition by c.fullname, c.bdate)
  from CLIENTS c
  where 1 < (select count(*)
               from CLIENTS c1
               where c1.fullname = c.fullname
                 and c1.bdate = c.bdate);

-- Для всех врачей клиники вывести следующий список: ФИО доктора, количество лечений за сегодня, количество лечений за сегодня, стоимость которых больше 10000.
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

-- Для всех врачей клиники вычислить абсолютное изменение средней стоимости наличного приёма (TREAT.AMOUNTCL) в 2019 году по отношению к 2018 году. Вывести ФИО доктора и указанный показатель
select d.dname
      ,nvl(avg(case when extract (year from t.treatdate) = 2019 then t.amountcl end)
           -
           avg(case when extract (year from t.treatdate) = 2018 then t.amountcl end)
           , 0) as change
  from DOCTOR d
    -- Получить все приемы по этому врачу за нужные года
    left join TREAT t
    on t.dcode = d.dcode
    and extract (year from t.treatdate) in (2018, 2019)
  group by d.dname;

-- Вывести список прикреплений, для которых стоимость годового прикрепления (CLHISTNUM.AMOUNTRUB) меньше половины стоимости фактически оказанных по этому прикреплению услуг (TREAT.AMOUNTJP). Указать ФИО пациента, номер договора (JPAGREEMENT.AGNUM), номер полиса (CLHISTNUM.NSP), период прикрепления (CLHISTNUM.BDATE,FDATE)
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
