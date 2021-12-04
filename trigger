create or replace function total_cost()
    returns trigger
    language PLPGSQL
    as
$$
declare
    temp_val1 numeric = 0;
    temp_val2 numeric = 0;
    temp_val3 numeric = 0;
    temp_val4 varchar(30) = 0;
    temp_val5 numeric = 0;
begin
        select package_weight into temp_val1
        from package_info
        where package_info.track_code = new.track_code;

        if (new.delivery_type = 'In city') then
        temp_val2 = 1000;
        end if;

        if (new.delivery_type = 'Out of city') then
        temp_val2 = 2500;
        end if;

        if (new.delivery_type = 'International') then
        temp_val2 = 5000;
        end if;

        if ((select package_info.package_type
            from package_info
            where package_info.track_code = new.track_code) = 'flat envelope') then
        temp_val3 = 300;
        end if;

        if ((select package_info.package_type
            from package_info
            where package_info.track_code = new.track_code) = 'small box') then
        temp_val3 = 500;
        end if;

        if ((select package_info.package_type
            from package_info
            where package_info.track_code = new.track_code) = 'large box') then
        temp_val3 = 1000;
        end if;

        temp_val5 = (temp_val1 * temp_val2) + temp_val3;

        update orders
        set total_cost = temp_val5
        where orders.order_id = new.order_id;



        if (new.payment_method = 'Contract') then
            temp_val4 = (select accounts.id from accounts, contracts
                         where contracts.customer_id = new.customer_id
                         and contracts.account_number = accounts.id);

            update accounts
            set owed =  owed+temp_val5
            where id = temp_val4;
        end if;

        return new;
end;
$$;

create trigger trigger_total_cost
  after insert
  on orders
  for each row
  execute procedure total_cost();
