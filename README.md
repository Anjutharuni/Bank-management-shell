# 🏦 Bank Account Management System (Shell Script + Dialog)

A terminal-based bank account management system built using **Bash shell scripting** and **Dialog UI** on Unix/Linux systems.

## 📌 Features

- Create Account (auto-generated account number)
- Deposit and Withdraw Money
- Check Balance
- Transfer Funds
- View Transaction History
- Change Account Name
- Close Account
- View Full Account Details
- Password-Protected Access

## 💻 Technologies Used

- Bash Shell Scripting
- Dialog (for GUI-style prompts in terminal)
- Linux Commands (`grep`, `sed`, `awk`, `bc`, `shuf`, etc.)
- File-based storage for account data

## 🧪 How to Run

```bash
chmod +x bank.sh
./bank.sh

⚙️ Requirements
Make sure dialog is installed:

sudo apt install dialog

📁 Project Structure
bank-management-shell/
├── bank.sh           # Main script
├── accounts/         # Stores individual account files
├── .gitignore
└── README.md

⚠️ Disclaimer
This is a beginner-level educational project and should not be used for actual banking. All account data is stored in plain text.
