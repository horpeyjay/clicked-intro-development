public with sharing class BillBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public List<Id> receivesBillByEmail = new List<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // This method will query all active accounts that have a value for Bill_By_Email__c.
        // Hint: In your dynamic query, remember to escape the single quotes around 'Yes'.
        // Use the Database.getQueryLocator(String) method to return the result.
        // Query for the following fields: Id, Bill_By_Email__c.
        // Learn more about QueryLocator: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Database_QueryLocator.htm
        return Database.getQueryLocator('Select Id, Email__c, Bill_By_Email__c from Account where Active__c = \'Yes\' AND Bill_By_Email__c != null'); 
        //return null; (I'm guessing this was a placeholder to have the file saved)
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // This method processes the queried records. It prepares a list of account IDs (this.receivesBillByEmail)
        // to carry over to the finish method. We do this by iterating over 'scope' and checking whether
        // Bill_By_Email__c is TRUE. This method will also call our BillAPI.getBills() method.
        List<Id> accIds = new List<Id>();
        for (Account a : scope){
            if (a.Bill_By_Email__c == true && a.Email__c != null){
                accIds.add(a.Id);
            }
        }
        this.receivesBillByEmail.addAll(accIds);
        BillAPI.getBills();
        // Learn more about Batch Apex: https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_batch
    }

    public void finish(Database.BatchableContext bc) {
        // This is the final method of the class, called after all processing in the start and execute methods is complete.
        // We use this method to send an email to each customer in the receivesBillByEmail list.

        // First, query for the recently created bills for each account using a nested query:
        // [SELECT Id, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC) FROM Account WHERE Id IN :this.receivesBillByEmail]

        List<Account> accAndBills = [Select Id, (Select Id From Bills__r Order By CreatedDate DESC) From Account Where Id IN :this.receivesBillByEmail];

        // Next, iterate over the results of this query and associate the ID of the most recent bill with the
        // corresponding account ID in a Map<Id, Id> called billMap, using the .put(Id, Id) method of the Map class.
        // Learn more about Maps: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_map.htm
        
        //create a map for the account Id and bill Id
        Map<Id, Id>billMap = new Map<Id, Id>();
    
        // Create a Map<Id, String> called emailMap, where we'll hold the Account ID and account email.
        Map<Id, String> emailMap = new Map<Id, String>();

        //iterate over the queried list and put both into the map
        for (Account a : accAndBills){
            if (!a.Bills__r.isEmpty() && a.Bills__r != null){
                billMap.put(a.Id, a.Bills__r[0].Id);
                emailMap.put(a.Id, a.Email__c);
            }
        }

        // Prepare to call our BillEmailer.sendEmails(Map<String, Blob> emailsWithBills) method.
        // The String in the map, called sendMap, will be the Account.Email__c field, and the Blob will be the PDF attachment.
        Map<String, Blob> sendMap = new Map<String, Blob>();

        // Iterate over the billMap to generate PDFs and populate sendMap
        for (Id accId : billMap.keySet()){
            String email = emailMap.get(accId);
            // Get the Bill ID from the billMap
            Id billId = billMap.get(accId);

            // Generate a PDF for each bill ID using:
            PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billId);
            Blob pdfBlob;
            try{
                pdfBlob = pageRef.getContentAsPDF();
            }catch (VisualforceException e){
                System.debug('Error generating PDF for bill: ' + billId + ' - ' + e.getMessage());
                continue;
            }
            
            // You'll need to use the .get() method of the Map class to retrieve values.
            sendMap.put(email, pdfBlob);
        }

        // Finally, call our BillEmailer.sendEmails(sendMap) method. This method is VOID, so there will be no return value.
        BillEmailer.sendEmails(sendMap);
        // Learn more about generating PDFs: https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_controller_sosc_output_pdf.htm
    }
}
