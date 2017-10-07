#search on max three evidence and combined the result with average score at the end


#search with selected multiple evidences with one drug name as parameters
drop procedure if exists searchMaxThreeSelectedEvidence;
DELIMITER $$
create procedure searchMaxThreeSelectedEvidence(IN drugName VARCHAR(255), IN evi1 VARCHAR(255), IN evi2 VARCHAR(255), 
IN evi3 VARCHAR(255))
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
        set @updateTable = concat('update ', @tempTable, ' f inner join ', @tempTableName, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;

    end if;
    if evi2 <> '' then
        set @total_amount = @total_amount +1;  
        set @tempTableName = evi2;
        set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
        PREPARE result FROM @tt;
        EXECUTE result;
        DEALLOCATE PREPARE result;
        set @updateTable = concat('update ', @tempTable, ' f inner join ', @tempTableName, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;
    end if;#

    if evi3 <> '' then 
        set @total_amount = @total_amount +1;
        set @tempTableName = evi3;
        set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
        PREPARE result FROM @tt;
        EXECUTE result;
        DEALLOCATE PREPARE result;
        set @updateTable = concat('update ', @tempTable, ' f inner join ', @tempTableName, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
        PREPARE re FROM @updateTable;
        EXECUTE re;
        DEALLOCATE PREPARE re;
    end if;

    #add the score column
    set @tempTableName = 'Score';
    set @tt = concat('alter table ', @tempTable, ' add column ', @tempTableName, ' VARCHAR(255)');
    PREPARE result FROM @tt;
    EXECUTE result;
    DEALLOCATE PREPARE result;

    if @total_amount = 1 then
        if evi1 <> '' then
            set @evidence_name = evi1;
            set @updateTable = concat('update ', @tempTable, ' f inner join ', @evidence_name, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end if;

        if evi2 <> '' then
            set @evidence_name = evi2;
            set @updateTable = concat('update ', @tempTable, ' f inner join ', @evidence_name, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;

        end if;

        if evi3 <> '' then
            set @evidence_name = evi3;
            set @updateTable = concat('update ', @tempTable, ' f inner join ', @evidence_name, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
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
            DEALLOCATE PREPARE re;

        end if;
        if evi2 <> '' and evi3 <> '' then
            set @firt_column = 'all_drug_name';
            set @average = 'average';
            #update final_result f inner join (select all_drug_name, (sum(evidence1) + sum(evidence2))/2 as average from final_result group by all_drug_name) a on a.all_drug_name = f.all_drug_name set f.Score= a.average;
            set @updateTable = concat('update ', @tempTable, ' f inner join (select ', @firt_column,', (sum(', evi2 ,')+sum(', evi3,'))/2 as average from ', @tempTable,' group by ', @firt_column,' ) a on f.all_drug_name = a.all_drug_name set f.', @tempTableName, ' = a.',@average);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;

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


#    set @updateTable = concat('update ', @tempTable, ' f inner join ', @tempTableName, ' e on f.all_drug_name = e.`Unnamed: 0` set f.', @tempTableName, ' = e.',drugName);
#    PREPARE re FROM @updateTable;
#    EXECUTE re;
#    DEALLOCATE PREPARE re;

end$$ 
DELIMITER ;
call searchMaxThreeSelectedEvidence('ANWABDrug', 'evidence1','evidence2','evidence3');

##########################
###########################

select (SUM(evi1)+SUM(evi2)) from final_result group by all_drug_name; 


