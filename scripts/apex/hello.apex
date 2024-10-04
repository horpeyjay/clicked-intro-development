// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
/*
string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);*/

/*generateInvoiceNumber randString = new generateInvoiceNumber();

string testing = randString.generateRanInvoiceNumber();

Bill__c newBill = new Bill__c();
newBill.Account__c = '001aj00000U5jWsAAJ';
newBill.Balance__c = 5000;
newBill.Invoice_Number__c = testing;

insert newBill;

system.debug('The new external Id generated was :' + newBill.Invoice_Number__c);*/

//BillAPI.getBills();

/*List<Bill__c> newbills = [SELECT Account__r.Name, Id, Invoice_Number__c, Balance__c FROM Bill__c WHERE Invoice_Number__c != null WITH SECURITY_ENFORCED LIMIT 20];
system.debug (newbills);
String searchTerm = '%Acc%';
List<Bill__c> newB = [Select Account__r.Name, Id, Invoice_Number__c, Balance__c From Bill__c WHERE Account__r.Name LIKE :searchTerm WITH SECURITY_ENFORCED];
            //query the bills
            system.debug (newB);

BillController.getAllBills();
BillController.searchBill('Bur');*/

InterestCalculator IC = new InterestCalculator();
IC.InterestCal('Tayo', 20000.00, 5, 5, false);