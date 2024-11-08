## Store Management System(Team13)


GitHub link- https://github.com/Nirajpatel26/Team13_Store_Management_System

# Steps to run the scripts for Project_3-

1. Open Environment setup folder from the github and then in the Oracle Admin, run the APP_Admin-creation.sql file to create the Admin for the StoreManagementSystem 
2. Once APP_Admin user is created , Create new connection in SQL Developer with name and password mentioned in APP_ADMIN-creation.sql file , then run Table-creation-DDL.sql file to create the tables 
3. From APP_Admin user, run Creation_Stored_Procedures.sql file to create stored procedures for inserting data
4. From APP_Admin  user, run ViewsCreation.sql file to create views 
5. From APP_Admin  user, run User_Creation.sql file to create users and provide the privileges
6. Please note From the same App_admin user we will be creating 4 different worksheets and running above scripts (Table-creation-DDL.sql, Creation_Stored_Procedures.sql, ViewsCreation.sql, User_Creation.sql ) in the same given sequence
6. Now open Data Insertion folder from the GitHub and run the scripts in the order below:-
7. Connect to MANAGER_User (Username and password is mentioned in User_Creation file ) and then run MANAGER_USER_INSERTION.SQL file to insert data 
8. Connect to Inventory_User (Username and password is mentioned in User_Creation file)and then run INVENTORY_USER_INSERTION.SQL file to insert data 
9. Connect to CASHIER_USER(Username and password is mentioned in User_Creation file)and then run CASHIER_USER_INSERTION.SQL file to insert data 
10. Connect to MARKETING_User (Username and password is mentioned in User_Creation file)and then run MARKETING_USER_INSERTION.SQL file to insert data 
11. Now Open Views Folder from the Github
12. Run each view script through mentioned user(Eg-From the CASHIER_USER run the CASHIER_USER_VIEWS.sql file) Similarly run for the remaining three views 
