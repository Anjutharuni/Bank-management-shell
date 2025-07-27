#!/bin/bash

# Bank Account Management System using Shell Scripting and Dialog

# Function to display the main menu
display_main_menu() {
  dialog --clear --title "Main Menu" \
    --menu "Select an option:" 15 50 10 \
    1 "Create Account" \
    2 "Deposit" \
    3 "Withdraw" \
    4 "Check Balance" \
    5 "View Transaction History" \
    6 "Transfer Funds" \
    7 "Change Name" \
    8 "Close Account" \
    9 "View Account Details" \
    10 "Exit" 2>/tmp/menu_choice
  menu_choice=$(< /tmp/menu_choice)
}

# Function to authenticate user
authenticate_user() {
  account_no=$1
  # Retrieve stored password from the account file
  stored_password=$(grep -oP 'Password: \K.*' "accounts/$account_no.txt")

  # Prompt user for password
  password=$(dialog --title "Authentication" --inputbox "Enter your password:" 8 40 3>&1 1>&2 2>&3)

  # Check if password matches
  if [[ "$password" == "$stored_password" ]]; then
    return 0  # Success
  else
    dialog --msgbox "Incorrect password." 6 40
    return 1  # Failure
  fi
}

# Function to create a new account
create_account() {
  account_no=$(shuf -i 100000-999999 -n 1)
  name=$(dialog --inputbox "Enter your name:" 8 40 3>&1 1>&2 2>&3)
  initial_balance=$(dialog --inputbox "Enter initial balance:" 8 40 3>&1 1>&2 2>&3)
  password=$(dialog --title "Set Password" --inputbox "Enter your password:" 8 40 3>&1 1>&2 2>&3)

  if [[ -z "$name" || -z "$initial_balance" || -z "$password" ]]; then
    dialog --msgbox "Please enter all required information." 6 40
    return 1
  fi

  if ! [[ "$initial_balance" =~ ^[0-9]+$ ]]; then
    dialog --msgbox "Initial balance must be numeric." 6 40
    return 1
  fi

  mkdir -p accounts
  echo "Account Number: $account_no" > "accounts/$account_no.txt"
  echo "Name: $name" >> "accounts/$account_no.txt"
  echo "Balance: $initial_balance" >> "accounts/$account_no.txt"
  echo "Password: $password" >> "accounts/$account_no.txt"
  echo "Transaction History:" >> "accounts/$account_no.txt"
  echo "$(date): Initial deposit of $initial_balance" >> "accounts/$account_no.txt"

  dialog --msgbox "Account created successfully! Account Number: $account_no" 6 40
}

# Function to deposit money
deposit() {
  account_no=$(dialog --inputbox "Enter your account number:" 8 40 3>&1 1>&2 2>&3)

  if [[ ! -f "accounts/$account_no.txt" ]]; then
    dialog --msgbox "Account not found." 6 40
    return 1
  fi

  # Authenticate user before proceeding
  authenticate_user "$account_no" || return 1

  amount=$(dialog --inputbox "Enter amount to deposit:" 8 40 3>&1 1>&2 2>&3)

  current_balance=$(grep -oP 'Balance: \K\d+' "accounts/$account_no.txt")
  new_balance=$(echo "$current_balance + $amount" | bc)

  # Update balance and record transaction
  sed -i "s/Balance: .*/Balance: $new_balance/" "accounts/$account_no.txt"
  echo "$(date): Deposited $amount" >> "accounts/$account_no.txt"

  dialog --msgbox "Deposit successful. New balance: $new_balance" 6 40
}

# Function to withdraw money
withdraw() {
  account_no=$(dialog --inputbox "Enter your account number:" 8 40 3>&1 1>&2 2>&3)
  amount=$(dialog --inputbox "Enter amount to withdraw:" 8 40 3>&1 1>&2 2>&3)

  if [[ -z "$account_no" || -z "$amount" ]]; then
    dialog --msgbox "Please enter all required information." 6 40
    return 1
  fi

  if [[ ! -f "accounts/$account_no.txt" ]]; then
    dialog --msgbox "Account not found." 6 40
    return 1
  fi

  # Authenticate user before proceeding
  authenticate_user "$account_no" || return 1

  current_balance=$(grep -oP 'Balance: \K\d+' "accounts/$account_no.txt")

  if [[ $(echo "$current_balance < $amount" | bc) -eq 1 ]]; then
    dialog --msgbox "Insufficient balance." 6 40
    return 1
  fi


  new_balance=$(echo "$current_balance - $amount" | bc)

  sed -i "s/Balance: .*/Balance: $new_balance/" "accounts/$account_no.txt"
  echo "$(date): Withdrew $amount" >> "accounts/$account_no.txt"

  dialog --msgbox "Withdrawal successful. New balance: $new_balance" 6 40
}

# Function to check account balance
check_balance() {
  account_no=$(dialog --inputbox "Enter your account number:" 8 40 3>&1 1>&2 2>&3)

  if [[ -z "$account_no" ]]; then
    dialog --msgbox "Please enter your account number." 6 40
    return 1
  fi

  if [[ ! -f "accounts/$account_no.txt" ]]; then
    dialog --msgbox "Account not found." 6 40
    return 1
  fi

  # Authenticate user before proceeding
  authenticate_user "$account_no" || return 1

  balance=$(grep -oP 'Balance: \K\d+' "accounts/$account_no.txt")
  dialog --msgbox "Your current balance is: $balance" 6 40
}

