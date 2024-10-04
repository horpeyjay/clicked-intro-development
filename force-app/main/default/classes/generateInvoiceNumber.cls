public with sharing class generateInvoiceNumber {
    public string generateRanInvoiceNumber() {
        integer length = 24;
        String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';

        for(integer i = 0; i < length; i++){
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), characters.length());
            randomString += characters.substring(index, index+1);  
        }
        //query the list of Bill records
        List<Bill__c> existingBills = [Select Id, Invoice_Number__c From Bill__c where Invoice_Number__c = :randomString];

        //if string isn't unique, then recursion occur
        while(!existingBills.isEmpty()){
                randomString = generateRanInvoiceNumber();
        }
        return randomString;
    }
}