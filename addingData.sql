#search on max three evidence and combined the result with average score at the end


#search with selected multiple evidences with one drug name as parameters
drop procedure if exists addNewDrug;
DELIMITER $$
create procedure addNewDrug(IN drugID VARCHAR(255), IN drugName VARCHAR(255), IN evi1 VARCHAR(255))
begin
    DECLARE done int default false;
    DECLARE table_name CHAR(255);
    DECLARE table_name1 CHAR(255);
    DECLARE table_name2 CHAR(255);
    DECLARE cur1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%';
    
    DECLARE cur2 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'struct%';
    
    DECLARE cur3 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chem%';
    
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    ####update the last row of the info dataset####
    #######  evia<---->info
    set @row = concat('insert into info (ID, `GENERIC NAME`) values ( \'', drugID,  '\', \'', drugName,'\')');
    select @row;
    PREPARE r FROM @row;
    EXECUTE r;
    DEALLOCATE PREPARE r;
    #########


    #new drug input --> drugID as the table name
    if evi1 = 'Target' then 
        open cur1;
        myloop: loop
            fetch cur1 into table_name; #target0, target1....
            if done then
                leave myloop;
            end if;
        end loop;
        #add to the end of the last file of the evidence file
        SET @tempTable = table_name;
        select @tempTable;
        #add the new null column for the new drug with its ID as the column name
        set @tempTableID = drugID; #new uplaod file for the new drug
        select @tempTableID;

        set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableID,' VARCHAR(255)');
        PREPARE res FROM @tt;
        EXECUTE res;
        DEALLOCATE PREPARE res;

        set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, ', drugID ,' from ', @tempTableID, ' )a on f.DRUGBANK_ID = a.DRUGBANK_ID set f.',@tempTableID,'= a.', drugID);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;

        set @updateTableNULL = concat('update ', @tempTable, ' set ', drugID, '= 0 where ', drugID, ' is null');
        PREPARE re1 FROM @updateTableNULL;
        EXECUTE re1;
        DEALLOCATE PREPARE re1;
        close cur1; 
    end if;


    if evi1 = 'Struct' then 
        open cur2;
        myloop: loop
            fetch cur2 into table_name1; 
            if done then
                leave myloop;
            end if;
        end loop;
        #add to the end of the last file of the evidence file
        SET @tempTable = table_name1;
        select @tempTable;
        #add the new null column for the new drug with its ID as the column name
        set @tempTableID = drugID; #new uplaod file for the new drug
        select @tempTableID;
        
        set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableID,' VARCHAR(255)');
        PREPARE res FROM @tt;
        EXECUTE res;
        DEALLOCATE PREPARE res;

        set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, ', drugID ,' from ', @tempTableID, ' )a on f.DRUGBANK_ID = a.DRUGBANK_ID set f.',@tempTableID,'= a.', drugID);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;

        set @updateTableNULL = concat('update ', @tempTable, ' set ', drugID, '= 0 where ', drugID, ' is null');
        PREPARE re1 FROM @updateTableNULL;
        EXECUTE re1;
        DEALLOCATE PREPARE re1;
        close cur2; 
    end if;

    if evi1 = 'Chem' then 
        open cur3;
        myloop: loop
            fetch cur3 into table_name2; 
            if done then
                leave myloop;
            end if;
        end loop;
        #add to the end of the last file of the evidence file
        SET @tempTable = table_name2;
        select @tempTable;
        #add the new null column for the new drug with its ID as the column name
        set @tempTableID = drugID; #new uplaod file for the new drug
        select @tempTableID;
        
        set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableID,' VARCHAR(255)');
        PREPARE res FROM @tt;
        EXECUTE res;
        DEALLOCATE PREPARE res;

        set @updateTable = concat('update ', @tempTable, ' f inner join ( select DRUGBANK_ID, ', drugID ,' from ', @tempTableID, ' )a on f.DRUGBANK_ID = a.DRUGBANK_ID set f.',@tempTableID,'= a.', drugID);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;

        set @updateTableNULL = concat('update ', @tempTable, ' set ', drugID, '= 0 where ', drugID, ' is null');
        PREPARE re1 FROM @updateTableNULL;
        EXECUTE re1;
        DEALLOCATE PREPARE re1;
        close cur3; 
    end if;

end$$ 
DELIMITER ;
call addNewDrug('DB20000','ABCCCC','Target');


