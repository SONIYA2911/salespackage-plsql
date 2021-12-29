create table Products(Product_id int generated by default as identity (start with 10 increment by 1) ,Product_name varchar2(50),Description varchar2(200),
Standard_cost number,List_price number,Category_id int,constraint pk_productid primary key(Product_id),foreign key (Category_id) references
product_categories(Category_id));
drop table Products cascade constraints;

create table product_categories(Category_id int generated by default as identity (start with 100 increment by 1) ,Category_name varchar2(100),
constraint pk_Categoryid primary key(Category_id));


create table Employees(employee_id int generated by default as identity (start with 200 increment by 1) ,first_name varchar2(50),last_name varchar2(50),
email varchar2(200),phone_number number,hire_date date,manager_id int,job_title varchar2(100),constraint pk_employeeid primary key(employee_id));


create table Customers(cust_id int generated by default as identity (start with 300 increment by 1),cust_name varchar2(50),address varchar2(100),
website varchar2(100),credit_limit number,constraint pk_customerid primary key(cust_id));


create table Orders(order_id int generated by default as identity (start with 400 increment by 1), cust_id int,status varchar2(50),salesman_id int,
order_date date,constraint pk_orderid primary key(order_id),foreign key(cust_id) references Customers(cust_id),
foreign key(salesman_id) references Employees(employee_id));


create table Order_items(item_id int generated by default as identity (start with 500 increment by 1),order_id int,Product_id int,Quantity number,
unit_price number,constraint pk_itemid primary key(item_id),foreign key(order_id) references Orders(order_id),
foreign key(Product_id) references Products(Product_id));




--Product_Category
create or replace package sales_package AS
procedure addCategories(
cat_name  in product_categories.category_name%type,
p_status out varchar2,
p_error out varchar2);

procedure delCategories(cat_id  in product_categories.category_id%type,
                      p_status out varchar2,
                      p_error out varchar2);
                     
procedure addCustomers(c_name in Customers.cust_name%type,
                    c_addr in Customers.address%type,
                    c_web in Customers.website%type,
                    c_limit in Customers.credit_limit%type,
                    c_status out varchar2,
                    c_error out varchar2);
   
procedure delCustomers(c_id in Customers.cust_id%type,
                       c_status out varchar2,
                       c_error out varchar2);

procedure addProduct(
   p_name in  Products.product_name%type,
   p_des  in  Products.description%type,
   p_scost in Products.standard_cost%type,
   p_price in products.list_price%type,
   p_cat  in  products.category_id%type,
   pro_status  out varchar2,
   pro_error out varchar2);

procedure delProduct(p_id in Products.product_id%type,
                     pro_status  out varchar2,
                     pro_error out varchar2);
                     
procedure addEmployee(
e_fname in Employees.first_name%type,
e_lname in Employees.last_name%type,
e_mail in Employees.email%type,
e_pnumber in Employees.phone_number%type,
e_date in Employees.hire_date%type,
e_mid in Employees.manager_id%type,
e_title in Employees.job_title%type,
e_status out varchar2,
e_error out varchar2);

procedure delEmployee(e_id in Employees.employee_id%type,
                       e_status out varchar2,
                       e_error out varchar2);
                       
procedure addOrder(
O_cust_id  in Orders.cust_id%type,
Order_status  in Orders.status%type,
O_emp_id  in orders.salesman_id%type,
O_date in  Orders.order_date%type,
O_status out varchar2,
O_error out varchar2);


procedure updateOrder(O_id in Orders.order_id%type,
                   Order_status  in Orders.status%type,                  
                   O_status out varchar2,
                   O_error out varchar2);                      
                         
procedure addOrderitems(
Oitem_oid in Order_items.order_id%type,
Oitem_pid in Order_items.product_id%type,
Oitem_quan  in Order_items.quantity%type,
Oitem_uprice in  Order_items.unit_price%type,
Oitem_status out varchar2,
Oitem_error out varchar2);

