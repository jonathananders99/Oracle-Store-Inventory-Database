SET SERVEROUTPUT ON;

-- TABLE CREATION
Create table DEPARTMENT (
    DepartmentID CHAR(3) Primary Key,
    DepartmentName VARCHAR(30) NOT NULL,
    DepartmentShelfLimit NUMBER(10) NOT NULL
);

Create table SHIPPING (
    ShippingID CHAR(20) Primary Key,
    ShippingDate DATE NOT NULL,
    DateDelivered DATE
);

Create table SHELF_TYPE (
    ShelfTypeID CHAR(10) Primary Key,
    ShelfName VARCHAR(50) NOT NULL,
    ShelfParts VARCHAR(500) NOT NULL,
    ShelfCapacity NUMBER(10) NOT NULL
);

Create table SHELF (
    ShelfID CHAR(20) Primary Key,
    ShelfLocation VARCHAR(10) NOT NULL,
    ShelfTypeID CHAR(10) NOT NULL,
    Constraint Shelf_Type_ID FOREIGN KEY (ShelfTypeID) REFERENCES SHELF_TYPE(ShelfTypeID)
);

Create table BRAND (
    BrandID CHAR(10) Primary Key,
    BrandName VARCHAR(50) NOT NULL,
    BrandLoc VARCHAR(200) NOT NULL
);

Create table SUPPLIES_TYPE (
    SuppliesTypeID CHAR(20) Primary Key,
    SuppliesTypeName VARCHAR(50) NOT NULL,
    DepartmentID CHAR(3) NOT NULL,
    Constraint ST_Department_ID FOREIGN KEY (DepartmentID) REFERENCES DEPARTMENT(DepartmentID)
);

Create table SUPPLIES (
    SuppliesID CHAR(20) Primary Key,
    SuppliesName VARCHAR(50) NOT NULL,
    SuppliesTypeID CHAR(20) NOT NULL,
    Constraint Supplies_Type_ID FOREIGN KEY (SuppliesTypeID) REFERENCES SUPPLIES_TYPE(SuppliesTypeID)
);

Create table INDIVIDUAL_SUPPLIES (
    IndSuppliesID CHAR(20) Primary Key,
    Location VARCHAR(50) NOT NULL,
    SuppliesID CHAR(20) NOT NULL,
    Constraint Supplies_ID FOREIGN KEY (SuppliesID) REFERENCES SUPPLIES(SuppliesID)
);

Create table ITEM_TYPE (
    ItemTypeID CHAR(20) Primary Key,
    TypeName VARCHAR(100) NOT NULL,
    DepartmentID CHAR(3) NOT NULL,
    Constraint IT_Department_ID FOREIGN KEY (DepartmentID) REFERENCES DEPARTMENT(DepartmentID)
);

Create table ITEM (
    ItemID CHAR(20) Primary Key,
    ItemName VARCHAR(100) NOT NULL,
    BrandID CHAR(10) NOT NULL,
    ItemSize VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    ItemTypeID CHAR(20) NOT NULL,
    SaleType VARCHAR(20) NOT NULL,
    ShelfTypeID CHAR(10) NOT NULL,
    Constraint Brand_ID FOREIGN KEY (BrandID) REFERENCES BRAND(BrandID),
    Constraint Item_Type_ID FOREIGN KEY (ItemTypeID) REFERENCES ITEM_TYPE(ItemTypeID),
    Constraint IT_Shelf_Type_ID FOREIGN KEY (ShelfTypeID) REFERENCES SHELF_TYPE(ShelfTypeID)
);

Create table INDIVIDUAL_ITEM (
    IndItemID CHAR(20) Primary Key,
    ItemLocation VARCHAR(10) NOT NULL,
    ItemID CHAR(20) NOT NULL,
    ShippingID CHAR(20) NOT NULL,
    Constraint IT_Item_ID FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID),
    Constraint Shipping_ID FOREIGN KEY (ShippingID) REFERENCES SHIPPING(ShippingID)
);

create table expiredItems (
    DateDelivered date,
    ItemName VARCHAR(100) NOT NULL,
    IndItemID CHAR(20) Primary Key,
    ItemID CHAR(20) NOT NULL,
    Constraint EIT_Item_ID FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID)
);

