--Ilu pracowników znajduje siê w bazie danych tej firmy?
select count(*) from hr_database hd ;
--311 pracowników

--Ilu aktywnych pracowników (Termd = 0) nie jest obywatelami USA?
select count(emp_id) from hr_database hd 
where termd = 0 and citizen_desc != 'US Citizen';
--8

--Czy ID pracowników (EmpID) jest unikalne?
select count(distinct emp_id) from hr_database hd ;
--jest unikalne poniewa¿ po u¿yciu distinct nadal otrzymujemy t¹ sam¹ liczbê wierszy,
--oznacza to, ze rekord siê nie powtarzaj¹ 

--Jakie s¹ wide³ki zarobków (minimum i maksimum)? Jakie one s¹ dla poszczególnych pozycji?
select min(salary), max(salary), "position" from hr_database hd 
group  by "position";
--min: 63000	max:64520   Accountant I
--min: 49920	max:55000	Administrative Assistant
--min: 55875	max:74326 Area Sales Manager;
--min: 90100	max:99020	BI Developer;
--min: 110929	max:110929	BI Director;
--min: 220450	max:220450	CIO;
--min: 83552	max:93554	Data Analyst;
--min: 88527	max:88527	Data Analyst ;
--min: 150290	max:150290	Data Architect;
--min: 97999	max:114800	Database Administrator;
--min: 170500	max:170500	Director of Operations;
--min: 180000	max:180000	Director of Sales;
--min: 103613	max:103613	Enterprise Architect;
--min: 178000	max:178000	IT Director;
--min: 140920	max:148999	IT Manager - DB
--min: 157000	max:157000	IT Manager - Infra;
--min: 138888	max:138888	IT Manager - support;
--min: 50178	max:74679	IT support;
--min: 50750	max:76029	Network Engineer;
--min: 250000	max:250000	President & CEO;
--min: 120000	max:120000	Principal Data Architect;
--min: 62957	max:88976	Production Manager;
--min: 45046	max:64991	Production Technician I;
--min: 55315	max:74813	Production Technician II;
--min: 65729	max:72992	Sales Manager;
--min: 81584	max:87921	Senior BI Developer;
--min: 93046	max:93046	Shared Services Manager;
--min: 83363	max:108987	Software Engineer;
--min: 77692	max:77692	Software Engineering Manager;
--min: 99351	max:106367	Sr. Accountant
--min: 100031	max:104437	Sr. DBA
--min: 85028	max:107226	Sr. Network Engineer;


--Ile osób jest zatrudnionych na stanowisku Production Technician (niezale¿nie od rangi)?
select count("position") from hr_database hd 
where "position" like 'Production Technician%';
--194
--Dlaczego Carol Anderson zrezygnowa³a z pracy?
select termreason from hr_database hd 
where employee_name = 'Anderson, Carol ';
-- return to school

--Podopieczni której/go managerki/a s¹ najbardziej zadowoleni z pracy (EmpSatisfaction)?
select avg(empsatisfaction), managername from hr_database hd 
group by managername ;
-- Debra Houlihan

--BONUS: ile jest departamentów, w których wiêcej ni¿ 5 aktywnych pracowników przekracza oczekiwania odnoœnie performance’u?
select count(department), department from hr_database hd2 
where employmentstatus = 'Active' and  performancescore = 'Exceeds'
group by department 
having count(department) > 5 
;
-- Dwa departamenty, IT/IS i Production

