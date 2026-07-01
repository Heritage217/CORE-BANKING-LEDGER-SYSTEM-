# Core Banking Ledger System

A PostgreSQL database project simulating the core data infrastructure of a Nigerian retail bank, built and deployed on Supabase.

Developed as part of a Database Administration portfolio targeting financial institution DBA roles.

---

## Overview

This system models real-world retail banking operations including customer management, account handling, fund transfers, loan tracking, audit logging, and end-of-day branch reconciliation. All records reflect Nigerian banking context — BVN numbers, NGN amounts, Nigerian names, and local branch locations.

---

## Database Architecture

The schema spans 3 layers across 8 tables:

Layer 1 — Core Entities: branches, customers

Layer 2 — Financial Operations: accounts, transactions

Layer 3 — Advanced Banking: transfers, loans, audit_logs, daily_reconciliation

---

## Project Files

01_schema.sql — Table definitions, constraints, and foreign key relationships

02_seed_data.sql — Realistic Nigerian banking dummy data

03_views.sql — Pre-built queries for reporting and dashboard use

04_functions_procedures.sql — Stored procedures for deposit, withdrawal, and fund transfer

05_triggers.sql — Automated triggers for auditing, fraud prevention, and reconciliation

---

## Key Features

Account Status Enforcement — Frozen accounts are automatically blocked from processing any transactions

Audit Logging — Every balance change and customer record update is captured automatically in the audit log

Loan Default Detection — Overdue active loans are flagged as defaulted without manual intervention

Real-Time Reconciliation — Branch daily credit and debit totals update automatically with every transaction

Balance Validation — Withdrawal and transfer procedures check available balance before executing

BVN Tracking — Every customer record includes a unique 11-digit Bank Verification Number

---

## Tech Stack

Database: PostgreSQL

Cloud Platform: Supabase

Tools: VS Code, Git, GitHub

---

## Author

Heritage217
Computer Science Graduate | Aspiring Database Administrator

GitHub: https://github.com/Heritage217
