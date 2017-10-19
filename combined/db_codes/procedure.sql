DROP PROCEDURE IF EXISTS searchOneEvidence;
DELIMITER $$
CREATE PROCEDURE searchOneEvidence(IN drugName VARCHAR(255),IN evidenceName VARCHAR(255))
BEGIN
  SET @t1 =CONCAT('SELECT `Unnamed: 0`, ',drugName ,' FROM ',evidenceName, ' WHERE `Unnamed: 0` != "',drugName, '"');
  PREPARE result FROM @t1;
  EXECUTE result;
  DEALLOCATE PREPARE result;
END$$
DELIMITER ;

call searchOneEvidence('ANWABDrug','qq')//
call searchAllEvidence('ANWABDrug')//

#search all evidence with one drugName as a parameter
#database name = 'mydrugfinaldatabase'
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
        SET @t1 =CONCAT('SELECT `Unnamed: 0`, ',drugName ,' FROM ',TABLE_NAME, ' WHERE `Unnamed: 0` != "',drugName, '"');
		PREPARE result FROM @t1;
		EXECUTE result;
		DEALLOCATE PREPARE result;
    end loop;
    close cur1;
end $$
DELIMITER ;



select 
  evib.`Unnamed: 0`,
  evia.`ANWABDrug` as eviaa, 
  evib.`ANWABDrug` as evibb
from evia, evib
where evia.`Unnamed: 0` = evib.`Unnamed: 0`
union
select evib.`Unnamed: 0`, '0' as eviaa, evib.`ANWABDrug` as evibb 
from evib
where evib.`Unnamed: 0` NOT IN
    (select `Unnamed: 0` from evia)
union
select evia.`Unnamed: 0`, 'ANWABDrug' as eviaa, '0' as evibb 
from evia
where evia.`Unnamed: 0` NOT IN
    (select `Unnamed: 0` from evib)






#search on max three evidence and combined the result with average score at the end


