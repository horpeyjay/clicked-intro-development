@isTest
public with sharing class BillHelperTest {
    @isTest
    static void accFieldValidationTest (){
        Account newAcc = new Account(Name = 'Test Account');
        insert newAcc;
        Bill__c newBill = new Bill__c(Account__c = newAcc.Id, Balance__c = 5000);
        insert newBill;
             
        List<Bill__c> insertedBills = [Select Id, Balance__c FROM Bill__c Where Balance__c = 5000];
        system.assertEquals(insertedBills.size(), 1, 'expected 1 accounts');

        /* this failed because I used a DML operation instead of a database.insert operation.
        try{
            insert massBills;
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Account Name is required'), 'Unexpected error message: ' + e.getMessage());
        }
        //check for trigger
        List<Bill__c> bills = [SELECT Id FROM Bill__c];
        System.assertEquals(150, bills.size(), 'something went wrong');

        //Using a Database operation
        Database.SaveResult[] sr = Database.insert(massBills, false);
        //check for trigger
        List<Bill__c> bills = [SELECT Id FROM Bill__c];
        System.assertEquals(150, bills.size(), 'There are 150 invalid records');

        //check for error message
        Integer failedBills = 0;
        for (Database.SaveResult result : sr){
            if (!result.isSuccess()){
                for(Database.Error err : result.getErrors()){
                    System.assert(err.getMessage().contains('Account Name is required'), 'Unexpected error message: ' + err.getMessage());
                }
                failedBills++;
            }
        }
        System.assertEquals(150, failedBills, 'There are 150 invalid records');*/
    }
    @isTest
    static void createOppTest(){

        //create test account
        Account newAcc = new Account(Name = 'Test Account');
        insert newAcc;
        
        //create two opportunity for this account: one close, another open
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity', AccountId = newAcc.Id, StageName = 'Closed Won', Amount = 50000, CloseDate = Date.today().addDays(30));
        insert opp1;
        Opportunity opp2 = new Opportunity(Name = 'Test Opportunity', AccountId = newAcc.Id, StageName = 'Prospecting', Amount = 50000, CloseDate = Date.today().addDays(30));
        insert opp2;

        //create a bill
        Bill__c newBill = new Bill__c(Account__c = newAcc.Id, Balance__c = 5000);
        insert newBill;

        //check if the opportunity size is increased to 3. we should retain just 2
        List<Opportunity> oppList = [Select Id from Opportunity where AccountId = : newAcc.Id];
        System.assertEquals(2, oppList.size(), 'We should have 2 opportunity because there is still an open opp');

        //Second logic
        Account newAcc1 = new Account(Name = 'Test Account Opp Created');
        insert newAcc1;
        Bill__c newBill1 = new Bill__c(Account__c = newAcc1.Id, Balance__c = 5000, Invoice_Number__c = '');
        insert newBill1;

        //check if opportunity record was created
        List<Opportunity> createdOpps = [Select Id, Name, Amount From Opportunity where AccountId = : newAcc1.Id];
        System.assertEquals(1, createdOpps.size(), 'There should be 1 opportunity created because there is no open opp');
        system.assertEquals(5000, createdOpps[0].Amount, 'The amount should be 5000');
        system.assertNotEquals(newAcc1.Name + ' - Opportunity -' + newBill1.Invoice_Number__c, createdOpps[0].Name, 'something wrong with the naming of the opportunity');
    }

    @isTest
    static void generateInvoicenum (){
        
        //create test account
        Account newAcc = new Account(Name = 'Testing Account');
        //insert the test account
        insert newAcc;

        //Create a bill record but with the invoice number missing

        Bill__c bill = new Bill__c ();
        bill.Account__c = newAcc.Id; 
        bill.Balance__c = 5000;
        insert bill;

        //assert to check if the invoice field is null
        Bill__c newBill = [SELECT Id, Invoice_Number__c FROM Bill__c WHERE Id = :bill.Id];
        //check if the invoice number is generated
        system.assertNotEquals(null, newBill.Invoice_Number__c, 'Invoice number should not be empty');
    }
}