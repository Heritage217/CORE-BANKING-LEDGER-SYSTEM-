-- ================================================
-- CORE BANKING LEDGER SYSTEM
-- Round 3: Views
-- Platform: PostgreSQL on Supabase
-- Author: Blaze
-- ================================================

CREATE VIEW vw_customer_accounts AS
SELECT
    c.customer_id,
    c.full_name,
    c.phone_number,
    a.account_number,
    a.account_type,
    a.balance,
    a.status,
    b.branch_name
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN branches b ON a.branch_id = b.branch_id;

CREATE VIEW vw_transaction_history AS
SELECT
    t.transaction_id,
    c.full_name,
    a.account_number,
    t.type,
    t.amount,
    t.balance_after,
    t.description,
    t.transaction_date
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id;

CREATE VIEW vw_active_loans AS
SELECT
    l.loan_id,
    c.full_name,
    a.account_number,
    l.loan_type,
    l.principal,
    l.interest_rate,
    l.tenure_months,
    l.monthly_payment,
    l.due_date,
    l.status
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
JOIN accounts a ON l.account_id = a.account_id
WHERE l.status = 'active';

CREATE VIEW vw_branch_reconciliation AS
SELECT
    b.branch_name,
    b.state,
    r.reconciliation_date,
    r.total_credits,
    r.total_debits,
    r.net_position
FROM daily_reconciliation r
JOIN branches b ON r.branch_id = b.branch_id;

CREATE VIEW vw_pending_failed_transfers AS
SELECT
    t.transfer_id,
    a1.account_number AS from_account,
    a2.account_number AS to_account,
    t.amount,
    t.status,
    t.initiated_at
FROM transfers t
JOIN accounts a1 ON t.from_account_id = a1.account_id
JOIN accounts a2 ON t.to_account_id = a2.account_id
WHERE t.status IN ('pending', 'failed');