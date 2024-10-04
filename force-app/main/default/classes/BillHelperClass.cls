public with sharing class BillHelperClass {
    public static void billAccountFieldValidation(List<Bill__c> allBills) {
        //Bill Account Field Validation
        //Ensure the Account__c field is not empty during the insertion by adding logic to check if the Account__c field is blank and throw an error if it is.
        //Hint: Use the trigger functionality addError to prevent DML operations from occurring.
        for(Bill__c bill : allBills) {
            if(bill.Account__c == null) {
                bill.Account__c.addError('Account Name is required');
            }
        }
    }
     //had to comment the entire method out so I can merge it together
    public static void invoiceAutopopulate(List<Bill__c> allBills){
        //Invoice Number Autopopulation 
        //Ensure the Invoice_Number__c field has a value when it is created. 
        //Hint: Use features like UUID or random number generation to create a unique value for the Invoice Number.

        
    generateInvoiceNumber randString = new generateInvoiceNumber();//instantiate the class for generating random string
        String randomString = randString.generateRanInvoiceNumber(); //return the string value from the class generate invoice number
        //new List to insert
        List<Bill__c> billsToInsert = new List<Bill__c>();

        for (Bill__c b : allBills){
            if(String.isBlank(b.Invoice_Number__c) || b.Invoice_Number__c.length() < 24){
                //set the invoice number to the random string generated from the class above
                b.Invoice_Number__c = randomString;

                //add the bill to the newBill list to insert
                billsToInsert.add(b);
            }
        }
    }

    public static void createOpps4Bill(List<Bill__c> newBills){
        //When a bill is created check the account it is associated with, if there are no open opportunities then create an opportunity with information from the bill.
        //Set the Opportunity amount to the bill balance
        //Set the Opportunity name to follow this pattern ‘{Account Name } - Opportunity {Bill Invoice Number}’
        List<Opportunity> newOppsList = new List<Opportunity>(); //collection of opportunity to create
        Set<Id> accId = new Set<Id> (); //get the list of account Ids
        
        //Loop thorugh the parameter newBills above to add the Id of the account in the set
        for(Bill__c b: newBills){
            accId.add(b.Account__c);
        }
        //query to get all account
        Map<Id, Account> accMap = new Map<Id, Account>([Select Id, Name From Account where Id in :accId]);

        //Query the list of opportunity separately related to an accounts
        List<Opportunity> oppList = new List<Opportunity>([Select Id, Name, AccountId, StageName From Opportunity where (StageName != 'Closed Won' AND StageName != 'Closed Lost') AND AccountId in :accId]);
        
        //build a map for the account and related opportunities
        Map<Id, List<Opportunity>> accToOppMap = new Map<Id, List<Opportunity>>();
        for(Opportunity o : oppList){
            if (!accToOppMap.containsKey(o.AccountId)){
                accToOppMap.put(o.AccountId, new List<Opportunity>());
            }
            accToOppMap.get(o.AccountId).add(o);
        }

        for(Bill__c b: newBills){
            //check all existing account alongside the opportunity records
            if (b.Account__c != null && !accToOppMap.containsKey(b.Account__c)){
                Account relatedAccount = accMap.get(b.Account__c);
                if (relatedAccount != null){
                    Opportunity opp = new Opportunity();
                    opp.Name = relatedAccount.Name + ' - Opportunity -' + b.Invoice_Number__c;
                    opp.AccountId = relatedAccount.Id;
                    opp.Amount = b.Balance__c;
                    opp.StageName = 'Prospecting';
                    opp.CloseDate = Date.today().addDays(30);
                    //Gather the new opps created into a bucket
                    newOppsList.add(opp);
                }             
            }
        }

        if (newOppsList.size() > 0){
            insert newOppsList;
        }
    }

}