create table almostExpiredItems (
    DateDelivered date,
    ItemName VARCHAR(100) NOT NULL,
    IndItemID CHAR(20) Primary Key,
    ItemID CHAR(20) NOT NULL,
    Constraint AEIT_Item_ID FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID)
);


create table itemRemovalLog (
    DateRemoved date primary key,
    RemovalUser VARCHAR(100) NOT NULL,
    NumOfItems int
);

create table itemsAddedLog (
    DateAdded date primary key,
    AddingUser VARCHAR(100) NOT NULL,
    NumOfItems int,
    ShippingID CHAR(20) NOT NULL,
    Constraint IAL_Shipping_ID FOREIGN KEY (ShippingID) REFERENCES SHIPPING(ShippingID)
);







--DATA INSERTION


--DEPARTMENT
insert into DEPARTMENT
values ('1', 'Mens', 50);

insert into DEPARTMENT
values ('2', 'Womans', 80);

insert into DEPARTMENT
values ('3', 'Kids', 25);

insert into DEPARTMENT
values ('4', 'Misc', 15);

insert into DEPARTMENT
values ('5', 'Shoes', 40);


--SHIPPING
insert into SHIPPING
values ('1', TO_DATE('11-NOV-2015','DD-MON-YYYY'),TO_DATE('12-NOV-2015','DD-MON-YYYY'));

insert into SHIPPING
values ('2', TO_DATE('14-NOV-2010','DD-MON-YYYY'),TO_DATE('15-NOV-2010','DD-MON-YYYY'));

insert into SHIPPING
values ('3', TO_DATE('18-NOV-2021','DD-MON-YYYY'),TO_DATE('21-NOV-2021','DD-MON-YYYY'));


--SHELF_TYPE
insert into SHELF_TYPE
values ('1', 'Double Shelf', 'N/A', 50);

insert into SHELF_TYPE
values ('2', 'Quad Spiral', '4 arms, 8 screws', 100);

insert into SHELF_TYPE
values ('3', 'See-through drawer', '1 handle, 1 screws', 25);

insert into SHELF_TYPE
values ('4', 'Large shoe rack', 'N/A', 70);


--SHELF
insert into SHELF
values ('1', 'Back Stock', '1');

insert into SHELF
values ('2', 'Floor', '1');

insert into SHELF
values ('3', 'Floor', '4');

insert into SHELF
values ('4', 'Floor', '3');

insert into SHELF
values ('5', 'Back Stock', '4');


--BRAND
insert into BRAND
values ('1', 'Nike', '383 Fordham DriveChelmsford, MA 01824');

insert into BRAND
values ('2', 'Adidas', '405 Tailwater St.Falls Church, VA 22041');

insert into BRAND
values ('3', 'Tommy Bahama', '9821 West Forest Dr.Saint Albans, NY 11412');


--SUPPLIES_TYPE
insert into SUPPLIES_TYPE
values ('1', 'Tissues', '4');

insert into SUPPLIES_TYPE
values ('2', 'Toilet Paper', '4');

insert into SUPPLIES_TYPE
values ('3', 'Shoe Cart', '5');


--SUPPLIES
insert into SUPPLIES
values ('1', 'Lotion Tissues', '1');

insert into SUPPLIES
values ('2', 'Sandpaper Toilet Paper', '2');

insert into SUPPLIES
values ('3', 'Large Shoe Cart', '3');

insert into SUPPLIES
values ('4', 'Small Shoe Cart', '3');


--INDIVIDUAL_SUPPLIES
insert into INDIVIDUAL_SUPPLIES
values ('1', 'Employee Lounge', '1');

insert into INDIVIDUAL_SUPPLIES
values ('2', 'Backstock Floor 1', '3');

insert into INDIVIDUAL_SUPPLIES
values ('3', 'Customer Restroom', '2');

insert into INDIVIDUAL_SUPPLIES
values ('4', 'Employee Restroom', '2');

insert into INDIVIDUAL_SUPPLIES
values ('5', 'Backstock Floor 1', '4');

insert into INDIVIDUAL_SUPPLIES
values ('6', 'Employee Lounge', '1');


