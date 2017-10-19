
#delete with selected multiple evidences with one drug name as parameters
drop procedure if exists drugDeletion;
DELIMITER $$
create procedure drugDeletion(IN drugID VARCHAR(255), IN evi1 VARCHAR(255))
begin

    DECLARE cur1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%';
    DECLARE cur1_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%' and t.COLUMN_NAME = 'DRUGBANK_ID';
    
    DECLARE cur2 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'struct%';
    DECLARE cur2_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'struct%' and t.COLUMN_NAME = 'DRUGBANK_ID';
    
    DECLARE cur3 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chem%';
    DECLARE cur3_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chem%' and t.COLUMN_NAME = 'DRUGBANK_ID';
    
    #new drug input --> drugID as the table name
    if evi1 = 'target' then 
        #######  evia<---->info
        set @row = concat('delete from info where ID = \'', drugID,  '\'');
        select @row;
        PREPARE r FROM @row;
        EXECUTE r;
        DEALLOCATE PREPARE r;
        #select * from evia;
        #########
        #deleterow for all the table drugbank_id
        open cur1_1;
        begin
            DECLARE done int default false;
            DECLARE table_name1_1 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop1: loop
                fetch cur1_1 into table_name1_1; #target0, target1....
                if done then
                    leave myloop1;
                end if;
                SET @tempTable = table_name1_1; 
                #select @tempTable;
                set @tempTableID = drugID; 
                select @tempTableID;
                set @deleteRow = concat('delete from ',@tempTable,' where DRUGBANK_ID = \'',@tempTableID,'\'');
                PREPARE re FROM @deleteRow;
                EXECUTE re;
                DEALLOCATE PREPARE re;
            end loop;
        end;
        close cur1_1;
        #add the column to the file
        open cur1;
        begin
            DECLARE done int default false;
            DECLARE table_name1_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop2: loop
                fetch cur1 into table_name1_2; #target0, target1....
                if done then
                    leave myloop2;
                end if;
                SET @tempTable1 = table_name1_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            #select @tempTableID;#
            set @tt = concat('alter table ', @tempTable1, ' drop column ', @tempTableID1);
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;
        end;
        close cur1; ###
        #find where the latest column store in
        select @tempTable1;
        #double check the present drugID
        select @tempTableID1;##
        
    end if;

    if evi1 = 'struct' then 
        ####update the last row of the info dataset####
        #######  evia<---->info
        set @row = concat('delete from info where ID = \'', drugID,  '\'');
        select @row;
        PREPARE r FROM @row;
        EXECUTE r;
        DEALLOCATE PREPARE r;
        #select * from evia;
        #########
        #add the new row for all the table drugbank_id
        open cur2_1;
        begin
            DECLARE done int default false;
            DECLARE table_name2_1 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop4: loop
                fetch cur2_1 into table_name2_1; #target0, target1....
                if done then
                    leave myloop4;
                end if;
                SET @tempTable = table_name2_1; 
                set @tempTableID = drugID; 
                set @deleteRow = concat('delete from ',@tempTable,' where DRUGBANK_ID = \'',@tempTableID,'\'');
                PREPARE re FROM @deleteRow;
                EXECUTE re;
                DEALLOCATE PREPARE re;
            end loop;
        end;
        close cur2_1;
        #add the column to the file
        open cur2;
        begin
            DECLARE done int default false;
            DECLARE table_name2_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop5: loop
                fetch cur2 into table_name2_2;
                if done then
                    leave myloop5;
                end if;
                SET @tempTable1 = table_name2_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            #select @tempTableID;#
            set @tt = concat('alter table ', @tempTable1, ' drop column ', @tempTableID1);
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;
        end;
        close cur2; 

        
    end if;

    if evi1 = 'chem' then 
        ####update the last row of the info dataset####
        #######  evia<---->info
        set @row = concat('delete from info where ID = \'', drugID,  '\'');
        select @row;
        PREPARE r FROM @row;
        EXECUTE r;
        DEALLOCATE PREPARE r;
        #select * from evia;
        #########
        #add the new row for all the table drugbank_id
        open cur3_1;
        begin
            DECLARE done int default false;
            DECLARE table_name3_1 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop7: loop
                fetch cur3_1 into table_name3_1;
                if done then
                    leave myloop7;
                end if;
                SET @tempTable = table_name3_1; 
                #select @tempTable;
                set @tempTableID = drugID; 
                #select @tempTableID;
                set @deleteRow = concat('delete from ',@tempTable,' where DRUGBANK_ID = \'',@tempTableID,'\'');
                PREPARE re FROM @deleteRow;
                EXECUTE re;
                DEALLOCATE PREPARE re;
            end loop;
        end;
        close cur3_1;

        #add the column to the file
        open cur3;
        begin
            DECLARE done int default false;
            DECLARE table_name3_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop8: loop
                fetch cur3 into table_name3_2; #target0, target1....
                if done then
                    leave myloop8;
                end if;
                SET @tempTable1 = table_name3_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            #select @tempTableID;#
            set @tt = concat('alter table ', @tempTable1, ' drop column ', @tempTableID1);
            PREPARE res FROM @tt;
            EXECUTE res;
            DEALLOCATE PREPARE res;
        end;
        close cur3; 

    end if;

end$$ 
DELIMITER ;




call drugDeletion('DB30000','struct');