#search with selected multiple evidences with one drug name as parameters
drop procedure if exists searchMaxThreeSelectedEvidence;
DELIMITER $$
create procedure searchMaxThreeSelectedEvidence(IN drugName VARCHAR(255), IN evi1 VARCHAR(255), IN evi2 VARCHAR(255), 
IN evi3 VARCHAR(255), IN threshold FLOAT)
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

    set @total_amount = 0;

    if evi1 <> '' then 
        set @total_amount = @total_amount +1;
        set @tempTableName = evi1;
        set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
        PREPARE result FROM @tt;
        EXECUTE result;
        DEALLOCATE PREPARE result;
        #update final_result f inner join (select `Unnamed: 0`, ANWABDrug from evidence4 where ANWABDrug >=1) a on f.all_drug_name = a.`Unnamed: 0` set f.evidence4 = a.ANWABDrug;
        #set @updateTable = concat('update ', @tempTable, ' f inner join ', @tempTableName, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
        set @updateTable = concat('update ', @tempTable, ' f inner join ( select `Unnamed: 0`, ', drugName, ' from ', @tempTableName, ' where ', drugName ,' >= ', threshold, ')a on f.all_drug_name = a.`Unnamed: 0` set f.', @tempTableName, '= a.', drugName);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;
        #update the null part into 0
        update final_result set evidence1 = 0 where evidence1 is null;

    end if;
    if evi2 <> '' then
        set @total_amount = @total_amount +1;  
        set @tempTableName = evi2;
        set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
        PREPARE result FROM @tt;
        EXECUTE result;
        DEALLOCATE PREPARE result;
        set @updateTable = concat('update ', @tempTable, ' f inner join ( select `Unnamed: 0`, ', drugName, ' from ', @tempTableName, ' where ', drugName ,' >= ', threshold, ')a on f.all_drug_name = a.`Unnamed: 0` set f.', @tempTableName, '= a.', drugName);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;
        #update the null part into 0
        update final_result set evidence2 = 0 where evidence2 is null;
    end if;#

    if evi3 <> '' then 
        set @total_amount = @total_amount +1;
        set @tempTableName = evi3;
        set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
        PREPARE result FROM @tt;
        EXECUTE result;
        DEALLOCATE PREPARE result;
        set @updateTable = concat('update ', @tempTable, ' f inner join ( select `Unnamed: 0`, ', drugName, ' from ', @tempTableName, ' where ', drugName ,' >= ', threshold, ')a on f.all_drug_name = a.`Unnamed: 0` set f.', @tempTableName, '= a.', drugName);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;
        update final_result set evidence3 = 0 where evidence3 is null;
    end if;


    #add the score column
    set @tempTableName = 'Score';
    set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
    PREPARE result FROM @tt;
    EXECUTE result;
    DEALLOCATE PREPARE result;
    
    #select * from final_result;
    if @total_amount = 1 then
        if evi1 <> '' then
            set @evidence_name = evi1;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi1 ,'))/1 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end if;#
        if evi2 <> '' then
            set @evidence_name = evi2;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi2 ,'))/1 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;#
        end if;#
        if evi3 <> '' then
            set @evidence_name = evi3;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi3 ,'))/1 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        
        end if;
    elseif @total_amount = 2 then
        if evi1 <> '' and evi2 <> '' then
            set @firt_column = 'all_drug_name';
            set @average = 'average';
            #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi1 ,')+sum(', evi2,'))/2 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end if;
        if evi1 <> '' and evi3 <> '' then
            set @firt_column = 'all_drug_name';
            set @average = 'average';
            #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi1 ,')+sum(', evi3,'))/2 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;#
        end if;
        if evi2 <> '' and evi3 <> '' then
            set @firt_column = 'all_drug_name';
            set @average = 'average';
            #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi2 ,')+sum(', evi3,'))/2 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;#
        end if;
    elseif @total_amount = 3 then
        set @firt_column = 'all_drug_name';
        set @average = 'average';
        #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
        set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi1 ,')+sum(', evi2,')+sum(',evi3,'))/3 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;
    end if;
    select * from final_result;


end$$ 
DELIMITER ;
call searchMaxThreeSelectedEvidence('ANWABDrug','evidence1','evidence2','evidence3',1);



#========================version 3===============with real data======

#search on max three evidence and combined the result with average score at the end


