-- ================================================
-- CORE BANKING LEDGER SYSTEM
-- Round 2: Seed Data
-- Platform: PostgreSQL on Supabase
-- Author: Blaze
-- ================================================

INSERT INTO branches (branch_name, branch_code, state, city) VALUES
('Lagos Island Branch', 'LAG001', 'Lagos', 'Lagos Island'),
('Abuja Central Branch', 'ABJ001', 'FCT', 'Garki'),
('Port Harcourt Branch', 'PHC001', 'Rivers', 'Port Harcourt'),
('Kano Main Branch', 'KAN001', 'Kano', 'Kano City'),
('Ibadan Branch', 'IBA001', 'Oyo', 'Ibadan');

INSERT INTO customers (full_name, email, phone_number, bvn, address, state, city) VALUES
('Chukwuemeka Obi', 'emeka.obi@gmail.com', '08031234567', '12345678901', '14 Broad Street', 'Lagos', 'Lagos Island'),
('Fatima Al-Hassan', 'fatima.hassan@yahoo.com', '08052345678', '23456789012', '7 Ahmadu Bello Way', 'FCT', 'Garki'),
('Adaeze Nwosu', 'adaeze.nwosu@gmail.com', '08073456789', '34567890123', '3 Rumuola Road', 'Rivers', 'Port Harcourt'),
('Musa Abdullahi', 'musa.abdullahi@gmail.com', '08094567890', '45678901234', '22 Zoo Road', 'Kano', 'Kano City'),
('Bimpe Adeleke', 'bimpe.adeleke@gmail.com', '08015678901', '56789012345', '9 Ring Road', 'Oyo', 'Ibadan');

INSERT INTO accounts (customer_id, branch_id, account_number, account_type, balance, status) VALUES
(1, 1, '0123456789', 'savings', 150000.00, 'active'),
(2, 2, '0234567890', 'current', 500000.00, 'active'),
(3, 3, '0345678901', 'savings', 75000.00, 'active'),
(4, 4, '0456789012', 'fixed_deposit', 1000000.00, 'active'),
(5, 5, '0567890123', 'current', 230000.00, 'active');

INSERT INTO transactions (account_id, type, amount, balance_after, description) VALUES
(1, 'credit', 50000.00, 150000.00, 'Salary deposit'),
(1, 'debit', 20000.00, 130000.00, 'ATM withdrawal'),
(2, 'credit', 200000.00, 500000.00, 'Business income'),
(3, 'debit', 10000.00, 65000.00, 'POS purchase'),
(4, 'credit', 100000.00, 1000000.00, 'Fixed deposit top-up'),
(5, 'credit', 80000.00, 230000.00, 'Transfer received'),
(5, 'debit', 30000.00, 200000.00, 'Utility bill payment');

INSERT INTO transfers (from_account_id, to_account_id, amount, status, completed_at) VALUES
(1, 2, 20000.00, 'completed', CURRENT_TIMESTAMP),
(3, 5, 15000.00, 'completed', CURRENT_TIMESTAMP),
(2, 4, 50000.00, 'pending', NULL),
(5, 1, 10000.00, 'failed', NULL),
(4, 3, 25000.00, 'completed', CURRENT_TIMESTAMP);

INSERT INTO loans (customer_id, account_id, loan_type, principal, interest_rate, tenure_months, monthly_payment, status, due_date) VALUES
(1, 1, 'personal', 500000.00, 24.50, 12, 46500.00, 'active', '2025-06-01'),
(2, 2, 'business', 2000000.00, 18.00, 24, 98000.00, 'active', '2026-06-01'),
(3, 3, 'auto', 800000.00, 22.00, 18, 52000.00, 'defaulted', '2024-12-01'),
(4, 4, 'mortgage', 5000000.00, 15.00, 60, 118000.00, 'active', '2028-06-01'),
(5, 5, 'personal', 300000.00, 24.50, 6, 54000.00, 'completed', '2024-03-01');

INSERT INTO audit_logs (table_name, operation, changed_by, old_data, new_data) VALUES
('accounts', 'UPDATE', 'system', '{"balance": 100000.00}', '{"balance": 150000.00}'),
('customers', 'UPDATE', 'admin', '{"email": "old.email@gmail.com"}', '{"email": "emeka.obi@gmail.com"}'),
('loans', 'INSERT', 'system', NULL, '{"loan_type": "personal", "principal": 500000.00}'),
('transfers', 'UPDATE', 'system', '{"status": "pending"}', '{"status": "completed"}'),
('accounts', 'UPDATE', 'system', '{"status": "active"}', '{"status": "frozen"}');

INSERT INTO daily_reconciliation (branch_id, reconciliation_date, total_credits, total_debits) VALUES
(1, '2024-01-15', 250000.00, 70000.00),
(2, '2024-01-15', 700000.00, 150000.00),
(3, '2024-01-15', 110000.00, 45000.00),
(4, '2024-01-15', 125000.00, 30000.00),
(5, '2024-01-15', 310000.00, 80000.00);