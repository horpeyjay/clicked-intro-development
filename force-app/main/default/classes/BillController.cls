public with sharing class BillController {
    @AuraEnabled(cacheable = true scope='global')
    public static List<Bill__c> getAllBills () {
        return [SELECT Account__r.Name, Name, Id, Invoice_Number__c, Balance__c FROM Bill__c WHERE Invoice_Number__c != null WITH SECURITY_ENFORCED ];
    }
    @AuraEnabled(cacheable=true scope='global')
    public static List<Bill__c> searchBill(string searchTerm){
        //return all bill if no search terms entered
        searchTerm = searchTerm.trim();
        if(searchTerm == ''){
            return getAllBills();
        }else{
            //prepare search term
            searchTerm = '%'+searchTerm+'%';
            //query the bills
            return [Select Account__r.Name, Name, Id, Invoice_Number__c, Balance__c From Bill__c WHERE Account__r.Name LIKE :searchTerm WITH SECURITY_ENFORCED];
        }
    }
    @AuraEnabled(cacheable =true scope='global')
    public static List<Bill__c> billsToAccount(Id accountId){
        //return all bills related to an account
        return [select Account__r.Name, Account__c, Name, Invoice_Number__c, Balance__c from Bill__c Where Account__c = :accountId WITH SECURITY_ENFORCED];
        
    }
}