# Function to view transaction history
view_history() {
  account_no=$(dialog --inputbox "Enter your account number:" 8 40 3>&1 1>&2 2>&3)

  if [[ -z "$account_no" ]]; then
    dialog --msgbox "Please enter your account number." 6 40
    return 1
  fi

  if [[ ! -f "accounts/$account_no.txt" ]]; then
    dialog --msgbox "Account not found." 6 40
    return 1
  fi

  # Authenticate user before proceeding
  authenticate_user "$account_no" || return 1

  history=$(grep -A 100 "Transaction History:" "accounts/$account_no.txt")
  dialog --msgbox "$history" 15 60
}

# Function to transfer funds
transfer_funds() {
  from_account=$(dialog --inputbox "Enter your account number:" 8 40 3>&1 1>&2 2>&3)
  to_account=$(dialog --inputbox "Enter recipient's account number:" 8 40 3>&1 1>&2 2>&3)
  amount=$(dialog --inputbox "Enter amount to transfer:" 8 40 3>&1 1>&2 2>&3)

  if [[ -z "$from_account" || -z "$to_account" || -z "$amount" ]]; then
    dialog --msgbox "Please enter all required information." 6 40
    return 1
  fi

  if [[ ! -f "accounts/$from_account.txt" ]]; then
    dialog --msgbox "Your account not found." 6 40
    return 1
  fi

  if [[ ! -f "accounts/$to_account.txt" ]]; then
    dialog --msgbox "Recipient's account not found." 6 40
    return 1
  fi

  # Authenticate user before proceeding
  authenticate_user "$from_account" || return 1

  from_balance=$(grep -oP 'Balance: \K\d+' "accounts/$from_account.txt")

  if [[ $(echo "$from_balance < $amount" | bc) -eq 1 ]]; then
    dialog --msgbox "Insufficient balance." 6 40
    return 1
  fi

  to_balance=$(grep -oP 'Balance: \K\d+' "accounts/$to_account.txt")
  new_from_balance=$(echo "$from_balance - $amount" | bc)
  new_to_balance=$(echo "$to_balance + $amount" | bc)

  sed -i "s/Balance: .*/Balance: $new_from_balance/" "accounts/$from_account.txt"
  echo "$(date): Transferred $amount to account $to_account" >> "accounts/$from_account.txt"

  sed -i "s/Balance: .*/Balance: $new_to_balance/" "accounts/$to_account.txt"
  echo "$(date): Received $amount from account $from_account" >> "accounts/$to_account.txt"

  dialog --msgbox "Transfer successful." 6 40
}

# Function to change account name
change_name() {
  account_no=$(dialog --inputbox "Enter your account number:" 8 40 3>&1 1>&2 2>&3)
  new_name=$(dialog --inputbox "Enter new name:" 8 40 3>&1 1>&2 2>&3)

  if [[ -z "$account_no" || -z "$new_name" ]]; then
    dialog --msgbox "Please enter all required information." 6 40
    return 1
  fi

  if [[ ! -f "accounts/$account_no.txt" ]]; then
    dialog --msgbox "Account not found." 6 40
    return 1
  fi

  # Authenticate user before proceeding
  authenticate_user "$account_no" || return 1

  sed -i "s/Name: .*/Name: $new_name/" "accounts/$account_no.txt"
  dialog --msgbox "Name changed successfully." 6 40
}

# Function to close an account
close_account() {
  account_no=$(dialog --inputbox "Enter your account number:" 8 40 3>&1 1>&2 2>&3)

  if [[ -z "$account_no" ]]; then
    dialog --msgbox "Please enter your account number." 6 40
    return 1
  fi

  if [[ ! -f "accounts/$account_no.txt" ]]; then
    dialog --msgbox "Account not found." 6 40
    return 1
  fi

  # Authenticate user before proceeding
  authenticate_user "$account_no" || return 1

  rm -f "accounts/$account_no.txt"
  dialog --msgbox "Account closed successfully." 6 40
}

# Function to view account details
view_account_details() {
  account_no=$(dialog --inputbox "Enter your account number:" 8 40 3>&1 1>&2 2>&3)

  if [[ -z "$account_no" ]]; then
    dialog --msgbox "Please enter your account number." 6 40
    return 1
  fi

  if [[ ! -f "accounts/$account_no.txt" ]]; then
    dialog --msgbox "Account not found." 6 40
    return 1
  fi

  # Authenticate user before proceeding
  authenticate_user "$account_no" || return 1

  details=$(cat "accounts/$account_no.txt")
  dialog --msgbox "$details" 15 60
}

# Main program loop
while true; do
  display_main_menu
  case $menu_choice in
    1) create_account ;;
    2) deposit ;;
    3) withdraw ;;
    4) check_balance ;;
    5) view_history ;;
    6) transfer_funds ;;
    7) change_name ;;
    8) close_account ;;
    9) view_account_details ;;
    10) break ;;
    *) dialog --msgbox "Invalid option selected." 6 40 ;;
  esac
done
