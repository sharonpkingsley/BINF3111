#search and combined all evidence in a single result 
#######################
#######################
call searchSelectedEvidence('ANWABDrug');
#search with selected multiple evidences with one drug name as parameters
drop procedure if exists searchSelectedEvidence;
DELIMITER $$
create procedure searchSelectedEvidence(IN drugName VARCHAR(255))
begin
    DECLARE done int default false;
    DECLARE table_name CHAR(255);
    DECLARE cur1 cursor for SELECT t.TABLE_NAME FROM information_schema.tables t
        WHERE t.table_schema='drugdb' and not t.TABLE_NAME = 'final_result';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET @tempTable = 'final_result';
    SET @droptable = CONCAT ('DROP TABLE IF EXISTS  ', @tempTable);
    PREPARE deletetb FROM @droptable;
    EXECUTE deletetb ;
    DEALLOCATE PREPARE deletetb ;

    SET @createtable = CONCAT('CREATE TABLE ', @tempTable, ' (all_drug_name varchar(255) default NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8');
    PREPARE createtb FROM @createtable ; 
    EXECUTE createtb;
    DEALLOCATE PREPARE createtb ;
    insert into `final_result` select `Unnamed: 0` from evidence1;
    open cur1;
    myloop: loop
        fetch cur1 into table_name;
        if done then
            leave myloop;
        end if;
   
    set @tempTableName = table_name;
    set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
    PREPARE result FROM @tt;
    EXECUTE result;
    DEALLOCATE PREPARE result;

    #update final_result f inner join evidence1 e on f.all_drug_name = e.`Unnamed: 0` set f.evidence1 =  e.ANWABDrug;
    set @updateTable = concat('update ', @tempTable, ' f inner join ', @tempTableName, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
#    SET @insertTable = concat('insert into final_result(', @tempTableName, ') select ', @tempTableName.drugName, ' from ', @tempTableName);
    PREPARE re FROM @updateTable;
    EXECUTE re;
    DEALLOCATE PREPARE re;
 
    end loop;
    close cur1;    
end$$ 
DELIMITER ;
call searchSelectedEvidence('ANWABDrug');

##########################
###########################

CONCAT(

select 
evidence1.`Unnamed: 0`, 
evidence1.drugName as evidence1, 
table_name.drugName as table_name 
from 
(evidence1 


)
    inner join A on evidence1.`Unnamed: 0` = A.`Unnamed: 0`
    inner join A on evidence1.`Unnamed: 0` = A.`Unnamed: 0`
    inner join A on evidence1.`Unnamed: 0` = A.`Unnamed: 0`
    inner join A on evidence1.`Unnamed: 0` = A.`Unnamed: 0`)


GROUP_CONCAT(table_name SEPARATOR ' on ')
GROUP_CONCAT(concat('evidence1.`Unnamed: 0` = ', table_name) SEPARATOR '.`Unnamed: 0`')









select 
        GROUP_CONCAT(
            CONCAT(
                'select''', r.table_name, ''' as table_name from ', r.table_name,' ' 
            )
            SEPARATOR ' union '
        )as Qry
    from 
        information_schema.`tables` r
    where 
        r.table_schema = @database

    into @all;

    PREPARE stmt FROM @all;

    EXECUTE stmt;

('SELECT
                evidence1.`Unnamed: 0`, ', r.TABLE_NAME, '.', drugName,  ' as ', r.TABLE_NAME , ' FROM (evidence1 INNER JOIN ', @all_tables,
                ' ON evidence1.`Unnamed: 0` = ', @all_tables, '.`Unnamed: 0` )'
        )
SET @t1 = NULL;
    SELECT
        GROUP_CONCAT(
            CONCAT('SELECT ', r.TABLE_NAME,'.`Unnamed: 0`, ', drugName, ' AS ', r.TABLE_NAME ,' FROM ',r.TABLE_NAME)
            SEPARATOR ' union all '
        )
    INTO
        @t1
    FROM information_schema.tables r
    WHERE r.table_schema='drugdb';

    #SET @t2 = CONCAT('select * from (', @t1, ')');
    #select @t1;
    PREPARE result FROM @t1;
    EXECUTE result;
    DEALLOCATE PREPARE result;

drop procedure if exists searchAllEvidence;
DELIMITER $$
create procedure searchAllEvidence(IN drugName VARCHAR(255))
begin
    DECLARE done int default false;
    DECLARE table_name CHAR(255);

    DECLARE cur1 cursor for SELECT t.TABLE_NAME FROM information_schema.tables t
        WHERE t.table_schema='drugdb';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    open cur1;
    myloop: loop
        fetch cur1 into table_name;
        if done then
            leave myloop;
        end if;
        SET @t1 =CONCAT('SELECT `Unnamed: 0`, ',drugName ,' FROM ',TABLE_NAME);
        PREPARE result FROM @t1;
        EXECUTE result;
        DEALLOCATE PREPARE result;
    end loop;
    close cur1;
end$$ 
DELIMITER ;