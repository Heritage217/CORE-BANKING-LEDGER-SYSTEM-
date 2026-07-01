-- ================================================
-- CORE BANKING LEDGER SYSTEM
-- Round 1: Schema (DDL)
-- Platform: PostgreSQL on Supabase
-- Author: Blaze
-- ================================================

CREATE TABLE branches (
    branch_id    SERIAL PRIMARY KEY,
    branch_name  VARCHAR(100) NOT NULL,
    branch_code  VARCHAR(10)  UNIQUE NOT NULL,
    state        VARCHAR(50)  NOT NULL,
    city         VARCHAR(50)  NOT NULL,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    full_name     VARCHAR(150) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    phone_number  VARCHAR(20)  UNIQUE NOT NULL,
    bvn           CHAR(11)     UNIQUE NOT NULL,
    address       TEXT,
    state         VARCHAR(50)  NOT NULL,
    city          VARCHAR(50)  NOT NULL,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id     SERIAL PRIMARY KEY,
    customer_id    INT NOT NULL REFERENCES customers(customer_id),
    branch_id      INT NOT NULL REFERENCES branches(branch_id),
    account_number VARCHAR(10)     UNIQUE NOT NULL,
    account_type   VARCHAR(20)     NOT NULL CHECK (account_type IN ('savings', 'current', 'fixed_deposit')),
    balance        NUMERIC(15, 2)  NOT NULL DEFAULT 0.00,
    status         VARCHAR(10)     NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'frozen')),
    created_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id   SERIAL PRIMARY KEY,
    account_id       INT            NOT NULL REFERENCES accounts(account_id),
    type             VARCHAR(10)    NOT NULL CHECK (type IN ('credit', 'debit')),
    amount           NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    balance_after    NUMERIC(15, 2) NOT NULL,
    description      TEXT,
    transaction_date TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transfers (
    transfer_id        SERIAL PRIMARY KEY,
    from_account_id    INT            NOT NULL REFERENCES accounts(account_id),
    to_account_id      INT            NOT NULL REFERENCES accounts(account_id),
    amount             NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    status             VARCHAR(10)    NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
    initiated_at       TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    completed_at       TIMESTAMP
);

CREATE TABLE audit_logs (
    log_id        SERIAL PRIMARY KEY,
    table_name    VARCHAR(50)  NOT NULL,
    operation     VARCHAR(10)  NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    changed_by    VARCHAR(100),
    changed_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    old_data      JSONB,
    new_data      JSONB
);

CREATE TABLE loans (
    loan_id          SERIAL PRIMARY KEY,
    customer_id      INT            NOT NULL REFERENCES customers(customer_id),
    account_id       INT            NOT NULL REFERENCES accounts(account_id),
    loan_type        VARCHAR(20)    NOT NULL CHECK (loan_type IN ('personal', 'mortgage', 'business', 'auto')),
    principal        NUMERIC(15, 2) NOT NULL CHECK (principal > 0),
    interest_rate    NUMERIC(5, 2)  NOT NULL,
    tenure_months    INT            NOT NULL CHECK (tenure_months > 0),
    monthly_payment  NUMERIC(15, 2) NOT NULL,
    status           VARCHAR(10)    NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'defaulted')),
    disbursed_at     TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    due_date         DATE           NOT NULL
);

CREATE TABLE daily_reconciliation (
    reconciliation_id   SERIAL PRIMARY KEY,
    branch_id           INT            NOT NULL REFERENCES branches(branch_id),
    reconciliation_date DATE           NOT NULL,
    total_credits       NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    total_debits        NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    net_position        NUMERIC(15, 2) GENERATED ALWAYS AS (total_credits - total_debits) STORED,
    created_at          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (branch_id, reconciliation_date)
);