procedure delOrderitems(Oitem_id  in Order_items.item_id%type,
                   Oitem_status out varchar2,
                   Oitem_error out varchar2);                        
                     
end sales_package;                      
/
--package created



create or replace package body sales_package as
procedure addCategories(
cat_name  in product_categories.category_name%type,
p_status out varchar2,
p_error out varchar2)
is
begin
insert into product_categories(category_name) values(cat_name);
if sql%rowcount>0
then p_status:='inserted';
end if;
commit;
exception when others then
p_status:='product category does not exist';
p_error:='sqlcode'||sqlerrm;
end addCategories;

procedure delCategories(cat_id  in product_categories.category_id%type,
                        p_status out varchar2,
                        p_error out varchar2)
is
begin
delete from product_categories where category_id = cat_id;
if sql%rowcount=0
then p_status:='category id deleted:'||cat_id ;
end if;
commit;
exception when others then
p_status:='category id does not exist:'||cat_id;
p_error:='sql code'||sqlerrm;
end delCategories;


procedure addCustomers(
      c_name in Customers.cust_name%type,
      c_addr in Customers.address%type,
      c_web in Customers.website%type,
      c_limit in Customers.credit_limit%type,
      c_status out varchar2,
      c_error out varchar2)
is
begin
insert into Customers(cust_name,address,website,credit_limit)
values(c_name,c_addr,c_web,c_limit);
if sql%rowcount>0
then c_status:='inserted';
end if;
commit;
exception when others then
c_status:='customers details does not exist';
c_error:='sqlcode'||sqlerrm;
end addCustomers;

procedure delCustomers(c_id in Customers.cust_id%type,
                        c_status out varchar2,
                       c_error out varchar2)
is
begin
delete from Customers where cust_id = c_id;
if sql%rowcount=0
then c_status:='customer id deleted:' ||c_id;
end if;
commit;
exception when others then
c_status:='customer id does not exist:' ||c_id;
c_error:='sqlcode'||sqlerrm;
end delCustomers;

procedure addProduct(
   p_name  in Products.product_name%type,
   p_des  in  Products.description%type,
   p_scost in  Products.standard_cost%type,
   p_price in  Products.list_price%type,
   p_cat in   Products.category_id%type,
   pro_status out varchar2,
   pro_error  out varchar2)
   
is
begin
insert into Products(product_name,description,standard_cost,list_price,category_id)
values(p_name,p_des,p_scost,p_price,p_cat);
if sql%rowcount>0
then pro_status:='products inserted';
end if;
commit;
exception when others then
pro_status:='products does not exist';
pro_error:='sqlcode'||sqlerrm;
end addProduct;  
   
procedure delProduct(p_id in  Products.product_id%type,
                     pro_status out  varchar2,
                     pro_error out varchar2)
 is
 begin
delete from Products where product_id=p_id;
if sql%rowcount=0
then pro_status:='product id deleted:' || p_id;
end if;
commit;
exception when others then
pro_status:='product id does not exist:' ||p_id;
pro_error:='sqlcode'||sqlerrm;
end delProduct;

procedure addEmployee(
e_fname in Employees.first_name%type,
e_lname in Employees.last_name%type,
e_mail in Employees.email%type,
e_pnumber in Employees.phone_number%type,
e_date in Employees.hire_date%type,
e_mid in Employees.manager_id%type,
e_title in Employees.job_title%type,
e_status out varchar2,
e_error out varchar2)

is
begin
insert into Employees(first_name,last_name,email,phone_number,hire_date,manager_id,job_title)
values(e_fname,e_lname,e_mail,e_pnumber,e_date,e_mid,e_title);
if sql%rowcount>0
then e_status:='employees inserted ';
end if;
commit;
exception when others then
e_status:='employees does not exist';
e_error:='sqlcode'||sqlerrm;
end addEmployee;  
   
procedure delEmployee(e_id in Employees.employee_id%type,
                     e_status out  varchar2,
                     e_error out varchar2)
