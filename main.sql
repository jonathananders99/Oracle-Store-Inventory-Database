--procedure to update both expired item tables
--if an item came into the store more than 10 years ago it gets put into a table
--that shows all items that need to be disposed of/ sent back to warehouses that deal with getting rid of items
--if an item came into the store 5-10 years ago it gets added to a different table
--that serves as a warning table/a try to get this item sold table
--exception handling is NO_DATA_FOUND defined by oracle and serves to give a warning when
--there is no data found in the particular rows its searching through.
create or replace procedure expiredUpdate
is
    cursor ind_item_cursor is select * from INDIVIDUAL_ITEM;
    cursor item_cursor is select * from ITEM;
    cursor ship_cursor is select * from SHIPPING;
    prevEntry int;
begin
    for ind_item_val in ind_item_cursor loop
        for item_val in item_cursor loop
            for ship_val in ship_cursor loop
                if ship_val.ShippingID = ind_item_val.ShippingID and ind_item_val.ItemID = item_val.ItemId then
                    --delivery date is more than 10 years from now
                    if  months_between(sysdate, ship_val.DateDelivered) > 120 then
                        select count(*) into prevEntry from expiredItems;
                        if prevEntry = 0 then
                            insert into expiredItems values(
                                ship_val.DateDelivered, item_val.ItemName, 
                                ind_item_val.IndItemID, item_val.ItemID
                            );
                        end if;
                    --delivery date is more than 5 and equal to 10 or less years from now
                    elsif months_between(sysdate, ship_val.DateDelivered) <= 120 and months_between(sysdate, ship_val.DateDelivered) > 60 then
                        select count(*) into prevEntry from almostExpiredItems;
                        if prevEntry = 0 then
                            insert into almostExpiredItems values(
                                ship_val.DateDelivered, item_val.ItemName, 
                                ind_item_val.IndItemID, item_val.ItemID
                            );
                        end if;
                    end if;
                end if;
            end loop;
        end loop;
    end loop;
exception when no_data_found then dbms_output.put_line('No data found');
end;
/

--testing procedure
execute expiredUpdate;


--trigger is for any insertions into INDIVIDUAL_ITEM. This is to simulate shipments coming in.
--this trigger has exception handling to handle when there is no delivered date but there are
--items trying to be added from that shipment
create or replace trigger ind_item_additions
before insert on INDIVIDUAL_ITEM
for each row
declare
    prevEntry int;
    curUser varchar(100);
    deliveredDate date;
    noDeliveredDate exception;
    pragma exception_init(noDeliveredDate, -20001);
begin
    prevEntry := null;
    curUser := sys_context('userenv', 'session_user');
    select dateDelivered into deliveredDate from shipping where :new.shippingId = shipping.shippingId;
    if deliveredDate is null then raise noDeliveredDate;
    else
        for oneRow in (select * from itemsAddedLog) loop
            if to_char(oneRow.DateAdded, 'DD-MON-YY') = to_char(sysdate, 'DD-MON-YY') and curUser = oneRow.AddingUser then
                prevEntry := oneRow.NumOfItems;
            end if;
        end loop;
        case
        --there is not a previous entry
        when prevEntry is null then
            insert into itemsAddedLog values(sysdate, curUser, 1, :new.shippingId);
        --there is a previous entry
        when prevEntry >= 1 then
            update itemsAddedLog
            set NumOfItems = NumOfItems+1
            where to_char(DateAdded, 'DD-MON-YY') = to_char(sysdate, 'DD-MON-YY');
        end case;
    end if;
exception
    when noDeliveredDate then
        dbms_output.put_line('Failed addition to individual item table due to shipping entry not having a delivered date.Individual Item Id: ' || :new.IndItemID);
        raise_application_error(-20001, 'Row not inserted');
end;
/

--inserts data into shipping
insert into SHIPPING
values ('4', TO_DATE('30-NOV-2021','DD-MON-YYYY'), NULL);--added with no delivery date to cause exception later on

--inserts data into shipping
insert into INDIVIDUAL_ITEM
values ('20', 'Back Stock', '5', '3');
insert into INDIVIDUAL_ITEM
values ('21', 'Back Stock', '3', '3');
insert into INDIVIDUAL_ITEM
values ('22', 'Floor', '6', '4');--triggers error because shipping row 4 doesnt have a delivery date


-- This trigger is for deletions. This one is to simulate purchases from the store.
create or replace trigger ind_item_removals
after delete on INDIVIDUAL_ITEM
for each row
declare
    prevEntry int;
    curUser varchar(100);
begin
    prevEntry := null;
    curUser := sys_context('userenv', 'session_user');
    for oneRow in (select * from itemRemovalLog) loop
        if to_char(oneRow.DateRemoved, 'DD-MON-YY') = to_char(sysdate, 'DD-MON-YY') and curUser = oneRow.RemovalUser then
            prevEntry := oneRow.NumOfItems;
        end if;
    end loop;
    case
        --there is not a previous entry
        when prevEntry is null then
            insert into itemRemovalLog values(sysdate, curUser, 1);
        --there is a previous entry
        when prevEntry >= 1 then
            update itemRemovalLog
            set NumOfItems = NumOfItems+1
            where to_char(DateRemoved, 'DD-MON-YY') = to_char(sysdate, 'DD-MON-YY');
    end case;
end;
/

-- test trigger
delete from individual_item where IndItemID = 21;
delete from individual_item where IndItemID = 20 or IndItemID = 19;


--given two dates it gets the amount of deletions in that given date range
--uses exception that makes sure dates are legal inputs
create or replace function getNumOfAdditions(date1 in date, date2 in date) 
return int
is
    curNum int;
    startDate date;
    endDate date;
    illegalInput exception;
    pragma exception_init(illegalInput, -20002);
