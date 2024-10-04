@isTest
public with sharing class BillScheduleTest {
    @isTest
    static void  billSchedule() {
        string cronExp =  '0 0 0 15 * ? 2025';
        Test.setMock(HttpCalloutMock.class, new BillAPITestMock());
        Test.startTest();

        String jobId = System.schedule('BillApiTest', cronExp, new BillScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, State FROM CronTrigger WHERE id = :jobId];

        Test.stopTest();
        List<Bill__c> testbill = [SELECT Id FROM Bill__c];
        System.assertEquals(0, testbill.size(), 'Test Bill didn\'t insert');
    }
}