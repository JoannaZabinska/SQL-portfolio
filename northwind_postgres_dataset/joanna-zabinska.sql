--a)Jakie są miasta, w których mieszka więcej niż 3 pracowników? 

select percentile_disc(0.33) within group(order by "City") from employees e ; 
--ODP:3 pracownik�w to 33% wszystkich pracownik�w.

--b)Zakładając, że produkty, które kosztują (UnitPrice) mniej niż 10$ możemy uznać za tanie, 
--te między 10$ a 50$ za średnie, a te powyżej 50$ za drogie, le produktów należy do poszczególnych przedziałów? 

with drogie as
(
select count(p."UnitPrice") drogie  from products p 
where p."UnitPrice" >50 
), 
tanie as 
(select count(p."UnitPrice") tanie from products p 
where p."UnitPrice" < 10
),
srednie as 
(select count(p."UnitPrice") srednie from products p 
where p."UnitPrice" > 10 or p."UnitPrice"< 50
)
select * from drogie, tanie, srednie;

--ODP: drogich by�o 7, tanich 11 a srednich 77.

--c)Czy najdroższy produkt z kategorii z największą średnią ceną to najdroższy produkt ogólnie?

select p."ProductName", p."UnitPrice", p."CategoryID", c."CategoryName",
avg(p."UnitPrice") over (partition by c."CategoryID") �rednia_z_kategorii,
max(p."UnitPrice") over (partition by c."CategoryID") najdro�szy_produkt  from products p
right join categories c on c."CategoryID"=p."CategoryID" 
group by p."ProductName", p."UnitPrice", p."CategoryID",c."CategoryName",c."CategoryID"
order by �rednia_z_kategorii desc ;

select max(p."UnitPrice"), p."ProductName"  from products p
group by p."ProductName", p."UnitPrice"
order by 1 desc ;

--ODP: Nie.Najdro�szy product ma cene 263.5 i jest to C�te de Blaye z kategorii Beverages.
-- a najwi�sz� �redni� cene ma kategoria Meat/Poultry.

--d)d.	Ile kosztuje najtańszy, najdroższy i ile średnio kosztuje produkt od każdego z dostawców? 
--UWAGA – te dane powinny być przedstawione z nazwami dostawców, nie ich identyfikatorami 

select p."ProductName", p."UnitPrice", s."CompanyName", 
min(p."UnitPrice") over(partition by s."SupplierID") cena_najtanszego_produktu_od_dostawcy, 
max(p."UnitPrice") over(partition by s."SupplierID") cena_najdro�szego_produktu_od_dostawcy,
avg(p."UnitPrice") over(partition by s."SupplierID") �rednia_cena_produkt�w_od_dostawcy 
from products p
right join suppliers s  on s."SupplierID"=p."SupplierID"
order by p."SupplierID";

--e)Jak się nazywają i jakie mają numery kontaktowe wszyscy dostawcy i klienci (ContactName) z Londynu? Jeśli nie ma numeru telefonu, wyświetl faks. 

select s."ContactName", s."City",
case
	when s."Phone" = ' ' then s."Fax" 
	else s."Phone" 
end as contact_number
from suppliers s 
where s."City" = 'London'
union
select c."ContactName", c."City",
case 
	when c."Phone" = '' then c."Fax" 
	else c."Phone" 
end
from customers c 
where c."City"='London'
;

--f)Jakie produkty były na najdroższym zamówieniu (OrderID)? Uwzględnij zniżki (Discount) 

select p."ProductName", od."UnitPrice", 
od."Quantity", 
od."OrderID",od."Discount" , 
(od."Quantity" * od."UnitPrice")-(od."Quantity" * od."UnitPrice")*od."Discount" warto��_zam�wienia_ze_zni�k�,
avg((od."Quantity" * od."UnitPrice")-(od."Quantity" * od."UnitPrice")*od."Discount") over(partition by od."OrderID") �rednia_warto��_ka�dego_zam�wienia
from order_details od 
right join products p on p."ProductID" = od."ProductID" 
order by �rednia_warto��_ka�dego_zam�wienia desc;

--ODP: C�te de Blaye, order ID=10981

--g)które miejsce cenowo (od najtańszego) zajmują w swojej kategorii (CategoryID) wszystkie produkty? 

select p."UnitPrice", p."CategoryID", c."CategoryName", p."ProductName",
row_number() over (partition by c."CategoryName" order by p."UnitPrice") from products p 
right join categories c on c."CategoryID" = p."CategoryID"
order by p."CategoryID", p."UnitPrice";

--BONUS: c.d przykładu wyżej – które miejsce zajmuje „Ravioli Angelo”? Wyświetl tylko ten produkt

select unitprice, catid, catname, productname, rownumber
from 
(
select p."UnitPrice" unitprice, p."CategoryID" catid, c."CategoryName" catname, p."ProductName" productname , 
row_number() over (partition by c."CategoryName" order by p."UnitPrice") rownumber from products p 
right join categories c on c."CategoryID" = p."CategoryID"
order by p."CategoryID", p."UnitPrice") as ravioli 
where productname = 'Ravioli Angelo';





