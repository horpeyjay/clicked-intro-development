@isTest
private class BillAPITest {
    @TestSetup
    static void createTestAccount(){
        //Had to do this because of the error of pending DML operation i got when i test it out.
        //create the two test accounts with expected names from the mock test
        Account account1 = new Account(Name = 'Account Test 0', Active__c = 'true');
        Account account2 = new Account(Name = 'Account Test 1', Active__c = 'true');
        insert new List<Account>{account1, account2};     
    }
    @isTest
    static void testCallout() {
        /*
        //set callout from the static resources created
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('BillTest');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset = UTF-8');*/

        //Call the mock class just so to see the difference
        BillAPITestMock mock = new BillAPITestMock();
        //set the mock callout class
        Test.setMock(HttpCalloutMock.class, mock);

        //enforce the start and stop text to prevent the uncommitted work error
        Test.startTest();
        //callout method to test
        HttpResponse result = BillAPI.getBills();
        Test.stopTest();

        // Log the response for debugging
        System.debug('Response Body: ' + result.getBody());

        //Assert both the status code and the results
        system.assertEquals(200, result.getStatusCode(), 'The response should be 200');
        Assert.areNotEqual(null, result, 'The callout returned a null response');
        //I need to parse the value as I'm getting incorrect conversion from List to Map
        Object parsedBody = JSON.deserializeUntyped(result.getBody());
        if (parsedBody instanceof Map<String, Object>){
            Map<String, Object> results = (Map<String, Object>)parsedBody;
            List<Object> billResults = (List<Object>)results.get('bills');
            assert.areEqual(2, billResults.size() , 'expected 2 billing records');
        }else{
            System.assert(false, 'Expected response to be a JSON object');
        }
    }
    
}