--ITEM_TYPE
insert into ITEM_TYPE
values ('1', 'Mens Active Shoes', '5');

insert into ITEM_TYPE
values ('2', 'Womans Active Shoes', '5');

insert into ITEM_TYPE
values ('3', 'Crop Tops', '2');

insert into ITEM_TYPE
values ('4', 'Dresses', '2');

insert into ITEM_TYPE
values ('5', 'Hoodies', '1');

insert into ITEM_TYPE
values ('6', 'Hoodies', '2');

insert into ITEM_TYPE
values ('7', 'Shirts', '1');

insert into ITEM_TYPE
values ('8', 'Shirts', '2');


--ITEM
insert into ITEM
values ('1', 'Denim Hoodie', '2', 'XL', 19.99, '6', 'Normal', '1');

insert into ITEM
values ('2', 'Running Shoe Black', '1', '12M', 25.99, '1', 'Normal', '4');

insert into ITEM
values ('3', 'Running Shoe White', '1', '11.5M', 16.95, '1', 'Sale', '4');

insert into ITEM
values ('4', 'White Floral Dress With Belt', '3', 'M', 35.99, '4', 'Normal', '2');

insert into ITEM
values ('5', 'White Floral Dress', '3', 'XS', 22.95, '4', 'Sale', '2');

insert into ITEM
values ('6', 'Navy Blue Floral Dress', '3', 'S', 22.95, '4', 'Sale', '2');

insert into ITEM
values ('7', 'Blue Collared Shirt', '2', 'XXL', 29.99, '7', 'Normal', '2');

insert into ITEM
values ('8', 'Denim Shirt', '3', 'L', 14.95, '8', 'Sale', '2');


--INDIVIDUAL_ITEM
insert into INDIVIDUAL_ITEM
values ('1', 'Floor', '1', '1');

insert into INDIVIDUAL_ITEM
values ('2', 'Back Stock', '1', '1');

insert into INDIVIDUAL_ITEM
values ('3', 'Back Stock', '2', '1');

insert into INDIVIDUAL_ITEM
values ('4', 'Floor', '3', '1');

insert into INDIVIDUAL_ITEM
values ('5', 'Back Stock', '3', '1');

insert into INDIVIDUAL_ITEM
values ('6', 'Floor', '3', '2');

insert into INDIVIDUAL_ITEM
values ('7', 'Back Stock', '4', '2');

insert into INDIVIDUAL_ITEM
values ('8', 'Floor', '4', '2');

insert into INDIVIDUAL_ITEM
values ('9', 'Back Stock', '4', '2');

insert into INDIVIDUAL_ITEM
values ('10', 'Floor', '4', '2');

insert into INDIVIDUAL_ITEM
values ('11', 'Back Stock', '5', '2');

insert into INDIVIDUAL_ITEM
values ('12', 'Floor', '6', '2');

insert into INDIVIDUAL_ITEM
values ('13', 'Back Stock', '6', '3');

insert into INDIVIDUAL_ITEM
values ('14', 'Floor', '7', '3');

insert into INDIVIDUAL_ITEM
values ('15', 'Back Stock', '7', '3');

insert into INDIVIDUAL_ITEM
values ('16', 'Floor', '7', '3');

insert into INDIVIDUAL_ITEM
values ('17', 'Back Stock', '6', '3');

insert into INDIVIDUAL_ITEM
values ('18', 'Floor', '7', '3');

insert into INDIVIDUAL_ITEM
values ('19', 'Back Stock', '6', '3');


--add rows to both remove and add log tables with different users and dates for testing later on
insert into itemsAddedLog
values (TO_DATE('11-APR-2022','DD-MON-YYYY'), 'Anders9', 18, '2');

insert into itemsAddedLog
values (TO_DATE('18-MARCH-2022','DD-MON-YYYY'), 'SteveO', 6, '2');

insert into itemsAddedLog
values (TO_DATE('27-FEB-2022','DD-MON-YYYY'), 'Dumbledore', 13, '1');

insert into itemRemovalLog
values (TO_DATE('27-FEB-2022','DD-MON-YYYY'), 'Anders9', 11);

