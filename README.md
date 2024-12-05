## Store Management System(Team13)


GitHub link- https://github.com/Nirajpatel26/Team13_Store_Management_System

# Steps to run the scripts for Project_3-

1. Open Environment setup folder from the github and then in the Oracle Admin, run the APP_Admin-creation.sql file to create the Admin for the StoreManagementSystem 
2. Once APP_Admin user is created , Create new connection in SQL Developer with name and password mentioned in APP_ADMIN-creation.sql file , then run Table-creation-DDL.sql file to create the tables 
3. From APP_Admin user, run Creation_Stored_Procedures.sql file to create stored procedures for inserting data
4. From APP_Admin user, run Sequence_Creation.sql file to create the sequences
5. From APP_Admin user, run Function.sql file to create the function
6. From APP_Admin user, run Business_SP.sql file to create the business stored procedures
7. From APP_Admin  user, run Package_Product_Creation.sql file to create packages
8. From APP_Admin  user, run Triggers.sql file to create the triggers
9. From APP_Admin  user, run Indexes.sql file to create the indexes
10. From APP_Admin  user, run ViewsCreation.sql file to create views 
11. From APP_Admin  user, run User_Creation.sql file to create users and provide the privileges
12. Please note From the same App_admin user we will be creating different worksheets and running above scripts (Table-creation-DDL.sql, Creation_Stored_Procedures.sql, Sequence_Creation.sql, Sequence_Creation.sql, Function.sql, Business_SP.sql, Package_Product_Creation.sql,Triggers.sql,Indexes.sql ,ViewsCreation.sql, User_Creation.sql ) in the same given sequence
13. Now open Data Insertion folder from the GitHub and run the scripts in the order below:-
14. Connect to MANAGER_User (Username and password is mentioned in User_Creation file ) and then run MANAGER_USER_INSERTION.SQL file to insert data 
15. Connect to Inventory_User (Username and password is mentioned in User_Creation file)and then run INVENTORY_USER_INSERTION.SQL file to insert data 
16. Connect to CASHIER_USER(Username and password is mentioned in User_Creation file)and then run CASHIER_USER_INSERTION.SQL file to insert data 
17. Connect to MARKETING_User (Username and password is mentioned in User_Creation file)and then run MARKETING_USER_INSERTION.SQL file to insert data 
18. Now open Cashier_user folder and run and check each business logic
19. Inventory_user folder and run and check each business logic
20. Manager_User folder and run and check each business logic
21. Marketing_User folder and run and check each business logic
22. Now Open Views Folder from the Github
23. Run each view script through mentioned user(Eg-From the CASHIER_USER run the CASHIER_USER_VIEWS.sql file) Similarly run for the remaining three views 