is
begin
delete from Employees where employee_id=e_id;
if sql%rowcount=0
then e_status:='employee id deleted: '||e_id;
end if;
commit;
exception when others then
e_status:='employee id does not exist:'||e_id;
e_error:='sqlcode'||sqlerrm;
end delEmployee;

procedure addOrder(
O_cust_id  in Orders.cust_id%type,
Order_status in Orders.status%type,
O_emp_id  in orders.salesman_id%type,
O_date in Orders.order_date%type,
O_status out varchar2,
O_error out varchar2)

is
begin
insert into Orders(cust_id,status,salesman_id,order_date)
values(O_cust_id,Order_status,O_emp_id,O_date);
if sql%rowcount>0
then O_status:='inserted';
end if;
commit;
exception when others then
O_status:=' order does not exist';
O_error:='sqlcode'||sqlerrm;
end addOrder;  
 
 procedure updateOrder(O_id in Orders.order_id%type,
                       Order_status in  Orders.status%type,
                   O_status out varchar2,
                   O_error out varchar2)
                   
is
begin
update Orders set status=Order_status where order_id=O_id  ;
if sql%rowcount>0
then O_status:='order updated';
end if;
commit;
exception when others then
O_status:=' order does not exist';
O_error:='sqlcode'||sqlerrm;
end  updateOrder;



procedure addOrderitems(
Oitem_oid in Order_items.order_id%type,
Oitem_pid in Order_items.product_id%type,
Oitem_quan in Order_items.quantity%type,
Oitem_uprice in Order_items.unit_price%type,
Oitem_status out varchar2,
Oitem_error out varchar2)
is
begin
insert into Order_items(order_id,product_id,quantity,unit_price)
values(Oitem_oid,Oitem_pid,Oitem_quan,Oitem_uprice);
if sql%rowcount>0
then Oitem_status:='inserted';
end if;
commit;
exception when others then
Oitem_status:='does not exist';
Oitem_error:='sqlcode'||sqlerrm;
end addOrderitems;  

procedure delOrderitems(Oitem_id  in Order_items.item_id%type,
                   Oitem_status out varchar2,
                   Oitem_error out varchar2)
is
begin
delete from Order_items where item_id=Oitem_id;
if sql%rowcount=0
then Oitem_status:='Item id deleted';
end if;
commit;
exception when others then
Oitem_status:='Item  id does not exist';
Oitem_error:='sqlcode'||sqlerrm;
end delOrderitems;


end sales_package;
/




--CUSTOMERS
--insert
declare
c_status varchar2(50);
c_error varchar2(100);

begin
----sales_package.addCustomers('soniya','Chennai','soni@gmail.com',20000,c_status,c_error);
----sales_package.addCustomers('vignesh','Dindugal','vignesh@gmail.com',30000,c_status,c_error);
sales_package.addCustomers('rajam','madurai','raji@gmail.com',30000,c_status,c_error);
dbms_output.put_line(c_status||' '||c_error);
end;
/
select*from Customers;
set serveroutput on
--delete
declare
c_id Customers.cust_id%type:=&enter_id;
c_status varchar2(50);
c_error varchar2(100);
begin
sales_package.delCustomers(c_id,c_status,c_error);
dbms_output.put_line(c_status||' '||c_error);

end delCustomers;
/
set serveroutput on
select*from Customers;




--Product
--insert
declare
pro_status varchar2(50);
pro_error varchar2(100);
begin
--sales_package.addProduct('Pen drive','Type c pen drive',1500,999,102,pro_status,pro_error);
sales_package.addProduct('Waching machine','Fully automatic front load washing machine',43000,36000,101,pro_status,pro_error);
---sales_package.addProduct('eye liner','dazzler eye liner black',230,239,100,pro_status,pro_error);
--sales_package.addProduct('Refrigerator','Whirlpool 245 litres 2 star frost free Double door',22000,20490,103,pro_status,pro_error);
dbms_output.put_line(pro_status||' '||pro_error);
end;
/
desc Products;
set serveroutput on
select*from Products;
--delete
declare
p_id Products.product_id%type:=&enter_id;
pro_status varchar2(50);
pro_error varchar2(100);
begin
sales_package.delProduct(p_id,pro_status,pro_error);
dbms_output.put_line(pro_status||' '||pro_error);