#search with selected multiple evidences with one drug name as parameters
drop procedure if exists searchMaxThreeSelectedEvidence;
DELIMITER $$
create procedure searchMaxThreeSelectedEvidence(IN drugName VARCHAR(255), IN evi1 VARCHAR(255), IN evi2 VARCHAR(255),IN evi3 VARCHAR(255),IN threshold float)
begin
    DECLARE done int default false;
    DECLARE table_name CHAR(255);
    DECLARE table_name1 CHAR(255);
    DECLARE table_name2 CHAR(255);
    DECLARE cur1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%' and t.column_name = drugName;
    
    DECLARE cur2 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'struct%' and t.column_name = drugName;
    
    DECLARE cur3 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chem%' and t.column_name = drugName;
    
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET @tempTable = 'final_result';
    SET @droptable = CONCAT ('DROP TABLE IF EXISTS  ', @tempTable);
    PREPARE deletetb FROM @droptable;
    EXECUTE deletetb ;
    DEALLOCATE PREPARE deletetb ;
    SET @createtable = CONCAT('CREATE TABLE ', @tempTable, ' (all_drug_ID VARCHAR(255) default NULL , all_drug_name varchar(255) default NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8');
    PREPARE createtb FROM @createtable ; 
    EXECUTE createtb;
    DEALLOCATE PREPARE createtb ;
    insert into `final_result` select ID, `GENERIC NAME` from info;

    set @total_amount = 0;

    if evi1 <> '' then 
        set @total_amount = @total_amount +1;
        if evi1 = 'Target' then
            set @tt = concat('alter table ', @tempTable, ' add column Target VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;

            open cur1;
            myloop: loop
                fetch cur1 into table_name; #target0, target1....
                if done then
                    leave myloop;
                end if;
                set @tempTableName = table_name;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ', drugName ,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Target= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur1; 
        end if;

        if evi1 = 'Struct' then 
            set @tt = concat('alter table ', @tempTable, ' add column Struct VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;

            open cur2;
            myloop: loop
                fetch cur2 into table_name1; #target0, target1....
                if done then
                    leave myloop;
                end if;
                set @tempTableName = table_name1;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ',drugName,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Struct= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur2; 
        end if;

        if evi1 = 'Chem' then 
            set @tt = concat('alter table ', @tempTable, ' add column Chem VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;

            open cur3;
            myloop: loop
                fetch cur3 into table_name2; #target0, target1....
                if done then
                    leave myloop;
                end if;
                set @tempTableName = table_name2;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ', drugName ,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Chem= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur3; 
        end if;

        #update the null part into 0
        set @updateTableNULL = concat('update ', @tempTable, ' set ', evi1, '= 0 where ', evi1, ' is null');
        PREPARE re1 FROM @updateTableNULL;
        EXECUTE re1;
        DEALLOCATE PREPARE re1;

    end if;

    if evi2 <> '' then 
        set @total_amount = @total_amount +1;
        if evi2 = 'Target' then 
            set @tt = concat('alter table ', @tempTable, ' add column Target VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;

            open cur1;
            myloop: loop
                fetch cur1 into table_name; #target0, target1....
                if done then
                    leave myloop;
                end if;
                set @tempTableName = table_name;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ', drugName ,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Target= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur1; 
        end if;

        if evi2 = 'Struct' then 
            set @tt = concat('alter table ', @tempTable, ' add column Struct VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;            
            open cur2;
            myloop: loop
                fetch cur2 into table_name1; #struct0, struct....
                if done then
                    leave myloop;
                end if;
                set @tempTableName = table_name1;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ', drugName ,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Struct= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur2; 
        
        end if;

        if evi2 = 'Chem' then 
            set @tt = concat('alter table ', @tempTable, ' add column Chem VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;

            open cur3;
            myloop: loop
                fetch cur3 into table_name2; #target0, target1....
                if done then
                    leave myloop;
                end if;
                set @tempTableName = table_name2;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ', drugName ,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Chem= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur3; 
        end if;
        set @updateTableNULL = concat('update ', @tempTable, ' set ', evi2, '= 0 where ', evi2, ' is null');
        PREPARE re1 FROM @updateTableNULL;
        EXECUTE re1;
        DEALLOCATE PREPARE re1;

    end if;

    if evi3 <> '' then 
        set @total_amount = @total_amount +1;
        if evi3 = 'Target' then 
            set @tt = concat('alter table ', @tempTable, ' add column Target VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;

            open cur1;
            myloop: loop
                fetch cur1 into table_name; #target0, target1....
                if done then
                    leave myloop;
                end if;
                set @tempTableName = table_name;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ', drugName ,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Target= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur1; 
        end if;

        if evi3 = 'Struct' then 
            set @tt = concat('alter table ', @tempTable, ' add column Struct VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;            
            open cur2;
            myloop: loop
                fetch cur2 into table_name1; #struct0, struct....
                if done then
                    leave myloop;
                end if;
            set @tempTableName = table_name1;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ', drugName ,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Struct= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur2; 
        
        end if;

        if evi3 = 'Chem' then 
            set @tt = concat('alter table ', @tempTable, ' add column Chem VARCHAR(255)');
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;

            open cur3;
            myloop: loop
                fetch cur3 into table_name2; #target0, target1....
                if done then
                    leave myloop;
                end if;
                set @tempTableName = table_name2;
            end loop;
            set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, round(', drugName, ',3)as ', drugName ,' from ', @tempTableName, ' )a on f.all_drug_ID = a.DRUGBANK_ID set f.Chem= a.', drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            close cur3; 
        end if;

        set @updateTableNULL = concat('update ', @tempTable, ' set ', evi3, '= 0 where ', evi3, ' is null');
        PREPARE re1 FROM @updateTableNULL;
        EXECUTE re1;
        DEALLOCATE PREPARE re1;
    end if;

    #add the score column
    set @tempTableName = 'Score';
    set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
    PREPARE result FROM @tt;
    EXECUTE result;
    DEALLOCATE PREPARE result;

    if @total_amount = 1 then
        set @firt_column = 'all_drug_name';
        set @average = 'average';
        #select @firt_column;
        if evi1 <> '' then
            set @evidence_name = evi1;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi1 ,'))/1  as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            #select * from final_result where Score > threshold and all_drug_ID <> drugName and evi1 <> 0;
        end if;
        if evi2 <> '' then
            set @evidence_name = evi2;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi2 ,'))/1  as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            #select * from final_result where Score > threshold and all_drug_ID <> drugName and evi2 <> 0;
        end if;
        if evi3 <> '' then
            set @evidence_name = evi3;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi3 ,'))/1 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            #select * from final_result where Score > threshold and all_drug_ID <> drugName and evi3 <> 0;
        end if;

    elseif @total_amount = 2 then
        if evi1 <> '' and evi2 <> '' then
            set @firt_column = 'all_drug_name';
            set @average = 'average';
            #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', round((sum(', evi1 ,')+sum(', evi2,'))/2,3)  as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            #select * from final_result where Score > threshold and all_drug_ID <> drugName and evi1 <> 0 and evi2 <> 0;
        end if;
        if evi1 <> '' and evi3 <> '' then
            set @firt_column = 'all_drug_name';
            set @average = 'average';
            #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', round((sum(', evi1 ,')+sum(', evi3,'))/2,3)  as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            #select * from final_result where Score > threshold and all_drug_ID <> drugName and evi1 <> 0 and evi3 <> 0;
        end if;
        if evi2 <> '' and evi3 <> '' then
            set @firt_column = 'all_drug_name';
            set @average = 'average';
            #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', round((sum(', evi2 ,')+sum(', evi3,'))/2,3)  as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            #select * from final_result where Score > threshold and all_drug_ID <> drugName and evi2 <> 0 and evi2 <> 0;
        end if;
    elseif @total_amount = 3 then
        set @firt_column = 'all_drug_name';
        set @average = 'average';
        #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
        set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', round((sum(', evi1 ,')+sum(', evi2,')+sum(',evi3,'))/3,3)  as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;
        #select * from final_result where Score > threshold and all_drug_ID <> drugName and evi1 <> 0 and evi2 <> 0 and evi3 <> 0;
    end if;

    select * from final_result where Score > threshold and all_drug_ID <> drugName and Score <> 0;
    drop table final_result;

end$$ 
DELIMITER ;
call searchMaxThreeSelectedEvidence('DB00014','','','Target',0.07);



select CONCAT("\tDrugBank: ", IFNULL(links.DrugBank, ''), "\n\tKEGG: ", IFNULL(links.KEGG, ''), "\n\tPubChem: ", IFNULL(links.PubChem, ''), "\n\tDrugs.com: ", IFNULL(links.`Drugs.com`,'')) as hyperlink from  links, info where links.`GENERIC NAME` = info.`GENERIC NAME` and ID="DB00123"



#=======network=========
DROP PROCEDURE IF EXISTS fullNetwork;
DELIMITER $$
CREATE PROCEDURE fullNetwork(IN drugName VARCHAR(255), IN evidenceName VARCHAR(255))
BEGIN
  SET @t1 =CONCAT('SELECT * FROM ',evidenceName);
  PREPARE result FROM @t1;
  EXECUTE result;
  DEALLOCATE PREPARE result;
END$$
DELIMITER ;
