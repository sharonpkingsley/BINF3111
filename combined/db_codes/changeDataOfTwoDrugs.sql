#search on max three evidence and combined the result with average score at the end


#search with selected multiple evidences with one drug name as parameters
drop procedure if exists changeDrugRecord;
DELIMITER $$
create procedure changeDrugRecord(IN drugID_A VARCHAR(255), IN drugID_B VARCHAR(255), IN evi1 VARCHAR(255), IN dataChange float)
begin

    DECLARE cur1_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%' and t.COLUMN_NAME = drugID_A;
    DECLARE cur1_2 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%' and t.COLUMN_NAME = drugID_B;
    
    DECLARE cur2_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chemical_structure%' and t.COLUMN_NAME = drugID_A;
    DECLARE cur2_2 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chemical_structure%' and t.COLUMN_NAME = drugID_B;
    
    DECLARE cur3_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'pathway%' and t.COLUMN_NAME = drugID_A;
    DECLARE cur3_2 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'pathway%' and t.COLUMN_NAME = drugID_B;
    

    #new drug input --> drugID as the table name
    if evi1 = 'target' then 
        #change for first drug column
        open cur1_1;
        begin
            DECLARE done int default false;
            DECLARE table_name1_A CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur1_1 into table_name1_A; #target0, target1....
                if done then
                    leave myloop;
                end if;
            end loop;
            #add to the end of the last file of the evidence file
            SET @tempTableA = table_name1_A; #target0,1....
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID_A = drugID_A; #column name
        end;
        close cur1_1; 
        select @tempTableA;
        select @tempTableID_A;
        set @updateTableA = concat('update ', @tempTableA, ' set ', @tempTableID_A , ' = ', dataChange, ' where DRUGBANK_ID = \'', drugID_B, '\'');
        PREPARE re FROM @updateTableA;
        EXECUTE re;
        DEALLOCATE PREPARE re;

        #change second drug column
        open cur1_2;
        begin
            DECLARE done int default false;
            DECLARE table_name1_B CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur1_2 into table_name1_B; #target0, target1....
                if done then
                    leave myloop;
                end if;
            end loop;
            #add to the end of the last file of the evidence file
            SET @tempTableB = table_name1_B;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID_B = drugID_B; 
        end;
        close cur1_2; 
        select @tempTableB;
        select @tempTableID_B;
        set @updateTableB = concat('update ', @tempTableB, ' set ', @tempTableID_B , ' = ', dataChange, ' where DRUGBANK_ID = \'', drugID_A,'\'');
        PREPARE re FROM @updateTableB;
        EXECUTE re;
        DEALLOCATE PREPARE re;
    end if;


    if evi1 = 'chemical_structure' then 
        #change for first drug column
        open cur2_1;
        begin
            DECLARE done int default false;
            DECLARE table_name2_A CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur2_1 into table_name2_A; #target0, target1....
                if done then
                    leave myloop;
                end if;
            end loop;
            #add to the end of the last file of the evidence file
            SET @tempTableA = table_name2_A; #target0,1....
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID_A = drugID_A; #column name
        end;
        close cur2_1; 
        select @tempTableA;
        select @tempTableID_A;
        set @updateTableA = concat('update ', @tempTableA, ' set ', @tempTableID_A , ' = ', dataChange, ' where DRUGBANK_ID = \'', drugID_B, '\'');
        PREPARE re FROM @updateTableA;
        EXECUTE re;
        DEALLOCATE PREPARE re;

        #change second drug column
        open cur2_2;
        begin
            DECLARE done int default false;
            DECLARE table_name2_B CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur2_2 into table_name2_B; #target0, target1....
                if done then
                    leave myloop;
                end if;
            end loop;
            #add to the end of the last file of the evidence file
            SET @tempTableB = table_name2_B;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID_B = drugID_B; 
        end;
        close cur2_2; 
        select @tempTableB;
        select @tempTableID_B;
        set @updateTableB = concat('update ', @tempTableB, ' set ', @tempTableID_B , ' = ', dataChange, ' where DRUGBANK_ID = \'', drugID_A,'\'');
        PREPARE re FROM @updateTableB;
        EXECUTE re;
        DEALLOCATE PREPARE re;
    end if;

    if evi1 = 'pathway' then 
        #change for first drug column
        open cur3_1;
        begin
            DECLARE done int default false;
            DECLARE table_name3_A CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur3_1 into table_name3_A; #target0, target1....
                if done then
                    leave myloop;
                end if;
            end loop;
            #add to the end of the last file of the evidence file
            SET @tempTableA = table_name3_A; #target0,1....
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID_A = drugID_A; #column name
        end;
        close cur3_1; 
        select @tempTableA;
        select @tempTableID_A;
        set @updateTableA = concat('update ', @tempTableA, ' set ', @tempTableID_A , ' = ', dataChange, ' where DRUGBANK_ID = \'', drugID_B, '\'');
        PREPARE re FROM @updateTableA;
        EXECUTE re;
        DEALLOCATE PREPARE re;

        #change second drug column
        open cur3_2;
        begin
            DECLARE done int default false;
            DECLARE table_name3_B CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur3_2 into table_name3_B; #target0, target1....
                if done then
                    leave myloop;
                end if;
            end loop;
            #add to the end of the last file of the evidence file
            SET @tempTableB = table_name3_B;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID_B = drugID_B; 
        end;
        close cur3_2; 

        select @tempTableB;
        select @tempTableID_B;
        set @updateTableB = concat('update ', @tempTableB, ' set ', @tempTableID_B , ' = ', dataChange, ' where DRUGBANK_ID = \'', drugID_A,'\'');
        PREPARE re FROM @updateTableB;
        EXECUTE re;
        DEALLOCATE PREPARE re;
    end if;

end$$ 
DELIMITER ;

call changeDrugRecord('DB30000','DB00014','Struct',0.04);