insert into itemRemovalLog
values (TO_DATE('13-MAR-2022','DD-MON-YYYY'), 'Anders9', 1);

insert into itemRemovalLog
values (TO_DATE('20-APR-2022','DD-MON-YYYY'), 'Anders9', 4);





--VIEWS

--ITEMS_ON_SALE
create or replace view ITEMS_ON_SALE as
select ITEMNAME, PRICE
from ITEM
where SALETYPE = 'Sale'
order by ITEMNAME;

--ITEMS_NOT_ON_SALE
create or replace view ITEMS_NOT_ON_SALE as
select ITEMNAME, PRICE
from ITEM
where SALETYPE = 'Normal'
order by ITEMNAME;

--ITEMS_ON_FLOOR
create or replace view ITEMS_ON_FLOOR as
select ITEMNAME, COUNT(*) as "NUMBER"
from ITEM inner join INDIVIDUAL_ITEM
on ITEM.ITEMID = INDIVIDUAL_ITEM.ITEMID
    and ITEMLOCATION = 'Floor'
group by ITEMNAME
order by ITEMNAME;

--ITEMS_IN_BACK_STOCK
create or replace view ITEMS_IN_BACK_STOCK as
select ITEMNAME, COUNT(*) as "NUMBER"
from ITEM, INDIVIDUAL_ITEM
where ITEMLOCATION = 'Back Stock'
    and INDIVIDUAL_ITEM.ITEMID = ITEM.ITEMID
group by ITEMNAME
order by ITEMNAME;

--LOW_SUPPLIES
create or replace view LOW_SUPPLIES as
select SUPPLIESNAME, COUNT(*) as "NUMBER"
from SUPPLIES, SUPPLIES_TYPE
where SUPPLIES_TYPE.SUPPLIESTYPEID = SUPPLIES.SUPPLIESTYPEID
group by SUPPLIESNAME
having COUNT(*) < 2
order by SUPPLIESNAME;

--SHIPPING_LAST_30_DAYS
create or replace view SHIPPING_LAST_30_DAYS as
select *
from SHIPPING
where round(sysdate - DATEDELIVERED) <= 30
order by DATEDELIVERED;

--SHIPPING_LAST_12_MONTHS
create or replace view SHIPPING_LAST_12_MONTHS as
select SHIPPINGID, SHIPPINGDATE, TO_CHAR(DATEDELIVERED, 'MM-DD-YYYY') as DATEDELIVERED, round(MONTHS_BETWEEN(sysdate,DATEDELIVERED)) as "Number Of Months Ago"
from SHIPPING
where MONTHS_BETWEEN(sysdate,DATEDELIVERED) <= 12
order by DATEDELIVERED;

--ITEMS_PER_DEPARTMENT
create or replace view ITEMS_PER_DEPARTMENT as
select DEPARTMENTNAME, COUNT(*) as "NUMBER"
from ITEM, DEPARTMENT, INDIVIDUAL_ITEM, ITEM_TYPE
where DEPARTMENT.DEPARTMENTID = ITEM_TYPE.DEPARTMENTID
    and INDIVIDUAL_ITEM.ITEMID = ITEM.ITEMID
    and ITEM.ITEMTYPEID = ITEM_TYPE.ITEMTYPEID
group by DEPARTMENTNAME
order by DEPARTMENTNAME;

--create table from another table
create table SALE_ITEMS (
    ItemID CHAR(20) Primary Key,
    ItemName VARCHAR(100) NOT NULL,
    BrandID CHAR(10) NOT NULL,
    ItemSize VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    ItemTypeID CHAR(20) NOT NULL,
    SaleType VARCHAR(20) NOT NULL,
    ShelfTypeID CHAR(10) NOT NULL,
    Constraint ST_Brand_ID FOREIGN KEY (BrandID) REFERENCES BRAND(BrandID),
    Constraint ST_Item_Type_ID FOREIGN KEY (ItemTypeID) REFERENCES ITEM_TYPE(ItemTypeID),
    Constraint ST_Shelf_Type_ID FOREIGN KEY (ShelfTypeID) REFERENCES SHELF_TYPE(ShelfTypeID)
);
insert into SALE_ITEMS select * from ITEM;