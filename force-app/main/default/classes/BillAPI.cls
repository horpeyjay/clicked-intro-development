public with sharing class BillAPI {
    public static HttpResponse getBills() {  //changed this from VOID to HttpResponse
        /* 
        Start by creating an HttpRequest object and set the endpoint and method.
        Endpoint: https://my-json-server.typicode.com/walters954/clicked-intro-development-server/bills
        Method: GET
        Learn more about HTTPRequest: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm
        */

        // Create an HttpRequest object
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://my-json-server.typicode.com/walters954/clicked-intro-development-server/bills');
        request.setMethod('GET');

        // Set up an Http object and an HTTPResponse object, then use the .getBody() method to get the response body.
        Http http = new Http();
        HttpResponse response = http.send(request);

        //create the response body
        String responseBody = response.getBody();

        //System.debug('Response Body: ' + responseBody);

        // Deserialize the JSON response into a list of BillWrapper objects.
        // Learn more about JSON.deserialize: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Json.htm#apex_System_Json_deserialize


            List<Object> bwListRaw = (List<Object>)JSON.deserializeUntyped(responseBody);
            
            //deserialize the json string into a primitive data type like a map
            //Map<String, Object> jsonbody = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

            //extract list of json body from a map
            //List<Object> bwListRaw = (List<Object>)jsonbody.get('bills');
            
            //cast the value in the jsonbody to the BillWrapper objects
            List<BillWrapper> bwList = new List<BillWrapper>();

            //iterate over the list object over
            for(Object o: bwListRaw){
                Map<String, Object> billMap = (Map<String, Object>)o;
                BillWrapper bw = new BillWrapper();
                bw.billId = (String)billMap.get('billId');
                bw.accountName = (String)billMap.get('accountName');
                bw.balance = (String)billMap.get('balance');
                bwList.add(bw);
            }

        // Create a list to hold the bills we will insert into Salesforce.
        List<Bill__c> newBills = new List<Bill__c>();

        // Query for active accounts (Active__c = 'Yes').
        // Learn more about SOQL: https://trailhead.salesforce.com/en/content/learn/modules/apex_database/apex_database_soql
        List<Account> activeAccounts = [Select Name, Active__c From Account Where Active__c = 'Yes'];

        // Create a map to hold active account names and their IDs.
        // Learn more about Maps: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_map.htm
        Map<String,Id> newAccMaps = new Map<String,Id>();

        // Iterate over the list of active accounts and add their name and ID to the map.
        for(Account a : activeAccounts){
            newAccMaps.put(a.Name, a.Id);
        }

        /*
        Iterate over the list of BillWrapper objects and create a new Bill__c record for each.
        Match the new bill fields with the properties of the BillWrapper class.
        For example, for Bill__c.Balance__c, use Decimal.valueOf(bw.balance.replace('$', '')) to convert the balance to a decimal.
        Remember, DML (Data Manipulation Language) operations should not be inside loops. Learn more about DML: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_section.htm
        */
        for (BillWrapper bw : bwList){
            //get the account ID first
            Id accountId = newAccMaps.get(bw.accountName);
            System.debug('bw.accountName: ' + bw.accountName);
            System.debug('newAccMaps keys: ' + newAccMaps.keySet());
            if (accountId != null){
                Bill__c newBill = new Bill__c();
                newBill.Invoice_Number__c = bw.billId;
                newBill.Account__c = accountId;
                newBill.Balance__c = Decimal.valueOf(bw.balance.replace('$', ''));
                newBills.add(newBill);
            }else{
                system.debug('Account with name ' + bw.accountName + ' not found.');
            }
        }
        

        if(!newBills.isEmpty()){
            //finally, insert the new bills list
            upsert newBills;
        }else{
            system.debug('no valid bills to insert');
        }
        

        return response; //added this return statement
    }

    /*  
    This is a wrapper class. A wrapper class allows us to create an instance of a class with the properties we specify.
    In this case, we are creating a class that will hold the properties for BillId, AccountName, and Balance.
    These properties will be populated from the JSON structure stored in our external data source.
    Once we get the body of our HTTP callout, we will use the following line of code to transform the response body into a list of instances of our wrapper class, BillWrapper:
    List<BillWrapper> bwList = (List<BillWrapper>)JSON.deserialize(responseBody, List<BillWrapper>.class);
    Once we have a list of BillWrapper objects (bwList), we will iterate over the bwList, create a new Bill__c record, and assign the values of the BillWrapper properties to the fields on the Bill__c record.
    */
    public class BillWrapper {
        public String billId{get; set; }
        public String accountName {get; set; }
        public String balance {get; set; }
    }
}