end delProduct;
/
set serveroutput on
--EMPLOYEE.
--insert
declare
e_status  varchar2(50);
e_error varchar2(100);
begin
--sales_package.addEmployee('anu','sharma','anu@gmail.com',9864675634,'13-08-2015',1,'Data analyst',e_status,e_error);
--sales_package.addEmployee('ananthi','sharma','ananthi@gmail.com',8608491910,'03-08-2015',2,'Data engineer',e_status,e_error);
--sales_package.addEmployee('amarnath','pillai','amarnath@gmail.com',7894589654,'20-07-2013',3,'Business analyst',e_status,e_error);
sales_package.addEmployee('vignesh','kumar','vignesh@gmail.com',7708480976,'01-01-2014',4,'Business analyst',e_status,e_error);
--sales_package.addEmployee('haritha', 'mohan', 'haritha@gmail.com', 7710589123, '22-07-2014',6,'Brand and positioning specialist',e_status,e_error);
dbms_output.put_line(e_status||' '||e_error);
end;
/
select*from Employees;
--delete
declare
e_id Employees.employee_id%type:=&enter_id;
e_status varchar2(50);
e_error varchar2(100);
begin
sales_package.delEmployee(e_id,e_status,e_error);
dbms_output.put_line(e_status||' '||e_error);

end delEmployees;
/

  select*from Orders;           
 --ORDERS
 --INSERT
 declare
O_status varchar2(50);
O_error varchar2(100);
begin
sales_package.addOrder(300,'order placed',200,'13-Nov-17',O_status,O_error);
dbms_output.put_line(O_status||' '||O_error);
end;
/
desc Orders;
set serveroutput on
declare
--O_id  Orders.order_id%type:=&enter_id;
O_status varchar2(50);
O_error varchar2(100);
begin
sales_package.updateOrder(404,'order cancelled',O_status,O_error);
--salaes_package.updateOrder('pending',O_status,O_error);
dbms_output.put_line(O_status||' '||O_error);

end;
/


set serveroutput on
select*from Orders;

--ORDER ITEMS
--INSERT
 declare
Oitem_status varchar2(50);
Oitem_error varchar2(100);
begin
sales_package.addOrderitems(403,18,3,399,Oitem_status,Oitem_error);
--sales_package.addOrderitem(406,11,1,2599,Oitem_status,Oitem_error);
--sales_package.addOrderitem(407,13,4,15999,Oitem_status,Oitem_error);
--sales_package.addOrderitem(408,14,1,3175,Oitem_status,Oitem_error);
--sales_package.addOrderitem(409,15,2,20000,Oitem_status,Oitem_error);
dbms_output.put_line(Oitem_status||' '||Oitem_error);
end;
/
select*from Order_items;
select*from Products;
desc Order_items;
--delete
declare
Oitem_id Order_items.order_id%type:=&enter_id;
Oitem_status varchar2(50);
Oitem_error varchar2(100);
begin
sales_package.delOrderitems(Oitem_id,Oitem_status,Oitem_error);
dbms_output.put_line(Oitem_status||' '||Oitem_error);

end delOrderitems;
/
select*from product_categories;
--product category
--insert
declare
p_status varchar2(50);
p_error varchar2(100);

begin

sales_package.addCategories('Electronics',p_status,p_error);
dbms_output.put_line(p_status||' '||p_error);
end;
/
--delete
declare
cat_id product_categories.category_id%type:=&enter_id;
p_status varchar2(50);
p_error varchar2(100);
begin
sales_package.delCategories(cat_id,p_status,p_error);
dbms_output.put_line(p_status||' '||p_error);

end delCategories;
/
select*from product_categories;
