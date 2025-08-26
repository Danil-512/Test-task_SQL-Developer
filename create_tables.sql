-- �����
create table DOCTOR (
  DCODE integer PRIMARY KEY,  -- ���� �����
  DNAME varchar(255)          -- ������ ��� �����
);

insert all 
  into DOCTOR (DCODE, DNAME) values (1, '������ �.�.')
  into DOCTOR (DCODE, DNAME) values (2, '������ �.�.')
  into DOCTOR (DCODE, DNAME) values (3, '�������� �.�.')
select * from dual
;

select *
  from DOCTOR;


-- ��������� �������� � ������ ��.����
create table JPERSONS (
  JID   integer PRIMARY KEY, -- ���� �������� 
  JNAME varchar(255)         -- �������� ��������
);

insert all 
  into JPERSONS (JID, JNAME) values (1, '��� "�������"')
  into JPERSONS (JID, JNAME) values (2, '��� "������������"')
  into JPERSONS (JID, JNAME) values (3, '��� "����"')
select * from dual
;

select *
  from JPERSONS;


-- �������� �� ���������� ���������� � �������������
create table JPAGREEMENT (
  AGRID integer PRIMARY KEY,  -- ���� ��������
  AGNUM varchar(255),         -- ����� ��������
  JID   integer,              -- ���� ��������� ��������
  -- ������� ���� JID �� ������� JPERSONS
  CONSTRAINT JID_JPAGREEMENT_fk FOREIGN KEY (JID) REFERENCES JPERSONS(JID)
);

insert all 
  into JPAGREEMENT (AGRID, AGNUM, JID) values (1, '4030', 1)
  into JPAGREEMENT (AGRID, AGNUM, JID) values (2, '2232', 2)
  into JPAGREEMENT (AGRID, AGNUM, JID) values (3, '10203', 3)
select * from dual
;

select *
  from JPAGREEMENT;
  
  
-- ��������
create table CLIENTS (
  PCODE    integer PRIMARY KEY, -- ���� ��������
  FULLNAME varchar(255),        -- ������ ��� ��������
  BDATE    date                 -- ���� �������� ��������
);

insert all 
  into CLIENTS (PCODE, FULLNAME, BDATE) values (1, '������� ����������', to_date('01.01.2000', 'dd.mm.yyyy'))
  into CLIENTS (PCODE, FULLNAME, BDATE) values (2, '���� ��������', to_date('02.02.2002', 'dd.mm.yyyy'))
  into CLIENTS (PCODE, FULLNAME, BDATE) values (3, '���� ��������', to_date('03.03.2003', 'dd.mm.yyyy'))
select * from dual
;

select *
  from CLIENTS;


-- ��������� ������������ (������)
create table CLHISTNUM (
  HISTID    integer PRIMARY KEY,                                     -- ���� ������
  PCODE     integer,                                                 -- ���� �������
  CONSTRAINT PCODE_CLHISTNUM_fk FOREIGN KEY (PCODE) REFERENCES CLIENTS(PCODE),
  BDATE     date,                                                    -- ���� ������ �������� ������
  FDATE     date,                                                    -- ���� ��������� �������� ������
  NSP       varchar(255),                                            -- ����� ���������� ������
  AMOUNTRUE decimal(20, 2),                                          -- ��������� �����
  AGRID     integer,                                                 -- �� ��������� ��������
  CONSTRAINT AGRID_CLHISTNUM_fk FOREIGN KEY (AGRID) REFERENCES JPAGREEMENT(AGRID)
);

--drop table CLHISTNUM;

insert all 
  into CLHISTNUM (HISTID, PCODE, BDATE, FDATE, NSP, AMOUNTRUE, AGRID) values (1, 1, to_date('01.01.2020', 'dd.mm.yyyy'), to_date('01.01.2021', 'dd.mm.yyyy'), '423432423', 100000, 1)
  into CLHISTNUM (HISTID, PCODE, BDATE, FDATE, NSP, AMOUNTRUE, AGRID) values (2, 2, to_date('02.04.2021', 'dd.mm.yyyy'), to_date('01.01.2023', 'dd.mm.yyyy'), '423432424', 400000, 2)
  into CLHISTNUM (HISTID, PCODE, BDATE, FDATE, NSP, AMOUNTRUE, AGRID) values (3, 3, to_date('01.12.2019', 'dd.mm.yyyy'), to_date('01.01.2022', 'dd.mm.yyyy'), '423432425', 600000, 3)
select * from dual
;

select *
  from CLHISTNUM;
  

-- ������
create table TREAT (
  TREATCODE  integer PRIMARY KEY,                                     -- ���� ������
  PCODE      integer,                                                 -- ���� ��������
  CONSTRAINT PCODE_TREAT_fk FOREIGN KEY (PCODE) REFERENCES CLIENTS(PCODE),
  DCODE      integer,                                                 -- ���� �������
  CONSTRAINT DCODE_TREAT_fk FOREIGN KEY (DCODE) REFERENCES DOCTOR(DCODE),
  TREATDATE  date,                                                    -- ���� ������
  AMOUNTCL   decimal(20, 2),                                          -- ����� ������ �� �������
  AMOUNTJP   decimal(20, 2),                                          -- ����� ������ �� ��������� ��������
  HISTID     integer,                                                -- ���� ������
  CONSTRAINT HISTID_TREAT_fk FOREIGN KEY (HISTID) REFERENCES CLHISTNUM(HISTID)
);

--drop table TREAT;

insert all 
  into TREAT (TREATCODE, PCODE, DCODE, TREATDATE, AMOUNTCL, AMOUNTJP, HISTID) values (1, 1, 1, to_date('01.01.2021', 'dd.mm.yyyy'), 1000, 10000, 1)
  into TREAT (TREATCODE, PCODE, DCODE, TREATDATE, AMOUNTCL, AMOUNTJP, HISTID) values (2, 2, 2, to_date('01.03.2021', 'dd.mm.yyyy'), 3000, 40000, 2)
  into TREAT (TREATCODE, PCODE, DCODE, TREATDATE, AMOUNTCL, AMOUNTJP, HISTID) values (3, 3, 3, to_date('01.02.2021', 'dd.mm.yyyy'), 5000, 20000, 3)
select * from dual
;

select *
  from TREAT;

/*
begin
  execute immediate 'drop table TREAT';  
  execute immediate 'drop table CLHISTNUM';
  execute immediate 'drop table CLIENTS';
  execute immediate 'drop table JPAGREEMENT';
  execute immediate 'drop table JPERSONS';
  execute immediate 'drop table DOCTOR';
  --
  dbms_output.put_line('��� ������� �������!');
end;
*/
