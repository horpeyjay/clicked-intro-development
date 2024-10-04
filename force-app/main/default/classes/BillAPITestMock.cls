@isTest
global class BillAPITestMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request){

        //create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"bills": [ {"billId": "64fe8c72be1ae0125246d287","accountName": "Account Test 0","balance": "$376.08"},{ "billId": "64fe8c72704103b206105ebf","accountName": "Account Test 1","balance": "$156.97"} ] }');
        response.setStatusCode(200);
        return response;
    }
}