LIBNAME SDTM "/home/u64220165/AE";

proc import datafile="/home/u64220165/Table/adam_adae_20250902_112452.csv"
    out=ADAE
    dbms=csv
    replace;
    getnames=yes;
run;

proc import datafile="/home/u64220165/Table/adam_adsl_20250902_112443.csv"
    out=ADSL
    dbms=csv
    replace;
    getnames=yes;
run;

data DM1;
set ADSL;
If SAFFL="Y";
run;

********  Giving orders to TRT's  *********;

data DM2;
set DM1;
If INDEX(TRT01A, "Treatment 1")>0 Then Do; TRT="A"; ORD="1"; End;
If INDEX(TRT01A, "Treatment 2")>0 Then Do; TRT="B"; ORD="2"; End;
Keep USUBJID TRT ORD;
run;

********  Creating N counts  *****************;
proc freq data=DM2;
    tables TRT / nocum nopercent;
run;

Proc sql noprint;
select count (distinct USUBJID) into : N1-:N2 Fro DM2
Group by ORD
order by ORD;
Quit;
%Put &N1 &N2;

********  Apply Filters to AE dataset  *****************;

data AE1;
set ADAE;
If TRTEMFL="Y";
If INDEX(TRTA, "Treatment 1")>0 Then Do; TRT="A"; ORD="1"; End;
If INDEX(TRTA, "Treatment 2")>0 Then Do; TRT="B"; ORD="2"; End;
run;

******* Getting the counts ***********;

proc freq data=AE1;
    tables AEDECOD/ nocum nopercent;
run;

proc freq data=AE1;
    tables AEBODSYS/ nocum nopercent;
run;

proc sql print;
create table A1 as 
select TRT, count (distinct USUBJID) as N, "Number of Subjects with TEAEs" as AEBODSYS
length=200 from AE1
Group by TRT;

create table A2 as 
select TRT,AEBODSYS, count (distinct USUBJID) as N from AE1
Group by TRT,AEBODSYS;

create table A3 as 
select TRT,AEBODSYS,AEDECOD, count (distinct USUBJID) as N from AE1
Group by TRT,AEBODSYS,AEDECOD;
Quit;

Data ALL;
set A1 A2 A3;
run;


proc sort;
BY AEBODSYS AEDECOD TRT;
run;


Proc Transpose data=ALL out=ALL_new;
ID TRT;
BY AEBODSYS AEDECOD;
run;

******* Percentage Calculations ***********;

Data FINAL;
set ALL_new;
length DRUGA DRUGB $100.;

If A=. then DRUGA="0";
	else if A=&N1 then DRUGA=put(A,3.)||"(100%)";
		else DRUGA=put(A,3.)||" ("||put(A/&N1*100,4.1)||") ";
		
If B=. then DRUGB="0";
	else if B=&N2 then DRUGB=put(B,3.)||"(100%)";
		else DRUGB=put(B,3.)||" ("||put(B/&N2*100,4.1)||") ";

If AEDECOD EQ " " and AEBODSYS NE " " then AEBODSYS1=AEBODSYS;
	else AEBODSYS1=" "|| AEDECOD;
run;


%MTITLET (progid=rtae1);
ods escapechar="^";

PROC REPORT DATA=FINAL NOWD HEADLINE HEADSKIP SPLIT="|" MISSING
    STYLE ={OUTPUTWIDTH=100%} SPACING=1 WRAP
    STYLE (HEADER)={JUST=C};

COLUMN AEBODSYS AEDECOD AEBODSYS1 
    ('^S={borderbottomcolor=black borderbottomwidth=2} Treatment' druga drugb);

DEFINE AEBODSYS/ORDER NOPRINT;
DEFINE AEDECOD/ORDER NOPRINT;

DEFINE AEBODSYS1/DISPLAY "MedDRA® System Organ Class| MedDRA® Preferred Term"
    STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=20%]
    STYLE (HEADER) =[JUST=LEFT CELLWIDTH=20%]
;
DEFINE druga/DISPLAY "100 MG TG3304|(N=&N1)"
    STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=20%]
    STYLE (HEADER) =[JUST=LEFT CELLWIDTH=20%]
;

DEFINE drugB/DISPLAY "PLACEBO|(N=&N2)"
    STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=20%]
    STYLE (HEADER) =[JUST=LEFT CELLWIDTH=20%]
;

COMPUTE BEFORE AEBODSYS;
    LINE '';
ENDCOMP;
RUN;



ODS _ALL_ CLOSE;
%MPAGEOF;



