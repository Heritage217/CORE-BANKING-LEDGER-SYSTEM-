-- ================================================
-- CORE BANKING LEDGER SYSTEM
-- Round 5: Triggers
-- Platform: PostgreSQL on Supabase
-- Author: Blaze
-- ================================================

-- Trigger 1: Auto-log balance changes
CREATE OR REPLACE FUNCTION log_balance_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.balance <> NEW.balance THEN
        INSERT INTO audit_logs(table_name, operation, changed_by, old_data, new_data)
        VALUES (
            'accounts',
            'UPDATE',
            current_user,
            jsonb_build_object('balance', OLD.balance),
            jsonb_build_object('balance', NEW.balance)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_balance_change
AFTER UPDATE ON accounts
FOR EACH ROW
EXECUTE FUNCTION log_balance_change();

-- Trigger 2: Auto-log customer updates
CREATE OR REPLACE FUNCTION log_customer_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs(table_name, operation, changed_by, old_data, new_data)
    VALUES (
        'customers',
        'UPDATE',
        current_user,
        row_to_json(OLD)::jsonb,
        row_to_json(NEW)::jsonb
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customer_update
AFTER UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION log_customer_update();

-- Trigger 3: Block transactions on frozen accounts
CREATE OR REPLACE FUNCTION block_frozen_account_transaction()
RETURNS TRIGGER AS $$
DECLARE
    v_status VARCHAR(10);
BEGIN
    SELECT status INTO v_status
    FROM accounts
    WHERE account_id = NEW.account_id;

    IF v_status = 'frozen' THEN
        RAISE EXCEPTION 'Transaction blocked: Account % is frozen.', NEW.account_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_block_frozen_transactions
BEFORE INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION block_frozen_account_transaction();

-- Trigger 4: Auto-flag defaulted loans
CREATE OR REPLACE FUNCTION flag_defaulted_loan()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.due_date < CURRENT_DATE AND NEW.status = 'active' THEN
        UPDATE loans
        SET status = 'defaulted'
        WHERE loan_id = NEW.loan_id;

        INSERT INTO audit_logs(table_name, operation, changed_by, old_data, new_data)
        VALUES (
            'loans',
            'UPDATE',
            current_user,
            jsonb_build_object('status', 'active'),
            jsonb_build_object('status', 'defaulted')
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_flag_defaulted_loan
AFTER INSERT OR UPDATE ON loans
FOR EACH ROW
EXECUTE FUNCTION flag_defaulted_loan();

-- Trigger 5: Auto-update daily reconciliation
CREATE OR REPLACE FUNCTION update_daily_reconciliation()
RETURNS TRIGGER AS $$
DECLARE
    v_branch_id INT;
BEGIN
    SELECT branch_id INTO v_branch_id
    FROM accounts
    WHERE account_id = NEW.account_id;

    IF NEW.type = 'credit' THEN
        INSERT INTO daily_reconciliation(branch_id, reconciliation_date, total_credits, total_debits)
        VALUES (v_branch_id, CURRENT_DATE, NEW.amount, 0.00)
        ON CONFLICT (branch_id, reconciliation_date)
        DO UPDATE SET total_credits = daily_reconciliation.total_credits + NEW.amount;

    ELSIF NEW.type = 'debit' THEN
        INSERT INTO daily_reconciliation(branch_id, reconciliation_date, total_credits, total_debits)
        VALUES (v_branch_id, CURRENT_DATE, 0.00, NEW.amount)
        ON CONFLICT (branch_id, reconciliation_date)
        DO UPDATE SET total_debits = daily_reconciliation.total_debits + NEW.amount;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_reconciliation
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION update_daily_reconciliation();