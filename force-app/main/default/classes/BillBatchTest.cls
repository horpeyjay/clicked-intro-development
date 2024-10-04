@isTest
private with sharing class BillBatchTest {
    @isTest
    static void batchTest() {
        //Create test data
        //4 test account
        Account acc1 = new Account(Name = 'Test account 1', Email__c = 'test@example.com', Bill_By_Email__c = true);
        Account acc2 = new Account(Name = 'Test account 2', Email__c = 'test@example.com', Bill_By_Email__c = true);
        Account acc3 = new Account(Name = 'Test account 3', Bill_By_Email__c = true);
        Account acc4 = new Account(Name = 'Test account 4', Email__c = 'test@example.com', Bill_By_Email__c = false);
        insert new List<Account>{acc1, acc2, acc3, acc4};

        //create test bill
        Bill__c bill1 = new Bill__c(Account__c = acc1.Id, Balance__c = 500);
        Bill__c bill2 = new Bill__c(Account__c = acc2.Id, Balance__c = 500);
        Bill__c bill3 = new Bill__c(Account__c = acc3.Id, Balance__c = 500);
        Bill__c bill4 = new Bill__c(Account__c = acc4.Id, Balance__c = 500);

        insert new List<Bill__c>{bill1, bill2, bill3, bill4};
        
        //start test
        test.startTest();
        //billEmailer.emailLog = new List<String>();
        //call the batch class
        BillBatch bb = new BillBatch();

        Database.executeBatch(bb, 200);
        test.stopTest();

        List<Account> retAccount = [Select Id, Email__c From Account where Name IN ('Test')];
        system.assertEquals(4, retAccount.size(), 'Expected 4 Account');

        //System.assertEquals(expectedEmailCount, MockEmailer.sentEmailCount, 'Expected 2 emails to be sent');
    }
}