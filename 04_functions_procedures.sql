-- ================================================
-- CORE BANKING LEDGER SYSTEM
-- Round 4: Functions & Procedures
-- Platform: PostgreSQL on Supabase
-- Author: Blaze
-- ================================================

CREATE OR REPLACE FUNCTION get_account_balance(p_account_id INT)
RETURNS NUMERIC(15,2) AS $$
BEGIN
    RETURN (
        SELECT balance
        FROM accounts
        WHERE account_id = p_account_id
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_customer_loan_total(p_customer_id INT)
RETURNS NUMERIC(15,2) AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(principal), 0)
        FROM loans
        WHERE customer_id = p_customer_id
        AND status = 'active'
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE deposit_funds(
    p_account_id INT,
    p_amount NUMERIC(15,2),
    p_description TEXT DEFAULT 'Deposit'
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    INSERT INTO transactions(account_id, type, amount, balance_after, description)
    VALUES (
        p_account_id,
        'credit',
        p_amount,
        (SELECT balance FROM accounts WHERE account_id = p_account_id),
        p_description
    );
END;
$$;

CREATE OR REPLACE PROCEDURE transfer_funds(
    p_from_account INT,
    p_to_account INT,
    p_amount NUMERIC(15,2)
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from_account;
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_to_account;

    INSERT INTO transfers(from_account_id, to_account_id, amount, status, completed_at)
    VALUES (p_from_account, p_to_account, p_amount, 'completed', CURRENT_TIMESTAMP);
END;
$$;

CREATE OR REPLACE PROCEDURE withdraw_funds(
    p_account_id INT,
    p_amount NUMERIC(15,2),
    p_description TEXT DEFAULT 'Withdrawal'
)
LANGUAGE plpgsql AS $$
DECLARE
    v_current_balance NUMERIC(15,2);
BEGIN
    SELECT balance INTO v_current_balance
    FROM accounts
    WHERE account_id = p_account_id;

    IF v_current_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds. Current balance: %', v_current_balance;
    END IF;

    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_account_id;

    INSERT INTO transactions(account_id, type, amount, balance_after, description)
    VALUES (
        p_account_id,
        'debit',
        p_amount,
        (SELECT balance FROM accounts WHERE account_id = p_account_id),
        p_description
    );
END;
$$;