begin
    curNum := 0;
    --if the 1st date is bigger than the 2nd
    if date1 > date2 then
        startDate := date2;
        endDate := date1;
    --if the 1st date  is less than the 2nd date
    elsif date1 < date2 then
        startDate := date1;
        endDate := date2;
    --illegal input/incorrect dates (like putting the same date twice)
    else
        raise illegalInput;
    end if;
    for oneRow in (select * from itemsAddedLog) loop
        if to_char(oneRow.DateAdded, 'DD-MON-YY') >= startDate and to_char(oneRow.DateAdded, 'DD-MON-YY') <= endDate then
            curNum := curNum + oneRow.NumOfItems;
        end if;
    end loop;
    return curNum;
exception
    when illegalInput then
        dbms_output.put_line('Date 1: ' || date1 || ' ~ Date 2: ' || date2);
        raise_application_error(-20002, 'Illegal date input');
end;
/

--test above function by trying different dates
select getNumOfAdditions(to_date('26-APR-2022', 'DD-MON-YY'), to_date('11-APR-2022', 'DD-MON-YY')) as curerent_number from dual;
select getNumOfAdditions(to_date('11-APR-2022', 'DD-MON-YY'), to_date('25-APR-2022', 'DD-MON-YY')) as curerent_number from dual;

--testing exception
select getNumOfAdditions(to_date('11-APR-2022', 'DD-MON-YY'), to_date('11-APR-2022', 'DD-MON-YY')) as curerent_number from dual;


--package yearly ind item report for percent of total deletions and inserts by month
--in function take month and use the given month and year to see how many items were
--removed or added during the time phrame
--in stored procedure do the last 3 months in previous function
--in this procedure it uses divide by zero exeption
create or replace package quarterly_ind_item_report_by_month
as
    function itemsAdded(ogMonth in int, ogYear in int) return int;
    function itemsRemoved(ogMonth in int, ogYear in int) return int;
    procedure monthReport;
end quarterly_ind_item_report_by_month;
/
create or replace package body quarterly_ind_item_report_by_month
as
function itemsAdded(ogMonth in int, ogYear in int)
return int
is
    numOfAdd int;
    curMonth int;
    curYear int;
begin
    numOfAdd := 0;
    --counts number of adds per each row if it falls into the given month and year
    for oneRow in (select * from itemsAddedLog) loop
        curMonth := to_number(extract(month from oneRow.DateAdded));
        curYear := to_number(extract(year from oneRow.DateAdded));
        if curMonth = ogMonth and curYear = ogYear then
            numOfAdd := numOfAdd + oneRow.NumOfItems;
        end if;
    end loop;
    return numOfAdd;
end itemsAdded;
function itemsRemoved(ogMonth in int, ogYear in int)
return int
is
    numOfRemove int;
    curMonth int;
    curYear int;
begin
    numOfRemove := 0;
    --counts number of removals per each row if it falls into the given month and year
    for oneRow in (select * from itemRemovalLog) loop
        curMonth := to_number(extract(month from oneRow.DateRemoved));
        curYear := to_number(extract(year from oneRow.DateRemoved));
        if curMonth = ogMonth and curYear = ogYear then
            numOfRemove := numOfRemove + oneRow.NumOfItems;
        end if;
    end loop;
    return numOfRemove;
end itemsRemoved;
procedure monthReport
as
    curMonth int;
    curYear int;
    totAdds int;
    totRemoves int;
    reportDetails varchar(1000);
begin
    totAdds := 0;
    totRemoves := 0;
    --gets total number to do calcs later on
    --could've done it in one loop but that would've required a lot more variables
    --so for the interest of keeping the code cleaner i did it this way
    for i in 0 ..2 loop
        curMonth := to_number(extract(month from sysdate)-i);
        curYear := to_number(extract(year from sysdate));
        totAdds := totAdds + itemsAdded(curMonth, curYear);
        totRemoves := totRemoves + itemsRemoved(curMonth, curYear);
    end loop;
    --calculations for percentage of total per month per add and remove
    for i in 0 ..2 loop
        curMonth := to_number(extract(month from sysdate)-i);
        curYear := to_number(extract(year from sysdate));
        dbms_output.put_line('~ Month: ' || to_char(to_date(curMonth, 'MM'), 'MONTH'));
        --adds first
        begin
            dbms_output.put_line('Percentage of additions: ' || to_char(round((itemsAdded(curMonth, curYear) / totAdds) * 100, 2)) || '%');
            exception
                when ZERO_DIVIDE then
                    dbms_output.put_line('Percentage of additions: 0%');
        end;
        --removals next
        begin
            dbms_output.put_line('Percentage of removals: ' || to_char(round((itemsRemoved(curMonth, curYear) / 
            totRemoves) * 100, 2)) || '%');
            exception
                when ZERO_DIVIDE then
                    dbms_output.put_line('Percentage of removals: 0%');
        end;
    end loop;
end monthReport;
end quarterly_ind_item_report_by_month;
/

--test package
execute quarterly_ind_item_report_by_month.monthReport;

--remove row to test exception
delete from itemRemovalLog;
execute quarterly_ind_item_report_by_month.monthReport;


--an object for deleting from ind item table to mimick a transaction
create or replace type itemTransaction as object
(indItemId CHAR(20), member procedure deleteRow (id in char));
/
create or replace type body itemTransaction as
member procedure deleteRow (id in char) is
    begin
    --deletes specified row from table
        delete from individual_item where indItemId = id;
    end;
end;
/
--use object
declare
    obj itemTransaction;
begin
    for i in 1 ..5 loop
        obj := itemTransaction(to_char(i));
        obj.deleteRow(obj.indItemId);
    end loop;
end;
/
